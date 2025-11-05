/// Core constants for TrueDay application
library;

/// Default duration for impromptu tasks when not specified
const Duration kDefaultTaskDuration = Duration(minutes: 30);

/// Notification timing
const Duration kTransitionNotificationBefore = Duration(minutes: 2);
const Duration kOverrunNotificationAfter = Duration(minutes: 5);

/// Time display formats
const String kTimeFormat24Hour = 'HH:mm';
const String kDateFormat = 'yyyy-MM-dd';
const String kDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
const String kDisplayDateFormat = 'EEE, d MMM yyyy';
const String kDisplayTimeFormat = 'HH:mm';

/// Widget refresh channels
const String kWidgetChannel = 'com.trueday.widget';
const String kWidgetGroupName = 'group.com.trueday.widget';

/// Notification channels
const String kNotificationChannelId = 'trueday_notifications';
const String kNotificationChannelName = 'TrueDay Notifications';
const String kNotificationChannelDescription = 'Gentle nudges for transitions, overruns, and recovery';

/// Deep link actions
const String kDeepLinkStart = 'trueday://action/start';
const String kDeepLinkStop = 'trueday://action/stop';
const String kDeepLinkSwitch = 'trueday://action/switch';
const String kDeepLinkAddFiveMinutes = 'trueday://action/add_five';

/// Database
const String kDatabaseName = 'trueday.db';
const int kDatabaseVersion = 1;

/// Categories with default colours
enum CategoryType {
  work,
  family,
  sleep,
  health,
  travel,
  study,
  sideHustle,
  admin,
  other;

  String get displayName {
    switch (this) {
      case CategoryType.work:
        return 'Work';
      case CategoryType.family:
        return 'Family';
      case CategoryType.sleep:
        return 'Sleep';
      case CategoryType.health:
        return 'Health';
      case CategoryType.travel:
        return 'Travel';
      case CategoryType.study:
        return 'Study';
      case CategoryType.sideHustle:
        return 'Side Hustle';
      case CategoryType.admin:
        return 'Admin';
      case CategoryType.other:
        return 'Other';
    }
  }

  int get colour {
    switch (this) {
      case CategoryType.work:
        return 0xFF2196F3; // Blue
      case CategoryType.family:
        return 0xFFE91E63; // Pink
      case CategoryType.sleep:
        return 0xFF9C27B0; // Purple
      case CategoryType.health:
        return 0xFF4CAF50; // Green
      case CategoryType.travel:
        return 0xFFFF9800; // Orange
      case CategoryType.study:
        return 0xFF00BCD4; // Cyan
      case CategoryType.sideHustle:
        return 0xFFFFEB3B; // Yellow
      case CategoryType.admin:
        return 0xFF795548; // Brown
      case CategoryType.other:
        return 0xFF9E9E9E; // Grey
    }
  }

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategoryType.other,
    );
  }
}
