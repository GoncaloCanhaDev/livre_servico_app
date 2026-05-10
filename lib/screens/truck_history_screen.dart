import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/truck_reception.dart';
import '../services/truck_service.dart';
import '../theme.dart';
import 'truck_form_screen.dart';

class TruckHistoryScreen extends StatefulWidget {
  const TruckHistoryScreen({super.key});

  @override
  State<TruckHistoryScreen> createState() => _TruckHistoryScreenState();
}

class _TruckHistoryScreenState extends State<TruckHistoryScreen> {
  late Future<List<TruckReception>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
    TruckService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    TruckService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = TruckService.instance.all();
    });
  }

  Future<void> _newTruck() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TruckFormScreen()),
    );
    if (ok == true) _reload();
  }

  Future<void> _confirmDelete(TruckReception t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar receção?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apagar')),
        ],
      ),
    );
    if (ok == true) {
      await TruckService.instance.delete(t.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat("d 'de' MMM, HH:mm", 'pt_PT');
    return Scaffold(
      appBar: AppBar(title: const Text('Camiões Recebidos')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        onPressed: _newTruck,
        icon: const Icon(Icons.local_shipping),
        label: const Text('Novo'),
      ),
      body: FutureBuilder<List<TruckReception>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final trucks = snap.data!;
          if (trucks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Ainda não há camiões registados.\nToque em "Novo" para registar.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: trucks.length,
            itemBuilder: (_, i) {
              final t = trucks[i];
              final subtitleParts = <String>[
                if (t.licensePlate != null) t.licensePlate!,
                if (t.supplier != null) t.supplier!,
              ];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(dateFmt.format(t.arrivalTime),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    [
                      if (subtitleParts.isNotEmpty) subtitleParts.join(' · '),
                      '${t.totalPallets} paletes · ${t.totalMistas} mistas',
                    ].join('\n'),
                  ),
                  trailing: const Icon(Icons.local_shipping,
                      color: AppColors.green),
                  children: [
                    ...t.pallets.map((p) => ListTile(
                          dense: true,
                          title: Text(p.category.label),
                          trailing: Text(
                            '${p.total} (${p.mistas} mistas)',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )),
                    if (t.notes != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Notas: ${t.notes}',
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic)),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _confirmDelete(t),
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        label: const Text('Apagar',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
