// Sentinel back/ — reglas de negocio de grupos.
//
// Puerto directo de las 3 funciones SQL SECURITY DEFINER que vivían en
// `supabase/migrations/20260827210009_rpc_functions.sql`
// (create_ride_group / join_group_by_code / leave_group) más los dos
// helpers `is_group_member`/`is_group_admin` de
// `20260827210004_ride_groups.sql`. Los mensajes de error son exactamente
// los mismos strings en inglés que esas funciones usaban en `raise
// exception ...` — `front/`'s `GroupRepositoryImpl._messageFor` ya sabe
// traducir estos mismos textos al español, así que se mantienen intactos.

import type { PoolClient } from 'pg';
import { randomUUID } from 'node:crypto';
import { pool, withTransaction } from '../db/pool.js';
import { HttpError } from '../lib/http.js';

export async function isGroupMember(
  groupId: string,
  userId: string,
): Promise<boolean> {
  const { rows } = await pool.query(
    `select 1 from public.ride_group_members
      where group_id = $1 and user_id = $2 and status = 'active'
      limit 1`,
    [groupId, userId],
  );
  return rows.length > 0;
}

export async function isGroupAdmin(
  groupId: string,
  userId: string,
): Promise<boolean> {
  const { rows } = await pool.query(
    `select 1 from public.ride_group_members
      where group_id = $1 and user_id = $2 and status = 'active'
        and role in ('owner', 'admin')
      limit 1`,
    [groupId, userId],
  );
  return rows.length > 0;
}

function newInviteCode(): string {
  // 8 hex chars, uppercased — same shape as the old
  // `upper(substr(md5(gen_random_uuid()::text), 1, 8))`.
  return randomUUID().replace(/-/g, '').slice(0, 8).toUpperCase();
}

export async function createGroup(
  ownerId: string,
  name: string,
  description: string | null,
) {
  if (name.trim() === '') {
    throw new HttpError(400, 'group name is required');
  }

  return withTransaction(async (client) => {
    // Retry on invite_code collision — astronomically unlikely (8 hex
    // chars) but handled anyway, same as the original PL/pgSQL loop.
    for (let attempt = 0; attempt < 5; attempt++) {
      try {
        const { rows } = await client.query(
          `insert into public.ride_groups (owner_id, name, description, invite_code)
           values ($1, $2, $3, $4)
           returning *`,
          [ownerId, name, description, newInviteCode()],
        );
        const group = rows[0];
        await client.query(
          `insert into public.ride_group_members (group_id, user_id, role, status)
           values ($1, $2, 'owner', 'active')`,
          [group.id, ownerId],
        );
        return group;
      } catch (error) {
        if (isUniqueViolation(error, 'ride_groups_invite_code_key')) continue;
        throw error;
      }
    }
    throw new HttpError(500, 'could not generate a unique invite code');
  });
}

export async function joinGroupByCode(userId: string, inviteCode: string) {
  return withTransaction(async (client) => {
    const { rows: groupRows } = await client.query(
      'select * from public.ride_groups where invite_code = $1',
      [inviteCode.trim().toUpperCase()],
    );
    const group = groupRows[0];
    if (!group) throw new HttpError(404, 'invalid invite code');
    if (group.status !== 'active') {
      throw new HttpError(409, 'this group is not accepting new members');
    }

    // Lock any existing membership row so two concurrent joins can't both
    // decide "not found" and double-insert — same as the SQL RPC's
    // `select ... for update`.
    const { rows: existingRows } = await client.query(
      `select * from public.ride_group_members
        where group_id = $1 and user_id = $2
        for update`,
      [group.id, userId],
    );
    const existing = existingRows[0];

    if (existing) {
      if (existing.status !== 'active') {
        await client.query(
          `update public.ride_group_members
              set status = 'active', left_at = null, joined_at = now()
            where group_id = $1 and user_id = $2`,
          [group.id, userId],
        );
      }
    } else {
      await client.query(
        `insert into public.ride_group_members (group_id, user_id, role, status)
         values ($1, $2, 'member', 'active')`,
        [group.id, userId],
      );
    }

    return group.id as string;
  });
}

export async function updateGroup(
  userId: string,
  groupId: string,
  name: string,
  description: string | null,
) {
  if (name.trim() === '') {
    throw new HttpError(400, 'group name is required');
  }
  if (!(await isGroupAdmin(groupId, userId))) {
    throw new HttpError(403, 'only the owner or an admin can edit this group');
  }

  const { rows } = await pool.query(
    `update public.ride_groups
        set name = $1, description = $2
      where id = $3
      returning *`,
    [name, description, groupId],
  );
  if (rows.length === 0) throw new HttpError(404, 'group not found');
  return rows[0];
}

/** Solo el dueño puede asignar/quitar admin — es una decisión de
 * confianza distinta a "editar el nombre del grupo" (que ya permite
 * admin), así que se valida contra `owner_id` directo, no
 * `isGroupAdmin`. No permite tocar el rol del propio dueño (no tiene
 * sentido: su rol siempre es 'owner', ver `leaveGroup`/transferencia de
 * propiedad, todavía sin implementar). */
export async function setMemberRole(
  actingUserId: string,
  groupId: string,
  targetUserId: string,
  role: 'admin' | 'member',
) {
  const { rows: groupRows } = await pool.query(
    'select owner_id from public.ride_groups where id = $1',
    [groupId],
  );
  const group = groupRows[0];
  if (!group) throw new HttpError(404, 'group not found');
  if (group.owner_id !== actingUserId) {
    throw new HttpError(403, 'only the group owner can assign admins');
  }
  if (targetUserId === group.owner_id) {
    throw new HttpError(400, "the owner's role cannot be changed");
  }

  const { rows } = await pool.query(
    `update public.ride_group_members
        set role = $1
      where group_id = $2 and user_id = $3 and status = 'active'
      returning *`,
    [role, groupId, targetUserId],
  );
  if (rows.length === 0) {
    throw new HttpError(404, 'that user is not an active member of this group');
  }
  return rows[0];
}

/** Expulsar a un miembro — misma mecánica que `leaveGroup` (soft, vía
 * `status`) pero iniciada por un admin contra otro usuario, y con
 * `status = 'removed'` en vez de `'left'` para que quede claro en
 * `ride_group_members` quién se fue por su cuenta y a quién sacaron. El
 * dueño no puede ser expulsado por nadie (ni siquiera por otro admin) —
 * misma regla que ya impide que el dueño se vaya solo. */
export async function removeMember(
  actingUserId: string,
  groupId: string,
  targetUserId: string,
) {
  if (!(await isGroupAdmin(groupId, actingUserId))) {
    throw new HttpError(403, 'only the owner or an admin can remove members');
  }
  if (targetUserId === actingUserId) {
    throw new HttpError(400, 'use leave instead of removing yourself');
  }

  const { rows: groupRows } = await pool.query(
    'select owner_id from public.ride_groups where id = $1',
    [groupId],
  );
  const group = groupRows[0];
  if (!group) throw new HttpError(404, 'group not found');
  if (targetUserId === group.owner_id) {
    throw new HttpError(400, 'the group owner cannot be removed');
  }

  const { rows } = await pool.query(
    `update public.ride_group_members
        set status = 'removed', left_at = now()
      where group_id = $1 and user_id = $2 and status = 'active'
      returning *`,
    [groupId, targetUserId],
  );
  if (rows.length === 0) {
    throw new HttpError(404, 'that user is not an active member of this group');
  }
}

/** Aviso fijado del grupo — un solo texto por grupo (no un feed de
 * múltiples notas: eso es una feature bastante más grande, con su propia
 * tabla/paginación/quién-lo-escribió; esto cubre el caso real pedido
 * ("avisale algo a todo el grupo") con el cambio de esquema más chico
 * posible). Cualquier admin puede editarlo/borrarlo (`note = null`),
 * igual que puede editar nombre/descripción. */
export async function setPinnedNote(
  userId: string,
  groupId: string,
  note: string | null,
) {
  if (!(await isGroupAdmin(groupId, userId))) {
    throw new HttpError(403, 'only the owner or an admin can set the group note');
  }
  const { rows } = await pool.query(
    `update public.ride_groups
        set pinned_note = $1
      where id = $2
      returning *`,
    [note, groupId],
  );
  if (rows.length === 0) throw new HttpError(404, 'group not found');
  return rows[0];
}

export async function leaveGroup(userId: string, groupId: string) {
  const { rows } = await pool.query(
    `select role from public.ride_group_members
      where group_id = $1 and user_id = $2 and status = 'active'`,
    [groupId, userId],
  );
  const membership = rows[0];
  if (!membership) {
    throw new HttpError(403, 'you are not an active member of this group');
  }
  if (membership.role === 'owner') {
    throw new HttpError(
      409,
      'the group owner cannot leave; transfer ownership or archive the group first',
    );
  }

  await pool.query(
    `update public.ride_group_members
        set status = 'left', left_at = now()
      where group_id = $1 and user_id = $2`,
    [groupId, userId],
  );
}

export async function fetchMyGroups(userId: string) {
  const { rows } = await pool.query(
    `select g.* from public.ride_groups g
       join public.ride_group_members m
         on m.group_id = g.id and m.user_id = $1 and m.status = 'active'
      order by g.created_at`,
    [userId],
  );
  return rows;
}

export async function fetchGroup(userId: string, groupId: string) {
  if (!(await isGroupMember(groupId, userId))) {
    throw new HttpError(404, 'group not found');
  }
  const { rows } = await pool.query(
    'select * from public.ride_groups where id = $1',
    [groupId],
  );
  if (rows.length === 0) throw new HttpError(404, 'group not found');
  return rows[0];
}

/** Raw `ride_group_members` rows only — no profile data attached. The
 * front does the same two-query merge it always did (see
 * `GroupRepositoryImpl.fetchMembers`), now against `GET /profiles?ids=...`
 * (`routes/profiles.routes.ts`) instead of a second Supabase table read.
 * Kept as two calls rather than merging server-side so the front's
 * repository/tests didn't need to change shape — only the datasource's
 * transport did. */
export async function fetchMembers(userId: string, groupId: string) {
  if (!(await isGroupMember(groupId, userId))) {
    throw new HttpError(404, 'group not found');
  }
  const { rows } = await pool.query(
    `select * from public.ride_group_members
      where group_id = $1 and status = 'active'
      order by joined_at`,
    [groupId],
  );
  return rows;
}

function isUniqueViolation(error: unknown, constraint: string): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    (error as { code: unknown }).code === '23505' &&
    'constraint' in error &&
    (error as { constraint: unknown }).constraint === constraint
  );
}

export type { PoolClient };
