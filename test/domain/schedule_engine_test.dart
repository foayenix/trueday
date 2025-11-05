/// Schedule Engine unit tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:trueday/core/constants.dart';
import 'package:trueday/domain/models/block.dart';
import 'package:trueday/domain/models/day.dart';
import 'package:trueday/domain/services/schedule_engine.dart';

void main() {
  group('ScheduleEngine', () {
    final engine = ScheduleEngine();
    final testDay = Day(id: '2025-11-05');
    final baseTime = DateTime(2025, 11, 5, 9, 0); // 09:00

    Block createBlock({
      required String id,
      required String title,
      required int startHour,
      required int durationMinutes,
      bool isAnchor = false,
      String? parentId,
    }) {
      final start = DateTime(2025, 11, 5, startHour, 0);
      final end = start.add(Duration(minutes: durationMinutes));
      return Block(
        id: id,
        dayId: testDay.id,
        title: title,
        category: CategoryType.work,
        start: start,
        end: end,
        isAnchor: isAnchor,
        parentId: parentId,
      );
    }

    test('inserts impromptu task with no conflicts', () {
      final existing = <Block>[];
      final newBlock = createBlock(
        id: 'new1',
        title: 'Meeting',
        startHour: 10,
        durationMinutes: 30,
      );

      final result = engine.insertImpromptu(testDay, newBlock, existing);

      expect(result.isRight, true);
      final reflow = result.value;
      expect(reflow.inserts.length, 1);
      expect(reflow.updates.length, 0);
      expect(reflow.deletes.length, 0);
      expect(reflow.overflow.length, 0);
    });

    test('pushes flexible block forward when overlapping', () {
      final existing = [
        createBlock(
          id: 'flex1',
          title: 'Flexible Task',
          startHour: 10,
          durationMinutes: 60,
          isAnchor: false,
        ),
      ];

      final newBlock = createBlock(
        id: 'new1',
        title: 'Urgent Meeting',
        startHour: 10,
        durationMinutes: 30,
      );

      final result = engine.insertImpromptu(testDay, newBlock, existing);

      expect(result.isRight, true);
      final reflow = result.value;
      expect(reflow.inserts.length, 1);
      expect(reflow.updates.length, 1);
      expect(reflow.overflow.length, 0);

      // Check that flexible block was pushed forward
      final updated = reflow.updates.first;
      expect(updated.start.hour, 10);
      expect(updated.start.minute, 30);
    });

    test('splits anchor when new block is fully inside', () {
      final existing = [
        createBlock(
          id: 'anchor1',
          title: 'Work',
          startHour: 9,
          durationMinutes: 180, // 3 hours
          isAnchor: true,
        ),
      ];

      final newBlock = createBlock(
        id: 'new1',
        title: 'Meeting',
        startHour: 10,
        durationMinutes: 30,
      );

      final result = engine.insertImpromptu(testDay, newBlock, existing);

      expect(result.isRight, true);
      final reflow = result.value;
      expect(reflow.inserts.length, 1);
      expect(reflow.inserts.first.parentId, 'anchor1');
    });

    test('returns overflow when no room before next anchor', () {
      final existing = [
        createBlock(
          id: 'anchor1',
          title: 'Morning Work',
          startHour: 9,
          durationMinutes: 120,
          isAnchor: true,
        ),
        createBlock(
          id: 'anchor2',
          title: 'Lunch',
          startHour: 12,
          durationMinutes: 60,
          isAnchor: true,
        ),
        createBlock(
          id: 'flex1',
          title: 'Task 1',
          startHour: 11,
          durationMinutes: 60,
        ),
      ];

      // Try to insert 90-minute block that won't fit
      final newBlock = createBlock(
        id: 'new1',
        title: 'Long Meeting',
        startHour: 11,
        durationMinutes: 90,
      );

      final result = engine.insertImpromptu(testDay, newBlock, existing);

      expect(result.isRight, true);
      final reflow = result.value;
      expect(reflow.overflow.length, greaterThan(0));
    });

    test('prevents inserting over anchor', () {
      final existing = [
        createBlock(
          id: 'anchor1',
          title: 'Important Meeting',
          startHour: 10,
          durationMinutes: 60,
          isAnchor: true,
        ),
      ];

      // Try to insert block that partially overlaps anchor
      final newBlock = createBlock(
        id: 'new1',
        title: 'Another Task',
        startHour: 10,
        durationMinutes: 30,
      );

      final result = engine.insertImpromptu(testDay, newBlock, existing);

      expect(result.isRight, true);
      final reflow = result.value;

      // Should either insert as child or overflow
      final insertedAsChild = reflow.inserts.isNotEmpty &&
          reflow.inserts.first.parentId == 'anchor1';
      final overflowed = reflow.overflow.isNotEmpty;

      expect(insertedAsChild || overflowed, true);
    });

    test('canInsert returns true for non-conflicting block', () {
      final existing = [
        createBlock(
          id: 'block1',
          title: 'Task',
          startHour: 10,
          durationMinutes: 60,
        ),
      ];

      final newBlock = createBlock(
        id: 'new1',
        title: 'New Task',
        startHour: 11,
        durationMinutes: 30,
      );

      final result = engine.canInsert(newBlock, existing);

      expect(result.isRight, true);
      expect(result.value, true);
    });

    test('findGaps finds empty slots in schedule', () {
      final blocks = [
        createBlock(
          id: 'block1',
          title: 'Morning',
          startHour: 9,
          durationMinutes: 60,
        ),
        createBlock(
          id: 'block2',
          title: 'Afternoon',
          startHour: 14,
          durationMinutes: 60,
        ),
      ];

      final dayStart = DateTime(2025, 11, 5, 8, 0);
      final dayEnd = DateTime(2025, 11, 5, 17, 0);

      final gaps = engine.findGaps(blocks, dayStart, dayEnd);

      expect(gaps.length, greaterThan(0));

      // Should have gaps: before first block, between blocks, after last block
      expect(gaps.length, 3);

      // Gap before first block (8:00-9:00)
      expect(gaps[0].start.hour, 8);
      expect(gaps[0].end.hour, 9);

      // Gap between blocks (10:00-14:00)
      expect(gaps[1].start.hour, 10);
      expect(gaps[1].end.hour, 14);

      // Gap after last block (15:00-17:00)
      expect(gaps[2].start.hour, 15);
      expect(gaps[2].end.hour, 17);
    });

    test('findGaps returns full day when no blocks', () {
      final blocks = <Block>[];

      final dayStart = DateTime(2025, 11, 5, 8, 0);
      final dayEnd = DateTime(2025, 11, 5, 17, 0);

      final gaps = engine.findGaps(blocks, dayStart, dayEnd);

      expect(gaps.length, 1);
      expect(gaps.first.start, dayStart);
      expect(gaps.first.end, dayEnd);
    });

    test('suggestPlacement provides alternatives for overflow', () {
      final existing = [
        createBlock(
          id: 'block1',
          title: 'Morning',
          startHour: 9,
          durationMinutes: 120,
        ),
      ];

      final overflowBlock = createBlock(
        id: 'new1',
        title: 'Task',
        startHour: 10,
        durationMinutes: 60,
      );

      final suggestions = engine.suggestPlacement(overflowBlock, testDay, existing);

      expect(suggestions, isNotEmpty);
    });

    test('handles multiple flexible blocks needing to be pushed', () {
      final existing = [
        createBlock(
          id: 'flex1',
          title: 'Task 1',
          startHour: 10,
          durationMinutes: 30,
        ),
        createBlock(
          id: 'flex2',
          title: 'Task 2',
          startHour: 10,
          durationMinutes: 30,
        ),
      ];

      final newBlock = createBlock(
        id: 'new1',
        title: 'Urgent',
        startHour: 10,
        durationMinutes: 30,
      );

      final result = engine.insertImpromptu(testDay, newBlock, existing);

      expect(result.isRight, true);
      final reflow = result.value;
      expect(reflow.inserts.length, 1);
    });

    test('clamps new block within containing anchor', () {
      final existing = [
        createBlock(
          id: 'anchor1',
          title: 'Work Block',
          startHour: 9,
          durationMinutes: 180,
          isAnchor: true,
        ),
      ];

      // Try to insert block that extends beyond anchor
      final start = DateTime(2025, 11, 5, 11, 0);
      final end = DateTime(2025, 11, 5, 13, 0); // Would extend past anchor
      final newBlock = Block(
        id: 'new1',
        dayId: testDay.id,
        title: 'Long Meeting',
        category: CategoryType.work,
        start: start,
        end: end,
        isAnchor: false,
      );

      final result = engine.insertImpromptu(testDay, newBlock, existing);

      expect(result.isRight, true);
      final reflow = result.value;

      if (reflow.inserts.isNotEmpty) {
        final inserted = reflow.inserts.first;
        // Should be clamped to anchor bounds
        expect(inserted.end.isBefore(existing.first.end) ||
            inserted.end.isAtSameMomentAs(existing.first.end), true);
      }
    });
  });
}
