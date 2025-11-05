/// Time utilities for TrueDay
library;

import 'package:clock/clock.dart';
import 'extensions.dart';

/// Time utilities with clock support for testing
class TimeUtils {
  const TimeUtils();

  /// Get current DateTime (uses clock for testing)
  DateTime now() => clock.now();

  /// Get current date only
  DateTime today() => clock.now().dateOnly;

  /// Get yesterday's date
  DateTime yesterday() => clock.now().subtract(const Duration(days: 1)).dateOnly;

  /// Get tomorrow's date
  DateTime tomorrow() => clock.now().add(const Duration(days: 1)).dateOnly;

  /// Get start of current week (Monday)
  DateTime thisWeekStart() => clock.now().startOfWeek;

  /// Get end of current week (Sunday)
  DateTime thisWeekEnd() => clock.now().endOfWeek;

  /// Parse time string (HH:MM) and combine with date
  DateTime? parseTime(String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;

    return date.copyWith(hour: hour, minute: minute, second: 0, millisecond: 0, microsecond: 0);
  }

  /// Parse duration string (e.g., "30m", "1h", "1h30m")
  Duration? parseDuration(String durationStr) {
    final str = durationStr.toLowerCase().trim();

    // Match patterns like "30m", "1h", "1h30m", "90m"
    final hoursMatch = RegExp(r'(\d+)h').firstMatch(str);
    final minutesMatch = RegExp(r'(\d+)m').firstMatch(str);

    int hours = 0;
    int minutes = 0;

    if (hoursMatch != null) {
      hours = int.parse(hoursMatch.group(1)!);
    }

    if (minutesMatch != null) {
      minutes = int.parse(minutesMatch.group(1)!);
    }

    if (hours == 0 && minutes == 0) {
      return null;
    }

    return Duration(hours: hours, minutes: minutes);
  }

  /// Format duration to short string (e.g., "1h 30m", "45m")
  String formatDuration(Duration duration) {
    return duration.formatted;
  }

  /// Check if two DateTime ranges overlap
  bool doOverlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  /// Get the gap between two time ranges (if any)
  Duration? getGap(DateTime end1, DateTime start2) {
    if (end1.isBefore(start2)) {
      return start2.difference(end1);
    }
    return null;
  }

  /// Round time to nearest minute
  DateTime roundToMinute(DateTime dateTime) {
    return dateTime.copyWith(second: 0, millisecond: 0, microsecond: 0);
  }

  /// Get elapsed time since a DateTime
  Duration elapsed(DateTime since) {
    return clock.now().difference(since);
  }

  /// Format elapsed time as MM:SS
  String formatElapsed(Duration elapsed) {
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if a time is in the past
  bool isPast(DateTime dateTime) {
    return dateTime.isBefore(clock.now());
  }

  /// Check if a time is in the future
  bool isFuture(DateTime dateTime) {
    return dateTime.isAfter(clock.now());
  }

  /// Get date range for a week containing a date
  ({DateTime start, DateTime end}) getWeekRange(DateTime date) {
    return (start: date.startOfWeek, end: date.endOfWeek);
  }

  /// Get all dates in a week
  List<DateTime> getDatesInWeek(DateTime date) {
    final start = date.startOfWeek;
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  /// Check if two dates are on the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Global time utils instance
const timeUtils = TimeUtils();
