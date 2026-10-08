part of '../historico_screen.dart';

class _TrucksTab extends StatefulWidget {
  const _TrucksTab();
  @override
  State<_TrucksTab> createState() => _TrucksTabState();
}

class _TrucksTabState extends State<_TrucksTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<TruckReception>> _future;

  @override
  void initState() {
    super.initState();
    _future = TruckService.instance.all(includeDeleted: true);
    TruckService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    TruckService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = TruckService.instance.all(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateFmt = DateFormat("d 'de' MMM, HH:mm", 'pt_PT');
    return FutureBuilder<List<TruckReception>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final trucks = snap.data!;
        if (trucks.isEmpty) return _emptyMsg('Sem camiões registados.');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trucks.length,
          itemBuilder: (_, i) {
            final t = trucks[i];
            final parts = <String>[
              if (t.type != null) t.type!.label,
              if (t.licensePlate != null) t.licensePlate!,
              if (t.supplier != null) t.supplier!,
            ];
            return _dimmedIfDeleted(
              deleted: t.syncDeletedAt != null,
              child: _HistoryDismissible(
                itemKey: ValueKey(t.id),
                deletePromptName: 'camião',
                onDelete: () async {
                  await TruckService.instance.delete(t.id);
                },
                onSendWhatsApp: (ctx) async {
                  final dateFmtWa = DateFormat("d/MM/y, HH:mm", 'pt_PT');
                  final lines = StringBuffer();
                  lines.writeln('🚛 Receção de Camião');
                  if (t.type != null) lines.writeln('Tipo: ${t.type!.label}');
                  lines.writeln('Hora: ${dateFmtWa.format(t.arrivalTime)}');
                  if (t.licensePlate != null)
                    lines.writeln('Matrícula: ${t.licensePlate}');
                  if (t.supplier != null)
                    lines.writeln('Fornecedor: ${t.supplier}');
                  for (final p in t.pallets) {
                    final mista = p.mistas > 0
                        ? ' (${p.mistas} mista${p.mistas > 1 ? 's' : ''})'
                        : '';
                    lines.writeln('${p.label}: ${p.total}$mista');
                  }
                  lines.writeln(
                    'Total: ${t.totalPallets} paletes, ${t.totalMistas} mistas',
                  );
                  if (t.expositores.isNotEmpty) {
                    lines.writeln('\nExpositores:');
                    for (final e in t.expositores) {
                      lines.writeln(
                        e.content.isEmpty
                            ? '- ${e.amount}'
                            : '- ${e.amount} · ${e.content}',
                      );
                    }
                  }
                  if (t.issues != null) {
                    lines.writeln('⚠️ Problemas: ${t.issues}');
                  }
                  if (t.notes != null) lines.writeln('Notas: ${t.notes}');
                  await WhatsAppService.sendWithConfirm(
                    ctx,
                    lines.toString().trim(),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      dateFmt.format(t.arrivalTime),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      [
                        if (parts.isNotEmpty) parts.join(' · '),
                        [
                          '${t.totalPallets} paletes · ${t.totalMistas} mistas',
                          if (t.totalExpositores > 0)
                            '${t.totalExpositores} expositores',
                        ].join(' · '),
                        if (t.issues != null) '⚠️ Problemas registados',
                      ].join('\n'),
                    ),
                    trailing: _trailingWithInitials(
                      t.createdByInitials,
                      Icon(
                        t.issues != null
                            ? Icons.warning_amber_rounded
                            : Icons.local_shipping,
                        color: t.issues != null
                            ? Colors.orange.shade800
                            : AppColors.green,
                      ),
                    ),
                    children: [
                      ...t.pallets.map(
                        (p) => ListTile(
                          dense: true,
                          title: Text(p.label),
                          trailing: Text(
                            '${p.total} (${p.mistas} mistas)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      for (final e in t.expositores)
                        ListTile(
                          dense: true,
                          title: Text(
                            e.content.isEmpty
                                ? 'Expositores'
                                : 'Expositores · ${e.content}',
                          ),
                          trailing: Text(
                            '${e.amount}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      if (t.issues != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '⚠️ Problemas: ${t.issues}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (t.notes != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Notas: ${t.notes}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
