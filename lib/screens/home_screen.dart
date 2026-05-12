import 'dart:async';

import 'package:flutter/material.dart';
import '../models/shift_event.dart';
import '../services/shift_service.dart';
import '../theme.dart';
import 'daily_tasks_screen.dart';
import 'historico_screen.dart';
import 'inventory_screen.dart';
import 'products_list_screen.dart';
import 'replenishment_lists_screen.dart';
import 'settings_screen.dart';
import 'truck_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  List<ShiftEvent> _todayEvents = [];

  @override
  void initState() {
    super.initState();
    ShiftService.instance.addListener(_onChanged);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _loadCurrent();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    ShiftService.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    _loadCurrent();
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
        content: const Text('Vais fazer uma pausa normal (15m) ou de almoço (60m)?'),
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

    bool isPauseOverLimit = false;
    if (status == WorkStatus.paused && svc.lastEvent != null) {
      final pauseDuration = DateTime.now().difference(svc.lastEvent!.timestamp);
      if (svc.lastEvent!.type == ShiftEventType.lunch && pauseDuration.inMinutes >= 60) {
        isPauseOverLimit = true;
      } else if (svc.lastEvent!.type == ShiftEventType.pause && pauseDuration.inMinutes >= 15) {
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusCard(
                status: status,
                worked: _fmtDuration(worked),
                paused: _fmtDuration(paused),
                isPauseOverLimit: isPauseOverLimit,
                isLunch: svc.lastEvent?.type == ShiftEventType.lunch,
                onPausePressed: _handlePause,
                onResumePressed: svc.resume,
              ),
              const SizedBox(height: 24),
              ..._buildActions(status),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('Camiões'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const TruckFormScreen(),
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Produtos'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ProductsListScreen(),
                        ));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.checklist),
                label: const Text('Listas de Reposição'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ReplenishmentListsScreen(),
                  ));
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.task_alt),
                label: const Text('Tarefas Diárias'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const DailyTasksScreen(),
                  ));
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.assignment),
                      label: const Text('Inventários'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const InventoryScreen(),
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.history),
                      label: const Text('Histórico'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const HistoricoScreen(),
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.worked,
    required this.paused,
    required this.onPausePressed,
    required this.onResumePressed,
    this.isPauseOverLimit = false,
    this.isLunch = false,
  });

  final WorkStatus status;
  final String worked;
  final String paused;
  final VoidCallback onPausePressed;
  final VoidCallback onResumePressed;
  final bool isPauseOverLimit;
  final bool isLunch;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WorkStatus.idle => ('Fora de serviço', AppColors.black),
      WorkStatus.working => ('Em serviço', AppColors.green),
      WorkStatus.paused => (isLunch ? 'Em almoço' : 'Em pausa', AppColors.greenDark),
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
            const SizedBox(height: 8),
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
            const Text('Tempo trabalhado',
                style: TextStyle(color: Colors.black54)),
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
                        status == WorkStatus.working ? Icons.pause_circle_filled : Icons.play_circle_filled,
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
                    const Text('Tempo em pausa',
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
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
