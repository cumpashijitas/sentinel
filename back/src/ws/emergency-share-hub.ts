// Sentinel back/ — relevo en vivo del link público de "compartir con
// contactos de emergencia", por WebSocket. Mismo patrón que
// ws/location-hub.ts (ver su comentario de cabecera para el porqué de
// este diseño en memoria, sin Docker/pub-sub externo) — la diferencia es
// la clave de las conexiones: acá es el `share_token` público, no un
// `session_id` + JWT. Cualquiera que tenga el token puede conectarse, es
// la misma superficie de acceso que la ruta HTTP pública
// (routes/public.routes.ts).

import type { IncomingMessage, Server } from 'node:http';
import type { Socket } from 'node:net';
import { WebSocketServer, type WebSocket } from 'ws';
import { shareIdForToken } from '../services/emergency-share.service.js';
import { pool } from '../db/pool.js';

const clientsByToken = new Map<string, Set<WebSocket>>();

const SHARE_WS_PATH = /^\/ws\/public\/emergency-shares\/([^/]+)\/locations$/;

export function attachEmergencyShareHub(server: Server) {
  const wss = new WebSocketServer({ noServer: true });

  server.on('upgrade', (req: IncomingMessage, socket: Socket, head: Buffer) => {
    const url = new URL(req.url ?? '', 'http://internal');
    const match = SHARE_WS_PATH.exec(url.pathname);
    if (!match) return; // deja pasar a otros handlers de 'upgrade' (location-hub)
    const token = match[1];

    void shareIdForToken(token).then((shareId) => {
      if (!shareId) {
        socket.write('HTTP/1.1 404 Not Found\r\n\r\n');
        socket.destroy();
        return;
      }
      wss.handleUpgrade(req, socket, head, (ws) => {
        void onConnect(ws, token, shareId);
      });
    });
  });
}

async function onConnect(ws: WebSocket, token: string, shareId: string) {
  let clients = clientsByToken.get(token);
  if (!clients) {
    clients = new Set();
    clientsByToken.set(token, clients);
  }
  clients.add(ws);

  ws.on('close', () => {
    clients?.delete(ws);
    if (clients?.size === 0) clientsByToken.delete(token);
  });

  try {
    const { rows } = await pool.query(
      'select * from public.emergency_share_locations where share_id = $1',
      [shareId],
    );
    if (ws.readyState === ws.OPEN) {
      ws.send(JSON.stringify({ type: 'snapshot', row: rows[0] ?? null }));
    }
  } catch {
    // No fatal — el cliente igual recibe actualizaciones en vivo de acá en más.
  }
}

/** Llamado por emergency-shares.routes.ts justo después de un
 * upsertShareLocation exitoso. */
export function broadcastShareLocation(token: string, row: unknown) {
  const clients = clientsByToken.get(token);
  if (!clients || clients.size === 0) return;
  const payload = JSON.stringify({ type: 'update', row });
  for (const client of clients) {
    if (client.readyState === client.OPEN) client.send(payload);
  }
}
