import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct TrueDayEntry: TimelineEntry {
    let date: Date
    let currentTitle: String
    let currentSince: String
    let nextTitle: String
    let nextStart: String
}

// MARK: - Timeline Provider
struct TrueDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TrueDayEntry {
        TrueDayEntry(
            date: Date(),
            currentTitle: "Work",
            currentSince: "09:00",
            nextTitle: "Meeting",
            nextStart: "10:30"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TrueDayEntry) -> ()) {
        let entry = TrueDayEntry(
            date: Date(),
            currentTitle: "Work",
            currentSince: "09:00",
            nextTitle: "Meeting",
            nextStart: "10:30"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Read from shared UserDefaults (App Groups)
        let sharedDefaults = UserDefaults(suiteName: "group.com.trueday.widget")

        let currentTitle = sharedDefaults?.string(forKey: "current_title") ?? "No activity"
        let currentSince = sharedDefaults?.string(forKey: "current_since") ?? ""
        let nextTitle = sharedDefaults?.string(forKey: "next_title") ?? "No upcoming"
        let nextStart = sharedDefaults?.string(forKey: "next_start") ?? ""

        let entry = TrueDayEntry(
            date: Date(),
            currentTitle: currentTitle,
            currentSince: currentSince,
            nextTitle: nextTitle,
            nextStart: nextStart
        )

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

// MARK: - Widget View
struct TrueDayWidgetView: View {
    var entry: TrueDayProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Text("TrueDay")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

            // Now section
            VStack(alignment: .leading, spacing: 4) {
                Text("Now")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(entry.currentTitle)
                    .font(.headline)
                    .lineLimit(2)

                if !entry.currentSince.isEmpty {
                    Text("Since \(entry.currentSince)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Next section
            VStack(alignment: .leading, spacing: 4) {
                Text("Next")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(entry.nextTitle)
                    .font(.subheadline)
                    .lineLimit(1)

                if !entry.nextStart.isEmpty {
                    Text("Starts at \(entry.nextStart)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Widget Configuration
@main
struct TrueDayWidget: Widget {
    let kind: String = "TrueDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrueDayProvider()) { entry in
            TrueDayWidgetView(entry: entry)
        }
        .configurationDisplayName("TrueDay")
        .description("View your current and next activities")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
struct TrueDayWidget_Previews: PreviewProvider {
    static var previews: some View {
        TrueDayWidgetView(entry: TrueDayEntry(
            date: Date(),
            currentTitle: "Deep Work",
            currentSince: "09:00",
            nextTitle: "Team Meeting",
            nextStart: "11:00"
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
