package com.idleman.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.content.Intent
import android.net.Uri

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.idleman/native"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkAccessibilityPermission" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibilityPermission" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "checkOverlayPermission" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "updateBlockedApps" -> {
                    val packages = call.argument<List<String>>("packages")
                    if (packages != null) {
                        updateBlockedApps(packages.toSet())
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Packages list is null", null)
                    }
                }
                "getInstalledApps" -> {
                    val apps = getInstalledApps()
                    result.success(apps)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Set up method channel for AppMonitorService
        AppMonitorService.methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AppMonitorService.CHANNEL_NAME
        )
    }

    /**
     * Check if accessibility service is enabled
     */
    private fun isAccessibilityServiceEnabled(): Boolean {
        val service = "${packageName}/${AppMonitorService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        return enabledServices?.contains(service) == true
    }

    /**
     * Open accessibility settings
     */
    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    /**
     * Request overlay permission
     */
    private fun requestOverlayPermission() {
        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }

    /**
     * Update blocked apps in the accessibility service
     */
    private fun updateBlockedApps(packages: Set<String>) {
        AppMonitorService.instance?.updateBlockedApps(packages)
    }

    /**
     * Get list of installed apps
     */
    private fun getInstalledApps(): List<Map<String, String>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(0)
        
        return apps.mapNotNull { appInfo ->
            try {
                mapOf(
                    "packageName" to appInfo.packageName,
                    "appName" to pm.getApplicationLabel(appInfo).toString()
                )
            } catch (e: Exception) {
                null
            }
        }.sortedBy { it["appName"] }
    }
}
