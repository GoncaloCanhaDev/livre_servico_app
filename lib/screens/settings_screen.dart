import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/task_notification_service.dart';
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

  Widget _buildToggle(String title, String key) {
    return SwitchListTile(
      dense: true,
      title: Text(title),
      activeTrackColor: AppColors.green.withValues(alpha: 0.5),
      activeThumbColor: AppColors.green,
      value: SettingsService.instance.isNotificationEnabled(key),
      onChanged: (val) async {
        await SettingsService.instance.setNotificationEnabled(key, val);
        await TaskNotificationService.instance.rescheduleAll();
      },
    );
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
                  await TaskNotificationService.instance.rescheduleAll();
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
                await TaskNotificationService.instance.rescheduleAll();
                await NotificationService.instance.cancelPauseReminders();
                await NotificationService.instance.cancelStraightWorkReminders();
                await NotificationService.instance.cancelTotalWorkReminders();
              }
            },
          ),
          if (enabled) ...[
            const Divider(),
            ExpansionTile(
              title: const Text('Notificações Individuais',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Escolhe os alertas que queres receber.'),
              children: [
                _buildToggle('Notificações de Turnos e Pausas', 'page_turnos'),
                _buildToggle('Notificações de Listas de Reposição', 'page_listas'),
                _buildToggle('Notificações de Tarefas Diárias', 'page_tarefas'),
              ],
            ),
          ],
          const Divider(),
          ListTile(
            title: const Text('Objetivo Lista Visual',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Itens picados necessários por dia.'),
            trailing: Text(SettingsService.instance.visualGoal.toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onTap: () async {
              final ctrl = TextEditingController(
                  text: SettingsService.instance.visualGoal.toString());
              final val = await showDialog<int>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Objetivo Diário'),
                  content: TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Itens picados',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)),
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              );
              if (val != null && val > 0) {
                SettingsService.instance.setVisualGoal(val);
              }
            },
          ),
        ],
      ),
    );
  }
}
