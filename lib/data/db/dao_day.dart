/// Day DAO (Data Access Object)
library;

import 'package:drift/drift.dart';
import '../../core/either.dart';
import '../../core/errors.dart';
import '../../domain/models/day.dart' as domain;
import 'schema.dart';

part 'dao_day.g.dart';

/// Day Data Access Object
@DriftAccessor(tables: [Days])
class DayDao extends DatabaseAccessor<AppDatabase> with _$DayDaoMixin {
  DayDao(super.db);

  /// Get a day by ID
  Future<Result<domain.Day>> getDayById(String id) async {
    try {
      final query = select(days)..where((t) => t.id.equals(id));
      final entry = await query.getSingleOrNull();

      if (entry == null) {
        return Either.left(NotFoundError('Day', id));
      }

      return Either.right(db.toDomainDay(entry));
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get day: $e', stack));
    }
  }

  /// Get or create a day
  Future<Result<domain.Day>> getOrCreateDay(String id) async {
    try {
      final existing = await getDayById(id);
      if (existing.isRight) {
        return existing;
      }

      // Create new day
      final day = domain.Day(id: id);
      await into(days).insert(db.fromDomainDay(day));
      return Either.right(day);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get or create day: $e', stack));
    }
  }

  /// Get today's day
  Future<Result<domain.Day>> getToday() async {
    final today = domain.Day.today();
    return getOrCreateDay(today.id);
  }

  /// Update a day
  Future<Result<domain.Day>> updateDay(domain.Day day) async {
    try {
      final updated = await update(days).replace(db.fromDomainDay(day));
      if (!updated) {
        return Either.left(NotFoundError('Day', day.id));
      }
      return Either.right(day);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to update day: $e', stack));
    }
  }

  /// Set wake time for a day
  Future<Result<domain.Day>> setWakeTime(String dayId, DateTime wakeAt) async {
    try {
      final result = await getDayById(dayId);
      if (result.isLeft) {
        return result;
      }

      final day = result.value.copyWith(wakeAt: wakeAt);
      return updateDay(day);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to set wake time: $e', stack));
    }
  }

  /// Set sleep time for a day
  Future<Result<domain.Day>> setSleepTime(String dayId, DateTime sleepAt) async {
    try {
      final result = await getDayById(dayId);
      if (result.isLeft) {
        return result;
      }

      final day = result.value.copyWith(sleepAt: sleepAt);
      return updateDay(day);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to set sleep time: $e', stack));
    }
  }

  /// Update screen time for a day
  Future<Result<domain.Day>> updateScreenTime(String dayId, int minutes) async {
    try {
      final result = await getDayById(dayId);
      if (result.isLeft) {
        return result;
      }

      final day = result.value.copyWith(screenTimeMinutes: minutes);
      return updateDay(day);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to update screen time: $e', stack));
    }
  }

  /// Get days in a date range
  Future<Result<List<domain.Day>>> getDaysInRange(DateTime start, DateTime end) async {
    try {
      final query = select(days)
        ..where((t) => t.id.isBiggerOrEqualValue(start.toString().substring(0, 10)))
        ..where((t) => t.id.isSmallerOrEqualValue(end.toString().substring(0, 10)))
        ..orderBy([(t) => OrderingTerm.asc(t.id)]);

      final entries = await query.get();
      final domainDays = entries.map((e) => db.toDomainDay(e)).toList();

      return Either.right(domainDays);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get days in range: $e', stack));
    }
  }

  /// Get days for the current week
  Future<Result<List<domain.Day>>> getThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return getDaysInRange(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }

  /// Delete a day
  Future<Result<void>> deleteDay(String id) async {
    try {
      final deleted = await (delete(days)..where((t) => t.id.equals(id))).go();
      if (deleted == 0) {
        return Either.left(NotFoundError('Day', id));
      }
      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to delete day: $e', stack));
    }
  }
}
