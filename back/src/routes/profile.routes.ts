// Sentinel back/ — /profile
//
// Reemplaza el acceso directo de Flutter a la tabla `profiles`. Autorización
// que antes vivía en RLS (`profiles_select_own`, `profiles_select_group_members`,
// `profiles_update_own` — `supabase/migrations/20260827210001_profiles.sql` y
// `20260827210004_ride_groups.sql`), ahora explícita aquí.

import { Router } from 'express';
import { z } from 'zod';
import { pool } from '../db/pool.js';
import { asyncHandler, HttpError } from '../lib/http.js';

export const profileRoutes = Router();

// snake_case — matches `Profile`'s own `FieldRename.snake` on the front.
const updateProfileSchema = z.object({
  display_name: z.string().min(1),
  phone: z.string().nullable().optional(),
  whatsapp_alerts_opt_in: z.boolean(),
});

/** True if `viewerId` and `targetId` are both active members of at least
 * one shared group — mirrors the `profiles_select_group_members` RLS
 * policy exactly. */
async function shareAnActiveGroup(
  viewerId: string,
  targetId: string,
): Promise<boolean> {
  const { rows } = await pool.query(
    `select 1
       from public.ride_group_members me
       join public.ride_group_members them on them.group_id = me.group_id
      where me.user_id = $1 and me.status = 'active'
        and them.user_id = $2 and them.status = 'active'
      limit 1`,
    [viewerId, targetId],
  );
  return rows.length > 0;
}

/** Batch profile lookup, used by the groups/rides datasources to resolve
 * `display_name`/`avatar_url` for a roster (mirrors the two-query pattern
 * `GroupRepositoryImpl`/`RideSessionRepositoryImpl` already used against
 * Supabase directly — see their `fetchProfiles`). Same visibility rule as
 * `GET /profile/:userId`, applied per row instead of erroring: an id the
 * caller can't see is silently dropped from the result, exactly like RLS
 * used to just return fewer rows rather than fail the whole query. */
profileRoutes.get(
  '/profiles',
  asyncHandler(async (req, res) => {
    const idsParam = req.query.ids;
    const ids = (typeof idsParam === 'string' ? idsParam.split(',') : [])
      .map((id) => id.trim())
      .filter((id) => id.length > 0);
    if (ids.length === 0) {
      res.json([]);
      return;
    }

    const { rows } = await pool.query(
      `select p.* from public.profiles p
        where p.id = any($1)
          and (
            p.id = $2
            or exists (
              select 1
                from public.ride_group_members me
                join public.ride_group_members them on them.group_id = me.group_id
               where me.user_id = $2 and me.status = 'active'
                 and them.user_id = p.id and them.status = 'active'
            )
          )`,
      [ids, req.userId],
    );
    res.json(rows);
  }),
);

profileRoutes.get(
  '/profile/:userId',
  asyncHandler(async (req, res) => {
    const { userId } = req.params;
    if (userId !== req.userId && !(await shareAnActiveGroup(req.userId, userId))) {
      throw new HttpError(404, 'profile not found');
    }

    const { rows } = await pool.query(
      'select * from public.profiles where id = $1',
      [userId],
    );
    if (rows.length === 0) throw new HttpError(404, 'profile not found');
    res.json(rows[0]);
  }),
);

profileRoutes.put(
  '/profile/:userId',
  asyncHandler(async (req, res) => {
    const { userId } = req.params;
    if (userId !== req.userId) {
      throw new HttpError(403, 'you can only edit your own profile');
    }
    const body = updateProfileSchema.parse(req.body);

    const { rows } = await pool.query(
      `update public.profiles
          set display_name = $1, phone = $2, whatsapp_alerts_opt_in = $3
        where id = $4
        returning *`,
      [body.display_name, body.phone ?? null, body.whatsapp_alerts_opt_in, userId],
    );
    if (rows.length === 0) throw new HttpError(404, 'profile not found');
    res.json(rows[0]);
  }),
);
