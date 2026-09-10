// Sentinel back/ — helpers HTTP compartidos por todas las rutas.

import type { NextFunction, Request, RequestHandler, Response } from 'express';

/** Error con código HTTP explícito. `message` es el mismo texto en inglés
 * que las funciones SQL originales usaban en sus `raise exception` —
 * `front/`'s `ApiException` catch por feature ya sabe traducir estos
 * mensajes exactos al español para el usuario (ver
 * `docs/architecture.md`), así que cambiarlos aquí rompería esa traducción
 * sin necesidad. */
export class HttpError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
  }
}

/** Wraps an async Express handler so a rejected promise reaches the error
 * middleware instead of crashing the process (Express 4 doesn't do this
 * for you — Express 5 does, but the ecosystem's still mostly on 4). */
export function asyncHandler(
  fn: (req: Request, res: Response) => Promise<void>,
): RequestHandler {
  return (req, res, next) => {
    fn(req, res).catch(next);
  };
}

/** True if `error` is a Postgres CHECK-constraint violation (`23514`) on
 * the named constraint — used to turn a specific known constraint into a
 * clear 400 instead of letting it fall through to the generic 500 handler
 * (e.g. `vehicles_year_range` in `vehicles.routes.ts`). */
export function isCheckViolation(error: unknown, constraint: string): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    (error as { code: unknown }).code === '23514' &&
    'constraint' in error &&
    (error as { constraint: unknown }).constraint === constraint
  );
}

export function errorHandler(
  error: unknown,
  _req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction,
) {
  if (error instanceof HttpError) {
    res.status(error.status).json({ error: error.message });
    return;
  }

  // Bug real encontrado en vivo: un cuerpo mal formado (p. ej. el front
  // mandando el texto literal "null" en vez de nada — ya corregido en
  // ApiClient, pero esto queda como defensa en profundidad) lo rechaza
  // `body-parser` con un error que ya trae su propio `statusCode`/`status`
  // (400) — antes esta rama lo ignoraba y respondía 500 igual, mostrando
  // "Internal Server Error" en el front por algo que en realidad era un
  // pedido mal formado, no una falla del servidor.
  const statusCode =
    typeof error === 'object' &&
    error !== null &&
    'statusCode' in error &&
    typeof (error as { statusCode: unknown }).statusCode === 'number'
      ? (error as { statusCode: number }).statusCode
      : typeof error === 'object' &&
          error !== null &&
          'status' in error &&
          typeof (error as { status: unknown }).status === 'number'
        ? (error as { status: number }).status
        : null;

  if (statusCode !== null && statusCode >= 400 && statusCode < 500) {
    res.status(statusCode).json({ error: 'malformed request' });
    return;
  }

  console.error('Unhandled error:', error);
  res.status(500).json({ error: 'internal server error' });
}
