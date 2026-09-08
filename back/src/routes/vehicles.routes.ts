// Sentinel back/ — /vehicles
//
// Reemplaza el acceso directo a la tabla `vehicles`. Estrictamente privado
// — antes RLS (`vehicles_select_own` et al.,
// `supabase/migrations/20260827210002_vehicles.sql`), ahora un `where
// owner_id = $1` explícito en cada query, siempre con el id derivado del
// JWT (`req.userId`), nunca de un parámetro del cliente.

import { Router } from 'express';
import { z } from 'zod';
import { pool } from '../db/pool.js';
import { asyncHandler, HttpError, isCheckViolation } from '../lib/http.js';

export const vehicleRoutes = Router();

const vehicleSchema = z.object({
  brand: z.string().min(1),
  model: z.string().min(1),
  year: z.number().int().nullable().optional(),
  plate: z.string().nullable().optional(),
  color: z.string().nullable().optional(),
});

vehicleRoutes.get(
  '/vehicles',
  asyncHandler(async (req, res) => {
    const { rows } = await pool.query(
      'select * from public.vehicles where owner_id = $1 order by created_at',
      [req.userId],
    );
    res.json(rows);
  }),
);

vehicleRoutes.post(
  '/vehicles',
  asyncHandler(async (req, res) => {
    const body = vehicleSchema.parse(req.body);
    try {
      const { rows } = await pool.query(
        `insert into public.vehicles (owner_id, brand, model, year, plate, color)
         values ($1, $2, $3, $4, $5, $6)
         returning *`,
        [
          req.userId,
          body.brand,
          body.model,
          body.year ?? null,
          body.plate ?? null,
          body.color ?? null,
        ],
      );
      res.status(201).json(rows[0]);
    } catch (error) {
      if (isCheckViolation(error, 'vehicles_year_range')) {
        throw new HttpError(400, 'invalid year');
      }
      throw error;
    }
  }),
);

vehicleRoutes.put(
  '/vehicles/:id',
  asyncHandler(async (req, res) => {
    const body = vehicleSchema.parse(req.body);
    try {
      const { rows } = await pool.query(
        `update public.vehicles
            set brand = $1, model = $2, year = $3, plate = $4, color = $5
          where id = $6 and owner_id = $7
          returning *`,
        [
          body.brand,
          body.model,
          body.year ?? null,
          body.plate ?? null,
          body.color ?? null,
          req.params.id,
          req.userId,
        ],
      );
      if (rows.length === 0) throw new HttpError(404, 'vehicle not found');
      res.json(rows[0]);
    } catch (error) {
      if (isCheckViolation(error, 'vehicles_year_range')) {
        throw new HttpError(400, 'invalid year');
      }
      throw error;
    }
  }),
);

vehicleRoutes.delete(
  '/vehicles/:id',
  asyncHandler(async (req, res) => {
    await pool.query('delete from public.vehicles where id = $1 and owner_id = $2', [
      req.params.id,
      req.userId,
    ]);
    res.status(204).send();
  }),
);
