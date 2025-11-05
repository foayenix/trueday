/// Schedule engine for reflow logic
library;

import 'package:uuid/uuid.dart';
import '../../core/either.dart';
import '../../core/errors.dart';
import '../models/block.dart';
import '../models/day.dart';

/// Result of a reflow operation
class ReflowResult {
  /// Blocks to insert
  final List<Block> inserts;

  /// Blocks to update
  final List<Block> updates;

  /// Block IDs to delete
  final List<String> deletes;

  /// Blocks that couldn't fit (overflow)
  final List<Block> overflow;

  /// Messages/suggestions for the user
  final List<String> messages;

  const ReflowResult({
    this.inserts = const [],
    this.updates = const [],
    this.deletes = const [],
    this.overflow = const [],
    this.messages = const [],
  });

  /// Check if there are any changes
  bool get hasChanges =>
      inserts.isNotEmpty || updates.isNotEmpty || deletes.isNotEmpty;

  /// Check if there was overflow
  bool get hasOverflow => overflow.isNotEmpty;

  @override
  String toString() {
    return 'ReflowResult(inserts: ${inserts.length}, updates: ${updates.length}, '
        'deletes: ${deletes.length}, overflow: ${overflow.length}, '
        'messages: ${messages.length})';
  }
}

/// Schedule engine for managing block placement and reflow
class ScheduleEngine {
  final _uuid = const Uuid();

  /// Insert an impromptu task and reflow the schedule
  ///
  /// Rules:
  /// 1. Anchors don't move (isAnchor=true)
  /// 2. If newBlock is fully inside an anchor: split the anchor
  /// 3. If newBlock overlaps a flexible block: push flexible block forward
  /// 4. If no room before next anchor: mark overflow
  Result<ReflowResult> insertImpromptu(
    Day day,
    Block newBlock,
    List<Block> existing,
  ) {
    try {
      // Sort existing blocks by start time
      final sorted = List<Block>.from(existing)
        ..sort((a, b) => a.start.compareTo(b.start));

      final inserts = <Block>[];
      final updates = <Block>[];
      final deletes = <String>[];
      final overflow = <Block>[];
      final messages = <String>[];

      // Find containing anchor (if any)
      final containingAnchor = sorted.firstWhere(
        (b) => b.isAnchor && b.contains(newBlock),
        orElse: () => sorted.firstWhere(
          (b) => false,
          orElse: () => Block(
            id: '',
            dayId: '',
            title: '',
            category: newBlock.category,
            start: DateTime.now(),
            end: DateTime.now(),
            isAnchor: false,
          ),
        ),
      );

      // Case 1: New block is fully inside an anchor
      if (containingAnchor.id.isNotEmpty) {
        return _splitAnchor(
          containingAnchor,
          newBlock,
          sorted,
        );
      }

      // Case 2: New block overlaps with existing blocks
      final overlapping = sorted.where((b) => b.overlaps(newBlock)).toList();

      if (overlapping.isEmpty) {
        // No conflicts - just insert
        inserts.add(newBlock);
        return Either.right(ReflowResult(
          inserts: inserts,
          messages: ['Added ${newBlock.title}'],
        ));
      }

      // Process overlapping blocks
      for (final overlap in overlapping) {
        if (overlap.isAnchor) {
          // Can't move an anchor - this is an error
          messages.add(
            'Cannot insert ${newBlock.title} - overlaps with anchor ${overlap.title}',
          );
          overflow.add(newBlock);
          return Either.right(ReflowResult(
            overflow: overflow,
            messages: messages,
          ));
        }
      }

      // Try to push flexible blocks forward
      final pushResult = _pushBlocksForward(
        newBlock,
        overlapping,
        sorted,
      );

      if (pushResult.isLeft) {
        return pushResult;
      }

      final pushed = pushResult.value;
      inserts.add(newBlock);
      updates.addAll(pushed.updates);
      overflow.addAll(pushed.overflow);
      messages.addAll(pushed.messages);

      return Either.right(ReflowResult(
        inserts: inserts,
        updates: updates,
        overflow: overflow,
        messages: messages,
      ));
    } catch (e, stack) {
      return Either.left(ScheduleError('Failed to insert impromptu: $e', stack));
    }
  }

  /// Split an anchor block to accommodate a new block
  Result<ReflowResult> _splitAnchor(
    Block anchor,
    Block newBlock,
    List<Block> sorted,
  ) {
    final inserts = <Block>[];
    final updates = <Block>[];
    final deletes = <String>[];
    final messages = <String>[];

    // Clamp new block within anchor
    final clamped = newBlock.copyWith(
      start: newBlock.start.isBefore(anchor.start) ? anchor.start : newBlock.start,
      end: newBlock.end.isAfter(anchor.end) ? anchor.end : newBlock.end,
      parentId: anchor.id,
    );

    // Check if there's room within the anchor (considering existing sub-blocks)
    final existingSubBlocks = sorted
        .where((b) => b.parentId == anchor.id)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    // Check for overlaps with existing sub-blocks
    for (final sub in existingSubBlocks) {
      if (sub.overlaps(clamped)) {
        messages.add(
          'Cannot insert ${newBlock.title} inside ${anchor.title} - '
          'overlaps with ${sub.title}',
        );
        return Either.right(ReflowResult(
          overflow: [newBlock],
          messages: messages,
        ));
      }
    }

    // Insert the clamped block as a child of the anchor
    inserts.add(clamped);
    messages.add('Inserted ${newBlock.title} inside ${anchor.title}');

    return Either.right(ReflowResult(
      inserts: inserts,
      updates: updates,
      deletes: deletes,
      messages: messages,
    ));
  }

  /// Push flexible blocks forward to make room
  Result<ReflowResult> _pushBlocksForward(
    Block newBlock,
    List<Block> overlapping,
    List<Block> allBlocks,
  ) {
    final updates = <Block>[];
    final overflow = <Block>[];
    final messages = <String>[];

    // Find the next anchor after the new block
    final nextAnchor = allBlocks.firstWhere(
      (b) => b.isAnchor && b.start.isAfter(newBlock.end),
      orElse: () => allBlocks.firstWhere(
        (b) => false,
        orElse: () => Block(
          id: '',
          dayId: '',
          title: '',
          category: newBlock.category,
          start: DateTime.now(),
          end: DateTime.now(),
          isAnchor: false,
        ),
      ),
    );

    final hasNextAnchor = nextAnchor.id.isNotEmpty;
    final nextAnchorStart = hasNextAnchor ? nextAnchor.start : null;

    // Try to push each overlapping block
    var currentEnd = newBlock.end;

    for (final block in overlapping) {
      final duration = block.duration;
      final newStart = currentEnd;
      final newEnd = newStart.add(duration);

      // Check if it fits before the next anchor
      if (hasNextAnchor && newEnd.isAfter(nextAnchorStart!)) {
        overflow.add(block);
        messages.add(
          'Cannot fit ${block.title} before next anchor ${nextAnchor.title}',
        );
        continue;
      }

      // Update the block
      final updated = block.copyWith(start: newStart, end: newEnd);
      updates.add(updated);
      currentEnd = newEnd;
      messages.add('Moved ${block.title} to ${newStart.toString().substring(11, 16)}');
    }

    return Either.right(ReflowResult(
      updates: updates,
      overflow: overflow,
      messages: messages,
    ));
  }

  /// Check if a block can be inserted without conflicts
  Result<bool> canInsert(Block block, List<Block> existing) {
    try {
      // Check for anchor conflicts
      final anchorConflicts = existing.where(
        (b) => b.isAnchor && b.overlaps(block),
      );

      if (anchorConflicts.isNotEmpty) {
        // Check if fully contained
        final contained = anchorConflicts.firstWhere(
          (a) => a.contains(block),
          orElse: () => anchorConflicts.first,
        );

        if (contained.contains(block)) {
          // Can insert as child
          return const Either.right(true);
        }

        // Partial overlap with anchor
        return const Either.right(false);
      }

      // No anchor conflicts - can always insert (may need to push other blocks)
      return const Either.right(true);
    } catch (e, stack) {
      return Either.left(ScheduleError('Failed to check if can insert: $e', stack));
    }
  }

  /// Find gaps in the schedule
  List<({DateTime start, DateTime end, Duration duration})> findGaps(
    List<Block> blocks,
    DateTime dayStart,
    DateTime dayEnd,
  ) {
    final gaps = <({DateTime start, DateTime end, Duration duration})>[];

    if (blocks.isEmpty) {
      gaps.add((
        start: dayStart,
        end: dayEnd,
        duration: dayEnd.difference(dayStart),
      ));
      return gaps;
    }

    final sorted = List<Block>.from(blocks)
      ..sort((a, b) => a.start.compareTo(b.start));

    // Gap before first block
    if (sorted.first.start.isAfter(dayStart)) {
      final duration = sorted.first.start.difference(dayStart);
      gaps.add((
        start: dayStart,
        end: sorted.first.start,
        duration: duration,
      ));
    }

    // Gaps between blocks
    for (var i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];

      if (current.end.isBefore(next.start)) {
        final duration = next.start.difference(current.end);
        gaps.add((
          start: current.end,
          end: next.start,
          duration: duration,
        ));
      }
    }

    // Gap after last block
    if (sorted.last.end.isBefore(dayEnd)) {
      final duration = dayEnd.difference(sorted.last.end);
      gaps.add((
        start: sorted.last.end,
        end: dayEnd,
        duration: duration,
      ));
    }

    return gaps;
  }

  /// Suggest where to place a block that didn't fit
  List<String> suggestPlacement(Block block, Day day, List<Block> existing) {
    final suggestions = <String>[];

    // Find gaps
    final dayStart = day.wakeAt ?? DateTime(day.date.year, day.date.month, day.date.day, 6, 0);
    final dayEnd = day.sleepAt ?? DateTime(day.date.year, day.date.month, day.date.day, 22, 0);

    final gaps = findGaps(existing, dayStart, dayEnd);

    // Find gaps that can fit this block
    final fittingGaps = gaps.where((g) => g.duration >= block.duration).toList();

    if (fittingGaps.isEmpty) {
      suggestions.add('No available gaps for ${block.duration.inMinutes}m block');
      suggestions.add('Consider:');
      suggestions.add('- Compressing existing activities');
      suggestions.add('- Moving to evening');
      suggestions.add('- Scheduling for tomorrow');
    } else {
      suggestions.add('Available gaps:');
      for (final gap in fittingGaps) {
        final startTime = gap.start.toString().substring(11, 16);
        final endTime = gap.end.toString().substring(11, 16);
        suggestions.add('- $startTime to $endTime (${gap.duration.inMinutes}m)');
      }
    }

    return suggestions;
  }
}
