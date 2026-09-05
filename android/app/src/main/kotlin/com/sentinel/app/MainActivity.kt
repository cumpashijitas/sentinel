package com.sentinel.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Registers the `com.sentinel.app/background_location` channel that
 * [AndroidBackgroundLocationService] (Dart side) uses to start/stop/query
 * `RideBackgroundService`. See docs/background_service.md for the full
 * design; [RideBackgroundService] for what the service itself does.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.sentinel.app/background_location"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val sessionId = call.argument<String>("sessionId")
                        if (sessionId.isNullOrEmpty()) {
                            result.error("INVALID_ARGUMENT", "sessionId is required", null)
                            return@setMethodCallHandler
                        }
                        if (!hasBackgroundLocationPermission()) {
                            // Defensive: the Dart side
                            // (AndroidBackgroundLocationService.start) already checks
                            // this via geolocator before ever reaching this channel —
                            // this is a second, independent check in case that's ever
                            // bypassed, not the primary permission-request UX.
                            result.error(
                                "PERMISSION_DENIED",
                                "ACCESS_BACKGROUND_LOCATION not granted",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, RideBackgroundService::class.java)
                            .putExtra(RideBackgroundService.EXTRA_SESSION_ID, sessionId)
                        ContextCompat.startForegroundService(this, intent)
                        result.success(null)
                    }

                    "stop" -> {
                        stopService(Intent(this, RideBackgroundService::class.java))
                        result.success(null)
                    }

                    "isRunning" -> result.success(RideBackgroundService.isRunning)

                    else -> result.notImplemented()
                }
            }
    }

    private fun hasBackgroundLocationPermission(): Boolean {
        // ACCESS_BACKGROUND_LOCATION only exists as a distinct runtime
        // permission from API 29 onward — on older versions, holding fine
        // location is already enough for background access.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return true
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_BACKGROUND_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
    }
}
