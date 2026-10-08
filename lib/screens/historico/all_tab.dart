part of '../historico_screen.dart';

/// What a Tudo line is searched by: its date, texts and who.
String _dayItemText(_DayItem i) =>
    [dateWords(i.time), i.title, i.subtitle, ...i.names].join(' ');

class _AllTab extends StatefulWidget {
  const _AllTab();
  @override
  State<_AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<_AllTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<Map<DateTime, List<_DayItem>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    TruckService.instance.addListener(_reload);
    OpeningListService.instance.addListener(_reload);
    AutoListService.instance.addListener(_reload);
    ReportListService.instance.addListener(_reload);
    VisualListService.instance.addListener(_reload);
    DailyTasksService.instance.addListener(_reload);
    InventoryService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    TruckService.instance.removeListener(_reload);
    OpeningListService.instance.removeListener(_reload);
    AutoListService.instance.removeListener(_reload);
    ReportListService.instance.removeListener(_reload);
    VisualListService.instance.removeListener(_reload);
    DailyTasksService.instance.removeListener(_reload);
    InventoryService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  DateTime _toServiceDay(DateTime dt) {
    if (dt.hour < 5) {
      final y = dt.subtract(const Duration(days: 1));
      return DateTime(y.year, y.month, y.day, 5);
    }
    return DateTime(dt.year, dt.month, dt.day, 5);
  }

  Future<Map<DateTime, List<_DayItem>>> _load() async {
    final items = <_DayItem>[];

    // Trucks
    final trucks = await TruckService.instance.all(includeDeleted: true);
    for (final t in trucks) {
      final parts = <String>[
        if (t.licensePlate != null) t.licensePlate!,
        if (t.supplier != null) t.supplier!,
      ];
      items.add(
        _DayItem(
          type: _ItemType.truck,
          time: t.arrivalTime,
          title: '🚛 ${truckTitle(t)}',
          subtitle:
              '${parts.isNotEmpty ? '${parts.join(' · ')} · ' : ''}${t.totalPallets} paletes',
          icon: Icons.local_shipping,
          names: resolveNames(t.createdByNames, t.createdByInitials),
          deleted: t.syncDeletedAt != null,
        ),
      );
    }

    // Opening lists (only finalized)
    final openings = await OpeningListService.instance.history(
      includeDeleted: true,
    );
    for (final o in openings) {
      if (!o.isFinalized) continue;
      items.add(
        _DayItem(
          type: _ItemType.opening,
          time: o.finalizedAt ?? o.serviceDay,
          title: '📋 Lista de Abertura',
          subtitle:
              'Cong: ${o.congelados} · OPLS: ${o.opls} · NP: ${o.naoPereciveis} · Total: ${o.total}',
          icon: Icons.check_circle,
          names: resolveNames(o.createdByNames, o.createdByInitials),
          deleted: o.syncDeletedAt != null,
        ),
      );
    }

    // Auto lists
    final autos = await AutoListService.instance.history(includeDeleted: true);
    for (final a in autos) {
      items.add(
        _DayItem(
          type: _ItemType.auto,
          time: a.createdAt,
          title: '⚡ Lista Automática',
          subtitle:
              'Cong: ${a.congelados} · OPLS: ${a.opls} · NP: ${a.naoPereciveis} · Total: ${a.total}',
          icon: Icons.bolt,
          names: resolveNames(a.createdByNames, a.createdByInitials),
          deleted: a.syncDeletedAt != null,
        ),
      );
    }

    // Reports (only finalized)
    final reports = await ReportListService.instance.history(
      includeDeleted: true,
    );
    for (final r in reports) {
      if (!r.isFinalized) continue;
      items.add(
        _DayItem(
          type: _ItemType.report,
          time: r.finalizedAt ?? r.serviceDay,
          title: '📊 Relatório',
          subtitle:
              'DSV: ${r.diasSemVendas} · Reg: ${r.regularizacoes} · Mas: ${r.massiva} · Rep: ${r.repetidos} · Total: ${r.total}',
          icon: Icons.check_circle,
          names: resolveNames(r.createdByNames, r.createdByInitials),
          deleted: r.syncDeletedAt != null,
        ),
      );
    }

    // Visual lists
    final visuals = await VisualListService.instance.all(includeDeleted: true);
    for (final v in visuals) {
      items.add(
        _DayItem(
          type: _ItemType.visual,
          time: v.createdAt,
          title: '👁 Lista Visual',
          subtitle: '${v.itensPicados} itens picados',
          icon: Icons.visibility,
          names: resolveNames(v.createdByNames, v.createdByInitials),
          deleted: v.syncDeletedAt != null,
        ),
      );
    }

    // Tasks (same counting logic as the Tasks tab — includes derived tasks)
    final tasks = await DailyTasksService.instance.history(
      includeDeleted: true,
    );
    for (final t in tasks) {
      final day = t.serviceDay;
      final openingEntries = await OpeningListService.instance
          .entriesForServiceDay(day);
      final aberturaDone = openingEntries.any((o) => o.isFinalized);
      final reportEntries = await ReportListService.instance
          .entriesForServiceDay(day);
      final relatorioDone = reportEntries.any((r) => r.isFinalized);
      final visualEntries = await VisualListService.instance
          .entriesForServiceDay(day);
      final visualItens = visualEntries.fold<int>(
        0,
        (s, e) => s + e.itensPicados,
      );
      final visualDone = visualItens >= SettingsService.instance.visualGoal;
      final autoEntries = await AutoListService.instance.entriesForServiceDay(
        day,
      );
      final autoDone = autoEntries.isNotEmpty;

      final flags = <bool>[
        t.kiwiAbertura,
        t.alteracoesPreco,
        t.verificacaoTemperaturas,
        aberturaDone,
        relatorioDone,
        t.preenchimentoQuadro,
        visualDone,
        autoDone,
        t.verificacaoValidades,
        t.validadesNoite,
        t.kiwiFecho,
      ];
      final total = flags.length;
      final doneCount = flags.where((v) => v).length;
      items.add(
        _DayItem(
          type: _ItemType.tasks,
          time: t.lastUpdatedAt ?? t.serviceDay,
          title: '✅ Tarefas Diárias',
          subtitle: '$doneCount/$total concluídas',
          icon: Icons.task_alt,
          iconColor: doneCount == total ? null : Colors.grey,
          deleted: t.syncDeletedAt != null,
        ),
      );
    }

    // Inventories
    final invs = await InventoryService.instance.history(includeDeleted: true);
    for (final inv in invs) {
      items.add(
        _DayItem(
          type: _ItemType.inventory,
          time: inv.createdAt,
          title: '📦 Inventário: ${inv.name}',
          subtitle: '${formatCents(inv.valueCents)} €',
          icon: Icons.assignment,
          iconColor: inv.valueCents >= 0 ? null : Colors.redAccent,
          names: resolveNames(inv.createdByNames, inv.createdByInitials),
          deleted: inv.syncDeletedAt != null,
        ),
      );
    }

    // Group by service day
    final grouped = <DateTime, List<_DayItem>>{};
    for (final item in items) {
      final day = _toServiceDay(item.time);
      (grouped[day] ??= []).add(item);
    }
    // Sort days descending
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    // Sort items within each day by time descending
    final result = <DateTime, List<_DayItem>>{};
    for (final key in sortedKeys) {
      grouped[key]!.sort((a, b) => b.time.compareTo(a.time));
      result[key] = grouped[key]!;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final dayFmt = DateFormat("EEEE, d 'de' MMMM y", 'pt_PT');
    return FutureBuilder<Map<DateTime, List<_DayItem>>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final grouped = {
          for (final e in snap.data!.entries)
            if (_searched(query, e.value, _dayItemText) case final items
                when items.isNotEmpty)
              e.key: items,
        };
        if (grouped.isEmpty) return _emptyOr(query, 'Sem histórico.');
        final days = grouped.keys.toList();
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.colors.secondary,
                    ),
                  ),
                ),
                ...items.map((item) {
                  final timeFmt = DateFormat('HH:mm');
                  final card = Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: item.iconColor ?? context.colors.primary,
                        size: 24,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: item.deleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.names.isNotEmpty) ...[
                            _HistoryInitials(names: item.names),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            timeFmt.format(item.time),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.faint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  return item.deleted
                      ? IgnorePointer(child: Opacity(opacity: 0.4, child: card))
                      : card;
                }),
              ],
            );
          },
        );
      },
    );
  }
}
