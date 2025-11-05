/// Parser unit tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trueday/domain/services/parser.dart';

void main() {
  group('Parser', () {
    final parser = Parser();
    final now = DateTime(2025, 11, 5, 9, 30); // 09:30 on Nov 5, 2025

    test('parses task with specific time and duration', () {
      final result = parser.parse('Meeting 10:00 30m', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Meeting');
      expect(task.start.hour, 10);
      expect(task.start.minute, 0);
      expect(task.duration.inMinutes, 30);
      expect(task.end.hour, 10);
      expect(task.end.minute, 30);
    });

    test('parses task starting now with duration', () {
      final result = parser.parse('Call now 15m', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Call');
      expect(task.start.hour, 9);
      expect(task.start.minute, 30);
      expect(task.duration.inMinutes, 15);
    });

    test('parses task with time but default duration', () {
      final result = parser.parse('Lunch 12:30', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Lunch');
      expect(task.start.hour, 12);
      expect(task.start.minute, 30);
      expect(task.duration.inMinutes, 30); // default
    });

    test('parses task with duration only (starts now)', () {
      final result = parser.parse('Exercise for 1h', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Exercise');
      expect(task.start.hour, 9);
      expect(task.start.minute, 30);
      expect(task.duration.inMinutes, 60);
    });

    test('parses task with hours and minutes duration', () {
      final result = parser.parse('Review 14:00 1h30m', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Review');
      expect(task.start.hour, 14);
      expect(task.start.minute, 0);
      expect(task.duration.inMinutes, 90);
    });

    test('parses task with only title (default time and duration)', () {
      final result = parser.parse('Quick task', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Quick task');
      expect(task.start.hour, 9);
      expect(task.start.minute, 30);
      expect(task.duration.inMinutes, 30);
    });

    test('parses task with "at" keyword', () {
      final result = parser.parse('Standup at 9:00 15m', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Standup');
      expect(task.start.hour, 9);
      expect(task.start.minute, 0);
      expect(task.duration.inMinutes, 15);
    });

    test('parses task with "for" keyword', () {
      final result = parser.parse('Break for 10m', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Break');
      expect(task.duration.inMinutes, 10);
    });

    test('returns error for empty input', () {
      final result = parser.parse('', now);

      expect(result.isLeft, true);
      expect(result.leftOrNull.toString(), contains('empty'));
    });

    test('returns error for invalid time format', () {
      final result = parser.parse('Meeting 25:00 30m', now);

      expect(result.isLeft, true);
    });

    test('handles single-digit hours', () {
      final result = parser.parse('Meeting 9:00 30m', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.start.hour, 9);
      expect(task.start.minute, 0);
    });

    test('parseFlexible handles time-time format', () {
      final result = parser.parseFlexible('Meeting 10:00-11:30', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Meeting');
      expect(task.start.hour, 10);
      expect(task.start.minute, 0);
      expect(task.end.hour, 11);
      expect(task.end.minute, 30);
      expect(task.duration.inMinutes, 90);
    });

    test('parseFlexible handles duration-time format', () {
      final result = parser.parseFlexible('Meeting 30m 10:00', now);

      expect(result.isRight, true);
      final task = result.value;
      expect(task.title, 'Meeting');
      expect(task.start.hour, 10);
      expect(task.start.minute, 0);
      expect(task.duration.inMinutes, 30);
    });
  });
}
