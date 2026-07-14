# TrueDay

**Manual lock-screen accountability tracker MVP**

TrueDay is a Flutter-based time tracking and accountability app that helps you stay on track with your daily schedule through gentle notifications and lock-screen widgets.

## Features

- ✅ **Manual Activity Tracking**: Check in/out of activities manually
- ✅ **Lock Screen Widgets**: View current and next activities on your home/lock screen
- ✅ **Impromptu Task Entry**: Quick text-based task insertion (e.g., "Meeting 10:00 30m")
- ✅ **Smart Reflow**: Intelligent schedule adjustment with anchor blocks
- ✅ **Daily Summary**: End-of-day activity breakdown
- ✅ **Weekly Report**: Aggregated statistics and insights
- ✅ **Gentle Notifications**: Transition nudges, overrun alerts, and recovery suggestions
- 🚧 **Screen Time Import**: Optional integration with device screen time (Android/iOS)

## Tech Stack

- **Flutter**: 3.x with null-safety
- **State Management**: Riverpod (hooks_riverpod)
- **Routing**: go_router
- **Local Database**: Drift (SQLite)
- **Notifications**: flutter_local_notifications
- **Home Widgets**: home_widget (Android & iOS)
- **Time Utils**: intl, timezone, clock
- **Testing**: flutter_test, mocktail

## Project Structure

```
lib/
├── app.dart                    # App root widget
├── main.dart                   # Entry point
├── core/                       # Core utilities
│   ├── constants.dart          # App constants and enums
│   ├── either.dart             # Functional Either type
│   ├── errors.dart             # Error types
│   ├── extensions.dart         # Dart extensions
│   └── time.dart               # Time utilities
├── data/                       # Data layer
│   ├── db/                     # Drift database
│   │   ├── schema.dart         # Database schema
│   │   ├── dao_day.dart        # Day DAO
│   │   └── dao_block.dart      # Block DAO
│   └── sources/                # Data sources
│       ├── screen_time_android.dart
│       └── screen_time_ios.dart
├── domain/                     # Business logic
│   ├── models/                 # Domain models
│   │   ├── day.dart
│   │   ├── block.dart
│   │   └── category.dart
│   └── services/               # Services
│       ├── parser.dart         # Impromptu task parser
│       ├── schedule_engine.dart # Reflow logic
│       ├── summaries.dart      # Summary generation
│       └── notifications.dart  # Notification handling
├── presentation/               # UI layer
│   ├── theme.dart              # App theme
│   ├── router.dart             # Navigation
│   ├── providers.dart          # Riverpod providers
│   ├── pages/                  # Screens
│   │   ├── today_page.dart
│   │   ├── weekly_report_page.dart
│   │   └── settings_page.dart
│   └── widgets/                # Reusable widgets
│       ├── now_card.dart
│       ├── next_card.dart
│       ├── impromptu_composer.dart
│       └── day_timeline.dart
└── widgets_integration/        # Widget integrations
    ├── android_homewidget.dart
    └── ios_widgetkit.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Dart SDK 3.x or later
- Android Studio / Xcode (for platform builds)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd trueday
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code** (for Drift and other code generation):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android
   ```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/domain/parser_test.dart

# Run with coverage
flutter test --coverage
```

## Configuration

### Android Setup

#### Notifications

No special permissions required for basic notifications (pre-Android 13).

For Android 13+, the app will request `POST_NOTIFICATIONS` permission at runtime.

#### Screen Time (Optional)

To enable screen time tracking on Android:

1. Add to `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
       tools:ignore="ProtectedPermissions"/>
   ```

2. Guide users to: **Settings → Apps → Special app access → Usage access** → Enable for TrueDay

#### Home Widget

The Android home widget is configured via `home_widget` package. Widget layout should be defined in:
- `android/app/src/main/res/layout/trueday_widget.xml`
- `android/app/src/main/res/xml/trueday_widget_info.xml`

Example widget configuration:

**res/xml/trueday_widget_info.xml**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="180dp"
    android:minHeight="120dp"
    android:updatePeriodMillis="1800000"
    android:initialLayout="@layout/trueday_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen">
</appwidget-provider>
```

**res/layout/trueday_widget.xml**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="8dp"
    android:background="@android:color/white">

    <TextView
        android:id="@+id/widget_current_title"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Now: --"
        android:textSize="16sp"
        android:textStyle="bold"/>

    <TextView
        android:id="@+id/widget_next_title"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Next: --"
        android:textSize="14sp"/>

</LinearLayout>
```

### iOS Setup

#### Notifications

Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

#### WidgetKit (Optional)

To add a home screen widget on iOS:

1. In Xcode, **File → New → Target → Widget Extension**
2. Name it `TrueDayWidget`
3. Add App Groups capability to both the main app and widget:
   - **Signing & Capabilities → + Capability → App Groups**
   - Use group ID: `group.com.trueday.widget`
4. Implement widget using SwiftUI (see `lib/widgets_integration/ios_widgetkit.dart` for example)

#### DeviceActivity (Screen Time) - Optional

Screen time tracking on iOS requires:

1. Add **Family Controls** capability in Xcode
2. Request authorization in code
3. Note: Apple has significant restrictions on this API

**For MVP, iOS screen time is stubbed with fallback message.**

## Usage

### Daily Workflow

1. **Start your day**: Tap "Awake" to mark wake time
2. **Track activities**:
   - Current activity shows in the "Now" card
   - Use "Stop" to end current activity
   - Use "Start Next" to begin the next planned activity
3. **Add impromptu tasks**:
   ```
   Meeting 10:00 30m
   Call now 15m
   Lunch 12:30
   Exercise for 1h
   ```
4. **End your day**: Tap "Finish Day" to set sleep time

### Impromptu Task Format

```
<title> [at HH:MM|now] [for Xm|Xh|XhYm]
```

**Examples**:
- `Meeting 10:00 30m` → Meeting at 10:00 for 30 minutes
- `Call now 15m` → Call starting now for 15 minutes
- `Lunch 12:30` → Lunch at 12:30 (default 30m)
- `Exercise for 1h` → Exercise starting now for 1 hour
- `Review 14:00 1h30m` → Review at 14:00 for 1.5 hours

### Anchor Blocks

Mark important, immovable blocks (like Sleep, Commute, Fixed Meetings) as "anchors" in Settings. During reflow:
- **Anchors don't move**
- New tasks inside an anchor become sub-blocks
- Flexible blocks are pushed around anchors

## Notifications

TrueDay sends gentle reminders:

- **Transition nudge**: 2 minutes before next activity
- **Overrun alert**: 5 minutes past scheduled end time
- **Recovery suggestion**: When planned start time passes without check-in

Configure these in **Settings → Notifications**.

## Architecture

### Clean Architecture

The app follows clean architecture principles:

1. **Presentation** (UI) → Uses Riverpod for state management
2. **Domain** (Business Logic) → Pure Dart, no Flutter dependencies
3. **Data** (Persistence) → Drift for local SQLite database

### State Management

- **Riverpod providers** in `presentation/providers.dart`
- **FutureProvider** for async data
- **StateNotifierProvider** for actions (e.g., adding impromptu tasks)

### Error Handling

- Functional `Either<Error, Value>` type for explicit error handling
- All service methods return `Result<T>` (alias for `Either<AppError, T>`)
- Errors bubble up to UI layer for user feedback

## Testing

### Unit Tests

Located in `test/`:
- `test/domain/parser_test.dart` - Parser logic (14 tests)
- `test/domain/schedule_engine_test.dart` - Reflow logic (13 tests)
- `test/domain/summaries_test.dart` - Summary generation (12 tests)

Run tests:
```bash
flutter test
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Known Limitations (MVP)

- [ ] iOS screen time import (DeviceActivity limitations)
- [ ] In-app editing of blocks (drag-to-resize)
- [ ] CSV export implementation
- [ ] Category customization UI
- [ ] Widget tap actions (deep linking)
- [ ] Timezone support (currently uses local time)

## Future Enhancements

- [ ] Multi-day view
- [ ] Templates for recurring schedules
- [ ] Smart suggestions based on history
- [ ] Sync across devices (Firebase/Supabase)
- [ ] Habit tracking
- [ ] Pomodoro timer integration
- [ ] Calendar import/export

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

[Add your license here]

## Support

For issues and questions:
- Open an issue on GitHub
- Contact: [your-email@example.com]

## Acknowledgments

- Flutter team for the amazing framework
- Drift for the excellent SQLite wrapper
- Riverpod for elegant state management

---

**Built with ❤️ using Flutter**
