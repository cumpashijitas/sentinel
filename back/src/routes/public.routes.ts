// Sentinel back/ — rutas públicas, SIN JWT.
//
// El link que un motociclista comparte por WhatsApp/SMS con sus contactos
// de emergencia (`/share/<token>` en el front) llega hasta acá. El único
// control de acceso es conocer el `share_token` — igual de válido que
// cualquier link "quien tiene el link, entra" (Google Docs, Figma, etc.).
// Montada ANTES de `requireAuth` en server.ts, igual que /health y /auth/*.

import { Router } from 'express';
import { asyncHandler } from '../lib/http.js';
import { fetchByToken } from '../services/emergency-share.service.js';

export const publicRoutes = Router();

publicRoutes.get(
  '/public/emergency-shares/:token',
  asyncHandler(async (req, res) => {
    res.json(await fetchByToken(req.params.token));
  }),
);
