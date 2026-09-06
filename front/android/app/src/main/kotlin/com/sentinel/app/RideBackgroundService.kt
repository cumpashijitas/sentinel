package com.sentinel.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Foreground service that keeps sharing this rider's location for an
 * active ride session while Sentinel is backgrounded (screen off, app not
 * in the foreground, or the user swiped it away from Recents — see the
 * comment on [onTaskRemoved] for why the last one is deliberate). Full
 * design writeup: docs/background_service.md.
 *
 * This class deliberately does **no** location or network work of its
 * own. Its only two jobs are:
 *  1. Call [ServiceCompat.startForeground] with a persistent notification.
 *     That is both what protects this process from being killed under
 *     memory pressure while backgrounded, and — separately — what
 *     Android's location permission system requires for *any* component
 *     to receive updates outside of visible foreground UI (holding
 *     `ACCESS_BACKGROUND_LOCATION` is necessary but not sufficient by
 *     itself; see `AndroidBackgroundLocationService.start` on the Dart
 *     side, which checks that permission before ever starting this
 *     service).
 *  2. Boot a second, headless [FlutterEngine] — entirely separate from the
 *     one `MainActivity` uses for the UI — running `rideBackgroundMain()`
 *     (`lib/background/ride_background_main.dart`), which does the actual
 *     tracking using the exact same `LocationRepositoryImpl` /
 *     `GeolocatorLocationTracker` / `LiveLocationRepositoryImpl` classes
 *     Fase 5 already built and tested for the foreground path. No
 *     tracking/sampling logic is duplicated in Kotlin.
 *
 * Started/stopped exclusively via `MainActivity`'s `MethodChannel` handler
 * (`com.sentinel.app/background_location`), which is itself only reached
 * through `AndroidBackgroundLocationService` on the Dart side — never
 * start this service any other way, or `rideBackgroundMain` never learns
 * which session to share.
 */
class RideBackgroundService : Service() {

    private var engine: FlutterEngine? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val sessionId = intent?.getStringExtra(EXTRA_SESSION_ID)
        if (sessionId.isNullOrEmpty()) {
            // Nothing to share — most likely the OS restarting this
            // service after the process was killed (see the START_STICKY
            // note below): there is no persisted sessionId to resume with
            // yet, so there is nothing useful this restart can do.
            stopSelf()
            return START_NOT_STICKY
        }

        ensureNotificationChannel()
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ServiceCompat.startForeground(
                this,
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION,
            )
        } else {
            @Suppress("DEPRECATION")
            startForeground(NOTIFICATION_ID, notification)
        }

        startBackgroundEngine(sessionId)
        isRunning = true

        // START_STICKY: if the OS kills this process under memory
        // pressure, ask it to recreate the service afterwards. Recreation
        // arrives with a null Intent (see the guard above), so this does
        // NOT resume sharing by itself yet — persisting/restoring the
        // active sessionId across a kill is not implemented in this
        // phase; see docs/background_service.md's known-limitations
        // section. START_STICKY is still the right flag: it's strictly
        // better than START_NOT_STICKY (which wouldn't even try) and
        // costs nothing since the no-sessionId guard above makes a bare
        // restart a safe no-op.
        return START_STICKY
    }

    private fun startBackgroundEngine(sessionId: String) {
        // Replace any previous engine instead of stacking a second one —
        // e.g. the app called start() again for a different session
        // without stopping the first.
        engine?.destroy()

        val flutterLoader = FlutterInjector.instance().flutterLoader()
        if (!flutterLoader.initialized()) {
            flutterLoader.startInitialization(applicationContext)
            flutterLoader.ensureInitializationComplete(applicationContext, null)
        }

        val newEngine = FlutterEngine(applicationContext)
        val entrypoint = DartExecutor.DartEntrypoint(
            flutterLoader.findAppBundlePath(),
            "package:sentinel_v2/background/ride_background_main.dart",
            "rideBackgroundMain",
        )
        // sessionId travels as a Dart entrypoint argument, not a
        // MethodChannel call — rideBackgroundMain reads it straight out of
        // `args`, no round trip needed once the engine is up.
        newEngine.dartExecutor.executeDartEntrypoint(entrypoint, listOf(sessionId))
        engine = newEngine
    }

    override fun onDestroy() {
        engine?.destroy()
        engine = null
        isRunning = false
        super.onDestroy()
    }

    /**
     * Deliberately a no-op. The whole reason this phase built a real
     * Service instead of relying on `geolocator`'s
     * `foregroundNotificationConfig` (see docs/background_service.md for
     * that trade-off) is that swiping Sentinel away from Recents must
     * *not* silently stop sharing location for an active ride — the rider
     * opted in explicitly by tapping "Compartir mi ubicación", and an
     * accidental (or even deliberate) task swipe is not the same action as
     * tapping "Dejar de compartir" in the app. The persistent, ongoing
     * notification is what gives them visibility that it's still active
     * and a way back into the app to stop it properly.
     */
    override fun onTaskRemoved(rootIntent: Intent?) {
        // no-op — see doc comment above.
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Viaje activo",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Se muestra mientras Sentinel comparte tu ubicación en un viaje."
        }
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val openApp = packageManager.getLaunchIntentForPackage(packageName)
        val contentIntent = openApp?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Sentinel está compartiendo tu ubicación")
            .setContentText("Toca para ver el viaje o dejar de compartir.")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(true)
            .setContentIntent(contentIntent)
            .build()
    }

    companion object {
        const val EXTRA_SESSION_ID = "sessionId"
        private const val CHANNEL_ID = "ride_background_service"
        private const val NOTIFICATION_ID = 4001

        /**
         * Queried by `MainActivity`'s `isRunning` MethodChannel handler.
         * Not persisted — plain in-memory state, which is enough: a
         * `Service` and its app's `Activity` share one process by default,
         * so this stays correct even if the UI is closed and reopened
         * while the service keeps running underneath it.
         */
        @Volatile
        var isRunning: Boolean = false
            private set
    }
}
