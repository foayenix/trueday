/// Summaries service for day and week reports
library;

import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../models/block.dart';
import '../models/day.dart';

/// Category summary
class CategorySummary {
  final CategoryType category;
  final Duration totalDuration;
  final int blockCount;
  final double percentage;

  const CategorySummary({
    required this.category,
    required this.totalDuration,
    required this.blockCount,
    required this.percentage,
  });

  int get totalMinutes => totalDuration.inMinutes;

  @override
  String toString() {
    return 'CategorySummary(${category.displayName}: ${totalDuration.formatted}, '
        '$blockCount blocks, ${percentage.toStringAsFixed(1)}%)';
  }
}

/// Day summary
class DaySummary {
  final Day day;
  final List<Block> blocks;
  final Duration totalScheduled;
  final Duration totalIdle;
  final List<CategorySummary> categoryBreakdown;
  final int screenTimeMinutes;

  const DaySummary({
    required this.day,
    required this.blocks,
    required this.totalScheduled,
    required this.totalIdle,
    required this.categoryBreakdown,
    required this.screenTimeMinutes,
  });

  int get totalScheduledMinutes => totalScheduled.inMinutes;
  int get totalIdleMinutes => totalIdle.inMinutes;
  int get blockCount => blocks.length;

  @override
  String toString() {
    return 'DaySummary(${day.id}: ${blocks.length} blocks, '
        'scheduled: ${totalScheduled.formatted}, idle: ${totalIdle.formatted})';
  }
}

/// Week summary
class WeekSummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DaySummary> days;
  final List<CategorySummary> categoryBreakdown;
  final Duration totalScheduled;
  final int totalScreenTimeMinutes;

  const WeekSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.days,
    required this.categoryBreakdown,
    required this.totalScheduled,
    required this.totalScreenTimeMinutes,
  });

  int get totalScheduledMinutes => totalScheduled.inMinutes;
  int get dayCount => days.length;
  int get totalBlocks => days.fold(0, (sum, d) => sum + d.blockCount);

  @override
  String toString() {
    return 'WeekSummary(${weekStart.isoDate} to ${weekEnd.isoDate}: '
        '${days.length} days, ${totalBlocks} blocks, '
        'scheduled: ${totalScheduled.formatted})';
  }
}

/// Summaries service
class SummariesService {
  const SummariesService();

  /// Generate a day summary
  DaySummary generateDaySummary(Day day, List<Block> blocks) {
    // Sort blocks by start time
    final sorted = List<Block>.from(blocks)
      ..sort((a, b) => a.start.compareTo(b.start));

    // Calculate total scheduled time
    final totalScheduled = blocks.fold<Duration>(
      Duration.zero,
      (sum, block) => sum + block.duration,
    );

    // Calculate idle time (gaps between blocks)
    Duration totalIdle = Duration.zero;
    if (sorted.isNotEmpty && day.wakeAt != null) {
      final dayStart = day.wakeAt!;
      final dayEnd = day.sleepAt ?? DateTime.now();

      // Gap before first block
      if (sorted.first.start.isAfter(dayStart)) {
        totalIdle += sorted.first.start.difference(dayStart);
      }

      // Gaps between blocks
      for (var i = 0; i < sorted.length - 1; i++) {
        final current = sorted[i];
        final next = sorted[i + 1];
        if (current.end.isBefore(next.start)) {
          totalIdle += next.start.difference(current.end);
        }
      }

      // Gap after last block
      if (sorted.last.end.isBefore(dayEnd)) {
        totalIdle += dayEnd.difference(sorted.last.end);
      }
    }

    // Generate category breakdown
    final categoryBreakdown = _generateCategoryBreakdown(blocks, totalScheduled);

    return DaySummary(
      day: day,
      blocks: sorted,
      totalScheduled: totalScheduled,
      totalIdle: totalIdle,
      categoryBreakdown: categoryBreakdown,
      screenTimeMinutes: day.screenTimeMinutes,
    );
  }

  /// Generate a week summary
  WeekSummary generateWeekSummary(
    DateTime weekStart,
    List<Day> days,
    Map<String, List<Block>> blocksByDay,
  ) {
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Generate day summaries
    final daySummaries = days.map((day) {
      final blocks = blocksByDay[day.id] ?? [];
      return generateDaySummary(day, blocks);
    }).toList();

    // Calculate totals
    final totalScheduled = daySummaries.fold<Duration>(
      Duration.zero,
      (sum, day) => sum + day.totalScheduled,
    );

    final totalScreenTime = daySummaries.fold<int>(
      0,
      (sum, day) => sum + day.screenTimeMinutes,
    );

    // Aggregate category breakdown across all days
    final allBlocks = daySummaries.expand((d) => d.blocks).toList();
    final categoryBreakdown = _generateCategoryBreakdown(allBlocks, totalScheduled);

    return WeekSummary(
      weekStart: weekStart,
      weekEnd: weekEnd,
      days: daySummaries,
      categoryBreakdown: categoryBreakdown,
      totalScheduled: totalScheduled,
      totalScreenTimeMinutes: totalScreenTime,
    );
  }

  /// Generate category breakdown
  List<CategorySummary> _generateCategoryBreakdown(
    List<Block> blocks,
    Duration totalDuration,
  ) {
    // Group blocks by category
    final grouped = blocks.groupBy((b) => b.category);

    // Calculate summaries for each category
    final summaries = grouped.entries.map((entry) {
      final category = entry.key;
      final categoryBlocks = entry.value;

      final duration = categoryBlocks.fold<Duration>(
        Duration.zero,
        (sum, block) => sum + block.duration,
      );

      final percentage = totalDuration.inMilliseconds > 0
          ? (duration.inMilliseconds / totalDuration.inMilliseconds) * 100
          : 0.0;

      return CategorySummary(
        category: category,
        totalDuration: duration,
        blockCount: categoryBlocks.length,
        percentage: percentage,
      );
    }).toList();

    // Sort by duration (descending)
    summaries.sort((a, b) => b.totalDuration.compareTo(a.totalDuration));

    return summaries;
  }

  /// Get insights and suggestions from a day summary
  List<String> getDayInsights(DaySummary summary) {
    final insights = <String>[];

    // Check for excessive idle time
    if (summary.totalIdleMinutes > 120) {
      insights.add(
        'You had ${summary.totalIdle.formatted} of idle time today. '
        'Consider planning more activities.',
      );
    }

    // Check for work-life balance
    final workSummary = summary.categoryBreakdown.firstWhere(
      (c) => c.category == CategoryType.work,
      orElse: () => CategorySummary(
        category: CategoryType.work,
        totalDuration: Duration.zero,
        blockCount: 0,
        percentage: 0,
      ),
    );

    if (workSummary.percentage > 50) {
      insights.add(
        'Work took ${workSummary.percentage.toStringAsFixed(0)}% of your day. '
        'Remember to take breaks!',
      );
    }

    // Check for screen time
    if (summary.screenTimeMinutes > 180) {
      final hours = summary.screenTimeMinutes ~/ 60;
      final minutes = summary.screenTimeMinutes % 60;
      insights.add(
        'Screen time: ${hours}h ${minutes}m. '
        'Consider reducing by 20 minutes tomorrow.',
      );
    }

    // Positive reinforcement
    if (summary.blockCount >= 5) {
      insights.add('Well done! You planned and tracked ${summary.blockCount} activities today.');
    }

    return insights;
  }

  /// Get insights and suggestions from a week summary
  List<String> getWeekInsights(WeekSummary summary) {
    final insights = <String>[];

    // Overall productivity
    final avgMinutesPerDay = summary.totalScheduledMinutes / summary.dayCount;
    insights.add(
      'This week: ${summary.totalScheduled.formatted} scheduled across ${summary.totalBlocks} activities '
      '(avg ${avgMinutesPerDay.toStringAsFixed(0)}m/day).',
    );

    // Top categories
    if (summary.categoryBreakdown.isNotEmpty) {
      final top = summary.categoryBreakdown.first;
      insights.add(
        'Most time spent on ${top.category.displayName}: ${top.totalDuration.formatted} '
        '(${top.percentage.toStringAsFixed(0)}%).',
      );
    }

    // Screen time insights
    if (summary.totalScreenTimeMinutes > 0) {
      final avgScreenTimePerDay = summary.totalScreenTimeMinutes / summary.dayCount;
      final potentialSavings = (avgScreenTimePerDay * 0.2 * 7).toInt();

      insights.add(
        'Screen time: ${(summary.totalScreenTimeMinutes / 60).toStringAsFixed(1)}h this week. '
        'Cut by 20 min/day → gain ${potentialSavings}m this week.',
      );
    }

    // Balance check
    final categoryNames = summary.categoryBreakdown.map((c) => c.category).toList();
    if (categoryNames.contains(CategoryType.work) &&
        !categoryNames.contains(CategoryType.health) &&
        !categoryNames.contains(CategoryType.family)) {
      insights.add(
        'Consider adding more health and family activities for better balance.',
      );
    }

    return insights;
  }

  /// Format a summary as text
  String formatDaySummary(DaySummary summary) {
    final buffer = StringBuffer();
    buffer.writeln('Day Summary: ${summary.day.date.displayDate}');
    buffer.writeln('');
    buffer.writeln('Total scheduled: ${summary.totalScheduled.formatted}');
    buffer.writeln('Idle time: ${summary.totalIdle.formatted}');
    buffer.writeln('Blocks: ${summary.blockCount}');
    buffer.writeln('');
    buffer.writeln('Breakdown by category:');

    for (final cat in summary.categoryBreakdown) {
      buffer.writeln(
        '  ${cat.category.displayName}: ${cat.totalDuration.formatted} '
        '(${cat.percentage.toStringAsFixed(0)}%) - ${cat.blockCount} blocks',
      );
    }

    return buffer.toString();
  }

  /// Format a week summary as text
  String formatWeekSummary(WeekSummary summary) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Week Summary: ${summary.weekStart.displayDate} to ${summary.weekEnd.displayDate}',
    );
    buffer.writeln('');
    buffer.writeln('Total scheduled: ${summary.totalScheduled.formatted}');
    buffer.writeln('Days: ${summary.dayCount}');
    buffer.writeln('Total blocks: ${summary.totalBlocks}');
    buffer.writeln('');
    buffer.writeln('Breakdown by category:');

    for (final cat in summary.categoryBreakdown) {
      buffer.writeln(
        '  ${cat.category.displayName}: ${cat.totalDuration.formatted} '
        '(${cat.percentage.toStringAsFixed(0)}%) - ${cat.blockCount} blocks',
      );
    }

    return buffer.toString();
  }
}

/// Global summaries service instance
const summariesService = SummariesService();
