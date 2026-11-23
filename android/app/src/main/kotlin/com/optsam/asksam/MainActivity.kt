package com.optsam.asksam

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

class MainActivity : FlutterActivity(), SensorEventListener {
    private val channelName = "com.optsam.asksam/accessibility"
    private val permissionReqCode = 4401
    private var methodChannel: MethodChannel? = null
    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var shakeEnabled: Boolean = true
    private var lastShakeTimestamp: Long = 0L
    private var shakePeakCount: Int = 0
    private var firstPeakTimestamp: Long = 0L
    private var launchedViaAssist: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableLockScreenWake()
        checkAssistIntent(intent)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "wakeScreen" -> {
                    wakeDeviceScreen()
                    result.success(true)
                }
                "setShakeEnabled" -> {
                    val enabled = call.arguments as? Boolean ?: true
                    shakeEnabled = enabled
                    syncForegroundService(enabled)
                    result.success(true)
                }
                "consumeAssistLaunch" -> {
                    val wasAssist = launchedViaAssist
                    launchedViaAssist = false
                    result.success(wasAssist)
                }
                "getPermissionsStatus" -> {
                    result.success(getPermissionsStatusMap())
                }
                "requestMicAndNotifications" -> {
                    requestMicAndNotificationPermissions()
                    result.success(true)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    openIgnoreBatteryOptimizations()
                    result.success(true)
                }
                "requestOverlayPermission" -> {
                    openOverlayPermissionSettings()
                    result.success(true)
                }
                "openVoiceAssistantSettings" -> {
                    openAssistantSettings()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasMicPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun hasNotificationPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun hasOverlayPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return Settings.canDrawOverlays(this)
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager ?: return false
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun getPermissionsStatusMap(): Map<String, Boolean> {
        return mapOf(
            "mic" to hasMicPermission(),
            "notifications" to hasNotificationPermission(),
            "overlay" to hasOverlayPermission(),
            "battery" to isIgnoringBatteryOptimizations(),
            "serviceRunning" to HandsFreeWakeService.isRunning
        )
    }

    private fun requestMicAndNotificationPermissions() {
        val needed = mutableListOf<String>()
        if (!hasMicPermission()) {
            needed.add(Manifest.permission.RECORD_AUDIO)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !hasNotificationPermission()) {
            needed.add(Manifest.permission.POST_NOTIFICATIONS)
        }
        if (needed.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, needed.toTypedArray(), permissionReqCode)
        } else {
            syncForegroundService(shakeEnabled)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == permissionReqCode) {
            syncForegroundService(shakeEnabled)
            methodChannel?.invokeMethod("onPermissionsUpdated", getPermissionsStatusMap())
        }
    }

    private fun openIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                if (!isIgnoringBatteryOptimizations()) {
                    val intent = Intent(
                        Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(intent)
                }
            } catch (_: Throwable) {
                try {
                    startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                } catch (_: Throwable) {
                }
            }
        }
    }

    private fun openOverlayPermissionSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                )
                startActivity(intent)
            } catch (_: Throwable) {
            }
        }
    }

    private fun openAssistantSettings() {
        try {
            startActivity(Intent(Settings.ACTION_VOICE_INPUT_SETTINGS))
        } catch (_: Throwable) {
            try {
                startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
            } catch (_: Throwable) {
            }
        }
    }

    private fun syncForegroundService(enabled: Boolean) {
        try {
            val serviceIntent = Intent(this, HandsFreeWakeService::class.java)
            if (enabled) {
                serviceIntent.action = HandsFreeWakeService.ACTION_START
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }
            } else {
                serviceIntent.action = HandsFreeWakeService.ACTION_STOP
                stopService(serviceIntent)
            }
        } catch (_: Throwable) {
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (checkAssistIntent(intent)) {
            wakeDeviceScreen()
            methodChannel?.invokeMethod("onWakeTriggered", "assist")
        }
    }

    private fun checkAssistIntent(intent: Intent?): Boolean {
        if (intent == null) return false
        val action = intent.action
        val extraTrigger = intent.getStringExtra("wake_trigger")
        if (action == Intent.ACTION_ASSIST ||
            action == Intent.ACTION_VOICE_COMMAND ||
            !extraTrigger.isNullOrEmpty()
        ) {
            launchedViaAssist = true
            return true
        }
        return false
    }

    private fun enableLockScreenWake() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
    }

    @Suppress("DEPRECATION")
    private fun wakeDeviceScreen() {
        try {
            enableLockScreenWake()
            val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager ?: return
            val wl = pm.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
                "askoptsam:voice_concierge_wake"
            )
            wl.acquire(10_000L)
        } catch (_: Throwable) {
        }
    }

    override fun onResume() {
        super.onResume()
        accelerometer?.let {
            sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
        }
        if (shakeEnabled && !HandsFreeWakeService.isRunning) {
            syncForegroundService(true)
        }
        methodChannel?.invokeMethod("onPermissionsUpdated", getPermissionsStatusMap())
    }

    override fun onPause() {
        super.onPause()
        sensorManager?.unregisterListener(this)
    }

    override fun onDestroy() {
        sensorManager?.unregisterListener(this)
        super.onDestroy()
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (!shakeEnabled || event?.sensor?.type != Sensor.TYPE_ACCELEROMETER) return
        val x = event.values[0]
        val y = event.values[1]
        val z = event.values[2]
        val gForce = sqrt((x * x + y * y + z * z).toDouble()) / SensorManager.GRAVITY_EARTH
        if (gForce > 2.15) {
            val now = System.currentTimeMillis()
            if (now - lastShakeTimestamp < 2500L) return
            if (now - firstPeakTimestamp > 900L) {
                shakePeakCount = 0
                firstPeakTimestamp = now
            }
            shakePeakCount++
            if (shakePeakCount >= 2) {
                shakePeakCount = 0
                lastShakeTimestamp = now
                wakeDeviceScreen()
                methodChannel?.invokeMethod("onWakeTriggered", "shake")
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
