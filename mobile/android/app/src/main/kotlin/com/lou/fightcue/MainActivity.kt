package com.lou.fightcue

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "fightcue/push_setup"
    private val preferencesName = "fightcue_push_permissions"
    private val askedPermissionKey = "asked_notification_permission"
    private val notificationPermissionRequestCode = 4517
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStatus" -> {
                    result.success(buildPushStatusPayload())
                }

                "requestPermission" -> {
                    requestPushPermission(result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun requestPushPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(buildPushStatusPayload(permissionStatusOverride = "granted"))
            return
        }

        val permission = Manifest.permission.POST_NOTIFICATIONS
        val granted =
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            result.success(buildPushStatusPayload(permissionStatusOverride = "granted"))
            return
        }

        pendingPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(permission),
            notificationPermissionRequestCode,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode != notificationPermissionRequestCode) {
            return
        }

        markNotificationPermissionAsked()
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        val result = mutableMapOf<String, Any?>(
            "permissionStatus" to if (granted) "granted" else "denied",
            "platform" to "android",
            "tokenValue" to null,
        )
        pendingPermissionResult?.success(result)
        pendingPermissionResult = null
    }

    private fun buildPushStatusPayload(permissionStatusOverride: String? = null): Map<String, Any?> {
        val permissionStatus = permissionStatusOverride ?: resolveNotificationPermissionStatus()
        return mapOf(
            "permissionStatus" to permissionStatus,
            "platform" to "android",
            "tokenValue" to null,
        )
    }

    private fun resolveNotificationPermissionStatus(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return "granted"
        }

        val permission = Manifest.permission.POST_NOTIFICATIONS
        val granted =
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            return "granted"
        }

        return if (hasAskedNotificationPermission()) "denied" else "prompt"
    }

    private fun hasAskedNotificationPermission(): Boolean {
        return getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .getBoolean(askedPermissionKey, false)
    }

    private fun markNotificationPermissionAsked() {
        getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(askedPermissionKey, true)
            .apply()
    }
}
