// Sentinel back/ — /emergency-shares (autenticado)
//
// Ver services/emergency-share.service.ts. La ruta pública sin auth
// (el link que se comparte) vive aparte, en routes/public.routes.ts.

import { Router } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../lib/http.js';
import * as shareService from '../services/emergency-share.service.js';
import { broadcastShareLocation } from '../ws/emergency-share-hub.js';

export const emergencyShareRoutes = Router();

emergencyShareRoutes.get(
  '/emergency-shares/active',
  asyncHandler(async (req, res) => {
    res.json(await shareService.fetchActiveShare(req.userId));
  }),
);

emergencyShareRoutes.post(
  '/emergency-shares/start',
  asyncHandler(async (req, res) => {
    res.status(201).json(await shareService.startShare(req.userId));
  }),
);

emergencyShareRoutes.post(
  '/emergency-shares/stop',
  asyncHandler(async (req, res) => {
    await shareService.stopShare(req.userId);
    res.status(204).send();
  }),
);

/// Riders que me agregaron como su contacto de emergencia (con cuenta
/// propia vinculada) y tienen un share activo ahora mismo — el camino
/// "adentro de la app" pedido explícitamente, junto con el link público.
emergencyShareRoutes.get(
  '/emergency-shares/shared-with-me',
  asyncHandler(async (req, res) => {
    res.json(await shareService.fetchSharesForContact(req.userId));
  }),
);

const locationFixSchema = z.object({
  latitude: z.number(),
  longitude: z.number(),
  accuracy: z.number().nullable().optional(),
  speed: z.number().nullable().optional(),
  heading: z.number().nullable().optional(),
  battery_level: z.number().int().nullable().optional(),
  recorded_at: z.string(),
});

emergencyShareRoutes.post(
  '/emergency-shares/:id/location',
  asyncHandler(async (req, res) => {
    const fix = locationFixSchema.parse(req.body);
    const { row, shareToken } = await shareService.upsertShareLocation(
      req.userId,
      req.params.id,
      {
        latitude: fix.latitude,
        longitude: fix.longitude,
        accuracy: fix.accuracy,
        speed: fix.speed,
        heading: fix.heading,
        batteryLevel: fix.battery_level,
        recordedAt: fix.recorded_at,
      },
    );
    // Releva a quien esté mirando el link público en vivo — ver
    // ws/emergency-share-hub.ts.
    broadcastShareLocation(shareToken, row);
    res.status(204).send();
  }),
);
