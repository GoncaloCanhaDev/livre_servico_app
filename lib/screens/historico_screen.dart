import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/auto_list.dart';
import '../models/daily_tasks.dart';
import '../models/inventory.dart';
import '../models/opening_list.dart';
import '../models/report_list.dart';
import '../models/shift_event.dart';
import '../models/truck_reception.dart';
import '../models/visual_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/inventory_service.dart';
import '../services/opening_list_service.dart';
import '../services/report_list_service.dart';
import '../services/shift_service.dart';
import '../services/truck_service.dart';
import '../services/visual_list_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key, this.initialTab = 0});

  final int initialTab;

  static const _tabNames = [
    'Tudo',
    'Turnos',
    'Camiões',
    'Abertura',
    'Automáticas',
    'Relatório',
    'Visual',
    'Tarefas',
    'Inventários',
  ];

  Future<void> _clearTab(int index) async {
    switch (index) {
      case 0:
        await _clearEverything();
        break;
      case 1:
        await ShiftService.instance.deleteAllShifts();
        break;
      case 2:
        await TruckService.instance.deleteAll();
        break;
      case 3:
        await OpeningListService.instance.deleteAll();
        break;
      case 4:
        await AutoListService.instance.deleteAll();
        break;
      case 5:
        await ReportListService.instance.deleteAll();
        break;
      case 6:
        await VisualListService.instance.deleteAll();
        break;
      case 7:
        await DailyTasksService.instance.deleteAll();
        break;
      case 8:
        await InventoryService.instance.deleteAll();
        break;
    }
  }

  Future<void> _clearEverything() async {
    await ShiftService.instance.deleteAllShifts();
    await TruckService.instance.deleteAll();
    await OpeningListService.instance.deleteAll();
    await AutoListService.instance.deleteAll();
    await ReportListService.instance.deleteAll();
    await VisualListService.instance.deleteAll();
    await DailyTasksService.instance.deleteAll();
    await InventoryService.instance.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabNames.map((n) => Tab(text: n)).toList();
    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialTab.clamp(0, tabs.length - 1),
      child: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: const Text('Histórico'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (v) async {
                  final controller = DefaultTabController.of(ctx);
                  if (v == 'tab') {
                    final name = _tabNames[controller.index];
                    if (await _confirmHardDelete(
                        ctx, 'Apagar histórico de $name?')) {
                      await _clearTab(controller.index);
                    }
                  } else if (v == 'all') {
                    if (await _confirmHardDelete(
                        ctx, 'Apagar TODO o histórico?')) {
                      await _clearEverything();
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'tab',
                    child: Text('Apagar separador atual'),
                  ),
                  PopupMenuItem(
                    value: 'all',
                    child: Text('Apagar todo o histórico',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: tabs,
            ),
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                _AllTab(),
                _ShiftsTab(),
                _TrucksTab(),
                _OpeningTab(),
                _AutoTab(),
                _ReportTab(),
                _VisualTab(),
                _TasksTab(),
                _InventoryTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _confirmHardDelete(BuildContext context, String title) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(title),
      content: const Text(
          'Vai apagar permanentemente todos os registos. Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar')),
        TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Apagar tudo',
                style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  return ok == true;
}

String _fmtH(Duration d) => '${d.inHours}h ${d.inMinutes % 60}m';

Future<bool> _confirmDelete(BuildContext context, String what) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text('Apagar $what?'),
      content: const Text('Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar')),
        TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Apagar', style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  return ok == true;
}

Widget _emptyMsg(String msg) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54)),
      ),
    );

// --- Tudo (All) ---

enum _ItemType { shift, truck, opening, auto, report, visual, tasks, inventory }

class _DayItem {
  _DayItem({
    required this.type,
    required this.time,
    required this.title,
    required this.subtitle,
    this.icon = Icons.circle,
    this.iconColor = AppColors.green,
  });
  final _ItemType type;
  final DateTime time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
}

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
    ShiftService.instance.addListener(_reload);
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
    ShiftService.instance.removeListener(_reload);
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
    setState(() { _future = _load(); });
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
    final timeFmt = DateFormat('HH:mm');

    // Shifts
    final shiftIds = await ShiftService.instance.allShiftIdsDesc();
    for (final id in shiftIds) {
      final events = await ShiftService.instance.eventsForShift(id);
      if (events.isEmpty) continue;
      final start = events.first.timestamp;
      final end = events.last.type == ShiftEventType.clockOut
          ? events.last.timestamp
          : null;
      if (end == null) continue; // Only show finished shifts
      final worked = computeWorked(events);
      items.add(_DayItem(
        type: _ItemType.shift,
        time: end,
        title: '🕒 Turno',
        subtitle: '${timeFmt.format(start)} – ${timeFmt.format(end)} · ${_fmtH(worked)}',
        icon: Icons.schedule,
      ));
    }

    // Trucks
    final trucks = await TruckService.instance.all();
    for (final t in trucks) {
      final parts = <String>[
        if (t.licensePlate != null) t.licensePlate!,
        if (t.supplier != null) t.supplier!,
      ];
      items.add(_DayItem(
        type: _ItemType.truck,
        time: t.arrivalTime,
        title: '🚛 Camião',
        subtitle: '${parts.isNotEmpty ? '${parts.join(' · ')} · ' : ''}${t.totalPallets} paletes',
        icon: Icons.local_shipping,
      ));
    }

    // Opening lists (only finalized)
    final openings = await OpeningListService.instance.history();
    for (final o in openings) {
      if (!o.isFinalized) continue;
      items.add(_DayItem(
        type: _ItemType.opening,
        time: o.finalizedAt ?? o.serviceDay,
        title: '📋 Lista de Abertura',
        subtitle: 'Cong: ${o.congelados} · OPLS: ${o.opls} · NP: ${o.naoPereciveis} · Total: ${o.total}',
        icon: Icons.check_circle,
        iconColor: AppColors.green,
      ));
    }

    // Auto lists
    final autos = await AutoListService.instance.history();
    for (final a in autos) {
      items.add(_DayItem(
        type: _ItemType.auto,
        time: a.createdAt,
        title: '⚡ Lista Automática',
        subtitle: 'Cong: ${a.congelados} · OPLS: ${a.opls} · NP: ${a.naoPereciveis} · Total: ${a.total}',
        icon: Icons.bolt,
      ));
    }

    // Reports (only finalized)
    final reports = await ReportListService.instance.history();
    for (final r in reports) {
      if (!r.isFinalized) continue;
      items.add(_DayItem(
        type: _ItemType.report,
        time: r.finalizedAt ?? r.serviceDay,
        title: '📊 Relatório',
        subtitle: 'DSV: ${r.diasSemVendas} · Reg: ${r.regularizacoes} · Mas: ${r.massiva} · Rep: ${r.repetidos} · Total: ${r.total}',
        icon: Icons.check_circle,
        iconColor: AppColors.green,
      ));
    }

    // Visual lists
    final visuals = await VisualListService.instance.all();
    for (final v in visuals) {
      items.add(_DayItem(
        type: _ItemType.visual,
        time: v.createdAt,
        title: '👁 Lista Visual',
        subtitle: '${v.itensPicados} itens picados',
        icon: Icons.visibility,
      ));
    }

    // Tasks (same counting logic as the Tasks tab — includes derived tasks)
    final tasks = await DailyTasksService.instance.history();
    for (final t in tasks) {
      final day = t.serviceDay;
      final openingEntries =
          await OpeningListService.instance.entriesForServiceDay(day);
      final aberturaDone = openingEntries.any((o) => o.isFinalized);
      final reportEntries =
          await ReportListService.instance.entriesForServiceDay(day);
      final relatorioDone = reportEntries.any((r) => r.isFinalized);
      final visualEntries =
          await VisualListService.instance.entriesForServiceDay(day);
      final visualItens =
          visualEntries.fold<int>(0, (s, e) => s + e.itensPicados);
      final visualDone = visualItens >= 200;
      final autoEntries =
          await AutoListService.instance.entriesForServiceDay(day);
      final autoDone = autoEntries.isNotEmpty;
      final isSaturday = day.weekday == DateTime.saturday;

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
        t.kiwiFecho,
        if (isSaturday) t.limpezaMaquinaVoltas,
      ];
      final total = flags.length;
      final doneCount = flags.where((v) => v).length;
      items.add(_DayItem(
        type: _ItemType.tasks,
        time: t.lastUpdatedAt ?? t.serviceDay,
        title: '✅ Tarefas Diárias',
        subtitle: '$doneCount/$total concluídas',
        icon: Icons.task_alt,
        iconColor: doneCount == total ? AppColors.green : Colors.black54,
      ));
    }

    // Inventories
    final invs = await InventoryService.instance.history();
    for (final inv in invs) {
      items.add(_DayItem(
        type: _ItemType.inventory,
        time: inv.createdAt,
        title: '📦 Inventário: ${inv.name}',
        subtitle: '${formatCents(inv.valueCents)} €',
        icon: Icons.assignment,
        iconColor: inv.valueCents >= 0 ? AppColors.green : Colors.redAccent,
      ));
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
    final dayFmt = DateFormat("EEEE, d 'de' MMMM y", 'pt_PT');
    return FutureBuilder<Map<DateTime, List<_DayItem>>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final grouped = snap.data!;
        if (grouped.isEmpty) return _emptyMsg('Sem histórico.');
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                    ),
                  ),
                ),
                ...items.map((item) {
                  final timeFmt = DateFormat('HH:mm');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(item.icon, color: item.iconColor, size: 24),
                      title: Text(item.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
                      trailing: Text(timeFmt.format(item.time),
                          style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}


class _HistoryDismissible extends StatelessWidget {
  const _HistoryDismissible({
    required this.itemKey,
    required this.child,
    required this.onDelete,
    required this.onSendWhatsApp,
    required this.deletePromptName,
  });

  final Key itemKey;
  final Widget child;
  final Future<void> Function() onDelete;
  final Future<void> Function(BuildContext) onSendWhatsApp;
  final String deletePromptName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.send, color: AppColors.green),
                  title: const Text('Enviar por WhatsApp'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await onSendWhatsApp(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text('Apagar $deletePromptName'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (await _confirmDelete(context, deletePromptName)) {
                      await onDelete();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }
}

// --- Turnos ---

class _ShiftsTab extends StatefulWidget {
  const _ShiftsTab();
  @override
  State<_ShiftsTab> createState() => _ShiftsTabState();
}

class _ShiftsTabState extends State<_ShiftsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<_ShiftRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    ShiftService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    ShiftService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() { _future = _load(); });
  }

  Future<List<_ShiftRow>> _load() async {
    final svc = ShiftService.instance;
    final ids = await svc.allShiftIdsDesc();
    final out = <_ShiftRow>[];
    for (final id in ids) {
      final events = await svc.eventsForShift(id);
      if (events.isEmpty) continue;
      out.add(_ShiftRow(
        events: events,
        worked: computeWorked(events),
        paused: computePaused(events),
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateFmt = DateFormat("EEE, d 'de' MMMM", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');
    return FutureBuilder<List<_ShiftRow>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snap.data!;
        if (rows.isEmpty) return _emptyMsg('Ainda não há turnos registados.');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (_, i) {
            final r = rows[i];
            final start = r.events.first.timestamp;
            final end = r.events.last.type == ShiftEventType.clockOut
                ? r.events.last.timestamp
                : null;
            return _HistoryDismissible(
              itemKey: ValueKey(r.events.first.id), // Using first event ID as shift key
              deletePromptName: 'turno',
              onDelete: () async {
                await ShiftService.instance.deleteShift(r.events.first.shiftId);
                setState(() {
                  _future = _load();
                });
              },
              onSendWhatsApp: (ctx) async {
                final startStr = timeFmt.format(start);
                final endStr = end == null ? 'Em curso' : timeFmt.format(end);
                final msg = '🕒 Turno: ${dateFmt.format(start)}\n'
                    'Início: $startStr\n'
                    'Fim: $endStr\n'
                    'Trabalhado: ${_fmtH(r.worked)}\n'
                    'Pausa: ${_fmtH(r.paused)}';
                await WhatsAppService.sendWithConfirm(ctx, msg);
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(dateFmt.format(start),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text([
                    end == null
                        ? 'Em curso · ${_fmtH(r.worked)}'
                        : '${timeFmt.format(start)} – ${timeFmt.format(end)} · ${_fmtH(r.worked)}',
                    if (r.paused.inSeconds > 0) 'Pausa: ${_fmtH(r.paused)}',
                  ].join('\n')),
                  trailing: Icon(
                    end == null ? Icons.timer : Icons.check_circle,
                    color: AppColors.green,
                  ),
                  children: [
                    ...r.events.map((e) => ListTile(
                          dense: true,
                          leading: Icon(_shiftIcon(e.type),
                              size: 20, color: AppColors.green),
                          title: Text(_shiftLabel(e.type)),
                          trailing: Text(timeFmt.format(e.timestamp)),
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ShiftRow {
  _ShiftRow({required this.events, required this.worked, required this.paused});
  final List<ShiftEvent> events;
  final Duration worked;
  final Duration paused;
}

IconData _shiftIcon(ShiftEventType t) {
  switch (t) {
    case ShiftEventType.clockIn:
      return Icons.login;
    case ShiftEventType.pause:
      return Icons.pause_circle;
    case ShiftEventType.lunch:
      return Icons.restaurant;
    case ShiftEventType.resume:
      return Icons.play_circle;
    case ShiftEventType.clockOut:
      return Icons.logout;
  }
}

String _shiftLabel(ShiftEventType t) {
  switch (t) {
    case ShiftEventType.clockIn:
      return 'Início de turno';
    case ShiftEventType.pause:
      return 'Pausa';
    case ShiftEventType.lunch:
      return 'Almoço';
    case ShiftEventType.resume:
      return 'Retoma';
    case ShiftEventType.clockOut:
      return 'Fim de turno';
  }
}

// --- Camiões ---

class _TrucksTab extends StatefulWidget {
  const _TrucksTab();
  @override
  State<_TrucksTab> createState() => _TrucksTabState();
}

class _TrucksTabState extends State<_TrucksTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<TruckReception>> _future;

  @override
  void initState() {
    super.initState();
    _future = TruckService.instance.all();
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
              if (t.licensePlate != null) t.licensePlate!,
              if (t.supplier != null) t.supplier!,
            ];
            return _HistoryDismissible(
              itemKey: ValueKey(t.id),
              deletePromptName: 'camião',
              onDelete: () async {
                await TruckService.instance.delete(t.id);
              },
              onSendWhatsApp: (ctx) async {
                final dateFmtWa = DateFormat("d/MM/y, HH:mm", 'pt_PT');
                final lines = StringBuffer();
                lines.writeln('🚛 Receção de Camião');
                lines.writeln('Hora: ${dateFmtWa.format(t.arrivalTime)}');
                if (t.licensePlate != null) lines.writeln('Matrícula: ${t.licensePlate}');
                if (t.supplier != null) lines.writeln('Fornecedor: ${t.supplier}');
                for (final p in t.pallets) {
                  final mista = p.mistas > 0 ? ' (${p.mistas} mista${p.mistas > 1 ? 's' : ''})' : '';
                  lines.writeln('${p.category.label}: ${p.total}$mista');
                }
                lines.writeln('Total: ${t.totalPallets} paletes, ${t.totalMistas} mistas');
                if (t.notes != null) lines.writeln('Notas: ${t.notes}');
                await WhatsAppService.sendWithConfirm(ctx, lines.toString().trim());
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(dateFmt.format(t.arrivalTime),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text([
                    if (parts.isNotEmpty) parts.join(' · '),
                    '${t.totalPallets} paletes · ${t.totalMistas} mistas',
                  ].join('\n')),
                  trailing:
                      const Icon(Icons.local_shipping, color: AppColors.green),
                  children: [
                    ...t.pallets.map((p) => ListTile(
                          dense: true,
                          title: Text(p.category.label),
                          trailing: Text('${p.total} (${p.mistas} mistas)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        )),
                    if (t.notes != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Notas: ${t.notes}',
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Abertura ---

class _OpeningTab extends StatefulWidget {
  const _OpeningTab();
  @override
  State<_OpeningTab> createState() => _OpeningTabState();
}

class _OpeningTabState extends State<_OpeningTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<OpeningList>> _future;

  @override
  void initState() {
    super.initState();
    _future = OpeningListService.instance.history();
    OpeningListService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    OpeningListService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = OpeningListService.instance.history();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dayFmt = DateFormat("d 'de' MMM y", 'pt_PT');
    return FutureBuilder<List<OpeningList>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) return _emptyMsg('Sem listas de abertura.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final l = items[i];
            return _HistoryDismissible(
              itemKey: ValueKey(l.id),
              deletePromptName: 'lista de abertura',
              onDelete: () async {
                await OpeningListService.instance.delete(l.id);
              },
              onSendWhatsApp: (ctx) async {
                final msg = '📋 Lista de Abertura (${dayFmt.format(l.serviceDay)})\n'
                    'Congelados: ${l.congelados}\n'
                    'OPLS: ${l.opls}\n'
                    'Não Perecíveis: ${l.naoPereciveis}\n'
                    'Total: ${l.total}';
                await WhatsAppService.sendWithConfirm(ctx, msg);
              },
              child: ListTile(
                leading: Icon(
                  l.isFinalized ? Icons.check_circle : Icons.edit,
                  color: l.isFinalized ? AppColors.green : Colors.black45,
                ),
                title: Text(dayFmt.format(l.serviceDay)),
                subtitle: Text(
                    'Cong: ${l.congelados} · OPLS: ${l.opls} · NP: ${l.naoPereciveis}'),
                trailing: Text('${l.total}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Automáticas ---

class _AutoTab extends StatefulWidget {
  const _AutoTab();
  @override
  State<_AutoTab> createState() => _AutoTabState();
}

class _AutoTabState extends State<_AutoTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<AutoList>> _future;

  @override
  void initState() {
    super.initState();
    _future = AutoListService.instance.history();
    AutoListService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    AutoListService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = AutoListService.instance.history();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fmt = DateFormat("d 'de' MMM, HH:mm", 'pt_PT');
    return FutureBuilder<List<AutoList>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) return _emptyMsg('Sem listas automáticas.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final l = items[i];
            return _HistoryDismissible(
              itemKey: ValueKey(l.id),
              deletePromptName: 'lista automática',
              onDelete: () async {
                await AutoListService.instance.delete(l.id);
              },
              onSendWhatsApp: (ctx) async {
                final msg = '📦 Lista Automática (${fmt.format(l.createdAt)})\n'
                    'Congelados: ${l.congelados}\n'
                    'OPLS: ${l.opls}\n'
                    'Não Perecíveis: ${l.naoPereciveis}\n'
                    'Total: ${l.total}';
                await WhatsAppService.sendWithConfirm(ctx, msg);
              },
              child: ListTile(
                leading: const Icon(Icons.bolt, color: AppColors.green),
                title: Text(fmt.format(l.createdAt)),
                subtitle: Text(
                    'Cong: ${l.congelados} · OPLS: ${l.opls} · NP: ${l.naoPereciveis}'),
                trailing: Text('${l.total}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Relatório ---

class _ReportTab extends StatefulWidget {
  const _ReportTab();
  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<ReportList>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReportListService.instance.history();
    ReportListService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    ReportListService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = ReportListService.instance.history();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dayFmt = DateFormat("d 'de' MMM y", 'pt_PT');
    return FutureBuilder<List<ReportList>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) return _emptyMsg('Sem relatórios.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final l = items[i];
            return _HistoryDismissible(
              itemKey: ValueKey(l.id),
              deletePromptName: 'relatório',
              onDelete: () async {
                await ReportListService.instance.delete(l.id);
              },
              onSendWhatsApp: (ctx) async {
                final msg = '📊 Relatório (${dayFmt.format(l.serviceDay)})\n'
                    'Dias s/ vendas: ${l.diasSemVendas}\n'
                    'Regularizações: ${l.regularizacoes}\n'
                    'Massiva: ${l.massiva}\n'
                    'Repetidos: ${l.repetidos}\n'
                    'Total: ${l.total}';
                await WhatsAppService.sendWithConfirm(ctx, msg);
              },
              child: ListTile(
                leading: Icon(
                  l.isFinalized ? Icons.check_circle : Icons.edit,
                  color: l.isFinalized ? AppColors.green : Colors.black45,
                ),
                title: Text(dayFmt.format(l.serviceDay)),
                subtitle: Text(
                    'DSV: ${l.diasSemVendas} · Reg: ${l.regularizacoes} · Mas: ${l.massiva} · Rep: ${l.repetidos}'),
                trailing: Text('${l.total}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Visual ---

class _VisualTab extends StatefulWidget {
  const _VisualTab();
  @override
  State<_VisualTab> createState() => _VisualTabState();
}

class _VisualTabState extends State<_VisualTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<VisualList>> _future;

  @override
  void initState() {
    super.initState();
    _future = VisualListService.instance.all();
    VisualListService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    VisualListService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = VisualListService.instance.all();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dayFmt = DateFormat("EEE, d 'de' MMM y", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');
    return FutureBuilder<List<VisualList>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = snap.data!;
        if (all.isEmpty) return _emptyMsg('Sem listas visuais.');
        final byDay = <DateTime, List<VisualList>>{};
        for (final e in all) {
          byDay.putIfAbsent(e.serviceDay, () => []).add(e);
        }
        final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: days.length,
          itemBuilder: (_, i) {
            final day = days[i];
            final entries = byDay[day]!;
            final tI = entries.fold(0, (s, e) => s + e.itensPicados);
            final tQ = entries.fold(0, (s, e) => s + e.quebraCents);
            final tB = entries.fold(0, (s, e) => s + e.beneficioCents);
            final tTotal = tB - tQ;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                title: Text(dayFmt.format(day),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text.rich(TextSpan(
                  style: const TextStyle(fontSize: 12),
                  children: [
                    TextSpan(text: 'Itens: $tI · Total: '),
                    TextSpan(
                      text: '${formatCents(tTotal)} €',
                      style: TextStyle(
                        color: tTotal >= 0 ? AppColors.green : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )),
                children: entries.map((e) {
                  final eTotal = e.beneficioCents - e.quebraCents;
                  return _HistoryDismissible(
                    itemKey: ValueKey(e.id),
                    deletePromptName: 'entrada visual',
                    onDelete: () async {
                      await VisualListService.instance.delete(e.id);
                    },
                    onSendWhatsApp: (ctx) async {
                      final msg = '👁 Lista Visual (${timeFmt.format(e.createdAt)})\n'
                          'Itens Picados: ${e.itensPicados}\n'
                          'Quebra: -${formatCents(e.quebraCents)} €\n'
                          'Benefício: ${formatCents(e.beneficioCents)} €\n'
                          'Total: ${formatCents(eTotal)} €';
                      await WhatsAppService.sendWithConfirm(ctx, msg);
                    },
                    child: ListTile(
                      dense: true,
                      leading:
                          const Icon(Icons.visibility, color: AppColors.green),
                      title: Text(timeFmt.format(e.createdAt)),
                      subtitle: Text.rich(TextSpan(
                        style: const TextStyle(fontSize: 12),
                        children: [
                          TextSpan(text: 'Itens: ${e.itensPicados} · Quebra: '),
                          TextSpan(
                            text: '-${formatCents(e.quebraCents)} €',
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ' · Benefício: '),
                          TextSpan(
                            text: '${formatCents(e.beneficioCents)} €',
                            style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ' · Total: '),
                          TextSpan(
                            text: '${formatCents(eTotal)} €',
                            style: TextStyle(
                              color: eTotal >= 0 ? AppColors.green : Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Tarefas ---

class _TasksTab extends StatefulWidget {
  const _TasksTab();
  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<_TasksRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    DailyTasksService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    DailyTasksService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<List<_TasksRow>> _load() async {
    final all = await DailyTasksService.instance.history();
    final rows = <_TasksRow>[];
    for (final t in all) {
      final day = t.serviceDay;
      final openingEntries = await OpeningListService.instance.entriesForServiceDay(day);
      final aberturaDone = openingEntries.any((o) => o.isFinalized);
      final reportEntries = await ReportListService.instance.entriesForServiceDay(day);
      final relatorioDone = reportEntries.any((r) => r.isFinalized);
      final visualEntries = await VisualListService.instance.entriesForServiceDay(day);
      final visualItens = visualEntries.fold<int>(0, (s, e) => s + e.itensPicados);
      final visualDone = visualItens >= 200;
      final autoEntries = await AutoListService.instance.entriesForServiceDay(day);
      final autoDone = autoEntries.isNotEmpty;
      rows.add(_TasksRow(
        tasks: t,
        aberturaDone: aberturaDone,
        relatorioDone: relatorioDone,
        visualDone: visualDone,
        visualItens: visualItens,
        autoDone: autoDone,
        autoCount: autoEntries.length,
      ));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dayFmt = DateFormat("EEEE, d 'de' MMM y", 'pt_PT');
    return FutureBuilder<List<_TasksRow>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) return _emptyMsg('Sem registos de tarefas.');
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (_, i) {
            final r = items[i];
            final t = r.tasks;
            final isSaturday = t.serviceDay.weekday == DateTime.saturday;

            final allTasks = <_TaskEntry>[
              _TaskEntry('Kiwi Abertura', t.kiwiAbertura),
              _TaskEntry('Alterações de Preço (${t.alteracoesPrecoCount})', t.alteracoesPreco),
              _TaskEntry('Verificação de Temperaturas', t.verificacaoTemperaturas),
              _TaskEntry('Lista de Abertura', r.aberturaDone),
              _TaskEntry('Relatório das Listas', r.relatorioDone),
              _TaskEntry('Preenchimento do Quadro', t.preenchimentoQuadro),
              _TaskEntry('Lista Visual (${r.visualItens}/200)', r.visualDone),
              _TaskEntry('Lista Automática (${r.autoCount})', r.autoDone),
              _TaskEntry('Verificação de Validades (${t.verificacaoValidadesCount})', t.verificacaoValidades),
              _TaskEntry('Kiwi Fecho', t.kiwiFecho),
              if (isSaturday) _TaskEntry('Limpeza da Máquina Voltas', t.limpezaMaquinaVoltas),
            ];
            final totalTasks = allTasks.length;
            final doneCount = allTasks.where((e) => e.done).length;

            return _HistoryDismissible(
              itemKey: ValueKey(t.id),
              deletePromptName: 'registo de tarefas',
              onDelete: () async {
                await DailyTasksService.instance.delete(t.id);
              },
              onSendWhatsApp: (ctx) async {
                String s(bool done, String label) => '${done ? '✅' : '❌'} $label';
                final lines = allTasks.map((e) => s(e.done, e.label)).join('\n');
                final msg = '📋 Tarefas (${dayFmt.format(t.serviceDay)})\n'
                    '$lines\n'
                    'Total: $doneCount/$totalTasks';
                await WhatsAppService.sendWithConfirm(ctx, msg);
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(dayFmt.format(t.serviceDay),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '$doneCount/$totalTasks tarefas concluídas',
                  ),
                  trailing: Icon(
                    doneCount == totalTasks ? Icons.check_circle : Icons.pending,
                    color: doneCount == totalTasks ? AppColors.green : Colors.black45,
                  ),
                  children: allTasks.map((e) => _taskTile(e.label, e.done)).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TaskEntry {
  const _TaskEntry(this.label, this.done);
  final String label;
  final bool done;
}

class _TasksRow {
  _TasksRow({
    required this.tasks,
    required this.aberturaDone,
    required this.relatorioDone,
    required this.visualDone,
    required this.visualItens,
    required this.autoDone,
    required this.autoCount,
  });
  final DailyTasks tasks;
  final bool aberturaDone;
  final bool relatorioDone;
  final bool visualDone;
  final int visualItens;
  final bool autoDone;
  final int autoCount;
}

Widget _taskTile(String label, bool done) {
  return ListTile(
    dense: true,
    leading: Icon(
      done ? Icons.check_circle : Icons.cancel,
      size: 20,
      color: done ? AppColors.green : Colors.black26,
    ),
    title: Text(
      label,
      style: TextStyle(
        decoration: done ? TextDecoration.lineThrough : null,
        color: done ? null : Colors.black45,
      ),
    ),
  );
}

class _InventoryTab extends StatefulWidget {
  const _InventoryTab();
  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Inventory>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _reload();
    InventoryService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    InventoryService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() { _future = InventoryService.instance.history(); });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateFmt = DateFormat("d 'de' MMMM, HH:mm", 'pt_PT');
    return FutureBuilder<List<Inventory>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const Center(child: Text('Sem inventários registados.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final inv = items[i];
            final color = inv.valueCents >= 0
                ? AppColors.green
                : Colors.redAccent;
            return _HistoryDismissible(
              itemKey: ValueKey(inv.id),
              deletePromptName: 'inventário',
              onDelete: () async {
                await InventoryService.instance.delete(inv.id);
              },
              onSendWhatsApp: (ctx) async {
                final msg = '📦 Inventário: ${inv.name}\n'
                    'Data: ${dateFmt.format(inv.createdAt)}\n'
                    'Valor: ${formatCents(inv.valueCents)} €';
                await WhatsAppService.sendWithConfirm(ctx, msg);
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(Icons.assignment, color: color),
                  title: Text(inv.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(dateFmt.format(inv.createdAt)),
                  trailing: Text(
                    '${formatCents(inv.valueCents)} €',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
