// Sentinel back/ — /push-tokens
//
// Tabla `device_push_tokens` (`supabase/migrations/20260827210008_push_tokens_and_alerts.sql`).
// `dispatch-accident-alerts` (back/src/alerts/) lee esta tabla directo por
// Postgres para saber a qué dispositivos empujar — nunca vía este API.

import { Router } from 'express';
import { z } from 'zod';
import { pool } from '../db/pool.js';
import { asyncHandler } from '../lib/http.js';

export const pushTokenRoutes = Router();

const registerSchema = z.object({
  platform: z.enum(['android', 'web']),
  token: z.string().min(1),
});

pushTokenRoutes.post(
  '/push-tokens',
  asyncHandler(async (req, res) => {
    const body = registerSchema.parse(req.body);
    const { rows } = await pool.query(
      `insert into public.device_push_tokens (user_id, platform, token, last_seen_at)
       values ($1, $2, $3, now())
       on conflict (token) do update
         set user_id = excluded.user_id,
             platform = excluded.platform,
             enabled = true,
             last_seen_at = now()
       returning *`,
      [req.userId, body.platform, body.token],
    );
    res.status(201).json(rows[0]);
  }),
);

pushTokenRoutes.delete(
  '/push-tokens/:token',
  asyncHandler(async (req, res) => {
    // Scoped to the caller's own tokens — a device only ever un-registers
    // itself, matching the old `device_push_tokens_delete_own` RLS policy.
    await pool.query(
      'delete from public.device_push_tokens where token = $1 and user_id = $2',
      [req.params.token, req.userId],
    );
    res.status(204).send();
  }),
);
