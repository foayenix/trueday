/// Useful extensions for the application
library;

import 'package:intl/intl.dart';

/// Extensions on DateTime
extension DateTimeX on DateTime {
  /// Get the date only (without time)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Get ISO date string (yyyy-MM-dd)
  String get isoDate => DateFormat('yyyy-MM-dd').format(this);

  /// Format as display date (e.g., "Mon, 5 Nov 2025")
  String get displayDate => DateFormat('EEE, d MMM y').format(this);

  /// Format as display time (e.g., "14:30")
  String get displayTime => DateFormat('HH:mm').format(this);

  /// Format as display date and time
  String get displayDateTime => DateFormat('EEE, d MMM y HH:mm').format(this);

  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if this date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get the start of the week (Monday)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - DateTime.monday;
    return subtract(Duration(days: daysFromMonday)).dateOnly;
  }

  /// Get the end of the week (Sunday)
  DateTime get endOfWeek {
    final daysToSunday = DateTime.sunday - weekday;
    return add(Duration(days: daysToSunday)).dateOnly;
  }

  /// Check if this DateTime is between start and end
  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end) ||
        isAtSameMomentAs(start) ||
        isAtSameMomentAs(end);
  }

  /// Copy with optional parameters
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}

/// Extensions on Duration
extension DurationX on Duration {
  /// Format duration as human-readable string (e.g., "1h 30m", "45m")
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }

  /// Format as HH:MM
  String get hourMinute {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Get total minutes as double
  double get totalMinutes => inMilliseconds / 60000.0;

  /// Get total hours as double
  double get totalHours => inMilliseconds / 3600000.0;
}

/// Extensions on String
extension StringX on String {
  /// Check if string is empty or only whitespace
  bool get isBlank => trim().isEmpty;

  /// Check if string is not empty and not only whitespace
  bool get isNotBlank => !isBlank;

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Parse to DateTime or return null
  DateTime? get tryParseDateTime {
    try {
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }

  /// Parse ISO date (yyyy-MM-dd)
  DateTime? get tryParseDate {
    try {
      final parts = split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}

/// Extensions on List
extension ListX<T> on List<T> {
  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Group by a key selector
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Sum by a value selector
  num sumBy(num Function(T) selector) {
    return fold(0, (sum, item) => sum + selector(item));
  }
}
