/// iOS WidgetKit integration
library;

import '../domain/models/block.dart';

/// iOS WidgetKit service
///
/// Note: This requires a WidgetKit extension target in the iOS project.
/// The actual widget UI is implemented in Swift/SwiftUI in the iOS folder.
class IosWidgetKit {
  /// Update widget with current and next blocks
  static Future<void> updateWidget({
    Block? currentBlock,
    Block? nextBlock,
  }) async {
    // TODO: Implement using platform channel to update widget via UserDefaults
    // shared with the widget extension via App Groups

    // The iOS widget will read from shared UserDefaults:
    // - current_title: String
    // - current_since: String (HH:mm format)
    // - next_title: String
    // - next_start: String (HH:mm format)

    // For MVP, this is a stub. Full implementation requires:
    // 1. App Groups setup in Xcode
    // 2. WidgetKit extension target
    // 3. Platform channel to write to shared UserDefaults
    // 4. WidgetCenter.shared.reloadAllTimelines() call from Swift
  }

  /// Clear widget data
  static Future<void> clearWidget() async {
    // TODO: Implement clearing via platform channel
  }

  /// Get widget configuration example
  static String getWidgetSwiftExample() {
    return '''
// iOS WidgetKit implementation example (add to iOS/TrueDayWidget folder)

import WidgetKit
import SwiftUI

struct TrueDayWidgetEntry: TimelineEntry {
    let date: Date
    let currentTitle: String
    let currentSince: String
    let nextTitle: String
    let nextStart: String
}

struct TrueDayWidgetEntryView: View {
    var entry: TrueDayWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Now section
            HStack {
                Text("Now")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.currentSince)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(entry.currentTitle)
                .font(.headline)

            Divider()

            // Next section
            Text("Next")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                Text(entry.nextTitle)
                    .font(.subheadline)
                Spacer()
                Text(entry.nextStart)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

@main
struct TrueDayWidget: Widget {
    let kind: String = "TrueDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrueDayProvider()) { entry in
            TrueDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TrueDay")
        .description("View your current and next activities")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
''';
  }
}
