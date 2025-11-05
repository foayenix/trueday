/// Android home widget integration
library;

import 'package:home_widget/home_widget.dart';
import '../domain/models/block.dart';

/// Android home widget service
class AndroidHomeWidget {
  static const String _widgetName = 'TrueDayWidget';

  /// Update widget with current and next blocks
  static Future<void> updateWidget({
    Block? currentBlock,
    Block? nextBlock,
  }) async {
    try {
      // Save data to shared preferences (accessible by widget)
      await HomeWidget.saveWidgetData<String>(
        'current_title',
        currentBlock?.title ?? 'No activity',
      );
      await HomeWidget.saveWidgetData<String>(
        'current_since',
        currentBlock != null ? _formatTime(currentBlock.start) : '',
      );
      await HomeWidget.saveWidgetData<String>(
        'next_title',
        nextBlock?.title ?? 'No upcoming',
      );
      await HomeWidget.saveWidgetData<String>(
        'next_start',
        nextBlock != null ? _formatTime(nextBlock.start) : '',
      );

      // Update widget
      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: _widgetName,
      );
    } catch (e) {
      // Silently fail if widget not installed
    }
  }

  /// Clear widget data
  static Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>('current_title', null);
      await HomeWidget.saveWidgetData<String>('current_since', null);
      await HomeWidget.saveWidgetData<String>('next_title', null);
      await HomeWidget.saveWidgetData<String>('next_start', null);

      await HomeWidget.updateWidget(
        androidName: _widgetName,
        iOSName: _widgetName,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Register deep link callback
  static Future<void> registerCallbacks(Function(Uri?) callback) async {
    try {
      HomeWidget.setAppGroupId('group.com.trueday.widget');
      HomeWidget.widgetClicked.listen(callback);
    } catch (e) {
      // Silently fail
    }
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
