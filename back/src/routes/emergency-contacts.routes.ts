// Sentinel back/ — /emergency-contacts
//
// Mismo patrón que /vehicles — ver ese archivo para el comentario general.
// Tabla: `supabase/migrations/20260827210003_emergency_contacts.sql` +
// `20260829000001_whatsapp_alerts.sql` (columna notify_whatsapp).

import { Router } from 'express';
import { z } from 'zod';
import { pool } from '../db/pool.js';
import { asyncHandler, HttpError } from '../lib/http.js';

export const emergencyContactRoutes = Router();

// snake_case — matches the row Map `EmergencyContactRemoteDataSource`
// already built for the old direct-to-Postgres insert/update.
const contactSchema = z.object({
  name: z.string().min(1),
  phone: z.string().min(1),
  relationship: z.string().nullable().optional(),
  notify_push: z.boolean(),
  notify_sms: z.boolean(),
  notify_whatsapp: z.boolean(),
});

emergencyContactRoutes.get(
  '/emergency-contacts',
  asyncHandler(async (req, res) => {
    const { rows } = await pool.query(
      'select * from public.emergency_contacts where owner_id = $1 order by created_at',
      [req.userId],
    );
    res.json(rows);
  }),
);

emergencyContactRoutes.post(
  '/emergency-contacts',
  asyncHandler(async (req, res) => {
    const body = contactSchema.parse(req.body);
    const { rows } = await pool.query(
      `insert into public.emergency_contacts
         (owner_id, name, phone, relationship, notify_push, notify_sms, notify_whatsapp)
       values ($1, $2, $3, $4, $5, $6, $7)
       returning *`,
      [
        req.userId,
        body.name,
        body.phone,
        body.relationship ?? null,
        body.notify_push,
        body.notify_sms,
        body.notify_whatsapp,
      ],
    );
    res.status(201).json(rows[0]);
  }),
);

emergencyContactRoutes.put(
  '/emergency-contacts/:id',
  asyncHandler(async (req, res) => {
    const body = contactSchema.parse(req.body);
    const { rows } = await pool.query(
      `update public.emergency_contacts
          set name = $1, phone = $2, relationship = $3,
              notify_push = $4, notify_sms = $5, notify_whatsapp = $6
        where id = $7 and owner_id = $8
        returning *`,
      [
        body.name,
        body.phone,
        body.relationship ?? null,
        body.notify_push,
        body.notify_sms,
        body.notify_whatsapp,
        req.params.id,
        req.userId,
      ],
    );
    if (rows.length === 0) throw new HttpError(404, 'emergency contact not found');
    res.json(rows[0]);
  }),
);

emergencyContactRoutes.delete(
  '/emergency-contacts/:id',
  asyncHandler(async (req, res) => {
    await pool.query(
      'delete from public.emergency_contacts where id = $1 and owner_id = $2',
      [req.params.id, req.userId],
    );
    res.status(204).send();
  }),
);
