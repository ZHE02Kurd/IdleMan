import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Model for daily stats
class DailyStats {
  final int interruptionsToday;
  final int appsBlocked;
  final int minutesSaved;
  final double improvementPercent;

  DailyStats({
    required this.interruptionsToday,
    required this.appsBlocked,
    required this.minutesSaved,
    required this.improvementPercent,
  });

  DailyStats copyWith({
    int? interruptionsToday,
    int? appsBlocked,
    int? minutesSaved,
    double? improvementPercent,
  }) {
    return DailyStats(
      interruptionsToday: interruptionsToday ?? this.interruptionsToday,
      appsBlocked: appsBlocked ?? this.appsBlocked,
      minutesSaved: minutesSaved ?? this.minutesSaved,
      improvementPercent: improvementPercent ?? this.improvementPercent,
    );
  }
}

/// Notifier for managing stats
class StatsNotifier extends StateNotifier<DailyStats> {
  static const String _boxName = 'statsBox';
  static const String _interruptionsKey = 'interruptions';
  static const String _lastResetKey = 'lastReset';

  StatsNotifier()
      : super(DailyStats(
          interruptionsToday: 0,
          appsBlocked: 0,
          minutesSaved: 0,
          improvementPercent: 0.0,
        )) {
    _loadStats();
  }

  /// Load stats from Hive
  Future<void> _loadStats() async {
    try {
      final box = await Hive.openBox(_boxName);
      
      // Check if we need to reset (new day)
      final lastReset = box.get(_lastResetKey, defaultValue: 0) as int;
      final now = DateTime.now();
      final lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastReset);
      
      if (!_isSameDay(now, lastResetDate)) {
        await _resetDailyStats();
        return;
      }

      final interruptions = box.get(_interruptionsKey, defaultValue: 0) as int;
      
      state = state.copyWith(
        interruptionsToday: interruptions,
        minutesSaved: interruptions * 3, // Estimate 3 min per interruption
        improvementPercent: _calculateImprovement(interruptions),
      );
    } catch (e) {
      // Keep default state
    }
  }

  /// Record an interruption
  Future<void> recordInterruption() async {
    state = state.copyWith(
      interruptionsToday: state.interruptionsToday + 1,
      minutesSaved: (state.interruptionsToday + 1) * 3,
      improvementPercent: _calculateImprovement(state.interruptionsToday + 1),
    );

    await _saveStats();
  }

  /// Update apps blocked count
  Future<void> updateAppsBlocked(int count) async {
    state = state.copyWith(appsBlocked: count);
    await _saveStats();
  }

  /// Save stats to Hive
  Future<void> _saveStats() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_interruptionsKey, state.interruptionsToday);
      await box.put(_lastResetKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Handle error
    }
  }

  /// Reset daily stats
  Future<void> _resetDailyStats() async {
    state = DailyStats(
      interruptionsToday: 0,
      appsBlocked: state.appsBlocked,
      minutesSaved: 0,
      improvementPercent: 0.0,
    );
    await _saveStats();
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Calculate improvement percentage (simple heuristic)
  double _calculateImprovement(int interruptions) {
    // Simple calculation: more interruptions = higher improvement
    // In real app, compare with historical data
    return (interruptions * 2.5).clamp(0.0, 100.0);
  }
}

/// Provider for stats
final statsProvider = StateNotifierProvider<StatsNotifier, DailyStats>((ref) {
  return StatsNotifier();
});
