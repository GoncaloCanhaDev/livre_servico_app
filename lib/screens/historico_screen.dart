import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/auto_list.dart';
import '../models/daily_tasks.dart';
import '../models/opening_list.dart';
import '../models/report_list.dart';
import '../models/shift_event.dart';
import '../models/truck_reception.dart';
import '../models/visual_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/opening_list_service.dart';
import '../services/report_list_service.dart';
import '../services/shift_service.dart';
import '../services/truck_service.dart';
import '../services/visual_list_service.dart';
import '../theme.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  static const _tabNames = [
    'Turnos',
    'Camiões',
    'Abertura',
    'Automáticas',
    'Relatório',
    'Visual',
    'Tarefas',
  ];

  Future<void> _clearTab(int index) async {
    switch (index) {
      case 0:
        await ShiftService.instance.deleteAllShifts();
        break;
      case 1:
        await TruckService.instance.deleteAll();
        break;
      case 2:
        await OpeningListService.instance.deleteAll();
        break;
      case 3:
        await AutoListService.instance.deleteAll();
        break;
      case 4:
        await ReportListService.instance.deleteAll();
        break;
      case 5:
        await VisualListService.instance.deleteAll();
        break;
      case 6:
        await DailyTasksService.instance.deleteAll();
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
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabNames.map((n) => Tab(text: n)).toList();
    return DefaultTabController(
      length: tabs.length,
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
          body: const TabBarView(
            children: [
              _ShiftsTab(),
              _TrucksTab(),
              _OpeningTab(),
              _AutoTab(),
              _ReportTab(),
              _VisualTab(),
              _TasksTab(),
            ],
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

// --- Turnos ---

class _ShiftsTab extends StatefulWidget {
  const _ShiftsTab();
  @override
  State<_ShiftsTab> createState() => _ShiftsTabState();
}

class _ShiftsTabState extends State<_ShiftsTab> {
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
    setState(() => _future = _load());
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
            return Card(
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        if (await _confirmDelete(context, 'turno')) {
                          await ShiftService.instance
                              .deleteShift(r.events.first.shiftId);
                          setState(() => _future = _load());
                        }
                      },
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

class _TrucksTabState extends State<_TrucksTab> {
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
            return Card(
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        if (await _confirmDelete(context, 'camião')) {
                          await TruckService.instance.delete(t.id);
                        }
                      },
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
    );
  }
}

// --- Abertura ---

class _OpeningTab extends StatefulWidget {
  const _OpeningTab();
  @override
  State<_OpeningTab> createState() => _OpeningTabState();
}

class _OpeningTabState extends State<_OpeningTab> {
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
            return ListTile(
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
              onLongPress: () async {
                if (await _confirmDelete(context, 'lista de abertura')) {
                  await OpeningListService.instance.delete(l.id);
                }
              },
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

class _AutoTabState extends State<_AutoTab> {
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
            return ListTile(
              leading: const Icon(Icons.bolt, color: AppColors.green),
              title: Text(fmt.format(l.createdAt)),
              subtitle: Text(
                  'Cong: ${l.congelados} · OPLS: ${l.opls} · NP: ${l.naoPereciveis}'),
              trailing: Text('${l.total}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              onLongPress: () async {
                if (await _confirmDelete(context, 'lista automática')) {
                  await AutoListService.instance.delete(l.id);
                }
              },
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

class _ReportTabState extends State<_ReportTab> {
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
            return ListTile(
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
              onLongPress: () async {
                if (await _confirmDelete(context, 'relatório')) {
                  await ReportListService.instance.delete(l.id);
                }
              },
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

class _VisualTabState extends State<_VisualTab> {
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                title: Text(dayFmt.format(day),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    'Itens: $tI · Quebra: ${formatCents(tQ)} € · Benefício: ${formatCents(tB)} €'),
                children: entries.map((e) {
                  return ListTile(
                    dense: true,
                    leading:
                        const Icon(Icons.visibility, color: AppColors.green),
                    title: Text(timeFmt.format(e.createdAt)),
                    subtitle: Text(
                        'Itens: ${e.itensPicados} · Quebra: ${formatCents(e.quebraCents)} € · Benefício: ${formatCents(e.beneficioCents)} €'),
                    onLongPress: () async {
                      if (await _confirmDelete(context, 'entrada visual')) {
                        await VisualListService.instance.delete(e.id);
                      }
                    },
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

class _TasksTabState extends State<_TasksTab> {
  late Future<List<DailyTasks>> _future;

  @override
  void initState() {
    super.initState();
    _future = DailyTasksService.instance.history();
    DailyTasksService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    DailyTasksService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = DailyTasksService.instance.history();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat("EEEE, d 'de' MMM y", 'pt_PT');
    return FutureBuilder<List<DailyTasks>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) return _emptyMsg('Sem registos de tarefas.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final t = items[i];
            final manual = [
              if (t.kiwiAbertura) 'Kiwi Abertura',
              if (t.alteracoesPreco)
                'Alterações de Preço (${t.alteracoesPrecoCount})',
              if (t.verificacaoTemperaturas) 'Temperaturas',
              if (t.preenchimentoQuadro) 'Preench. Quadro',
              if (t.verificacaoValidades)
                'Validades (${t.verificacaoValidadesCount})',
              if (t.kiwiFecho) 'Kiwi Fecho',
              if (t.limpezaMaquinaVoltas) 'Limpeza Máquina',
            ];
            return ListTile(
              title: Text(dayFmt.format(t.serviceDay),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                manual.isEmpty
                    ? 'Sem tarefas manuais marcadas'
                    : manual.join(' · '),
              ),
              onLongPress: () async {
                if (await _confirmDelete(context, 'registo de tarefas')) {
                  await DailyTasksService.instance.delete(t.id);
                }
              },
            );
          },
        );
      },
    );
  }
}
