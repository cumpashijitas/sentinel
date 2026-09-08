// Sentinel back/ — /accidents
//
// Ver `services/accident.service.ts` para la lógica portada.

import { Router } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../lib/http.js';
import * as accidentService from '../services/accident.service.js';

export const accidentRoutes = Router();

// snake_case — matches the row Map `AccidentEventRepositoryImpl.
// reportCandidate` already built for the old direct-to-Postgres insert
// (`user_id` excluded on purpose: derived from the JWT, never trusted from
// the body).
const reportSchema = z.object({
  session_id: z.string().nullable().optional(),
  latitude: z.number().nullable().optional(),
  longitude: z.number().nullable().optional(),
  impact_mps2: z.number(),
  gyro_rad_s: z.number().nullable().optional(),
  g_force: z.number().nullable().optional(),
  confidence_score: z.number().nullable().optional(),
  sensor_snapshot: z.unknown().optional(),
});

accidentRoutes.post(
  '/accidents',
  asyncHandler(async (req, res) => {
    const body = reportSchema.parse(req.body);
    const accident = await accidentService.reportCandidate(req.userId, {
      sessionId: body.session_id ?? null,
      latitude: body.latitude ?? null,
      longitude: body.longitude ?? null,
      impactMps2: body.impact_mps2,
      gyroRadS: body.gyro_rad_s ?? null,
      gForce: body.g_force ?? null,
      confidenceScore: body.confidence_score ?? null,
      sensorSnapshot: body.sensor_snapshot ?? {},
    });
    res.status(201).json(accident);
  }),
);

const statusSchema = z.object({ status: z.enum(['cancelled', 'confirmed']) });

accidentRoutes.patch(
  '/accidents/:id',
  asyncHandler(async (req, res) => {
    const { status } = statusSchema.parse(req.body);
    if (status === 'cancelled') {
      await accidentService.cancel(req.userId, req.params.id);
    } else {
      await accidentService.confirm(req.userId, req.params.id);
    }
    res.status(204).send();
  }),
);

accidentRoutes.get(
  '/accidents',
  asyncHandler(async (req, res) => {
    res.json(await accidentService.fetchMine(req.userId));
  }),
);

accidentRoutes.get(
  '/accidents/:id',
  asyncHandler(async (req, res) => {
    res.json(await accidentService.fetchById(req.userId, req.params.id));
  }),
);
