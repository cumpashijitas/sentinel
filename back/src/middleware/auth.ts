// Sentinel back/ — verifica el JWT de Supabase Auth en cada request.
//
// Reemplaza el rol de `auth.uid()` en las antiguas funciones SQL: el
// cliente Flutter sigue autenticándose directo contra Supabase Auth (eso
// es "control de usuarios", el trabajo que Supabase conserva — ver
// docs/architecture.md), y manda ese mismo access token acá como
// `Authorization: Bearer <token>`. Este middleware lo valida y expone
// `req.userId` — ninguna ruta debajo de esto vuelve a tocar Supabase para
// decidir quién es el usuario.

import type { NextFunction, Request, Response } from 'express';
import { jwtVerify } from 'jose';

const secret = process.env.SUPABASE_JWT_SECRET;
if (!secret) {
  throw new Error(
    'SUPABASE_JWT_SECRET no está configurada. Ver .env.example — está en ' +
      'Project Settings → API → JWT Settings → "JWT Secret".',
  );
}
const secretKey = new TextEncoder().encode(secret);

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
  const { payload } = await jwtVerify(token, secretKey);
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
