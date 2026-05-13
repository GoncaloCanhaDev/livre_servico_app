import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

import '../models/notification_log.dart';
import '../services/shift_service.dart';
import '../theme.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends State<NotificationHistoryScreen> {
  late Future<List<NotificationLog>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<NotificationLog>> _load() async {
    final list = await ShiftService.instance.isar.notificationLogs
        .where()
        .findAll();
    list.sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
    return list;
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar histórico'),
        content: const Text(
            'Esta ação irá apagar todo o histórico de notificações.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final isar = ShiftService.instance.isar;
    await isar.writeTxn(() => isar.notificationLogs.clear());
    if (mounted) setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat("EEEE, d 'de' MMM y", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Notificações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Apagar tudo',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<NotificationLog>>(
          future: _future,
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snap.data!;
            if (all.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sem notificações registadas.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }
            final now = DateTime.now();
            final grouped = <DateTime, List<NotificationLog>>{};
            for (final e in all) {
              final day = DateTime(
                  e.scheduledFor.year,
                  e.scheduledFor.month,
                  e.scheduledFor.day);
              (grouped[day] ??= []).add(e);
            }
            final days = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: days.length,
              itemBuilder: (_, i) {
                final day = days[i];
                final items = grouped[day]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (i > 0) const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        dayFmt.format(day),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greenDark,
                        ),
                      ),
                    ),
                    ...items.map((e) {
                      final fired = !e.scheduledFor.isAfter(now);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            fired
                                ? Icons.notifications_active
                                : Icons.schedule_send,
                            color: fired
                                ? AppColors.green
                                : Colors.black45,
                          ),
                          title: Text(
                            e.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            e.body,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(timeFmt.format(e.scheduledFor),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black45)),
                              if (!fired)
                                const Text('agendada',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black45)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
