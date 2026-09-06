// Sentinel back/ — relevo en vivo de ubicación por WebSocket.
//
// Reemplaza la suscripción de Realtime de Supabase
// (`live_locations`/`postgres_changes`) que el front usaba antes: el front
// ya no tiene ninguna credencial de Supabase (ver docs/architecture.md),
// así que ya no puede abrir esa suscripción él mismo. Este hub hace el
// mismo trabajo — reenviar en vivo cada fila que cambia — pero como parte
// de este backend: `rides.routes.ts` llama a [broadcastLocation] justo
// después de escribir en `live_locations`.
//
// Deliberadamente en memoria, sin cola/pub-sub externo: un solo proceso
// Node basta para la carga de un grupo de motociclistas, y mantiene el
// backend "sin Docker, tres comandos" — ver el plan de reestructuración.
// Si algún día el backend corre en más de una instancia, esto necesitaría
// un pub/sub compartido (Postgres LISTEN/NOTIFY es la opción más simple,
// ya que el backend igual está conectado a Postgres).

import type { IncomingMessage, Server } from 'node:http';
import type { Socket } from 'node:net';
import { WebSocketServer, type WebSocket } from 'ws';
import { verifyAccessToken } from '../middleware/auth.js';
import { fetchCurrentLocations, isSessionMember } from '../services/ride.service.js';

const clientsBySession = new Map<string, Set<WebSocket>>();

const SESSION_WS_PATH = /^\/ws\/sessions\/([^/]+)\/locations$/;

export function attachLocationHub(server: Server) {
  const wss = new WebSocketServer({ noServer: true });

  server.on('upgrade', (req: IncomingMessage, socket: Socket, head: Buffer) => {
    const url = new URL(req.url ?? '', 'http://internal');
    const match = SESSION_WS_PATH.exec(url.pathname);
    if (!match) {
      socket.destroy();
      return;
    }
    const sessionId = match[1];
    const token = url.searchParams.get('token');

    void authorize(token, sessionId).then((userId) => {
      if (!userId) {
        socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
        socket.destroy();
        return;
      }
      wss.handleUpgrade(req, socket, head, (ws) => {
        void onConnect(ws, sessionId, userId);
      });
    });
  });
}

async function authorize(
  token: string | null,
  sessionId: string,
): Promise<string | null> {
  if (!token) return null;
  try {
    const userId = await verifyAccessToken(token);
    return (await isSessionMember(sessionId, userId)) ? userId : null;
  } catch {
    return null;
  }
}

async function onConnect(ws: WebSocket, sessionId: string, userId: string) {
  let clients = clientsBySession.get(sessionId);
  if (!clients) {
    clients = new Set();
    clientsBySession.set(sessionId, clients);
  }
  clients.add(ws);

  ws.on('close', () => {
    clients?.delete(ws);
    if (clients?.size === 0) clientsBySession.delete(sessionId);
  });

  // Seed the client with the current snapshot the moment it connects — the
  // front used to get this from a plain `SELECT` before subscribing;
  // sending it as the first WS message keeps that one-round-trip feel
  // without needing a separate REST call first.
  try {
    const rows = await fetchCurrentLocations(userId, sessionId);
    if (ws.readyState === ws.OPEN) {
      ws.send(JSON.stringify({ type: 'snapshot', rows }));
    }
  } catch {
    // Non-fatal — the client still gets live updates from here on.
  }
}

/** Called by `rides.routes.ts` right after a successful
 * `upsertMyLocation` — pushes the new row to every other client currently
 * watching this session. */
export function broadcastLocation(sessionId: string, row: unknown) {
  const clients = clientsBySession.get(sessionId);
  if (!clients || clients.size === 0) return;
  const payload = JSON.stringify({ type: 'update', row });
  for (const client of clients) {
    if (client.readyState === client.OPEN) client.send(payload);
  }
}
