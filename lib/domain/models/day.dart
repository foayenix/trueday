/// Day model representing a single day
library;

import '../../core/extensions.dart';

/// Represents a single day in the user's schedule
class Day {
  final String id; // ISO date string (yyyy-MM-dd)
  final DateTime? wakeAt;
  final DateTime? sleepAt;
  final int screenTimeMinutes;

  const Day({
    required this.id,
    this.wakeAt,
    this.sleepAt,
    this.screenTimeMinutes = 0,
  });

  /// Get the date from the ID
  DateTime get date {
    final parsed = id.tryParseDate;
    if (parsed == null) {
      throw FormatException('Invalid date ID: $id');
    }
    return parsed;
  }

  /// Check if the day has started (wake time is set)
  bool get hasStarted => wakeAt != null;

  /// Check if the day has ended (sleep time is set)
  bool get hasEnded => sleepAt != null;

  /// Get the total awake duration for the day
  Duration? get awakeDuration {
    if (wakeAt == null) return null;
    final end = sleepAt ?? DateTime.now();
    return end.difference(wakeAt!);
  }

  /// Get the total awake time in minutes
  int? get awakeMinutes => awakeDuration?.inMinutes;

  /// Check if this is today
  bool get isToday => date.isToday;

  /// Check if this is yesterday
  bool get isYesterday => date.isYesterday;

  /// Check if this is tomorrow
  bool get isTomorrow => date.isTomorrow;

  /// Copy with new values
  Day copyWith({
    String? id,
    DateTime? wakeAt,
    DateTime? sleepAt,
    int? screenTimeMinutes,
  }) {
    return Day(
      id: id ?? this.id,
      wakeAt: wakeAt ?? this.wakeAt,
      sleepAt: sleepAt ?? this.sleepAt,
      screenTimeMinutes: screenTimeMinutes ?? this.screenTimeMinutes,
    );
  }

  /// Create a Day from a date
  factory Day.fromDate(DateTime date) {
    return Day(id: date.isoDate);
  }

  /// Create a Day for today
  factory Day.today() {
    return Day.fromDate(DateTime.now());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Day && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Day(id: $id, wakeAt: $wakeAt, sleepAt: $sleepAt, '
        'screenTimeMinutes: $screenTimeMinutes)';
  }
}
