package com.idleman.app

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Overlay Activity that displays Flutter-based friction tasks
 * Uses SYSTEM_ALERT_WINDOW to show overlays on top of blocked apps
 */
class OverlayActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Configure window to appear as overlay
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        
        // Make it full screen
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
    }

    /**
     * Get the initial route for the Flutter view
     * Randomly choose between bureaucrat and chase overlays
     */
    override fun getInitialRoute(): String {
        return if (Math.random() < 0.5) {
            "/overlay/bureaucrat"
        } else {
            "/overlay/chase"
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Additional configuration if needed
    }

    override fun onDestroy() {
        super.onDestroy()
        // Return to home screen when overlay is closed
        val intent = android.content.Intent(android.content.Intent.ACTION_MAIN)
        intent.addCategory(android.content.Intent.CATEGORY_HOME)
        intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }
}
