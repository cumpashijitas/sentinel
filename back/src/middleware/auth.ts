// Sentinel back/ — verifica el JWT de Supabase Auth en cada request.
//
// Reemplaza el rol de `auth.uid()` en las antiguas funciones SQL: el
// cliente Flutter sigue autenticándose directo contra Supabase Auth (eso
// es "control de usuarios", el trabajo que Supabase conserva — ver
// docs/architecture.md), y manda ese mismo access token acá como
// `Authorization: Bearer <token>`. Este middleware lo valida y expone
// `req.userId` — ninguna ruta debajo de esto vuelve a tocar Supabase para
// decidir quién es el usuario.
//
// Verificación en dos modos, porque Supabase cambió cómo firma estos
// tokens (ver docs/architecture.md):
//   - Proyectos creados desde nov. 2025 (el caso normal hoy): ya NO tienen
//     un "JWT Secret" compartido — firman con un par de llaves asimétrico
//     y publican la pública en un endpoint JWKS. Ese es el camino por
//     defecto de abajo: no requiere ninguna variable de entorno extra más
//     allá de SUPABASE_URL, que ya se necesita para /auth/*.
//   - Proyectos viejos que todavía tienen el JWT Secret clásico (HS256):
//     si SUPABASE_JWT_SECRET está seteada en .env, se usa esa en su lugar.
//     Nunca hace falta configurar ambas.

import type { NextFunction, Request, Response } from 'express';
import { createRemoteJWKSet, jwtVerify } from 'jose';

const legacySecret = process.env.SUPABASE_JWT_SECRET;
const supabaseUrl = process.env.SUPABASE_URL;

if (!legacySecret && !supabaseUrl) {
  throw new Error(
    'Falta SUPABASE_URL (o, en un proyecto viejo, SUPABASE_JWT_SECRET) en ' +
      'back/.env — necesaria para verificar los tokens de Supabase Auth. ' +
      'Ver .env.example.',
  );
}

// Resolved once at module load into one of two verification strategies —
// kept as two branches (rather than one variable typed as the union) since
// `jwtVerify`'s overloads don't collapse cleanly into a single call site
// otherwise.
const legacyKey = legacySecret ? new TextEncoder().encode(legacySecret) : null;
const jwks = legacySecret
  ? null
  : createRemoteJWKSet(new URL(`${supabaseUrl}/auth/v1/.well-known/jwks.json`));

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      userId: string;
    }
  }
}

/** Verifies a Supabase Auth access token and returns the user id (`sub`
 * claim). Shared by [requireAuth] (HTTP) and the WebSocket upgrade handshake
 * (`ws/location-hub.ts`) — a WebSocket has no per-message `Authorization`
 * header, so its handshake carries the same token as a query param instead,
 * but the verification itself is identical either way. Throws on a
 * missing/invalid/expired token; never returns a falsy user id. */
export async function verifyAccessToken(token: string): Promise<string> {
  const { payload } = legacyKey
    ? await jwtVerify(token, legacyKey)
    : await jwtVerify(token, jwks!);
  const userId = payload.sub;
  if (typeof userId !== 'string' || userId.length === 0) {
    throw new Error('invalid token');
  }
  return userId;
}

export async function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  const header = req.headers.authorization;
  const token = header?.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) {
    res.status(401).json({ error: 'authentication required' });
    return;
  }

  try {
    req.userId = await verifyAccessToken(token);
    next();
  } catch {
    res.status(401).json({ error: 'invalid or expired token' });
  }
}
