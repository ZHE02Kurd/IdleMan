import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'neu_theme.dart';

/// Theme notifier that manages theme state and persistence
class ThemeNotifier extends StateNotifier<NeuTheme> {
  static const String _themeBoxName = 'themeBox';
  static const String _themeModeKey = 'themeMode';

  ThemeNotifier() : super(NeuTheme.day) {
    _loadTheme();
  }

  /// Load saved theme from Hive
  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      final savedMode = box.get(_themeModeKey, defaultValue: 'day') as String;

      state = savedMode == 'night' ? NeuTheme.night : NeuTheme.day;
    } catch (e) {
      // If loading fails, use default day theme
      state = NeuTheme.day;
    }
  }

  /// Toggle between day and night themes
  Future<void> toggleTheme() async {
    state = state.toggle();
    await _saveTheme();
  }

  /// Set specific theme
  Future<void> setTheme(AppThemeMode mode) async {
    state = mode == AppThemeMode.day ? NeuTheme.day : NeuTheme.night;
    await _saveTheme();
  }

  /// Save current theme to Hive
  Future<void> _saveTheme() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      await box.put(
          _themeModeKey, state.mode == AppThemeMode.day ? 'day' : 'night');
    } catch (e) {
      // Silently fail if save doesn't work
    }
  }
}

/// Global theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, NeuTheme>((ref) {
  return ThemeNotifier();
});
