/// TrueDay - Manual lock-screen accountability tracker
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app
  runApp(
    const ProviderScope(
      child: TrueDayApp(),
    ),
  );
}
