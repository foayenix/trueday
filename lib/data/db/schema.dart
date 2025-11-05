/// Drift database schema for TrueDay
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../core/constants.dart';
import '../../domain/models/block.dart' as domain;
import '../../domain/models/day.dart' as domain;
import 'dart:io';

part 'schema.g.dart';

/// Days table
@DataClassName('DayEntry')
class Days extends Table {
  /// Primary key - ISO date string (yyyy-MM-dd)
  TextColumn get id => text()();

  /// When the user woke up
  DateTimeColumn get wakeAt => dateTime().nullable()();

  /// When the user went to sleep
  DateTimeColumn get sleepAt => dateTime().nullable()();

  /// Screen time in minutes for this day
  IntColumn get screenTimeMinutes => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Blocks table
@DataClassName('BlockEntry')
class Blocks extends Table {
  /// Primary key - UUID
  TextColumn get id => text()();

  /// Foreign key to Days table
  TextColumn get dayId => text().references(Days, #id, onDelete: KeyAction.cascade)();

  /// Title of the block
  TextColumn get title => text()();

  /// Category (stored as enum name)
  TextColumn get category => text()();

  /// Start time
  DateTimeColumn get start => dateTime()();

  /// End time
  DateTimeColumn get end => dateTime()();

  /// Whether this block is an anchor (doesn't move during reflow)
  BoolColumn get isAnchor => boolean().withDefault(const Constant(false))();

  /// Parent block ID (for sub-blocks)
  TextColumn get parentId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Main database class
@DriftDatabase(tables: [Days, Blocks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations will go here
      },
    );
  }

  /// Convert DayEntry to domain Day
  domain.Day toDomainDay(DayEntry entry) {
    return domain.Day(
      id: entry.id,
      wakeAt: entry.wakeAt,
      sleepAt: entry.sleepAt,
      screenTimeMinutes: entry.screenTimeMinutes,
    );
  }

  /// Convert domain Day to DaysCompanion
  DaysCompanion fromDomainDay(domain.Day day) {
    return DaysCompanion.insert(
      id: day.id,
      wakeAt: Value(day.wakeAt),
      sleepAt: Value(day.sleepAt),
      screenTimeMinutes: Value(day.screenTimeMinutes),
    );
  }

  /// Convert BlockEntry to domain Block
  domain.Block toDomainBlock(BlockEntry entry) {
    return domain.Block(
      id: entry.id,
      dayId: entry.dayId,
      title: entry.title,
      category: CategoryType.fromString(entry.category),
      start: entry.start,
      end: entry.end,
      isAnchor: entry.isAnchor,
      parentId: entry.parentId,
    );
  }

  /// Convert domain Block to BlocksCompanion
  BlocksCompanion fromDomainBlock(domain.Block block) {
    return BlocksCompanion.insert(
      id: block.id,
      dayId: block.dayId,
      title: block.title,
      category: block.category.name,
      start: block.start,
      end: block.end,
      isAnchor: Value(block.isAnchor),
      parentId: Value(block.parentId),
    );
  }
}

/// Open database connection
QueryExecutor _openConnection() {
  return driftDatabase(name: kDatabaseName);
}
