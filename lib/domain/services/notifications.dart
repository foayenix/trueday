/// Notifications service for TrueDay
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/constants.dart';
import '../../core/either.dart';
import '../../core/errors.dart';
import '../../core/extensions.dart';
import '../models/block.dart';

/// Notification types
enum NotificationType {
  transition, // Nudge before next activity
  overrun, // Activity running past end time
  recovery, // Missed start time
}

/// Notifications service
class NotificationsService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  NotificationsService(this._plugin);

  /// Initialize the notifications service
  Future<Result<void>> initialize() async {
    try {
      if (_initialized) {
        return const Either.right(null);
      }

      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          // Handle iOS foreground notification
        },
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final result = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (result == null || !result) {
        return Either.left(
          UnknownError('Failed to initialize notifications'),
        );
      }

      // Create notification channel for Android
      await _createNotificationChannel();

      _initialized = true;
      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(UnknownError('Notification initialization failed: $e', e, stack));
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      kNotificationChannelId,
      kNotificationChannelName,
      description: kNotificationChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle deep link navigation based on payload
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen
      // This will be handled by the app's navigation system
    }
  }

  /// Request notification permissions (iOS)
  Future<Result<bool>> requestPermissions() async {
    try {
      final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return Either.right(granted ?? false);
      }

      // Android doesn't need runtime permission for notifications (below Android 13)
      return const Either.right(true);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to request permissions: $e', e, stack));
    }
  }

  /// Schedule a transition notification (before next activity)
  Future<Result<void>> scheduleTransitionNotification(Block nextBlock) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final notificationTime = nextBlock.start.subtract(kTransitionNotificationBefore);

      // Don't schedule if in the past
      if (notificationTime.isBefore(DateTime.now())) {
        return const Either.right(null);
      }

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          kNotificationChannelId,
          kNotificationChannelName,
          channelDescription: kNotificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _plugin.zonedSchedule(
        nextBlock.hashCode, // Use block hash as ID
        'Upcoming: ${nextBlock.title}',
        'Starting in 2 minutes at ${nextBlock.start.displayTime}',
        _toTZDateTime(notificationTime),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'transition:${nextBlock.id}',
      );

      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to schedule transition notification: $e', e, stack));
    }
  }

  /// Schedule an overrun notification (after activity should have ended)
  Future<Result<void>> scheduleOverrunNotification(Block currentBlock) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final notificationTime = currentBlock.end.add(kOverrunNotificationAfter);

      // Don't schedule if in the past
      if (notificationTime.isBefore(DateTime.now())) {
        return const Either.right(null);
      }

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          kNotificationChannelId,
          kNotificationChannelName,
          channelDescription: kNotificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _plugin.zonedSchedule(
        currentBlock.hashCode + 1000000, // Offset to avoid ID collision
        'Overrunning: ${currentBlock.title}',
        'Planned to end at ${currentBlock.end.displayTime}',
        _toTZDateTime(notificationTime),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'overrun:${currentBlock.id}',
      );

      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to schedule overrun notification: $e', e, stack));
    }
  }

  /// Show a recovery notification (missed start)
  Future<Result<void>> showRecoveryNotification(Block missedBlock) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          kNotificationChannelId,
          kNotificationChannelName,
          channelDescription: kNotificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _plugin.show(
        missedBlock.hashCode + 2000000, // Offset to avoid ID collision
        'Missed: ${missedBlock.title}',
        'Planned at ${missedBlock.start.displayTime}. Start now or reschedule?',
        notificationDetails,
        payload: 'recovery:${missedBlock.id}',
      );

      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to show recovery notification: $e', e, stack));
    }
  }

  /// Cancel a specific notification
  Future<Result<void>> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to cancel notification: $e', e, stack));
    }
  }

  /// Cancel all notifications for a block
  Future<Result<void>> cancelBlockNotifications(Block block) async {
    try {
      await _plugin.cancel(block.hashCode);
      await _plugin.cancel(block.hashCode + 1000000);
      await _plugin.cancel(block.hashCode + 2000000);
      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to cancel block notifications: $e', e, stack));
    }
  }

  /// Cancel all notifications
  Future<Result<void>> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to cancel all notifications: $e', e, stack));
    }
  }

  /// Get pending notifications
  Future<Result<List<PendingNotificationRequest>>> getPendingNotifications() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return Either.right(pending);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to get pending notifications: $e', e, stack));
    }
  }

  /// Schedule notifications for a list of blocks
  Future<Result<void>> scheduleBlockNotifications(List<Block> blocks) async {
    try {
      final now = DateTime.now();

      for (final block in blocks) {
        // Schedule transition notification if block is upcoming
        if (block.isFuture) {
          await scheduleTransitionNotification(block);
        }

        // Schedule overrun notification if block is active
        if (block.isActive) {
          await scheduleOverrunNotification(block);
        }
      }

      return const Either.right(null);
    } catch (e, stack) {
      return Either.left(UnknownError('Failed to schedule block notifications: $e', e, stack));
    }
  }

  /// Convert DateTime to TZDateTime (for scheduling)
  /// Note: In production, use proper timezone package
  TZDateTime _toTZDateTime(DateTime dateTime) {
    // For now, we'll use local time
    // In production, implement proper timezone conversion
    final location = getLocation('UTC'); // Placeholder
    return TZDateTime.from(dateTime, location);
  }
}

// Stub for timezone location (would use actual timezone package in production)
dynamic getLocation(String name) {
  // This is a placeholder - in production use proper timezone package
  return null;
}

class TZDateTime extends DateTime {
  TZDateTime.from(DateTime dateTime, dynamic location)
      : super(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
          dateTime.millisecond,
          dateTime.microsecond,
        );
}
