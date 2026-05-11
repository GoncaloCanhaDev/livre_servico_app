import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    SettingsService.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enabled = SettingsService.instance.notificationsEnabled;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Definições'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Notificações',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Ativar lembretes de turnos e tarefas.'),
            activeTrackColor: AppColors.green.withValues(alpha: 0.5),
            activeThumbColor: AppColors.green,
            value: enabled,
            onChanged: (val) async {
              if (val) {
                // Request permissions when turned on
                final granted =
                    await NotificationService.instance.requestPermission();
                if (granted) {
                  await SettingsService.instance.setNotificationsEnabled(true);
                  // Quick test notification to confirm it works
                  await NotificationService.instance.testNotification();
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Permissão para notificações negada.')),
                    );
                  }
                }
              } else {
                await SettingsService.instance.setNotificationsEnabled(false);
              }
            },
          ),
        ],
      ),
    );
  }
}
