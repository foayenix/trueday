/// Day timeline widget showing all blocks
library;

import 'package:flutter/material.dart';
import '../../core/extensions.dart';
import '../../domain/models/block.dart';

/// Timeline visualization of the day's blocks
class DayTimeline extends StatelessWidget {
  final List<Block> blocks;
  final Function(Block block)? onBlockTap;
  final Function(Block block)? onBlockLongPress;

  const DayTimeline({
    super.key,
    required this.blocks,
    this.onBlockTap,
    this.onBlockLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No activities scheduled',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: blocks.map((block) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _TimelineBlock(
                      block: block,
                      onTap: onBlockTap != null ? () => onBlockTap!(block) : null,
                      onLongPress: onBlockLongPress != null
                          ? () => onBlockLongPress!(block)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineBlock extends StatelessWidget {
  final Block block;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _TimelineBlock({
    required this.block,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate height based on duration (1 minute = 2 pixels, min 40px, max 200px)
    final durationMinutes = block.duration.inMinutes;
    final height = (durationMinutes * 2.0).clamp(40.0, 200.0);

    final isActive = block.isActive;
    final isPast = block.isPast;
    final isFuture = block.isFuture;

    Color bgColor = Color(block.category.colour);
    if (isPast) {
      bgColor = bgColor.withOpacity(0.3);
    } else if (isActive) {
      bgColor = bgColor.withOpacity(0.8);
    } else {
      bgColor = bgColor.withOpacity(0.6);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Tooltip(
        message: '${block.title}\n${block.start.displayTime} - ${block.end.displayTime}',
        child: Container(
          width: 120,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? colorScheme.primary : Colors.transparent,
              width: isActive ? 3 : 0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (block.isAnchor)
                      const Icon(
                        Icons.anchor,
                        size: 12,
                        color: Colors.white,
                      ),
                    Flexible(
                      child: Text(
                        block.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.start.displayTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    block.duration.formatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Suggestion banner widget
class SuggestionBanner extends StatelessWidget {
  final String message;
  final List<String> suggestions;
  final VoidCallback? onDismiss;

  const SuggestionBanner({
    super.key,
    required this.message,
    required this.suggestions,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
              ],
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
