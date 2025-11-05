/// Impromptu task composer widget
library;

import 'package:flutter/material.dart';

/// Widget for composing impromptu tasks
class ImpromptuComposer extends StatefulWidget {
  final Function(String input) onSubmit;
  final bool isLoading;

  const ImpromptuComposer({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ImpromptuComposer> createState() => _ImpromptuComposerState();
}

class _ImpromptuComposerState extends State<ImpromptuComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showExamples = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    widget.onSubmit(input);
    _controller.clear();
    _focusNode.unfocus();
  }

  void _insertExample(String example) {
    _controller.text = example;
    _focusNode.requestFocus();
    // Move cursor to end
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Impromptu Task',
                  style: theme.textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showExamples = !_showExamples;
                    });
                  },
                  icon: Icon(
                    _showExamples ? Icons.expand_less : Icons.help_outline,
                  ),
                  tooltip: 'Show examples',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Text field
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !widget.isLoading,
              decoration: InputDecoration(
                hintText: 'e.g., Meeting 10:00 30m',
                suffixIcon: widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _handleSubmit,
                        icon: const Icon(Icons.add_circle),
                        tooltip: 'Add task',
                      ),
              ),
              onSubmitted: (_) => _handleSubmit(),
              textInputAction: TextInputAction.done,
            ),

            // Examples
            if (_showExamples) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Examples:',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ExampleChip(
                      label: 'Meeting 10:00 30m',
                      description: 'At specific time with duration',
                      onTap: () => _insertExample('Meeting 10:00 30m'),
                    ),
                    const SizedBox(height: 4),
                    _ExampleChip(
                      label: 'Call now 15m',
                      description: 'Start immediately',
                      onTap: () => _insertExample('Call now 15m'),
                    ),
                    const SizedBox(height: 4),
                    _ExampleChip(
                      label: 'Lunch 12:30',
                      description: 'Default 30m duration',
                      onTap: () => _insertExample('Lunch 12:30'),
                    ),
                    const SizedBox(height: 4),
                    _ExampleChip(
                      label: 'Exercise for 1h',
                      description: 'Start now, custom duration',
                      onTap: () => _insertExample('Exercise for 1h'),
                    ),
                    const SizedBox(height: 4),
                    _ExampleChip(
                      label: 'Review 14:00 1h30m',
                      description: 'Hours and minutes',
                      onTap: () => _insertExample('Review 14:00 1h30m'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Format: <title> [at HH:MM|now] [for Xm|Xh|XhYm]',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ExampleChip({
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(
              Icons.touch_app,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
