import 'package:flutter/material.dart';

import '../services/backup_service.dart';
import 'custom_tasks_screen.dart';
import 'daily_tasks_screen.dart';
import 'historico_screen.dart';
import 'info_screen.dart';
import 'inventory_screen.dart';
import 'pedidos_screen.dart';
import 'people_screen.dart';
import 'replenishment_lists_screen.dart';
import 'settings_screen.dart';
import 'truck_form_screen.dart';
import 'weekly_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptBackup());
  }

  Future<void> _maybePromptBackup() async {
    if (!await BackupService.instance.isBackupOverdue()) return;
    if (!mounted) return;
    final choice = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cópia de Segurança'),
        content: const Text(
          'Ainda não fizeste uma cópia de segurança há mais de 7 dias. '
          'Queres exportar os dados agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mais tarde'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Agora'),
          ),
        ],
      ),
    );
    if (choice == true) {
      try {
        await BackupService.instance.exportToFile();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
      }
    } else {
      await BackupService.instance.setLastPromptAt(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livre Serviço Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 76,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _NavButton(
                    icon: Icons.local_shipping,
                    label: 'Camiões',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TruckFormScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.checklist,
                    label: 'Listas',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReplenishmentListsScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.assignment,
                    label: 'Inventários',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InventoryScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.task_alt,
                    label: 'Tarefas Diárias',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DailyTasksScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.event_repeat,
                    label: 'Tarefas Semanais',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WeeklyTasksScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.playlist_add_check,
                    label: 'Tarefas Personalizadas',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CustomTasksScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.receipt_long,
                    label: 'Pedidos',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PedidosScreen()),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.info_outline,
                    label: 'Informações',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InfoScreen()),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.history,
                    label: 'Histórico',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HistoricoScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.people,
                    label: 'Pessoas',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PeopleScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      onPressed: onPressed,
    );
  }
}
