import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/names.dart';
import '../models/stats.dart';
import '../services/local_db.dart';
import '../services/stats_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'widgets/wide_layout.dart';

/// Estatísticas (level 3 and up): how a week or a month went: the tasks
/// done, by hand or by the app, não feitas and left unmarked; each day;
/// Validades; Listas 2.0; camiões, inventários and pedidos; and what each
/// person did. Shared by WhatsApp as a summary.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, this.now});

  /// "Now", for tests; the clock otherwise.
  final DateTime? now;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late StatsPeriod _period;
  StatsInput? _input;
  StoreStats? _stats;
  late final StreamSubscription<String> _writes;
  late final StreamSubscription<Set<String>> _remote;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _period = StatsPeriod.containing(StatsPeriodKind.week, _now);
    _writes = LocalDb.localWrites.listen((c) {
      if (statsCollections.contains(c)) _load();
    });
    _remote = LocalDb.listenRemote(statsCollections, _load);
    _load();
  }

  @override
  void dispose() {
    _writes.cancel();
    _remote.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final input = await loadStatsInput();
    if (!mounted) return;
    setState(() {
      _input = input;
      _stats = computeStats(_period, input, now: _now);
    });
  }

  void _show(StatsPeriod p) => setState(() {
    _period = p;
    if (_input case final input?) {
      _stats = computeStats(p, input, now: _now);
    }
  });

  bool get _atCurrent =>
      !_period.end.isBefore(StatsPeriod.containing(_period.kind, _now).end);

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final wide = columnsFor(context, 460, max: 2) == 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        actions: [
          IconButton(
            tooltip: 'Enviar por WhatsApp',
            icon: const Icon(Icons.share),
            onPressed: stats == null || stats.isEmpty
                ? null
                : () => WhatsAppService.sendWithConfirm(
                    context,
                    statsText(stats),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: SegmentedButton<StatsPeriodKind>(
                segments: const [
                  ButtonSegment(
                    value: StatsPeriodKind.week,
                    label: Text('Semana'),
                  ),
                  ButtonSegment(
                    value: StatsPeriodKind.month,
                    label: Text('Mês'),
                  ),
                ],
                selected: {_period.kind},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    _show(StatsPeriod.containing(s.single, _now)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Anterior',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _show(_period.previous),
                ),
                Expanded(
                  child: Text(
                    _period.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Seguinte',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _atCurrent ? null : () => _show(_period.next),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (stats == null)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (stats.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Nada registado neste período.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.muted),
                ),
              )
            else if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(children: _left(stats))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(children: _right(stats))),
                ],
              )
            else
              ReadableWidth(
                child: Column(children: [..._left(stats), ..._right(stats)]),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _left(StoreStats s) => [
    _Summary(stats: s),
    if (s.tasks.isNotEmpty) _TasksCard(stats: s),
    if (s.days.length > 1) _DaysCard(days: s.days),
    if (s.notDone.isNotEmpty) _NotDoneCard(notes: s.notDone),
  ];

  List<Widget> _right(StoreStats s) => [
    if (s.validadesWindows > 0) _ValidadesCard(stats: s),
    if (s.auto2Sends > 0 || s.visivelCount > 0) _ListasCard(stats: s),
    if (s.trucks > 0 ||
        s.inventoriesDone > 0 ||
        s.inventoriesLate > 0 ||
        s.pedidosCreated > 0 ||
        s.pedidosFinished > 0)
      _ActivityCard(stats: s),
    if (s.people.isNotEmpty) _PeopleCard(people: s.people),
  ];
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.children, this.note});

  final String title;
  final String? note;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (note case final n?) ...[
              const SizedBox(height: 2),
              Text(n, style: TextStyle(fontSize: 12, color: context.muted)),
            ],
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A big number with its label under it.
class _Figure extends StatelessWidget {
  const _Figure(this.value, this.label, {this.warn = false});

  final String value;
  final String label;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.faintest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: warn ? context.warningText : null,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: context.muted)),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.stats});

  final StoreStats stats;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    final figures = [
      if (s.tasksDue > 0) ...[
        _Figure(percentText(s.tasksRate), 'Tarefas feitas'),
        _Figure('${s.tasksNotDone}', 'Não feitas', warn: s.tasksNotDone > 0),
        _Figure('${s.tasksUnmarked}', 'Sem registo', warn: s.tasksUnmarked > 0),
        _Figure('${s.tasksAuto}', 'Marcadas pela app'),
      ],
      if (s.trucks > 0) _Figure('${s.trucks}', 'Camiões'),
      if (s.auto2Sends > 0) _Figure('${s.auto2Sends}', 'Automáticas'),
      if (s.visivelCount > 0) _Figure('${s.visivelCount}', 'Visível'),
      if (s.inventoriesDone > 0) _Figure('${s.inventoriesDone}', 'Inventários'),
    ];
    return _StatCard(
      title: 'Resumo',
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final perRow = c.maxWidth >= 420 ? 4 : 2;
            final width = (c.maxWidth - 8 * (perRow - 1)) / perRow;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in figures) SizedBox(width: width, child: f),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// A thin bar filled to [rate] (0 to 1).
class _Bar extends StatelessWidget {
  const _Bar(this.rate);

  final double rate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: rate,
        minHeight: 8,
        backgroundColor: context.faint,
        color: rate >= 0.9
            ? Colors.green.shade600
            : rate >= 0.7
            ? Colors.orange.shade600
            : Colors.red.shade400,
      ),
    );
  }
}

class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.stats});

  final StoreStats stats;

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      title: 'Tarefas',
      note:
          'Cada vez que uma tarefa devia ser feita, desde que acabou a sua '
          'hora. "Sem registo": ninguém a marcou.',
      children: [
        for (final t in stats.tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${t.done}/${t.due} · ${percentText(t.rate)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _Bar(t.rate ?? 0),
                if (t.auto > 0 || t.notDone > 0 || t.unmarked > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (t.auto > 0) '${t.auto} pela app',
                      if (t.notDone > 0)
                        '${t.notDone} não feita${t.notDone == 1 ? '' : 's'}',
                      if (t.unmarked > 0) '${t.unmarked} sem registo',
                    ].join(' · '),
                    style: TextStyle(fontSize: 12, color: context.muted),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _DaysCard extends StatelessWidget {
  const _DaysCard({required this.days});

  final List<DayStat> days;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE d/MM', 'pt_PT');
    return _StatCard(
      title: 'Por dia',
      note: 'Tarefas diárias feitas em cada dia.',
      children: [
        for (final d in days)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 82,
                  child: Text(
                    fmt.format(d.day),
                    style: TextStyle(fontSize: 13, color: context.muted),
                  ),
                ),
                Expanded(child: _Bar(d.rate ?? 0)),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${d.done}/${d.due}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NotDoneCard extends StatelessWidget {
  const _NotDoneCard({required this.notes});

  final List<NotDoneNote> notes;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE d/MM', 'pt_PT');
    return _StatCard(
      title: 'Não feitas',
      children: [
        for (final n in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fmt.format(n.day)} · ${n.label}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  [
                    n.reason.isEmpty ? 'Sem motivo' : n.reason,
                    if (n.byNames.isNotEmpty) joinNames(n.byNames),
                  ].join(' — '),
                  style: TextStyle(color: context.muted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ValidadesCard extends StatelessWidget {
  const _ValidadesCard({required this.stats});

  final StoreStats stats;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    Widget row(String label, int count, int left) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            '$count artigos · $left por fazer',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: left > 0 ? context.warningText : null,
            ),
          ),
        ],
      ),
    );
    return _StatCard(
      title: 'Validades',
      note: 'Artigos a verificar em cada turno e quantos ficaram por fazer.',
      children: [
        row('Manhã', s.validadesManhaCount, s.validadesManhaLeft),
        row('Noite', s.validadesNoiteCount, s.validadesNoiteLeft),
      ],
    );
  }
}

class _ListasCard extends StatelessWidget {
  const _ListasCard({required this.stats});

  final StoreStats stats;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    final muted = TextStyle(fontSize: 12, color: context.muted);
    return _StatCard(
      title: 'Listas 2.0',
      children: [
        if (s.auto2Sends > 0) ...[
          Text(
            '${s.auto2Sends} Automáticas · ${s.auto2Value} artigos, '
            '${s.auto2PorTratar} por tratar, ${s.auto2SemStock} sem stock',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          for (final i in s.auto2Items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(child: Text(i.label)),
                  Text(
                    '${i.sends}× · ${i.value} art. · ${i.porTratar} p/ tratar',
                    style: muted,
                  ),
                ],
              ),
            ),
        ],
        if (s.visivelCount > 0) ...[
          if (s.auto2Sends > 0) const Divider(),
          Text(
            '${s.visivelCount} Visível · ${s.visivelItens} itens picados',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.stats});

  final StoreStats stats;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    Widget line(IconData icon, String text, {bool warn = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: warn ? context.warningText : null),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: warn ? context.warningText : null),
            ),
          ),
        ],
      ),
    );
    return _StatCard(
      title: 'Receção e inventários',
      children: [
        if (s.trucks > 0)
          line(
            Icons.local_shipping,
            '${s.trucks} ${s.trucks == 1 ? 'camião' : 'camiões'} · '
            '${s.pallets} paletes (${s.mistas} mistas), '
            '${s.expositores} expositores',
          ),
        if (s.inventoriesDone > 0)
          line(
            Icons.assignment,
            '${s.inventoriesDone} inventário'
            '${s.inventoriesDone == 1 ? '' : 's'} feito'
            '${s.inventoriesDone == 1 ? '' : 's'}',
          ),
        if (s.inventoriesLate > 0)
          line(
            Icons.assignment_late,
            '${s.inventoriesLate} inventário'
            '${s.inventoriesLate == 1 ? '' : 's'} em atraso',
            warn: true,
          ),
        if (s.pedidosCreated > 0 || s.pedidosFinished > 0)
          line(
            Icons.receipt_long,
            '${s.pedidosCreated} pedido${s.pedidosCreated == 1 ? '' : 's'} '
            'criado${s.pedidosCreated == 1 ? '' : 's'}, '
            '${s.pedidosFinished} finalizado'
            '${s.pedidosFinished == 1 ? '' : 's'}',
          ),
      ],
    );
  }
}

class _PeopleCard extends StatelessWidget {
  const _PeopleCard({required this.people});

  final List<PersonStat> people;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(fontSize: 12, color: context.muted);
    return _StatCard(
      title: 'Pessoas',
      note: 'O que ficou registado com o nome de cada um.',
      children: [
        for (final p in people)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  [
                    if (p.tasks > 0)
                      '${p.tasks} tarefa${p.tasks == 1 ? '' : 's'}',
                    if (p.autoTasks > 0) '${p.autoTasks} pela app',
                    if (p.auto2 > 0) '${p.auto2} Automáticas',
                    if (p.visivel > 0) '${p.visivel} Visível',
                    if (p.trucks > 0)
                      '${p.trucks} ${p.trucks == 1 ? 'camião' : 'camiões'}',
                    if (p.inventories > 0)
                      '${p.inventories} inventário'
                          '${p.inventories == 1 ? '' : 's'}',
                  ].join(' · '),
                  style: muted,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
