/// Now card widget showing current activity
library;

import 'package:flutter/material.dart';
import '../../core/extensions.dart';
import '../../core/time.dart';
import '../../domain/models/block.dart';

/// Card showing the current activity
class NowCard extends StatefulWidget {
  final Block? currentBlock;
  final VoidCallback? onStop;
  final VoidCallback? onSwitch;
  final VoidCallback? onAddFive;

  const NowCard({
    super.key,
    this.currentBlock,
    this.onStop,
    this.onSwitch,
    this.onAddFive,
  });

  @override
  State<NowCard> createState() => _NowCardState();
}

class _NowCardState extends State<NowCard> {
  late Stream<Duration> _elapsedStream;

  @override
  void initState() {
    super.initState();
    _setupElapsedStream();
  }

  @override
  void didUpdateWidget(NowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentBlock?.id != widget.currentBlock?.id) {
      _setupElapsedStream();
    }
  }

  void _setupElapsedStream() {
    _elapsedStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => widget.currentBlock != null
          ? timeUtils.elapsed(widget.currentBlock!.start)
          : Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.currentBlock == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Now',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No activity in progress',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap "Start Next" or add an impromptu task',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final block = widget.currentBlock!;
    final isOverrunning = block.isOverrunning;
    final statusColor = isOverrunning ? colorScheme.error : colorScheme.primary;

    return Card(
      color: colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Now',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Chip(
                  label: Text(
                    isOverrunning ? 'Overrunning' : 'On track',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: statusColor.withOpacity(0.1),
                  side: BorderSide(color: statusColor, width: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Activity title
            Text(
              block.title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Category chip
            Chip(
              label: Text(block.category.displayName),
              backgroundColor: Color(block.category.colour).withOpacity(0.2),
              avatar: Icon(
                Icons.circle,
                size: 12,
                color: Color(block.category.colour),
              ),
            ),
            const SizedBox(height: 16),

            // Elapsed timer
            StreamBuilder<Duration>(
              stream: _elapsedStream,
              initialData: timeUtils.elapsed(block.start),
              builder: (context, snapshot) {
                final elapsed = snapshot.data ?? Duration.zero;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Since ${block.start.displayTime}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeUtils.formatElapsed(elapsed),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),

            // Planned end time
            Text(
              'Planned end: ${block.end.displayTime}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onStop,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
                OutlinedButton.icon(
                  onPressed: widget.onSwitch,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Switch'),
                ),
                TextButton.icon(
                  onPressed: widget.onAddFive,
                  icon: const Icon(Icons.add),
                  label: const Text('+5m'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
