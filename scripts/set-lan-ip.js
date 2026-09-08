#!/usr/bin/env node
// Detecta la IPv4 de LAN actual de esta PC y la escribe en front/.env
// (API_BASE_URL / WEB_BASE_URL), conservando el puerto que ya tenía cada
// una. Solo hace falta para probar la app en un celular/APK real, donde el
// teléfono es OTRO dispositivo en la red y sí necesita saber la IP de la
// PC — para `npm run dev` (Chrome en la misma PC) esto no aplica, ahí
// front/.env apunta a localhost y nunca cambia.
//
// Se corre solo, automáticamente, desde `npm run dev:android` y
// `npm run build:apk` — nunca hay que editar front/.env a mano de nuevo.

const fs = require('fs');
const os = require('os');
const path = require('path');

function detectLanIp() {
  const interfaces = os.networkInterfaces();
  const candidates = [];

  for (const [name, addrs] of Object.entries(interfaces)) {
    if (!addrs) continue;
    // Ignora adaptadores virtuales típicos (VPN, WSL, Hyper-V, VirtualBox)
    // que reportan una IPv4 "válida" pero no son la red física real.
    if (/vEthernet|VirtualBox|VMware|WSL|Loopback|Tailscale|ZeroTier|Hyper-V/i.test(name)) {
      continue;
    }
    for (const addr of addrs) {
      if (addr.family === 'IPv4' && !addr.internal) {
        candidates.push(addr.address);
      }
    }
  }

  // Preferir rangos LAN caseros/oficina típicos (192.168.x.x, 10.x.x.x)
  // sobre cualquier otra cosa que haya quedado en la lista.
  const preferred = candidates.find((ip) => ip.startsWith('192.168.'));
  if (preferred) return preferred;
  const alsoOk = candidates.find((ip) => ip.startsWith('10.'));
  if (alsoOk) return alsoOk;
  return candidates[0] ?? null;
}

function main() {
  const ip = detectLanIp();
  if (!ip) {
    console.error(
      '[set-lan-ip] No se encontró ninguna IPv4 de red local activa. ' +
        '¿Estás conectado a Wi-Fi o Ethernet? front/.env no se tocó.',
    );
    process.exit(1);
  }

  const envPath = path.join(__dirname, '..', 'front', '.env');
  let content = fs.readFileSync(envPath, 'utf8');

  const replacePort = (line, fallbackPort) => {
    const portMatch = line.match(/:(\d+)\s*$/);
    return portMatch ? portMatch[1] : fallbackPort;
  };

  content = content.replace(/^API_BASE_URL=.*$/m, (line) => {
    const port = replacePort(line, '3001');
    return `API_BASE_URL=http://${ip}:${port}`;
  });
  content = content.replace(/^WEB_BASE_URL=.*$/m, (line) => {
    const port = replacePort(line, '8080');
    return `WEB_BASE_URL=http://${ip}:${port}`;
  });

  fs.writeFileSync(envPath, content);
  console.log(`[set-lan-ip] front/.env actualizado con la IP actual: ${ip}`);
}

main();
