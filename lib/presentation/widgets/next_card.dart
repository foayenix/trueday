/// Next card widget showing upcoming activity
library;

import 'package:flutter/material.dart';
import '../../core/extensions.dart';
import '../../domain/models/block.dart';

/// Card showing the next upcoming activity
class NextCard extends StatelessWidget {
  final Block? nextBlock;
  final VoidCallback? onStart;
  final VoidCallback? onEdit;

  const NextCard({
    super.key,
    this.nextBlock,
    this.onStart,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (nextBlock == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No upcoming activities',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Add an impromptu task or plan your next activity',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final block = nextBlock!;
    final now = DateTime.now();
    final timeUntil = block.start.difference(now);
    final minutesUntil = timeUntil.inMinutes;

    return Card(
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
                  'Next',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Activity title
            Text(
              block.title,
              style: theme.textTheme.headlineMedium?.copyWith(
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

            // Time info
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${block.start.displayTime} - ${block.end.displayTime}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.timelapse,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  block.duration.formatted,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time until start
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: minutesUntil <= 5
                    ? colorScheme.errorContainer
                    : colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                minutesUntil <= 0
                    ? 'Overdue'
                    : minutesUntil == 1
                        ? 'Starting in 1 minute'
                        : minutesUntil < 60
                            ? 'Starting in $minutesUntil minutes'
                            : 'Starting in ${timeUntil.formatted}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: minutesUntil <= 5
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Start button (if close to start time or overdue)
            if (minutesUntil <= 10 && onStart != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
