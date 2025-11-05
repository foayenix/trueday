/// Today page - main page of the app
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers.dart';
import '../router.dart';
import '../widgets/day_timeline.dart';
import '../widgets/impromptu_composer.dart';
import '../widgets/next_card.dart';
import '../widgets/now_card.dart';

/// Today page showing current and next activities
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBlockAsync = ref.watch(currentBlockProvider);
    final nextBlockAsync = ref.watch(nextBlockProvider);
    final todayBlocksAsync = ref.watch(todayBlocksProvider);
    final addImpromptuState = ref.watch(addImpromptuProvider);
    final blockActions = ref.watch(blockActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueDay'),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.weekly),
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Weekly Report',
          ),
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentBlockProvider);
          ref.invalidate(nextBlockProvider);
          ref.invalidate(todayBlocksProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Now card
            currentBlockAsync.when(
              data: (currentBlock) => NowCard(
                currentBlock: currentBlock,
                onStop: currentBlock != null
                    ? () => blockActions.stopBlock(currentBlock)
                    : null,
                onSwitch: currentBlock != null
                    ? () => _showSwitchDialog(context, ref)
                    : null,
                onAddFive: currentBlock != null
                    ? () => blockActions.extendBlock(
                          currentBlock,
                          const Duration(minutes: 5),
                        )
                    : null,
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Next card
            nextBlockAsync.when(
              data: (nextBlock) => NextCard(
                nextBlock: nextBlock,
                onStart: nextBlock != null
                    ? () => blockActions.startBlock(nextBlock)
                    : null,
                onEdit: nextBlock != null
                    ? () => _showEditDialog(context, ref, nextBlock)
                    : null,
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Impromptu composer
            addImpromptuState.when(
              data: (_) => ImpromptuComposer(
                onSubmit: (input) {
                  ref.read(addImpromptuProvider.notifier).addImpromptu(input);
                },
              ),
              loading: () => ImpromptuComposer(
                onSubmit: (_) {},
                isLoading: true,
              ),
              error: (error, stack) => Column(
                children: [
                  ImpromptuComposer(
                    onSubmit: (input) {
                      ref.read(addImpromptuProvider.notifier).addImpromptu(input);
                    },
                  ),
                  const SizedBox(height: 8),
                  SuggestionBanner(
                    message: 'Failed to add task',
                    suggestions: [error.toString()],
                    onDismiss: () {
                      ref.read(addImpromptuProvider.notifier).state =
                          const AsyncValue.data(null);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timeline
            todayBlocksAsync.when(
              data: (blocks) => DayTimeline(
                blocks: blocks,
                onBlockTap: (block) => _showBlockDetails(context, ref, block),
                onBlockLongPress: (block) => _showBlockContextMenu(context, ref, block),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Footer actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showStartNextDialog(context, ref),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Next'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showFinishDayDialog(context, ref),
                      icon: const Icon(Icons.bedtime),
                      label: const Text('Finish Day'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSwitchDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement switch activity dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Switch activity (not implemented)')),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, block) {
    // TODO: Implement edit block dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit block (not implemented)')),
    );
  }

  void _showBlockDetails(BuildContext context, WidgetRef ref, block) {
    // TODO: Implement block details bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Block: ${block.title}')),
    );
  }

  void _showBlockContextMenu(BuildContext context, WidgetRef ref, block) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, ref, block);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                ref.read(blockActionsProvider).deleteBlock(block);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartNextDialog(BuildContext context, WidgetRef ref) {
    final nextBlockAsync = ref.read(nextBlockProvider);
    nextBlockAsync.whenData((nextBlock) {
      if (nextBlock != null) {
        ref.read(blockActionsProvider).startBlock(nextBlock);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Started: ${nextBlock.title}')),
        );
      }
    });
  }

  void _showFinishDayDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement finish day (set sleep time)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finish day (not implemented)')),
    );
  }
}
