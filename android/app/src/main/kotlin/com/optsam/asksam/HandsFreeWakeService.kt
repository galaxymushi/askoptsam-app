package com.optsam.asksam

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import kotlin.math.sqrt

class HandsFreeWakeService : Service(), SensorEventListener {
    companion object {
        const val CHANNEL_ID = "askoptsam_handsfree_wake"
        const val NOTIFICATION_ID = 9042
        const val ACTION_START = "com.optsam.asksam.START_HANDSFREE"
        const val ACTION_STOP = "com.optsam.asksam.STOP_HANDSFREE"
        var isRunning: Boolean = false
    }

    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var cpuWakeLock: PowerManager.WakeLock? = null
    private var lastShakeTimestamp: Long = 0L
    private var shakePeakCount: Int = 0
    private var firstPeakTimestamp: Long = 0L

    override fun onCreate() {
        super.onCreate()
        createChannel()
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }

        val notification = buildNotification()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            isRunning = true
        } catch (_: Throwable) {
            stopSelf()
            return START_NOT_STICKY
        }

        acquireCpuWakeLock()
        accelerometer?.let {
            sensorManager?.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
        return START_STICKY
    }

    private fun acquireCpuWakeLock() {
        try {
            if (cpuWakeLock?.isHeld == true) return
            val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager ?: return
            cpuWakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "askoptsam:handsfree_sensor_lock"
            ).apply {
                setReferenceCounted(false)
                acquire()
            }
        } catch (_: Throwable) {
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                ?: return
            val channel = NotificationChannel(
                CHANNEL_ID,
                "AskOptSam Hands-Free Blind Mode",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Inasikiliza 'Hey AskOptSam' au kutikiswa kwa simu hata kioo kikiwa kimezimwa."
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val wakeIntent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_VOICE_COMMAND
            putExtra("wake_trigger", "notification")
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
            )
        }
        val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getActivity(this, 0, wakeIntent, pendingFlags)

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setContentTitle("AskOptSam · Hali ya Wasioona Imewashwa")
            .setContentText("Tikisa simu au sema 'Hey AskOptSam' kuamsha msaidizi wa sauti")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    @Suppress("DEPRECATION")
    private fun wakeAndLaunchActivity() {
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager
            val screenLock = pm?.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE,
                "askoptsam:screen_wakeup"
            )
            screenLock?.acquire(10_000L)
        } catch (_: Throwable) {
        }

        try {
            val launchIntent = Intent(this, MainActivity::class.java).apply {
                action = Intent.ACTION_VOICE_COMMAND
                putExtra("wake_trigger", "background_shake")
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
                )
            }
            startActivity(launchIntent)
        } catch (_: Throwable) {
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type != Sensor.TYPE_ACCELEROMETER) return
        val x = event.values[0]
        val y = event.values[1]
        val z = event.values[2]
        val gForce = sqrt((x * x + y * y + z * z).toDouble()) / SensorManager.GRAVITY_EARTH
        if (gForce > 2.2) {
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
                wakeAndLaunchActivity()
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onDestroy() {
        isRunning = false
        sensorManager?.unregisterListener(this)
        try {
            if (cpuWakeLock?.isHeld == true) {
                cpuWakeLock?.release()
            }
        } catch (_: Throwable) {
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
