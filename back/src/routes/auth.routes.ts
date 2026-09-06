// Sentinel back/ — /auth
//
// El front no tiene ninguna credencial de Supabase (ni siquiera la
// publishable key) — ver docs/architecture.md. En su lugar, este backend
// es el único que le habla a Supabase Auth (GoTrue, su API REST) y le
// reenvía al front nada más que el resultado: tokens + datos del usuario.
// El front nunca ve `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY`.
//
// Montadas ANTES de `requireAuth` en server.ts — a diferencia de todo lo
// demás, register/login/refresh ocurren precisamente porque el cliente
// todavía no tiene un token.

import { Router } from 'express';
import { z } from 'zod';
import { asyncHandler, HttpError } from '../lib/http.js';

export const authRoutes = Router();

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_PUBLISHABLE_KEY = process.env.SUPABASE_PUBLISHABLE_KEY;
if (!SUPABASE_URL || !SUPABASE_PUBLISHABLE_KEY) {
  throw new Error(
    'SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY no están configuradas en ' +
      'back/.env — necesarias para que el backend hable con Supabase Auth ' +
      'en nombre del front. Ver .env.example.',
  );
}

interface GoTrueSession {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  expires_at: number;
  user: { id: string; email?: string; user_metadata?: Record<string, unknown> };
}

async function goTrue(
  path: string,
  body: Record<string, unknown>,
): Promise<GoTrueSession> {
  const response = await fetch(`${SUPABASE_URL}/auth/v1${path}`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      apikey: SUPABASE_PUBLISHABLE_KEY!,
    },
    body: JSON.stringify(body),
  });
  const json = (await response.json().catch(() => ({}))) as Record<string, unknown>;

  if (!response.ok) {
    const message =
      (json.msg as string | undefined) ??
      (json.error_description as string | undefined) ??
      (json.message as string | undefined) ??
      (json.error as string | undefined) ??
      'authentication failed';
    const code = (json.error_code as string | undefined) ?? (json.code as string | undefined);
    throw new HttpError(response.status, code ? `${code}: ${message}` : message);
  }
  if (!json.access_token) {
    // e.g. signup with email confirmation required — no session yet.
    throw new HttpError(
      202,
      'signup_needs_confirmation: revisa tu correo para confirmar la cuenta antes de iniciar sesión',
    );
  }
  return json as unknown as GoTrueSession;
}

const credentialsSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

authRoutes.post(
  '/auth/register',
  asyncHandler(async (req, res) => {
    const displayNameSchema = credentialsSchema.extend({
      display_name: z.string().nullable().optional(),
    });
    const body = displayNameSchema.parse(req.body);
    const session = await goTrue('/signup', {
      email: body.email,
      password: body.password,
      data: body.display_name ? { display_name: body.display_name } : undefined,
    });
    res.status(201).json(session);
  }),
);

authRoutes.post(
  '/auth/login',
  asyncHandler(async (req, res) => {
    const body = credentialsSchema.parse(req.body);
    const session = await goTrue('/token?grant_type=password', {
      email: body.email,
      password: body.password,
    });
    res.json(session);
  }),
);

const refreshSchema = z.object({ refresh_token: z.string().min(1) });

authRoutes.post(
  '/auth/refresh',
  asyncHandler(async (req, res) => {
    const body = refreshSchema.parse(req.body);
    const session = await goTrue('/token?grant_type=refresh_token', {
      refresh_token: body.refresh_token,
    });
    res.json(session);
  }),
);

authRoutes.post(
  '/auth/logout',
  asyncHandler(async (req, res) => {
    const header = req.headers.authorization;
    const token = header?.startsWith('Bearer ') ? header.slice(7) : null;
    if (token) {
      // Best-effort: an already-expired/invalid token here just means
      // there's nothing server-side left to revoke — never block the
      // client from clearing its own local session over this.
      await fetch(`${SUPABASE_URL}/auth/v1/logout`, {
        method: 'POST',
        headers: {
          apikey: SUPABASE_PUBLISHABLE_KEY!,
          Authorization: `Bearer ${token}`,
        },
      }).catch(() => undefined);
    }
    res.status(204).send();
  }),
);
