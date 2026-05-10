import 'dart:async';

import 'package:flutter/material.dart';
import '../models/shift_event.dart';
import '../services/shift_service.dart';
import '../theme.dart';
import 'daily_tasks_screen.dart';
import 'historico_screen.dart';
import 'products_list_screen.dart';
import 'replenishment_lists_screen.dart';
import 'truck_history_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final svc = ShiftService.instance;
    final status = svc.status;
    final worked = computeWorked(_todayEvents);
    final paused = computePaused(_todayEvents);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livre Serviço Companion'),
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
                          builder: (_) => const TruckHistoryScreen(),
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
              OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Histórico'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const HistoricoScreen(),
                  ));
                },
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
        return [
          ElevatedButton.icon(
            icon: const Icon(Icons.pause),
            label: const Text('Pausar'),
            onPressed: svc.pause,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.stop),
            label: const Text('Terminar Turno'),
            onPressed: svc.clockOut,
          ),
        ];
      case WorkStatus.paused:
        return [
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Retomar'),
            onPressed: svc.resume,
          ),
          const SizedBox(height: 12),
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
  });

  final WorkStatus status;
  final String worked;
  final String paused;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WorkStatus.idle => ('Fora de serviço', AppColors.black),
      WorkStatus.working => ('Em serviço', AppColors.green),
      WorkStatus.paused => ('Em pausa', AppColors.greenDark),
    };
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
            Text(
              paused,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.greenDark,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const Text('Tempo em pausa',
                style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
