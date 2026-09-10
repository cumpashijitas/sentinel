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
                        val trackingId = call.argument<String>("trackingId")
                        val kind = call.argument<String>("kind")
                        if (trackingId.isNullOrEmpty() || kind.isNullOrEmpty()) {
                            result.error(
                                "INVALID_ARGUMENT",
                                "trackingId and kind are required",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        if (!hasForegroundLocationPermission()) {
                            // Defensive: the Dart side
                            // (AndroidBackgroundLocationService.start) already checks
                            // this via geolocator before ever reaching this channel —
                            // this is a second, independent check in case that's ever
                            // bypassed, not the primary permission-request UX.
                            //
                            // Real bug fixed here: this used to require
                            // ACCESS_BACKGROUND_LOCATION, which Android does NOT ask
                            // for a foreground service with a visible notification —
                            // RideBackgroundService calls startForeground() with
                            // FOREGROUND_SERVICE_TYPE_LOCATION immediately, which is
                            // exactly the exemption Android's docs describe. Requiring
                            // the "Allow all the time" grant on top of that meant
                            // start() failed for every real user, since that grant
                            // isn't offered in the standard permission dialog at all.
                            result.error(
                                "PERMISSION_DENIED",
                                "ACCESS_FINE_LOCATION not granted",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, RideBackgroundService::class.java)
                            .putExtra(RideBackgroundService.EXTRA_TRACKING_ID, trackingId)
                            .putExtra(RideBackgroundService.EXTRA_KIND, kind)
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

    private fun hasForegroundLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_COARSE_LOCATION,
            ) == PackageManager.PERMISSION_GRANTED
    }
}
