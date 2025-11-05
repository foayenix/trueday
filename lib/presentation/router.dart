/// App router configuration using go_router
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/today_page.dart';
import 'pages/weekly_report_page.dart';
import 'pages/settings_page.dart';

/// Route paths
class Routes {
  static const today = '/';
  static const weekly = '/weekly';
  static const settings = '/settings';
}

/// App router
final appRouter = GoRouter(
  initialLocation: Routes.today,
  routes: [
    GoRoute(
      path: Routes.today,
      name: 'today',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const TodayPage(),
      ),
    ),
    GoRoute(
      path: Routes.weekly,
      name: 'weekly',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const WeeklyReportPage(),
      ),
    ),
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const SettingsPage(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text('Page not found: ${state.uri}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(Routes.today),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
