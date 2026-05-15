import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import 'notification_history_screen.dart';
import '../services/settings_service.dart';
import '../services/shift_service.dart';
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
    SyncService.instance.addListener(_onSettingsChanged);
    AuthService.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsChanged);
    SyncService.instance.removeListener(_onSettingsChanged);
    AuthService.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  String _syncSubtitle() {
    final s = SyncService.instance;
    if (s.syncing) return 'A sincronizar…';
    if (s.lastError != null) return 'Erro: ${s.lastError}';
    final last = s.lastSyncAt;
    if (last == null) return 'Ainda não sincronizado.';
    final h = last.hour.toString().padLeft(2, '0');
    final m = last.minute.toString().padLeft(2, '0');
    return 'Última sincronização às $h:$m.';
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
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
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Notificações'),
          SwitchListTile(
            title: const Text('Ativar Notificações',
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
          ListTile(
            title: const Text('Histórico de Notificações',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle:
                const Text('Vê todas as notificações agendadas e enviadas.'),
            trailing: const Icon(Icons.history),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const NotificationHistoryScreen(),
              ));
            },
          ),
          const Divider(),
          _sectionHeader('Geral'),
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
          const Divider(),
          _sectionHeader('Dados'),
          ListTile(
            title: const Text('Sincronizar agora',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(_syncSubtitle()),
            trailing: SyncService.instance.syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onTap: SyncService.instance.syncing
                ? null
                : () => SyncService.instance.syncNow(),
          ),
          ListTile(
            title: const Text('Exportar Dados',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(
                'Guarda uma cópia de segurança da base de dados.'),
            trailing: const Icon(Icons.upload_file),
            onTap: _onExport,
          ),
          ListTile(
            title: const Text('Importar Dados',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(
                'Substitui todos os dados atuais por uma cópia de segurança.'),
            trailing: const Icon(Icons.download),
            onTap: _onImport,
          ),
          ListTile(
            title: const Text('Apagar Todos os Dados',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.red)),
            subtitle: const Text(
                'Remove permanentemente todos os dados da aplicação.'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _onDeleteAll,
          ),
          const Divider(),
          _sectionHeader('Conta'),
          ListTile(
            title: Text(
              AuthService.instance.fullName ?? 'Sem nome',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              [
                if ((AuthService.instance.employeeNumber ?? '').isNotEmpty)
                  'Nº ${AuthService.instance.employeeNumber}',
                AuthService.instance.user?.email ?? '',
              ].where((s) => s.isNotEmpty).join(' · '),
            ),
            trailing: const Icon(Icons.edit, size: 18),
            onTap: _onEditName,
          ),
          ListTile(
            title: const Text('Terminar sessão',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Sair desta conta nesta aplicação.'),
            trailing: const Icon(Icons.logout),
            onTap: () async {
              final navigator = Navigator.of(context);
              await AuthService.instance.signOut();
              navigator.popUntil((r) => r.isFirst);
            },
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _onEditName() async {
    final auth = AuthService.instance;
    final firstCtrl = TextEditingController(text: auth.firstName ?? '');
    final lastCtrl = TextEditingController(text: auth.lastName ?? '');
    final empCtrl = TextEditingController(text: auth.employeeNumber ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Primeiro nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Último nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: empCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nº empregado',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    final first = firstCtrl.text.trim();
    final last = lastCtrl.text.trim();
    final emp = empCtrl.text.trim();
    if (first.isEmpty || last.isEmpty || emp.isEmpty) return;
    try {
      await AuthService.instance.updateProfile(
        firstName: first,
        lastName: last,
        employeeNumber: emp,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao guardar: $e')),
      );
    }
  }

  Future<void> _onExport() async {
    try {
      await BackupService.instance.exportToFile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    }
  }

  Future<void> _onDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar Todos os Dados'),
        content: const Text(
            'Esta ação irá apagar permanentemente todos os dados da aplicação (turnos, listas, produtos, inventário, tarefas, receções).\n\nEsta ação não pode ser revertida. Desejas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar Tudo'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await BackupService.instance.clearAll();
      await ShiftService.instance.refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os dados foram apagados.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao apagar: $e')),
      );
    }
  }

  Future<void> _onImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar Dados'),
        content: const Text(
            'Esta ação irá apagar todos os dados atuais e substituí-los pelos dados do ficheiro selecionado.\n\nDesejas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar e Importar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final imported = await BackupService.instance.pickAndImport();
      if (!mounted) return;
      if (imported) {
        await ShiftService.instance.refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados importados com sucesso.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar: $e')),
      );
    }
  }
}
