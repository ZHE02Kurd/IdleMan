package com.idleman.app

import android.accessibilityservice.AccessibilityService
import android.content.Context
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
    private var lastBlockedPackage: String? = null
    private var lastBlockTime: Long = 0
    private val BLOCK_COOLDOWN_MS = 3000 // 3 seconds cooldown
    private val temporaryBypassList = mutableMapOf<String, Long>() // Package to expiry time
    private val BYPASS_DURATION_MS = 30000 // 30 seconds access after completing task

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
            
            // Ignore null, empty, or system UI packages
            if (packageName.isEmpty() || 
                packageName == "android" || 
                packageName == "com.android.systemui") {
                return
            }
            
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
        // Check if app has temporary bypass
        val currentTime = System.currentTimeMillis()
        val bypassExpiry = temporaryBypassList[packageName]
        if (bypassExpiry != null && currentTime < bypassExpiry) {
            Log.d("IdleMan", "BYPASS: $packageName has temporary access (${(bypassExpiry - currentTime) / 1000}s remaining)")
            return false
        } else if (bypassExpiry != null) {
            // Expired, remove from list
            temporaryBypassList.remove(packageName)
            Log.d("IdleMan", "BYPASS EXPIRED: $packageName")
        }
        
        return blockedPackages.contains(packageName)
    }

    /**
     * Handle detection of blocked app
     */
    private fun handleBlockedApp(packageName: String) {
        // 🛡️ CRITICAL SAFETY CHECK: Never block ourselves!
        if (packageName == this.packageName) {
            Log.d("IdleMan", "SAFETY: Prevented blocking ourselves ($packageName)")
            return
        }
        
        // 🛡️ COOLDOWN CHECK: Prevent rapid re-triggering
        val currentTime = System.currentTimeMillis()
        if (packageName == lastBlockedPackage && 
            currentTime - lastBlockTime < BLOCK_COOLDOWN_MS) {
            Log.d("IdleMan", "COOLDOWN: Ignoring rapid re-trigger of $packageName")
            return
        }
        
        // Update cooldown tracking
        lastBlockedPackage = packageName
        lastBlockTime = currentTime
        
        // 🛡️ SAFETY CHECK: Don't block critical system apps
        val criticalApps = setOf(
            "com.android.settings",           // Settings
            "com.android.phone",              // Phone dialer
            "com.android.dialer",             // Alternative dialer
            "com.google.android.dialer",      // Google Phone
            "com.android.messaging",          // Messaging
            "com.google.android.apps.messaging", // Google Messages
            "com.android.mms",                // MMS
            "com.android.contacts",           // Contacts (needed for calls)
            "android",                        // System UI
            "com.android.systemui",           // System UI
            "com.google.android.apps.nexuslauncher", // Launcher
            "com.android.launcher3"           // Default launcher
        )
        
        if (criticalApps.contains(packageName)) {
            Log.d("IdleMan", "SAFETY: Prevented blocking critical system app ($packageName)")
            return
        }

        // Notify Flutter through MethodChannel
        try {
            methodChannel?.invokeMethod("appBlocked", mapOf(
                "packageName" to packageName,
                "timestamp" to System.currentTimeMillis()
            ))
        } catch (e: Exception) {
            Log.e("IdleMan", "Error invoking method channel: ${e.message}")
        }

        // Store blocked package for bypass grant
        val prefs = getSharedPreferences("idleman_prefs", MODE_PRIVATE)
        prefs.edit().putString("last_blocked_package", packageName).apply()
        
        // Launch overlay activity
        launchOverlay()
    }

    /**
     * Launch the overlay activity
     */
    private fun launchOverlay() {
        // Set a flag indicating the overlay is active
        val prefs = getSharedPreferences("idleman_prefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("is_overlay_active", true).apply()
        
        try {
            val intent = Intent(this, OverlayActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("IdleMan", "Error launching overlay: ${e.message}")
        }
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
    
    /**
     * Grant temporary bypass for an app (called after completing overlay task)
     * @param packageName The app package to grant bypass to
     * @param durationMinutes How many minutes of access to grant (default 5)
     */
    fun grantTemporaryBypass(packageName: String, durationMinutes: Int = 5) {
        val durationMs = durationMinutes * 60 * 1000L // Convert minutes to milliseconds
        val expiryTime = System.currentTimeMillis() + durationMs
        temporaryBypassList[packageName] = expiryTime
        Log.d("IdleMan", "BYPASS GRANTED: $packageName for $durationMinutes minutes")
    }
}
