// Sentinel — cliente mínimo de FCM HTTP v1.
//
// Puerto de `supabase/functions/dispatch-accident-alerts/fcm.ts`. Usaba
// `crypto.subtle`/`btoa`/`atob` de Deno — todos disponibles como globals en
// Node 20+ (este proyecto corre en Node 24), así que la única diferencia
// real es el tipo (`crypto.subtle` en Node viene de `node:crypto`'s
// `webcrypto`, pero el global `crypto` ya lo expone igual).

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

function base64UrlEncode(bytes: Uint8Array): string {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function pemToPkcs8(pem: string): ArrayBuffer {
  const base64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

/** Signs a fresh Google OAuth2 JWT-bearer assertion and exchanges it for an
 * access token scoped to Firebase Cloud Messaging. No caching: an accident
 * confirmation is infrequent, so the extra round trip isn't worth the
 * complexity/staleness risk of caching a token across requests. */
async function getAccessToken(account: ServiceAccount): Promise<string> {
  const header = { alg: 'RS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  const claims = {
    iss: account.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };
  const encode = (value: unknown) =>
    base64UrlEncode(new TextEncoder().encode(JSON.stringify(value)));
  const unsigned = `${encode(header)}.${encode(claims)}`;

  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToPkcs8(account.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64UrlEncode(new Uint8Array(signature))}`;

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  if (!response.ok) {
    throw new Error(`oauth2 token exchange failed: HTTP ${response.status}`);
  }
  const json = (await response.json()) as { access_token: string };
  return json.access_token;
}

export interface FcmSendResult {
  ok: boolean;
  providerMessageId?: string;
  error?: string;
}

export async function sendFcmPush(
  account: ServiceAccount,
  deviceToken: string,
  title: string,
  body: string,
): Promise<FcmSendResult> {
  try {
    const accessToken = await getAccessToken(account);
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: deviceToken,
            notification: { title, body },
            android: { priority: 'high' },
          },
        }),
      },
    );
    if (!response.ok) {
      return { ok: false, error: `fcm_http_${response.status}` };
    }
    const json = (await response.json()) as { name?: string };
    return { ok: true, providerMessageId: json.name };
  } catch (error) {
    return { ok: false, error: `fcm_exception: ${String(error)}` };
  }
}

export function parseServiceAccount(raw: string): ServiceAccount | null {
  try {
    const parsed = JSON.parse(raw);
    if (!parsed.project_id || !parsed.client_email || !parsed.private_key) {
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}
