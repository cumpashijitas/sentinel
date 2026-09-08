// Sentinel back/ — conexión a Postgres.
//
// Conexión directa al Postgres del proyecto Supabase (connection string de
// Project Settings → Database), no vía PostgREST/service_role HTTP. Esto es
// justamente lo que hace posible sacar la lógica de negocio de Supabase:
// este backend consulta la base como cualquier backend normal, y decide él
// mismo qué puede hacer cada usuario — ya no delega esa decisión en RLS.

import { Pool } from 'pg';

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  throw new Error(
    'DATABASE_URL no está configurada. Copia .env.example a .env y ' +
      'completa la connection string de tu proyecto Supabase (Project ' +
      'Settings → Database).',
  );
}

export const pool = new Pool({ connectionString });

/** Runs `fn` inside a single client/transaction — commits on success, rolls
 * back on any thrown error. Use for anything that makes more than one
 * write that must succeed or fail together (the same atomicity the old SQL
 * RPC functions got for free from being a single PL/pgSQL function). */
export async function withTransaction<T>(
  fn: (client: import('pg').PoolClient) => Promise<T>,
): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}
