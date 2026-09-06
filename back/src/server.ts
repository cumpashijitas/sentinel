// Sentinel — backend propio. Toda la lógica de negocio y de autorización
// vive en este proceso; Supabase queda reducido a Postgres (almacenamiento,
// vía `db/pool.ts`) y Auth (control de usuarios, verificado en
// `middleware/auth.ts`). Ver docs/architecture.md.

import 'dotenv/config';
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

const app = express();

app.use(
  cors({
    origin: (process.env.CORS_ORIGIN ?? '*').split(',').map((o) => o.trim()),
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

app.use(errorHandler);

const port = Number(process.env.PORT ?? 3000);
app.listen(port, () => {
  console.log(`Sentinel back/ escuchando en http://localhost:${port}`);
});
