# Credenciales de `back/.env` — de dónde sale cada una

9 variables en total. Las primeras 3 son **obligatorias** (sin ellas `back/`
ni arranca). Las otras 6 son de despacho de alertas — la app entera
funciona sin ellas, solo que no se manda push/SMS/WhatsApp de verdad (se
registra como `failed` en la tabla `alerts` y ahí queda). Ninguna de las 9
me la puedes pedir que la genere yo: todas exigen tu email/teléfono para
verificar una cuenta, eso no lo puede hacer una IA por ti.

---

## 1. `DATABASE_URL` (obligatoria)

1. [supabase.com/dashboard](https://supabase.com/dashboard) → si no tienes
   cuenta, **Sign up** (GitHub es lo más rápido, 1 click).
2. **New project** → nombre (`sentinel`) → **contraseña de base de datos**
   (invéntala y **guárdala en un bloc de notas**, la necesitas ahora mismo)
   → región → **Create new project**. Tarda ~2 min en aprovisionar.
3. Ya adentro del proyecto: botón **Connect** (arriba de la página) →
   pestaña **URI** → copia esa línea completa.
4. Reemplaza `[YOUR-PASSWORD]` (o similar) en esa línea por la contraseña
   del paso 2.

## 2. `SUPABASE_URL` (obligatoria)

Mismo botón **Connect** del paso 3 de arriba — la URL del proyecto está en
la misma pantalla, arriba del connection string. También en
**Project Settings (⚙️) → API Keys**, primer campo.

## 3. `SUPABASE_PUBLISHABLE_KEY` (obligatoria)

Mismo botón **Connect**, o **Project Settings (⚙️) → API Keys** → la key
marcada `anon` `public` (en proyectos nuevos puede aparecer como
`sb_publishable_...`).

*(No hay una 4ta obligatoria: este backend verifica tokens con las llaves
públicas de Supabase, no necesita el "JWT Secret" clásico — ver el
comentario en `back/.env.example`.)*

---

## 4-6. Firebase Cloud Messaging (push a Android) — opcional

Sin esto: nadie recibe notificación push de accidente; si el afectado
tiene teléfono registrado, cae a SMS (si configuraste Twilio) o WhatsApp
(si configuraste Meta).

1. [console.firebase.google.com](https://console.firebase.google.com) →
   inicia sesión con una cuenta Google.
2. **Add project** (o "Crear un proyecto") → nómbralo → puedes desactivar
   Google Analytics si no lo quieres → **Create project**.
3. Ya adentro: ícono de engranaje (⚙️) junto a "Project Overview" (arriba
   a la izquierda) → **Project settings**.
4. Pestaña **Service accounts** (arriba de la página).
5. Botón **Generate new private key** → confirma → se descarga un archivo
   `.json` a tu carpeta de Descargas.
6. Abre ese archivo con un editor de texto, copia **todo su contenido**
   como una sola línea (sin saltos de línea) y pégalo en:
   ```
   FCM_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"...",...}
   ```

No hay variables separadas para esto — es un solo JSON completo en una
variable.

## 7-9. Twilio (SMS) — opcional

Sin esto: nadie recibe SMS de respaldo cuando no tiene push configurado.

1. [console.twilio.com](https://console.twilio.com) → **Sign up**. Pide
   verificar tu número de teléfono por SMS/llamada (es obligatorio, no hay
   forma de saltarlo). La cuenta trial viene con crédito gratis, sin pedir
   tarjeta para el registro inicial.
2. Ya en el **Dashboard** principal (primera pantalla al entrar), ahí
   mismo, sin más clics, ves:
   - **Account SID** → eso es `TWILIO_ACCOUNT_SID`
   - **Auth Token** → tiene un botón/ícono de ojo para revelarlo → eso es
     `TWILIO_AUTH_TOKEN`
3. Para el número remitente: menú lateral izquierdo → **Phone Numbers** →
   **Manage** → **Active numbers**. Una cuenta trial nueva normalmente ya
   trae uno asignado; si no, **Buy a number** (gratis dentro del crédito
   trial). Cópialo en formato internacional: `TWILIO_FROM_NUMBER=+15017122661`.

**Límite del modo trial**: Twilio solo deja mandar SMS a números que hayas
verificado manualmente en **Phone Numbers → Manage → Verified Caller IDs**
mientras no pases a cuenta paga. Para producción real hace falta cargar
saldo/activar la cuenta — no bloquea probar el flujo contigo mismo como
destinatario.

## 10-13. Meta WhatsApp Cloud API — opcional, la más larga

Sin esto: nadie recibe WhatsApp. Es la única de las 4 que tiene un paso
adicional ineludible: **una plantilla de mensaje aprobada por Meta** — WhatsApp
no deja mandar texto libre a alguien que no te escribió primero.

1. [developers.facebook.com](https://developers.facebook.com) → inicia
   sesión con una cuenta de Facebook (si no tienes, tienes que crear una).
2. **My Apps** (arriba a la derecha) → **Create App** → tipo de app:
   **"Business"** → completa nombre/email → **Create app**.
3. Dentro del app, en el panel de productos: busca **WhatsApp** → **Set up**
   (te agrega el producto al app).
4. Te lleva a **WhatsApp → API Setup**. Ahí mismo, sin más clics, están:
   - **Temporary access token** → eso es `META_WHATSAPP_ACCESS_TOKEN`
     (⚠️ dura 24 horas — para uno que no expire hay que crear un "System
     User" con un token permanente en Meta Business Suite, varios pasos
     más; para probar, el temporal alcanza).
   - **Phone number ID** (Meta te da un número de prueba gratis, ya
     activado) → eso es `META_WHATSAPP_PHONE_NUMBER_ID`.
5. La plantilla: **WhatsApp → Message Templates → Create Template**. Tiene
   que decir exactamente (nombre `accident_alert`, categoría "Alert
   Update", cuerpo con 3 variables `{{1}} {{2}} {{3}}`):
   ```
   Posible accidente: {{1}} pudo haber tenido un accidente a las {{2}}
   y no respondió a tiempo. Ubicación: {{3}}
   ```
   Meta la revisa (puede tardar minutos u horas) antes de dejarte usarla.
6. `META_WHATSAPP_TEMPLATE_NAME=accident_alert` y
   `META_WHATSAPP_TEMPLATE_LANG=es` ya vienen puestos por defecto — solo
   los cambias si le pusiste otro nombre/idioma a la plantilla.

---

## Orden recomendado

Para tener la app **funcionando de punta a punta** (grupos, viajes,
ubicación en vivo, login): solo las 3 obligatorias. Para que las alertas
de accidente **realmente lleguen** a alguien: agrega Firebase (la más
simple de las 3 opcionales) — Twilio y WhatsApp son mejoras encima de eso,
no bloquean nada más.
