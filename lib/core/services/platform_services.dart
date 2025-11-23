import 'package:flutter/services.dart';

/// Service for communicating with native Android platform
class PlatformServices {
  static const MethodChannel _channel = MethodChannel('com.idleman/native');

  /// Check if accessibility permission is granted
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkAccessibilityPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Request accessibility permission (opens settings)
  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      // Handle error
    }
  }

  /// Check if overlay permission is granted
  static Future<bool> checkOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Request overlay permission (opens settings)
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      // Handle error
    }
  }

  /// Get list of installed apps
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      return result?.map((app) => Map<String, dynamic>.from(app as Map)).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Update the list of blocked apps
  static Future<bool> updateBlockedApps(List<String> packages) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'updateBlockedApps',
        {'packages': packages},
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
