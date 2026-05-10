import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/shift_event.dart';
import '../services/shift_service.dart';
import '../theme.dart';
import 'history_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livre Serviço Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              ));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusCard(status: status, worked: _fmtDuration(worked)),
              const SizedBox(height: 24),
              ..._buildActions(status),
              const SizedBox(height: 24),
              Expanded(child: _buildEventsList()),
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
            label: const Text('Clock In'),
            onPressed: svc.clockIn,
          ),
        ];
      case WorkStatus.working:
        return [
          ElevatedButton.icon(
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
            onPressed: svc.pause,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.stop),
            label: const Text('Clock Out'),
            onPressed: svc.clockOut,
          ),
        ];
      case WorkStatus.paused:
        return [
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
            onPressed: svc.resume,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.stop),
            label: const Text('Clock Out'),
            onPressed: svc.clockOut,
          ),
        ];
    }
  }

  Widget _buildEventsList() {
    if (_todayEvents.isEmpty) {
      return const Center(
        child: Text(
          'No events yet.\nClock in to start your shift.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      );
    }
    final fmt = DateFormat('HH:mm:ss');
    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _todayEvents.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final e = _todayEvents[i];
          return ListTile(
            leading: Icon(_iconFor(e.type), color: AppColors.green),
            title: Text(_labelFor(e.type)),
            trailing: Text(fmt.format(e.timestamp)),
          );
        },
      ),
    );
  }
}

IconData _iconFor(ShiftEventType t) {
  switch (t) {
    case ShiftEventType.clockIn:
      return Icons.login;
    case ShiftEventType.pause:
      return Icons.pause_circle;
    case ShiftEventType.resume:
      return Icons.play_circle;
    case ShiftEventType.clockOut:
      return Icons.logout;
  }
}

String _labelFor(ShiftEventType t) {
  switch (t) {
    case ShiftEventType.clockIn:
      return 'Clock In';
    case ShiftEventType.pause:
      return 'Pause';
    case ShiftEventType.resume:
      return 'Resume';
    case ShiftEventType.clockOut:
      return 'Clock Out';
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.worked});

  final WorkStatus status;
  final String worked;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WorkStatus.idle => ('Off the clock', AppColors.black),
      WorkStatus.working => ('Working', AppColors.green),
      WorkStatus.paused => ('Paused', AppColors.greenDark),
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
            const Text('Worked time',
                style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
