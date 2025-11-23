package com.idleman.app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.MethodChannel

/**
 * Accessibility Service that monitors app usage
 * Detects when blocked apps are launched and triggers overlays
 */
class AppMonitorService : AccessibilityService() {

    companion object {
        const val CHANNEL_NAME = "com.idleman/app_monitor"
        var instance: AppMonitorService? = null
        var methodChannel: MethodChannel? = null
        private var lastCreateTime = 0L
    }

    private val blockedPackages = mutableSetOf<String>()
    private var isInitialized = false

    override fun onCreate() {
        super.onCreate()
        
        // Prevent rapid recreation (service restart loop protection)
        val currentTime = System.currentTimeMillis()
        if (instance != null && currentTime - lastCreateTime < 1000) {
            Log.w("IdleMan", "Service recreation too fast, possible loop detected. Skipping duplicate onCreate.")
            return
        }
        
        lastCreateTime = currentTime
        instance = this
        
        if (!isInitialized) {
            loadBlockedApps()
            isInitialized = true
            Log.d("IdleMan", "AppMonitorService created. Loaded ${blockedPackages.size} blocked apps: $blockedPackages")
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            
            Log.d("IdleMan", "Window state changed: $packageName")
            
            // Check if the app is in the blocked list
            if (isAppBlocked(packageName)) {
                Log.d("IdleMan", "BLOCKED APP DETECTED: $packageName - Launching overlay!")
                handleBlockedApp(packageName)
            }
        }
    }

    override fun onInterrupt() {
        // Handle interruption
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    /**
     * Check if an app package is blocked
     */
    private fun isAppBlocked(packageName: String): Boolean {
        return blockedPackages.contains(packageName)
    }

    /**
     * Handle detection of blocked app
     */
    private fun handleBlockedApp(packageName: String) {
        // Notify Flutter through MethodChannel
        methodChannel?.invokeMethod("appBlocked", mapOf(
            "packageName" to packageName,
            "timestamp" to System.currentTimeMillis()
        ))

        // Launch overlay activity
        launchOverlay()
    }

    /**
     * Launch the overlay activity
     */
    private fun launchOverlay() {
        val intent = Intent(this, OverlayActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(intent)
    }

    /**
     * Load blocked apps from preferences
     */
    private fun loadBlockedApps() {
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        val blockedSet = prefs.getStringSet("blocked_apps", emptySet()) ?: emptySet()
        blockedPackages.clear()
        blockedPackages.addAll(blockedSet)
        Log.d("IdleMan", "Loaded blocked apps from prefs: $blockedPackages")
    }

    /**
     * Update the blocked apps list
     */
    fun updateBlockedApps(packages: Set<String>) {
        blockedPackages.clear()
        blockedPackages.addAll(packages)
        
        Log.d("IdleMan", "Updated blocked apps in service: $blockedPackages")
        
        // Don't save to preferences here - MainActivity already did it
        // Saving again causes unnecessary writes and potential loops
    }
}
