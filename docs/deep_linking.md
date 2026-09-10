# Sentinel V2 — Android App Links para el link público de ubicación

Cómo hacer que el link que un rider comparte por WhatsApp/SMS
(`_ShareLink` en
[emergency_share_page.dart](../front/lib/features/emergency_shares/presentation/pages/emergency_share_page.dart))
abra la app Sentinel instalada en vez de un navegador, cuando quien lo
recibe sí la tiene. Ver [docs/architecture.md](architecture.md) para el
resto de la feature; este documento cubre solo la parte de deep-linking.

Sin nada de esto, el link sigue funcionando exactamente igual que hoy
(abre `PublicSharePage` en el navegador) — no hay downside a hacerlo
gradualmente ni a dejarlo a medias un tiempo.

## Por qué hacía falta cambiar el formato del link primero

El link público era `https://<dominio>/#/share/<token>` — Flutter Web
usa por defecto `HashUrlStrategy`, así que todo lo que importa para el
routing vive después del `#`. Eso es invisible para un navegador, pero
**un intent-filter de Android nunca ve la parte después del `#`** — el
sistema de matching de `<data android:path.../>` opera sobre
esquema+host+path, no sobre el fragmento. Con ese formato, ningún
intent-filter podía distinguir `/share/tok1` de `/share/tok2`, ni
siquiera de la home.

La solución (ya aplicada) fue cambiar a rutas "de verdad" en Flutter Web:

- `bootstrap.dart` llama `usePathUrlStrategy()` (paquete
  `flutter_web_plugins`, agregado a `pubspec.yaml`) — no-op fuera de Web.
- El link ahora se arma sin `#`: `$webBaseUrl/share/$shareToken`.
- `front/vercel.json` agrega el rewrite de SPA estándar (`/(.*)` →
  `/index.html`) — sin esto, una visita directa a `/share/<token>` (en
  vez de navegar ahí desde dentro de la app) devolvía 404, porque el
  servidor no tiene ningún archivo real en esa ruta. Vercel sirve
  cualquier archivo estático real (como `/.well-known/assetlinks.json`,
  ver abajo) *antes* de aplicar este rewrite, así que no lo pisa.

## Lo que falta para que el link abra la app (pendiente de tu parte)

Android solo confía en un intent-filter con `autoVerify="true"` si el
dominio publica, en `https://<dominio>/.well-known/assetlinks.json`, el
SHA-256 de la clave con la que está firmado el APK instalado — cualquiera
puede declarar un intent-filter para cualquier dominio, así que este
archivo es lo que prueba que el dueño del dominio y el dueño de la app
son la misma persona.

Hoy el build release firma con el **debug keystore** (autogenerado por
el SDK de Android, distinto en cada máquina) — necesitás un keystore de
release propio, estable, para que esto no se rompa la próxima vez que
compiles desde otra máquina.

### 1. Generar el keystore de release (una sola vez)

En tu PowerShell, dentro de `front/android/`:

```powershell
& "$env:JAVA_HOME\bin\keytool.exe" -genkeypair -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Si `$env:JAVA_HOME` no está seteado, `keytool.exe` normalmente vive en el
JBR que trae Android Studio, por ejemplo:

```powershell
& "$env:LOCALAPPDATA\Programs\Android Studio\jbr\bin\keytool.exe" -genkeypair -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

Te va a pedir una contraseña para el keystore y otra para la clave (podés
usar la misma), y unos datos (nombre, organización, etc.) que no importan
funcionalmente — cualquier valor sirve. **Guardá el archivo
`upload-keystore.jks` y las contraseñas en un lugar seguro: si los
perdés, no vas a poder volver a firmar actualizaciones de la app con la
misma identidad.**

### 2. Configurar `android/key.properties`

Copiá `front/android/key.properties.example` a `front/android/key.properties`
(gitignored — nunca se commitea) y completalo con las contraseñas/alias
reales que usaste arriba. `android/app/build.gradle.kts` ya lo lee: si el
archivo existe, el build release firma con esa clave; si no, sigue
cayendo al debug keystore como hasta ahora.

### 3. Extraer el SHA-256 y pasármelo

```powershell
& "$env:JAVA_HOME\bin\keytool.exe" -list -v -keystore front/android/upload-keystore.jks -alias upload
```

Buscá la línea que empieza con `SHA256:` y pasame ese valor completo (es
información pública — es exactamente lo que va a quedar publicado en
`assetlinks.json`, no hay nada sensible en compartirlo). Con eso completo
`front/web/.well-known/assetlinks.json`:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.sentinel.app",
    "sha256_cert_fingerprints": ["<tu SHA-256 acá>"]
  }
}]
```

### 4. Compilar, redesplegar y verificar

1. Redeployá `front/` en Vercel (el rewrite + `assetlinks.json` nuevos
   necesitan estar publicados antes de que Android pueda verificarlos).
2. Compilá el APK release vos mismo — **yo no ejecuto builds**:
   ```powershell
   flutter build apk --release
   ```
   e instalalo (`adb install -r build/app/outputs/flutter-apk/app-release.apk`).
3. La verificación de dominio de Android corre en segundo plano al
   instalar. Para confirmarla sin esperar a probar un link real:
   ```powershell
   & "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" shell pm get-app-links com.sentinel.app
   ```
   Buscá `sentinel-orcin-eight.vercel.app` con estado `verified`.
4. Prueba real: mandate a vos mismo (por WhatsApp, a otro chat) el link
   de "Compartir ubicación" y tocalo desde el teléfono con la app
   instalada — debería abrir Sentinel directo, no Chrome.

## Si alguna vez cambia el dominio

`android/app/src/main/AndroidManifest.xml`'s intent-filter tiene
`sentinel-orcin-eight.vercel.app` hardcodeado (a propósito — un App Link
solo puede apuntar a un dominio exacto que controlás). Si el dominio de
producción cambia (dominio propio, otro proyecto de Vercel, etc.), hay
que actualizar ahí, en `assetlinks.json`, y en la variable de entorno
`WEB_BASE_URL` de Vercel, los tres a la vez.

## Alcance de esta pasada

El intent-filter de App Links solo cubre `pathPrefix="/share/"` — el
único link que hoy se manda fuera de la app a alguien que puede no
tenerla instalada. El resto de rutas de la SPA (`/groups/...`,
`/rides/...`, etc.) no lo necesitan: son navegación interna de alguien ya
logueado dentro de la app, no un link que se comparte por fuera.
