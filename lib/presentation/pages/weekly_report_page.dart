/// Weekly report page
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/extensions.dart';
import '../providers.dart';

/// Weekly report page showing aggregated statistics
class WeeklyReportPage extends ConsumerWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekSummaryAsync = ref.watch(weekSummaryProvider);
    final summariesService = ref.watch(summariesServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Report'),
      ),
      body: weekSummaryAsync.when(
        data: (summary) {
          final insights = summariesService.getWeekInsights(summary);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week of ${summary.weekStart.displayDate}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(
                        label: 'Total scheduled',
                        value: summary.totalScheduled.formatted,
                        icon: Icons.schedule,
                      ),
                      _SummaryRow(
                        label: 'Days tracked',
                        value: '${summary.dayCount}',
                        icon: Icons.calendar_today,
                      ),
                      _SummaryRow(
                        label: 'Total activities',
                        value: '${summary.totalBlocks}',
                        icon: Icons.list,
                      ),
                      if (summary.totalScreenTimeMinutes > 0)
                        _SummaryRow(
                          label: 'Screen time',
                          value: '${(summary.totalScreenTimeMinutes / 60).toStringAsFixed(1)}h',
                          icon: Icons.phone_android,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time by Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...summary.categoryBreakdown.map((cat) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: Color(cat.category.colour),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          cat.category.displayName,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      cat.totalDuration.formatted,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: cat.percentage / 100,
                                        backgroundColor: Colors.grey.withOpacity(0.2),
                                        color: Color(cat.category.colour),
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${cat.percentage.toStringAsFixed(0)}%',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Insights
              if (insights.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insights',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...insights.map((insight) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      insight,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Daily breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Breakdown',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...summary.days.map((day) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                child: Text(day.day.date.day.toString()),
                              ),
                              title: Text(day.day.date.displayDate),
                              subtitle: Text(
                                '${day.blockCount} activities • ${day.totalScheduled.formatted}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // TODO: Navigate to day details
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error loading report: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
