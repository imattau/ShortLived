import 'package:flutter/material.dart';
import '../../app/routes.dart';

/// Minimal Settings screen scaffold.
/// Actual settings groups (keys, relays, safety, notifications) will be added in follow-ups.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppLabels.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: const [
          _SettingsGroup(
            title: 'Account',
            children: [
              _SettingsTile('Profile & Keys'),
              _SettingsTile('Relays'),
            ],
          ),
          _SettingsGroup(
            title: 'Content & Safety',
            children: [
              _SettingsTile('Muted Users'),
              _SettingsTile('Media Preferences'),
            ],
          ),
          _SettingsGroup(
            title: 'Notifications',
            children: [
              _SettingsTile('Mentions & Likes'),
              _SettingsTile('Zaps'),
            ],
          ),
          _SettingsGroup(
            title: 'About',
            children: [
              _SettingsTile('App Version'),
              _SettingsTile('Licenses'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          ...children,
          const SizedBox(height: 8),
          const Divider(height: 0),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  const _SettingsTile(this.label);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: () {}, // wired later
    );
  }
}
