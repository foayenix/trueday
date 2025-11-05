/// Block DAO (Data Access Object)
library;

import 'package:drift/drift.dart';
import '../../core/either.dart';
import '../../core/errors.dart';
import '../../domain/models/block.dart' as domain;
import 'schema.dart';

part 'dao_block.g.dart';

/// Block Data Access Object
@DriftAccessor(tables: [Blocks])
class BlockDao extends DatabaseAccessor<AppDatabase> with _$BlockDaoMixin {
  BlockDao(super.db);

  /// Get a block by ID
  Future<Result<domain.Block>> getBlockById(String id) async {
    try {
      final query = select(blocks)..where((t) => t.id.equals(id));
      final entry = await query.getSingleOrNull();

      if (entry == null) {
        return Either.left(NotFoundError('Block', id));
      }

      return Either.right(db.toDomainBlock(entry));
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get block: $e', stack));
    }
  }

  /// Get all blocks for a day
  Future<Result<List<domain.Block>>> getBlocksForDay(String dayId) async {
    try {
      final query = select(blocks)
        ..where((t) => t.dayId.equals(dayId))
        ..orderBy([(t) => OrderingTerm.asc(t.start)]);

      final entries = await query.get();
      final domainBlocks = entries.map((e) => db.toDomainBlock(e)).toList();

      return Either.right(domainBlocks);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get blocks for day: $e', stack));
    }
  }

  /// Get blocks overlapping a time range
  Future<Result<List<domain.Block>>> getBlocksInRange(
    String dayId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final query = select(blocks)
        ..where((t) => t.dayId.equals(dayId))
        ..where((t) => t.start.isSmallerThanValue(end))
        ..where((t) => t.end.isBiggerThanValue(start))
        ..orderBy([(t) => OrderingTerm.asc(t.start)]);

      final entries = await query.get();
      final domainBlocks = entries.map((e) => db.toDomainBlock(e)).toList();

      return Either.right(domainBlocks);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get blocks in range: $e', stack));
    }
  }

  /// Get anchor blocks for a day
  Future<Result<List<domain.Block>>> getAnchorsForDay(String dayId) async {
    try {
      final query = select(blocks)
        ..where((t) => t.dayId.equals(dayId))
        ..where((t) => t.isAnchor.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.start)]);

      final entries = await query.get();
      final domainBlocks = entries.map((e) => db.toDomainBlock(e)).toList();

      return Either.right(domainBlocks);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get anchors: $e', stack));
    }
  }

  /// Get child blocks (sub-blocks) of a parent
  Future<Result<List<domain.Block>>> getChildBlocks(String parentId) async {
    try {
      final query = select(blocks)
        ..where((t) => t.parentId.equals(parentId))
        ..orderBy([(t) => OrderingTerm.asc(t.start)]);

      final entries = await query.get();
      final domainBlocks = entries.map((e) => db.toDomainBlock(e)).toList();

      return Either.right(domainBlocks);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get child blocks: $e', stack));
    }
  }

  /// Insert a new block
  Future<Result<domain.Block>> insertBlock(domain.Block block) async {
    try {
      await into(blocks).insert(db.fromDomainBlock(block));
      return Either.right(block);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to insert block: $e', stack));
    }
  }

  /// Update a block
  Future<Result<domain.Block>> updateBlock(domain.Block block) async {
    try {
      final updated = await update(blocks).replace(db.fromDomainBlock(block));
      if (!updated) {
        return Either.left(NotFoundError('Block', block.id));
      }
      return Either.right(block);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to update block: $e', stack));
    }
  }

  /// Delete a block
  Future<Result<void>> deleteBlock(String id) async {
    try {
      final deleted = await (delete(blocks)..where((t) => t.id.equals(id))).go();
      if (deleted == 0) {
        return Either.left(NotFoundError('Block', id));
      }
      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to delete block: $e', stack));
    }
  }

  /// Delete all blocks for a day
  Future<Result<int>> deleteBlocksForDay(String dayId) async {
    try {
      final deleted = await (delete(blocks)..where((t) => t.dayId.equals(dayId))).go();
      return Either.right(deleted);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to delete blocks for day: $e', stack));
    }
  }

  /// Insert multiple blocks in a transaction
  Future<Result<List<domain.Block>>> insertBlocks(List<domain.Block> blockList) async {
    try {
      await db.transaction(() async {
        for (final block in blockList) {
          await into(blocks).insert(db.fromDomainBlock(block));
        }
      });
      return Either.right(blockList);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to insert blocks: $e', stack));
    }
  }

  /// Update multiple blocks in a transaction
  Future<Result<List<domain.Block>>> updateBlocks(List<domain.Block> blockList) async {
    try {
      await db.transaction(() async {
        for (final block in blockList) {
          await update(blocks).replace(db.fromDomainBlock(block));
        }
      });
      return Either.right(blockList);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to update blocks: $e', stack));
    }
  }

  /// Get the current active block (if any)
  Future<Result<domain.Block?>> getCurrentBlock(String dayId) async {
    try {
      final now = DateTime.now();
      final query = select(blocks)
        ..where((t) => t.dayId.equals(dayId))
        ..where((t) => t.start.isSmallerOrEqualValue(now))
        ..where((t) => t.end.isBiggerOrEqualValue(now))
        ..orderBy([(t) => OrderingTerm.asc(t.start)])
        ..limit(1);

      final entry = await query.getSingleOrNull();

      if (entry == null) {
        return const Either.right(null);
      }

      return Either.right(db.toDomainBlock(entry));
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get current block: $e', stack));
    }
  }

  /// Get the next upcoming block (if any)
  Future<Result<domain.Block?>> getNextBlock(String dayId) async {
    try {
      final now = DateTime.now();
      final query = select(blocks)
        ..where((t) => t.dayId.equals(dayId))
        ..where((t) => t.start.isBiggerThanValue(now))
        ..orderBy([(t) => OrderingTerm.asc(t.start)])
        ..limit(1);

      final entry = await query.getSingleOrNull();

      if (entry == null) {
        return const Either.right(null);
      }

      return Either.right(db.toDomainBlock(entry));
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to get next block: $e', stack));
    }
  }

  /// Batch operation: delete multiple blocks and insert/update others
  Future<Result<void>> batchUpdateBlocks({
    List<String>? deleteIds,
    List<domain.Block>? insertList,
    List<domain.Block>? updateList,
  }) async {
    try {
      await db.transaction(() async {
        // Delete blocks
        if (deleteIds != null && deleteIds.isNotEmpty) {
          for (final id in deleteIds) {
            await (delete(blocks)..where((t) => t.id.equals(id))).go();
          }
        }

        // Insert new blocks
        if (insertList != null && insertList.isNotEmpty) {
          for (final block in insertList) {
            await into(blocks).insert(db.fromDomainBlock(block));
          }
        }

        // Update existing blocks
        if (updateList != null && updateList.isNotEmpty) {
          for (final block in updateList) {
            await update(blocks).replace(db.fromDomainBlock(block));
          }
        }
      });

      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(DatabaseError('Failed to batch update blocks: $e', stack));
    }
  }
}
