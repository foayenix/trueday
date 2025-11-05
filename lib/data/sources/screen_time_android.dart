/// Android screen time data source (UsageStats)
library;

import '../../core/either.dart';
import '../../core/errors.dart';

/// Android screen time source using UsageStats API
class AndroidScreenTimeSource {
  const AndroidScreenTimeSource();

  /// Check if permission is granted
  Future<Result<bool>> hasPermission() async {
    // TODO: Implement using permission_handler or platform channel
    // Requires PACKAGE_USAGE_STATS permission
    return const Either.right(false);
  }

  /// Request permission (opens settings)
  Future<Result<void>> requestPermission() async {
    // TODO: Implement - open settings to grant PACKAGE_USAGE_STATS
    // This requires opening Android Settings > Special app access > Usage access
    return Either.left(
      PermissionError(
        'PACKAGE_USAGE_STATS permission requires manual grant in Settings',
        'PACKAGE_USAGE_STATS',
      ),
    );
  }

  /// Get screen time for a specific date in minutes
  Future<Result<int>> getScreenTimeForDate(DateTime date) async {
    // TODO: Implement using platform channel to query UsageStats
    // Query events from start of day to end of day
    // Calculate total screen-on time

    // Stub implementation
    return const Either.right(0);
  }

  /// Get screen time for a date range
  Future<Result<Map<DateTime, int>>> getScreenTimeForRange(
    DateTime start,
    DateTime end,
  ) async {
    // TODO: Implement batch query for date range
    // More efficient than querying each day individually

    // Stub implementation
    return Either.right({});
  }

  /// Get app usage breakdown for a date
  Future<Result<Map<String, int>>> getAppUsageForDate(DateTime date) async {
    // TODO: Implement app-level breakdown
    // Returns map of package name to usage minutes

    // Stub implementation
    return Either.right({});
  }
}
