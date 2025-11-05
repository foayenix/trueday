/// Riverpod providers for state management
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/either.dart';
import '../data/db/dao_block.dart';
import '../data/db/dao_day.dart';
import '../data/db/schema.dart';
import '../domain/models/block.dart';
import '../domain/models/day.dart';
import '../domain/services/notifications.dart';
import '../domain/services/parser.dart';
import '../domain/services/schedule_engine.dart';
import '../domain/services/summaries.dart';

// ========== Database ==========

/// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Day DAO provider
final dayDaoProvider = Provider<DayDao>((ref) {
  final db = ref.watch(databaseProvider);
  return DayDao(db);
});

/// Block DAO provider
final blockDaoProvider = Provider<BlockDao>((ref) {
  final db = ref.watch(databaseProvider);
  return BlockDao(db);
});

// ========== Services ==========

/// Parser provider
final parserProvider = Provider<Parser>((ref) {
  return const Parser();
});

/// Schedule engine provider
final scheduleEngineProvider = Provider<ScheduleEngine>((ref) {
  return ScheduleEngine();
});

/// Summaries service provider
final summariesServiceProvider = Provider<SummariesService>((ref) {
  return const SummariesService();
});

/// Notifications service provider
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  final plugin = FlutterLocalNotificationsPlugin();
  return NotificationsService(plugin);
});

// ========== Data Providers ==========

/// Current day provider
final currentDayProvider = FutureProvider<Day>((ref) async {
  final dayDao = ref.watch(dayDaoProvider);
  final result = await dayDao.getToday();

  return result.fold(
    (error) => throw Exception('Failed to get today: $error'),
    (day) => day,
  );
});

/// Blocks for today provider
final todayBlocksProvider = FutureProvider<List<Block>>((ref) async {
  final blockDao = ref.watch(blockDaoProvider);
  final day = await ref.watch(currentDayProvider.future);

  final result = await blockDao.getBlocksForDay(day.id);

  return result.fold(
    (error) => throw Exception('Failed to get blocks: $error'),
    (blocks) => blocks,
  );
});

/// Current active block provider
final currentBlockProvider = FutureProvider<Block?>((ref) async {
  final blockDao = ref.watch(blockDaoProvider);
  final day = await ref.watch(currentDayProvider.future);

  final result = await blockDao.getCurrentBlock(day.id);

  return result.fold(
    (error) => null,
    (block) => block,
  );
});

/// Next upcoming block provider
final nextBlockProvider = FutureProvider<Block?>((ref) async {
  final blockDao = ref.watch(blockDaoProvider);
  final day = await ref.watch(currentDayProvider.future);

  final result = await blockDao.getNextBlock(day.id);

  return result.fold(
    (error) => null,
    (block) => block,
  );
});

/// Week summary provider
final weekSummaryProvider = FutureProvider((ref) async {
  final dayDao = ref.watch(dayDaoProvider);
  final blockDao = ref.watch(blockDaoProvider);
  final summariesService = ref.watch(summariesServiceProvider);

  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));

  final daysResult = await dayDao.getThisWeek();
  final days = daysResult.fold(
    (error) => <Day>[],
    (days) => days,
  );

  final blocksByDay = <String, List<Block>>{};
  for (final day in days) {
    final blocksResult = await blockDao.getBlocksForDay(day.id);
    blocksByDay[day.id] = blocksResult.fold(
      (error) => <Block>[],
      (blocks) => blocks,
    );
  }

  return summariesService.generateWeekSummary(weekStart, days, blocksByDay);
});

// ========== Actions ==========

/// Add impromptu task notifier
final addImpromptuProvider = StateNotifierProvider<AddImpromptuNotifier, AsyncValue<void>>((ref) {
  return AddImpromptuNotifier(ref);
});

class AddImpromptuNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AddImpromptuNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addImpromptu(String input) async {
    state = const AsyncValue.loading();

    try {
      final parser = ref.read(parserProvider);
      final engine = ref.read(scheduleEngineProvider);
      final blockDao = ref.read(blockDaoProvider);
      final dayDao = ref.read(dayDaoProvider);

      // Get current day
      final dayResult = await dayDao.getToday();
      if (dayResult.isLeft) {
        throw Exception('Failed to get today');
      }
      final day = dayResult.value;

      // Parse the input
      final now = DateTime.now();
      final parseResult = parser.parse(input, now);
      if (parseResult.isLeft) {
        throw Exception('Failed to parse: ${parseResult.leftOrNull}');
      }
      final parsed = parseResult.value;

      // Get existing blocks
      final blocksResult = await blockDao.getBlocksForDay(day.id);
      if (blocksResult.isLeft) {
        throw Exception('Failed to get blocks');
      }
      final existing = blocksResult.value;

      // Create new block from parsed task
      final newBlock = Block(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dayId: day.id,
        title: parsed.title,
        category: CategoryType.other,
        start: parsed.start,
        end: parsed.end,
        isAnchor: false,
      );

      // Use schedule engine to handle reflow
      final reflowResult = engine.insertImpromptu(day, newBlock, existing);
      if (reflowResult.isLeft) {
        throw Exception('Failed to reflow: ${reflowResult.leftOrNull}');
      }

      final reflow = reflowResult.value;

      // Apply changes to database
      await blockDao.batchUpdateBlocks(
        deleteIds: reflow.deletes,
        insertList: reflow.inserts,
        updateList: reflow.updates,
      );

      // Refresh providers
      ref.invalidate(todayBlocksProvider);
      ref.invalidate(currentBlockProvider);
      ref.invalidate(nextBlockProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Start/stop block actions
final blockActionsProvider = Provider<BlockActions>((ref) {
  return BlockActions(ref);
});

class BlockActions {
  final Ref ref;

  BlockActions(this.ref);

  Future<void> startBlock(Block block) async {
    // Implementation for starting a block
    // This would update the block's start time to now
    final blockDao = ref.read(blockDaoProvider);
    final updated = block.copyWith(start: DateTime.now());
    await blockDao.updateBlock(updated);

    ref.invalidate(todayBlocksProvider);
    ref.invalidate(currentBlockProvider);
    ref.invalidate(nextBlockProvider);
  }

  Future<void> stopBlock(Block block) async {
    // Implementation for stopping a block
    // This would update the block's end time to now
    final blockDao = ref.read(blockDaoProvider);
    final updated = block.copyWith(end: DateTime.now());
    await blockDao.updateBlock(updated);

    ref.invalidate(todayBlocksProvider);
    ref.invalidate(currentBlockProvider);
    ref.invalidate(nextBlockProvider);
  }

  Future<void> extendBlock(Block block, Duration extension) async {
    // Extend block by adding duration to end time
    final blockDao = ref.read(blockDaoProvider);
    final updated = block.copyWith(end: block.end.add(extension));
    await blockDao.updateBlock(updated);

    ref.invalidate(todayBlocksProvider);
    ref.invalidate(currentBlockProvider);
    ref.invalidate(nextBlockProvider);
  }

  Future<void> deleteBlock(Block block) async {
    final blockDao = ref.read(blockDaoProvider);
    await blockDao.deleteBlock(block.id);

    ref.invalidate(todayBlocksProvider);
    ref.invalidate(currentBlockProvider);
    ref.invalidate(nextBlockProvider);
  }
}
