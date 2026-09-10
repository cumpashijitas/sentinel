// Sentinel back/ — /groups/:groupId/sessions, /sessions
//
// Ver `services/ride.service.ts` para la lógica portada.

import { Router } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../lib/http.js';
import * as rideService from '../services/ride.service.js';
import { broadcastLocation } from '../ws/location-hub.js';

export const rideRoutes = Router();

rideRoutes.get(
  '/groups/:groupId/sessions/active',
  asyncHandler(async (req, res) => {
    const session = await rideService.fetchActiveSession(
      req.userId,
      req.params.groupId,
    );
    res.json(session);
  }),
);

const startSessionSchema = z.object({ name: z.string().nullable().optional() });

rideRoutes.post(
  '/groups/:groupId/sessions/start',
  asyncHandler(async (req, res) => {
    const body = startSessionSchema.parse(req.body);
    const session = await rideService.startSession(
      req.userId,
      req.params.groupId,
      body.name ?? null,
    );
    res.status(201).json(session);
  }),
);

rideRoutes.get(
  '/sessions/:id',
  asyncHandler(async (req, res) => {
    res.json(await rideService.fetchSession(req.userId, req.params.id));
  }),
);

rideRoutes.get(
  '/sessions/:id/participants',
  asyncHandler(async (req, res) => {
    res.json(await rideService.fetchParticipants(req.userId, req.params.id));
  }),
);

rideRoutes.post(
  '/sessions/:id/finish',
  asyncHandler(async (req, res) => {
    res.json(await rideService.finishSession(req.userId, req.params.id));
  }),
);

rideRoutes.get(
  '/rides/history',
  asyncHandler(async (req, res) => {
    res.json(await rideService.fetchHistoryRows(req.userId));
  }),
);

// snake_case, matching `LocationFix.toJson()` on the front (`@JsonSerializable
// (fieldRename: FieldRename.snake)`) — the front forwards that JSON as-is
// as the request body, same "same shape in/out" contract `ApiClient`'s doc
// comment describes.
const locationFixSchema = z.object({
  latitude: z.number(),
  longitude: z.number(),
  accuracy: z.number().nullable().optional(),
  speed: z.number().nullable().optional(),
  heading: z.number().nullable().optional(),
  battery_level: z.number().int().nullable().optional(),
  recorded_at: z.string(),
});

rideRoutes.post(
  '/sessions/:id/location',
  asyncHandler(async (req, res) => {
    const fix = locationFixSchema.parse(req.body);
    const row = await rideService.upsertMyLocation(req.userId, req.params.id, {
      latitude: fix.latitude,
      longitude: fix.longitude,
      accuracy: fix.accuracy,
      speed: fix.speed,
      heading: fix.heading,
      batteryLevel: fix.battery_level,
      recordedAt: fix.recorded_at,
    });
    // Replaces the Realtime `postgres_changes` event Supabase used to push
    // automatically — see ws/location-hub.ts.
    broadcastLocation(req.params.id, row);
    res.status(204).send();
  }),
);

rideRoutes.post(
  '/sessions/:id/location/history',
  asyncHandler(async (req, res) => {
    const fix = locationFixSchema.parse(req.body);
    await rideService.recordLocationHistory(req.userId, req.params.id, {
      latitude: fix.latitude,
      longitude: fix.longitude,
      accuracy: fix.accuracy,
      speed: fix.speed,
      heading: fix.heading,
      recordedAt: fix.recorded_at,
    });
    res.status(204).send();
  }),
);

// Para dibujar el camino recorrido en el mapa (RideMapPage) — ver
// ride.service.ts::fetchLocationHistory.
rideRoutes.get(
  '/sessions/:id/location/history',
  asyncHandler(async (req, res) => {
    res.json(await rideService.fetchLocationHistory(req.userId, req.params.id));
  }),
);
