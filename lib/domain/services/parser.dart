/// Parser for impromptu task input
library;

import '../../core/constants.dart';
import '../../core/either.dart';
import '../../core/errors.dart';
import '../../core/time.dart';

/// Parsed task result
class ParsedTask {
  final String title;
  final DateTime start;
  final DateTime end;
  final Duration duration;

  const ParsedTask({
    required this.title,
    required this.start,
    required this.end,
    required this.duration,
  });

  @override
  String toString() {
    return 'ParsedTask(title: $title, start: $start, end: $end, duration: $duration)';
  }
}

/// Parser for impromptu task strings
///
/// Supported formats:
/// - "Meeting 10:00 30m" → Meeting at 10:00 for 30 minutes
/// - "Call now 15m" → Call starting now for 15 minutes
/// - "Lunch 12:30" → Lunch at 12:30 for 30 minutes (default)
/// - "Exercise for 1h" → Exercise starting now for 1 hour
/// - "Review 14:00 1h30m" → Review at 14:00 for 1 hour 30 minutes
class Parser {
  static final _regex = RegExp(
    r'^\s*(?<title>.+?)\s*(?:(?:at\s+)?(?<time>\d{1,2}:\d{2}|now))?\s*(?:(?:for\s+)?(?<dur>\d+h|\d+m|\d+h\s*\d+m))?\s*$',
    caseSensitive: false,
  );

  const Parser();

  /// Parse an impromptu task input string
  Result<ParsedTask> parse(String input, DateTime now) {
    if (input.trim().isEmpty) {
      return Either.left(ParseError('Input is empty', input));
    }

    final match = _regex.firstMatch(input);
    if (match == null) {
      return Either.left(ParseError('Invalid format', input));
    }

    // Extract components
    final title = match.namedGroup('title')?.trim();
    final timeStr = match.namedGroup('time')?.trim().toLowerCase();
    final durationStr = match.namedGroup('dur')?.trim();

    if (title == null || title.isEmpty) {
      return Either.left(ParseError('Title is required', input));
    }

    // Parse start time
    DateTime? start;
    if (timeStr == null || timeStr == 'now') {
      start = timeUtils.roundToMinute(now);
    } else {
      start = timeUtils.parseTime(timeStr, now);
      if (start == null) {
        return Either.left(ParseError('Invalid time format: $timeStr', input));
      }
    }

    // Parse duration
    Duration duration;
    if (durationStr == null) {
      duration = kDefaultTaskDuration;
    } else {
      final parsed = timeUtils.parseDuration(durationStr);
      if (parsed == null) {
        return Either.left(ParseError('Invalid duration format: $durationStr', input));
      }
      duration = parsed;
    }

    // Calculate end time
    final end = start.add(duration);

    final task = ParsedTask(
      title: title,
      start: start,
      end: end,
      duration: duration,
    );

    return Either.right(task);
  }

  /// Try to parse with multiple formats/interpretations
  Result<ParsedTask> parseFlexible(String input, DateTime now) {
    // First try the standard parse
    final result = parse(input, now);
    if (result.isRight) {
      return result;
    }

    // Try alternative interpretations

    // Format: "title duration time" (e.g., "Meeting 30m 10:00")
    final altRegex1 = RegExp(
      r'^\s*(?<title>.+?)\s+(?<dur>\d+h|\d+m|\d+h\s*\d+m)\s+(?:at\s+)?(?<time>\d{1,2}:\d{2}|now)\s*$',
      caseSensitive: false,
    );
    final match1 = altRegex1.firstMatch(input);
    if (match1 != null) {
      final title = match1.namedGroup('title')?.trim();
      final durationStr = match1.namedGroup('dur')?.trim();
      final timeStr = match1.namedGroup('time')?.trim().toLowerCase();

      if (title != null && durationStr != null && timeStr != null) {
        final duration = timeUtils.parseDuration(durationStr);
        DateTime? start;
        if (timeStr == 'now') {
          start = timeUtils.roundToMinute(now);
        } else {
          start = timeUtils.parseTime(timeStr, now);
        }

        if (duration != null && start != null) {
          return Either.right(ParsedTask(
            title: title,
            start: start,
            end: start.add(duration),
            duration: duration,
          ));
        }
      }
    }

    // Format: "title time-time" (e.g., "Meeting 10:00-11:00")
    final altRegex2 = RegExp(
      r'^\s*(?<title>.+?)\s+(?<start>\d{1,2}:\d{2})\s*-\s*(?<end>\d{1,2}:\d{2})\s*$',
      caseSensitive: false,
    );
    final match2 = altRegex2.firstMatch(input);
    if (match2 != null) {
      final title = match2.namedGroup('title')?.trim();
      final startStr = match2.namedGroup('start')?.trim();
      final endStr = match2.namedGroup('end')?.trim();

      if (title != null && startStr != null && endStr != null) {
        final start = timeUtils.parseTime(startStr, now);
        final end = timeUtils.parseTime(endStr, now);

        if (start != null && end != null && end.isAfter(start)) {
          final duration = end.difference(start);
          return Either.right(ParsedTask(
            title: title,
            start: start,
            end: end,
            duration: duration,
          ));
        }
      }
    }

    // If all parsing attempts fail, return the original error
    return result;
  }
}

/// Global parser instance
const parser = Parser();
