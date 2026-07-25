import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _use24h = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          SwitchListTile(
            title: const Text('Format waktu 24 jam'),
            value: _use24h,
            onChanged: (v) => setState(() => _use24h = v),
          ),
          ListTile(
            title: const Text('Backup'),
            subtitle: const Text('Segera hadir'),
            enabled: false,
          ),
          ListTile(
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('${AppConstants.appName} v1.0.0'),
          ),
        ],
      ),
    );
  }
}
