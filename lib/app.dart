/// Main app widget
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'presentation/router.dart';
import 'presentation/theme.dart';

/// TrueDay app root widget
class TrueDayApp extends ConsumerStatefulWidget {
  const TrueDayApp({super.key});

  @override
  ConsumerState<TrueDayApp> createState() => _TrueDayAppState();
}

class _TrueDayAppState extends ConsumerState<TrueDayApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize notifications
    // final notificationsService = ref.read(notificationsServiceProvider);
    // await notificationsService.initialize();

    // Request notification permissions
    // await notificationsService.requestPermissions();

    // Initialize widget integration
    // AndroidHomeWidget.registerCallbacks((uri) {
    //   // Handle widget taps
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrueDay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
