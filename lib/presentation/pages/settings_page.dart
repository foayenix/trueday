/// Settings page
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Settings page for app configuration
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _transitionNotifications = true;
  bool _overrunNotifications = true;
  bool _recoveryNotifications = true;
  bool _screenTimeImport = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Notifications section
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Transition nudges'),
            subtitle: const Text('2 minutes before next activity'),
            value: _transitionNotifications,
            onChanged: (value) {
              setState(() {
                _transitionNotifications = value;
              });
              // TODO: Save to preferences
            },
          ),
          SwitchListTile(
            title: const Text('Overrun alerts'),
            subtitle: const Text('5 minutes past end time'),
            value: _overrunNotifications,
            onChanged: (value) {
              setState(() {
                _overrunNotifications = value;
              });
              // TODO: Save to preferences
            },
          ),
          SwitchListTile(
            title: const Text('Recovery suggestions'),
            subtitle: const Text('When planned start time passes'),
            value: _recoveryNotifications,
            onChanged: (value) {
              setState(() {
                _recoveryNotifications = value;
              });
              // TODO: Save to preferences
            },
          ),
          const Divider(),

          // Categories section
          _SectionHeader(title: 'Categories'),
          ListTile(
            title: const Text('Manage categories'),
            subtitle: const Text('Edit categories and set anchors'),
            leading: const Icon(Icons.category),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to categories management
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category management (not implemented)')),
              );
            },
          ),
          const Divider(),

          // Screen time section
          _SectionHeader(title: 'Screen Time'),
          SwitchListTile(
            title: const Text('Import screen time'),
            subtitle: Text(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? 'Requires DeviceActivity permission'
                  : 'Requires Usage Stats permission',
            ),
            value: _screenTimeImport,
            onChanged: (value) {
              setState(() {
                _screenTimeImport = value;
              });
              if (value) {
                _requestScreenTimePermission();
              }
            },
          ),
          if (_screenTimeImport)
            ListTile(
              title: const Text('Screen time permissions'),
              subtitle: const Text('Manage permissions'),
              leading: const Icon(Icons.phone_android),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _requestScreenTimePermission();
              },
            ),
          const Divider(),

          // Data section
          _SectionHeader(title: 'Data'),
          ListTile(
            title: const Text('Export data'),
            subtitle: const Text('Export activities as CSV'),
            leading: const Icon(Icons.file_download),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement data export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export (not implemented)')),
              );
            },
          ),
          ListTile(
            title: const Text('Clear all data'),
            subtitle: const Text('Reset app to initial state'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              _showClearDataDialog();
            },
          ),
          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('0.1.0+1'),
            leading: const Icon(Icons.info),
          ),
          ListTile(
            title: const Text('Privacy policy'),
            leading: const Icon(Icons.privacy_tip),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            title: const Text('Terms of service'),
            leading: const Icon(Icons.description),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open terms
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _requestScreenTimePermission() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screen Time Permission'),
        content: Text(
          Theme.of(context).platform == TargetPlatform.iOS
              ? 'TrueDay needs permission to access screen time data. '
                  'This requires Family Controls authorization.\n\n'
                  'Note: iOS has limitations on screen time access.'
              : 'TrueDay needs permission to access usage statistics. '
                  'You will be taken to Settings to grant this permission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open settings or request permission
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permission request (not implemented)')),
              );
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your activities, days, and settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement data clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear data (not implemented)')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
