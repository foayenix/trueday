/// Summaries service unit tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trueday/core/constants.dart';
import 'package:trueday/domain/models/block.dart';
import 'package:trueday/domain/models/day.dart';
import 'package:trueday/domain/services/summaries.dart';

void main() {
  group('SummariesService', () {
    final service = SummariesService();
    final testDay = Day(
      id: '2025-11-05',
      wakeAt: DateTime(2025, 11, 5, 7, 0),
      sleepAt: DateTime(2025, 11, 5, 22, 0),
    );

    Block createBlock({
      required String id,
      required String title,
      required CategoryType category,
      required int startHour,
      required int durationMinutes,
    }) {
      final start = DateTime(2025, 11, 5, startHour, 0);
      final end = start.add(Duration(minutes: durationMinutes));
      return Block(
        id: id,
        dayId: testDay.id,
        title: title,
        category: category,
        start: start,
        end: end,
        isAnchor: false,
      );
    }

    test('generates day summary with totals', () {
      final blocks = [
        createBlock(
          id: '1',
          title: 'Work',
          category: CategoryType.work,
          startHour: 9,
          durationMinutes: 120,
        ),
        createBlock(
          id: '2',
          title: 'Lunch',
          category: CategoryType.family,
          startHour: 12,
          durationMinutes: 60,
        ),
        createBlock(
          id: '3',
          title: 'Exercise',
          category: CategoryType.health,
          startHour: 18,
          durationMinutes: 60,
        ),
      ];

      final summary = service.generateDaySummary(testDay, blocks);

      expect(summary.day, testDay);
      expect(summary.blocks.length, 3);
      expect(summary.totalScheduledMinutes, 240); // 2h + 1h + 1h
      expect(summary.totalIdleMinutes, greaterThan(0));
      expect(summary.categoryBreakdown.length, 3);
    });

    test('calculates idle time correctly', () {
      final blocks = [
        createBlock(
          id: '1',
          title: 'Morning Work',
          category: CategoryType.work,
          startHour: 9,
          durationMinutes: 60,
        ),
        createBlock(
          id: '2',
          title: 'Afternoon Work',
          category: CategoryType.work,
          startHour: 14,
          durationMinutes: 60,
        ),
      ];

      final summary = service.generateDaySummary(testDay, blocks);

      // Should have idle time: 7am-9am (2h), 10am-2pm (4h), 3pm-10pm (7h)
      // Total: 13 hours = 780 minutes
      expect(summary.totalIdleMinutes, 780);
    });

    test('generates category breakdown with percentages', () {
      final blocks = [
        createBlock(
          id: '1',
          title: 'Work 1',
          category: CategoryType.work,
          startHour: 9,
          durationMinutes: 120,
        ),
        createBlock(
          id: '2',
          title: 'Family Time',
          category: CategoryType.family,
          startHour: 12,
          durationMinutes: 60,
        ),
        createBlock(
          id: '3',
          title: 'Work 2',
          category: CategoryType.work,
          startHour: 14,
          durationMinutes: 60,
        ),
      ];

      final summary = service.generateDaySummary(testDay, blocks);

      // Work: 180 minutes (75%)
      // Family: 60 minutes (25%)
      final workSummary = summary.categoryBreakdown
          .firstWhere((c) => c.category == CategoryType.work);
      final familySummary = summary.categoryBreakdown
          .firstWhere((c) => c.category == CategoryType.family);

      expect(workSummary.totalMinutes, 180);
      expect(workSummary.blockCount, 2);
      expect(workSummary.percentage, closeTo(75.0, 0.1));

      expect(familySummary.totalMinutes, 60);
      expect(familySummary.blockCount, 1);
      expect(familySummary.percentage, closeTo(25.0, 0.1));
    });

    test('generates week summary with aggregated data', () {
      final days = [
        Day(id: '2025-11-04', wakeAt: DateTime(2025, 11, 4, 7, 0)),
        Day(id: '2025-11-05', wakeAt: DateTime(2025, 11, 5, 7, 0)),
      ];

      final blocksByDay = {
        '2025-11-04': [
          createBlock(
            id: '1',
            title: 'Work',
            category: CategoryType.work,
            startHour: 9,
            durationMinutes: 120,
          ),
        ],
        '2025-11-05': [
          createBlock(
            id: '2',
            title: 'Work',
            category: CategoryType.work,
            startHour: 9,
            durationMinutes: 180,
          ),
        ],
      };

      final weekStart = DateTime(2025, 11, 4);
      final summary = service.generateWeekSummary(weekStart, days, blocksByDay);

      expect(summary.dayCount, 2);
      expect(summary.totalScheduledMinutes, 300); // 120 + 180
      expect(summary.totalBlocks, 2);
      expect(summary.categoryBreakdown.length, 1);

      final workSummary = summary.categoryBreakdown
          .firstWhere((c) => c.category == CategoryType.work);
      expect(workSummary.totalMinutes, 300);
      expect(workSummary.blockCount, 2);
    });

    test('provides day insights for excessive idle time', () {
      final blocks = [
        createBlock(
          id: '1',
          title: 'Short Task',
          category: CategoryType.work,
          startHour: 9,
          durationMinutes: 30,
        ),
      ];

      final summary = service.generateDaySummary(testDay, blocks);
      final insights = service.getDayInsights(summary);

      expect(insights.any((i) => i.contains('idle')), true);
    });

    test('provides day insights for work-life balance', () {
      final blocks = [
        createBlock(
          id: '1',
          title: 'Work',
          category: CategoryType.work,
          startHour: 9,
          durationMinutes: 480, // 8 hours = over 50%
        ),
      ];

      final summary = service.generateDaySummary(testDay, blocks);
      final insights = service.getDayInsights(summary);

      expect(insights.any((i) => i.contains('Work took')), true);
    });

    test('provides week insights with top category', () {
      final days = [testDay];
      final blocksByDay = {
        testDay.id: [
          createBlock(
            id: '1',
            title: 'Work',
            category: CategoryType.work,
            startHour: 9,
            durationMinutes: 240,
          ),
          createBlock(
            id: '2',
            title: 'Exercise',
            category: CategoryType.health,
            startHour: 17,
            durationMinutes: 60,
          ),
        ],
      };

      final weekStart = DateTime(2025, 11, 4);
      final summary = service.generateWeekSummary(weekStart, days, blocksByDay);
      final insights = service.getWeekInsights(summary);

      expect(insights.any((i) => i.contains('Most time spent')), true);
      expect(insights.any((i) => i.contains('Work')), true);
    });

    test('formats day summary as text', () {
      final blocks = [
        createBlock(
          id: '1',
          title: 'Work',
          category: CategoryType.work,
          startHour: 9,
          durationMinutes: 120,
        ),
      ];

      final summary = service.generateDaySummary(testDay, blocks);
      final formatted = service.formatDaySummary(summary);

      expect(formatted, contains('Day Summary'));
      expect(formatted, contains('2h'));
      expect(formatted, contains('Work'));
    });

    test('formats week summary as text', () {
      final days = [testDay];
      final blocksByDay = {
        testDay.id: [
          createBlock(
            id: '1',
            title: 'Work',
            category: CategoryType.work,
            startHour: 9,
            durationMinutes: 120,
          ),
        ],
      };

      final weekStart = DateTime(2025, 11, 4);
      final summary = service.generateWeekSummary(weekStart, days, blocksByDay);
      final formatted = service.formatWeekSummary(summary);

      expect(formatted, contains('Week Summary'));
      expect(formatted, contains('2h'));
    });

    test('handles empty blocks list', () {
      final blocks = <Block>[];

      final summary = service.generateDaySummary(testDay, blocks);

      expect(summary.blocks, isEmpty);
      expect(summary.totalScheduledMinutes, 0);
      expect(summary.categoryBreakdown, isEmpty);
    });

    test('sorts category breakdown by duration', () {
      final blocks = [
        createBlock(
          id: '1',
          title: 'Work',
          category: CategoryType.work,
          startHour: 9,
          durationMinutes: 60,
        ),
        createBlock(
          id: '2',
          title: 'Health',
          category: CategoryType.health,
          startHour: 10,
          durationMinutes: 120,
        ),
        createBlock(
          id: '3',
          title: 'Family',
          category: CategoryType.family,
          startHour: 12,
          durationMinutes: 90,
        ),
      ];

      final summary = service.generateDaySummary(testDay, blocks);

      // Should be sorted: Health (120), Family (90), Work (60)
      expect(summary.categoryBreakdown[0].category, CategoryType.health);
      expect(summary.categoryBreakdown[1].category, CategoryType.family);
      expect(summary.categoryBreakdown[2].category, CategoryType.work);
    });
  });
}
