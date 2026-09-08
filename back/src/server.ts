// Sentinel — backend propio. Toda la lógica de negocio y de autorización
// vive en este proceso; Supabase queda reducido a Postgres (almacenamiento,
// vía `db/pool.ts`) y Auth (control de usuarios, verificado en
// `middleware/auth.ts`). Ver docs/architecture.md.

import 'dotenv/config';
import { createServer } from 'node:http';
import cors from 'cors';
import express from 'express';
import { requireAuth } from './middleware/auth.js';
import { errorHandler } from './lib/http.js';
import { authRoutes } from './routes/auth.routes.js';
import { profileRoutes } from './routes/profile.routes.js';
import { vehicleRoutes } from './routes/vehicles.routes.js';
import { emergencyContactRoutes } from './routes/emergency-contacts.routes.js';
import { groupRoutes } from './routes/groups.routes.js';
import { rideRoutes } from './routes/rides.routes.js';
import { accidentRoutes } from './routes/accidents.routes.js';
import { pushTokenRoutes } from './routes/push-tokens.routes.js';
import { emergencyShareRoutes } from './routes/emergency-shares.routes.js';
import { publicRoutes } from './routes/public.routes.js';
import { attachLocationHub } from './ws/location-hub.js';
import { attachEmergencyShareHub } from './ws/emergency-share-hub.js';

const app = express();

// Bug real encontrado en vivo (Flutter Web en :8080 contra back/ en :3000):
// `cors_origin.split(',')` con CORS_ORIGIN=* producía el array `['*']`, y el
// paquete `cors` trata un array como lista exacta de orígenes permitidos —
// nunca hace match contra un Origin real de navegador, así que nunca mandaba
// `Access-Control-Allow-Origin` y el navegador bloqueaba todo en preflight.
// El wildcard real solo funciona si se le pasa el string `'*'` tal cual,
// no un array que lo contenga.
const corsOriginEnv = process.env.CORS_ORIGIN ?? '*';
app.use(
  cors({
    origin:
      corsOriginEnv === '*'
        ? '*'
        : corsOriginEnv.split(',').map((o) => o.trim()),
  }),
);
app.use(express.json());

// Sin auth: sirve para que `flutter run`/scripts de arranque confirmen que
// el backend está vivo antes de intentar nada más.
app.get('/health', (_req, res) => res.json({ ok: true }));

// Sin auth (obviamente): registro/login/refresh son precisamente cómo el
// front consigue un token en primer lugar. Es la ÚNICA parte de este
// backend que le habla a Supabase Auth — el front no tiene ninguna
// credencial de Supabase, ver docs/architecture.md.
app.use(authRoutes);

// Sin auth (a propósito): es el link que un rider comparte por WhatsApp/
// SMS — cualquiera con el token entra, sin cuenta. Ver public.routes.ts.
app.use(publicRoutes);

// Todo lo demás requiere un JWT válido de Supabase Auth — ver
// middleware/auth.ts.
app.use(requireAuth);
app.use(profileRoutes);
app.use(vehicleRoutes);
app.use(emergencyContactRoutes);
app.use(groupRoutes);
app.use(rideRoutes);
app.use(accidentRoutes);
app.use(pushTokenRoutes);
app.use(emergencyShareRoutes);

app.use(errorHandler);

// Bug real encontrado en vivo: la app corría con `app.listen(...)` (Express
// crea su propio http.Server internamente, sin exponerlo), así que
// `attachLocationHub` — que necesita el `http.Server` para escuchar el
// evento 'upgrade' de cada conexión WebSocket entrante — nunca se llamaba.
// Sin esto, TODA conexión WebSocket a /ws/sessions/:id/locations fallaba
// (WebSocketException: Failed to connect), sin importar qué tan bien
// funcionara el resto del pipeline de ubicación en vivo. Crear el
// http.Server explícitamente y pasárselo al hub es lo que faltaba.
const server = createServer(app);
attachLocationHub(server);
attachEmergencyShareHub(server);

const port = Number(process.env.PORT ?? 3000);
server.listen(port, () => {
  console.log(`Sentinel back/ escuchando en http://localhost:${port}`);
});
