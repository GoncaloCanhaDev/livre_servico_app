import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/shift_event.dart';
import '../services/backup_service.dart';
import '../services/shift_service.dart';
import '../services/task_notification_service.dart';
import '../theme.dart';
import 'custom_tasks_screen.dart';
import 'daily_tasks_screen.dart';
import 'dashboard_screen.dart';
import 'historico_screen.dart';
import 'info_screen.dart';
import 'inventory_screen.dart';
import 'pedidos_screen.dart';
import 'people_screen.dart';
import 'products_list_screen.dart';
import 'replenishment_lists_screen.dart';
import 'settings_screen.dart';
import 'truck_form_screen.dart';
import 'weekly_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _ticker;
  List<ShiftEvent> _todayEvents = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ShiftService.instance.addListener(_onChanged);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _loadCurrent();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptBackup());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    ShiftService.instance.removeListener(_onChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      TaskNotificationService.instance.rescheduleAll();
    }
  }

  void _onChanged() {
    _loadCurrent();
    TaskNotificationService.instance.rescheduleAll();
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

  Future<void> _loadCurrent() async {
    final svc = ShiftService.instance;
    if (svc.currentShiftId != null) {
      final events = await svc.eventsForShift(svc.currentShiftId!);
      if (mounted) setState(() => _todayEvents = events);
    } else {
      if (mounted) setState(() => _todayEvents = []);
    }
  }

  String _fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _handlePause() async {
    final isLunch = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tipo de Pausa'),
        content: const Text(
          'Vais fazer uma pausa normal (15m) ou de almoço (60m)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Pausa'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Almoço'),
          ),
        ],
      ),
    );
    if (isLunch != null) {
      ShiftService.instance.pause(isLunch: isLunch);
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = ShiftService.instance;
    final status = svc.status;
    final worked = computeWorked(_todayEvents);
    final paused = computePaused(_todayEvents);
    final startTime = _todayEvents.isNotEmpty
        ? _todayEvents.first.timestamp
        : null;

    bool isPauseOverLimit = false;
    if (status == WorkStatus.paused && svc.lastEvent != null) {
      final pauseDuration = DateTime.now().difference(svc.lastEvent!.timestamp);
      if (svc.lastEvent!.type == ShiftEventType.lunch &&
          pauseDuration.inMinutes >= 60) {
        isPauseOverLimit = true;
      } else if (svc.lastEvent!.type == ShiftEventType.pause &&
          pauseDuration.inMinutes >= 15) {
        isPauseOverLimit = true;
      }
    }

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
              _StatusCard(
                status: status,
                worked: _fmtDuration(worked),
                paused: _fmtDuration(paused),
                startTime: startTime,
                isPauseOverLimit: isPauseOverLimit,
                isLunch: svc.lastEvent?.type == ShiftEventType.lunch,
                onPausePressed: _handlePause,
                onResumePressed: svc.resume,
              ),
              const SizedBox(height: 12),
              ..._buildActions(status),
              const SizedBox(height: 12),
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
                    icon: Icons.inventory_2,
                    label: 'Produtos',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProductsListScreen(),
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
                    icon: Icons.insights,
                    label: 'Estatísticas',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
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

  List<Widget> _buildActions(WorkStatus status) {
    final svc = ShiftService.instance;
    switch (status) {
      case WorkStatus.idle:
        return [
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Turno'),
            onPressed: svc.clockIn,
          ),
        ];
      case WorkStatus.working:
      case WorkStatus.paused:
        return [
          OutlinedButton.icon(
            icon: const Icon(Icons.stop),
            label: const Text('Terminar Turno'),
            onPressed: svc.clockOut,
          ),
        ];
    }
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.worked,
    required this.paused,
    required this.onPausePressed,
    required this.onResumePressed,
    this.startTime,
    this.isPauseOverLimit = false,
    this.isLunch = false,
  });

  final WorkStatus status;
  final String worked;
  final String paused;
  final VoidCallback onPausePressed;
  final VoidCallback onResumePressed;
  final DateTime? startTime;
  final bool isPauseOverLimit;
  final bool isLunch;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WorkStatus.idle => ('Fora de serviço', AppColors.black),
      WorkStatus.working => ('Em serviço', AppColors.green),
      WorkStatus.paused => (
        isLunch ? 'Em almoço' : 'Em pausa',
        AppColors.greenDark,
      ),
    };

    final pulse = isPauseOverLimit && DateTime.now().second % 2 == 0;
    final pauseColor = pulse ? Colors.redAccent : AppColors.greenDark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (startTime != null)
              Text(
                'Início: ${DateFormat('HH:mm').format(startTime!)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            const SizedBox(height: 4),
            Text(
              worked,
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tempo trabalhado',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.grey),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (status != WorkStatus.idle)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      onPressed: status == WorkStatus.working
                          ? onPausePressed
                          : onResumePressed,
                      icon: Icon(
                        status == WorkStatus.working
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 32,
                        color: pauseColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                Column(
                  children: [
                    Text(
                      paused,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: pauseColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Text(
                      'Tempo em pausa',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
