/// Block model representing a time block in the day
library;

import '../../core/constants.dart';

/// Represents a time block in the user's day
class Block {
  final String id;
  final String dayId;
  final String title;
  final CategoryType category;
  final DateTime start;
  final DateTime end;
  final bool isAnchor;
  final String? parentId;

  const Block({
    required this.id,
    required this.dayId,
    required this.title,
    required this.category,
    required this.start,
    required this.end,
    required this.isAnchor,
    this.parentId,
  });

  /// Get the duration of this block
  Duration get duration => end.difference(start);

  /// Check if this block overlaps with another block
  bool overlaps(Block other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  /// Check if this block completely contains another block
  bool contains(Block other) {
    return start.isBefore(other.start) && end.isAfter(other.end) ||
        start.isAtSameMomentAs(other.start) && end.isAfter(other.end) ||
        start.isBefore(other.start) && end.isAtSameMomentAs(other.end);
  }

  /// Check if this block is fully inside another block
  bool isInside(Block other) {
    return other.contains(this);
  }

  /// Check if the given time is within this block
  bool containsTime(DateTime time) {
    return (time.isAfter(start) && time.isBefore(end)) ||
        time.isAtSameMomentAs(start) ||
        time.isAtSameMomentAs(end);
  }

  /// Check if this block is in the past
  bool get isPast => end.isBefore(DateTime.now());

  /// Check if this block is currently active
  bool get isActive {
    final now = DateTime.now();
    return containsTime(now);
  }

  /// Check if this block is in the future
  bool get isFuture => start.isAfter(DateTime.now());

  /// Get minutes overrun (if currently overrunning)
  int get overrunMinutes {
    if (!isActive && !isPast) return 0;
    final now = DateTime.now();
    if (now.isAfter(end)) {
      return now.difference(end).inMinutes;
    }
    return 0;
  }

  /// Check if this block is currently overrunning
  bool get isOverrunning => overrunMinutes > 0;

  /// Copy with new values
  Block copyWith({
    String? id,
    String? dayId,
    String? title,
    CategoryType? category,
    DateTime? start,
    DateTime? end,
    bool? isAnchor,
    String? parentId,
  }) {
    return Block(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      title: title ?? this.title,
      category: category ?? this.category,
      start: start ?? this.start,
      end: end ?? this.end,
      isAnchor: isAnchor ?? this.isAnchor,
      parentId: parentId ?? this.parentId,
    );
  }

  /// Create a block split before a given time
  Block splitBefore(DateTime splitTime, String newId) {
    assert(containsTime(splitTime), 'Split time must be within block');
    return copyWith(
      id: newId,
      end: splitTime,
    );
  }

  /// Create a block split after a given time
  Block splitAfter(DateTime splitTime, String newId) {
    assert(containsTime(splitTime), 'Split time must be within block');
    return copyWith(
      id: newId,
      start: splitTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Block && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Block(id: $id, title: $title, category: ${category.name}, '
        'start: $start, end: $end, isAnchor: $isAnchor, parentId: $parentId)';
  }
}
