/// iOS screen time data source (DeviceActivity)
library;

import '../../core/either.dart';
import '../../core/errors.dart';

/// iOS screen time source using DeviceActivity framework
/// Note: DeviceActivity has significant restrictions and may not be available
/// for all use cases. Apple requires Family Controls entitlement.
class IosScreenTimeSource {
  const IosScreenTimeSource();

  /// Check if DeviceActivity is available
  Future<Result<bool>> isAvailable() async {
    // TODO: Implement using platform channel
    // Check iOS version and entitlement
    return const Either.right(false);
  }

  /// Check if permission is granted
  Future<Result<bool>> hasPermission() async {
    // TODO: Implement authorization check
    // Requires user to grant Family Controls permission
    return const Either.right(false);
  }

  /// Request permission
  Future<Result<void>> requestPermission() async {
    // TODO: Implement using AuthorizationCenter
    // Shows system permission dialog
    return Either.left(
      PermissionError(
        'DeviceActivity requires Family Controls authorization',
        'Family Controls',
      ),
    );
  }

  /// Get screen time for a specific date in minutes
  Future<Result<int>> getScreenTimeForDate(DateTime date) async {
    // TODO: Implement using DeviceActivity API
    // Note: Apple's API has limitations on granularity and access

    // Stub implementation - DeviceActivity may not provide exact daily totals
    // May need to use alternative approach or show "not available" message
    return const Either.right(0);
  }

  /// Get screen time for a date range
  Future<Result<Map<DateTime, int>>> getScreenTimeForRange(
    DateTime start,
    DateTime end,
  ) async {
    // TODO: Implement batch query for date range
    // DeviceActivity API limitations may prevent detailed historical data

    // Stub implementation
    return Either.right({});
  }

  /// Get app usage breakdown for a date
  Future<Result<Map<String, int>>> getAppUsageForDate(DateTime date) async {
    // TODO: Implement app-level breakdown
    // Returns map of bundle ID to usage minutes
    // Note: Apple restricts access to detailed app usage

    // Stub implementation
    return Either.right({});
  }

  /// Show fallback message for unsupported scenarios
  String getFallbackMessage() {
    return 'Screen time tracking on iOS has limitations due to Apple restrictions. '
        'Consider manually tracking or using Screen Time widget in iOS Settings.';
  }
}
