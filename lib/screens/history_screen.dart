import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/shift_event.dart';
import '../services/shift_service.dart';
import '../theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<_ShiftSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_ShiftSummary>> _load() async {
    final svc = ShiftService.instance;
    final ids = await svc.allShiftIdsDesc();
    final out = <_ShiftSummary>[];
    for (final id in ids) {
      final events = await svc.eventsForShift(id);
      if (events.isEmpty) continue;
      out.add(_ShiftSummary(
        shiftId: id,
        events: events,
        worked: computeWorked(events),
        paused: computePaused(events),
      ));
    }
    return out;
  }

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat("EEE, d 'de' MMMM", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: FutureBuilder<List<_ShiftSummary>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final shifts = snap.data!;
          if (shifts.isEmpty) {
            return const Center(child: Text('Ainda não há turnos registados.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shifts.length,
            itemBuilder: (_, i) {
              final s = shifts[i];
              final start = s.events.first.timestamp;
              final end = s.events.last.type == ShiftEventType.clockOut
                  ? s.events.last.timestamp
                  : null;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    dateFmt.format(start),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    [
                      end == null
                          ? 'Em curso · ${_fmtDuration(s.worked)}'
                          : '${timeFmt.format(start)} – ${timeFmt.format(end)} · ${_fmtDuration(s.worked)}',
                      if (s.paused.inSeconds > 0)
                        'Pausa: ${_fmtDuration(s.paused)}',
                    ].join('\n'),
                  ),
                  trailing: Icon(
                    end == null ? Icons.timer : Icons.check_circle,
                    color: AppColors.green,
                  ),
                  children: s.events.map((e) {
                    return ListTile(
                      dense: true,
                      leading: Icon(_icon(e.type), size: 20,
                          color: AppColors.green),
                      title: Text(_label(e.type)),
                      trailing: Text(timeFmt.format(e.timestamp)),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ShiftSummary {
  _ShiftSummary({
    required this.shiftId,
    required this.events,
    required this.worked,
    required this.paused,
  });
  final int shiftId;
  final List<ShiftEvent> events;
  final Duration worked;
  final Duration paused;
}

IconData _icon(ShiftEventType t) {
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

String _label(ShiftEventType t) {
  switch (t) {
    case ShiftEventType.clockIn:
      return 'Início de turno';
    case ShiftEventType.pause:
      return 'Pausa';
    case ShiftEventType.resume:
      return 'Retoma';
    case ShiftEventType.clockOut:
      return 'Fim de turno';
  }
}
