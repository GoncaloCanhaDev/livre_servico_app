import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/opening_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/inventory_service.dart';
import '../services/opening_list_service.dart';
import '../services/report_list_service.dart';
import '../services/settings_service.dart';
import '../services/shift_service.dart';
import '../services/truck_service.dart';
import '../services/visual_list_service.dart';
import '../theme.dart';
import 'historico_screen.dart';

// Indexes mirror HistoricoScreen._tabNames.
const int _tabShifts = 1;
const int _tabTrucks = 2;
const int _tabOpening = 3;
const int _tabAuto = 4;
const int _tabReport = 5;
const int _tabVisual = 6;
const int _tabTasks = 7;
const int _tabInventory = 8;

enum _Range { week, month, allTime }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _Range _range = _Range.week;
  late Future<_Stats> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _setRange(_Range r) {
    setState(() {
      _range = r;
      _future = _load();
    });
  }

  Future<_Stats> _load() async {
    final now = DateTime.now();
    final today = currentServiceDay(now);
    final goal = SettingsService.instance.visualGoal;
    final int? days = switch (_range) {
      _Range.week => 7,
      _Range.month => 30,
      _Range.allTime => null,
    };
    final DateTime? curFrom =
        days == null ? null : today.subtract(Duration(days: days - 1));
    final cur = await _computeBucket(curFrom, null, goal);
    _Bucket? prev;
    if (days != null && curFrom != null) {
      final prevFrom = curFrom.subtract(Duration(days: days));
      final prevTo = curFrom.subtract(const Duration(days: 1));
      prev = await _computeBucket(prevFrom, prevTo, goal);
    }
    final daysSpan = days ?? 30;
    final series = <_DayBar>[];
    for (var i = daysSpan - 1; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final w = cur.dailyWorked[d] ?? Duration.zero;
      series.add(_DayBar(day: d, worked: w));
    }
    return _Stats(
      totalWorked: cur.totalWorked,
      totalPaused: cur.totalPaused,
      shiftCount: cur.shiftCount,
      truckCount: cur.truckCount,
      totalPallets: cur.totalPallets,
      aberturaTotal: cur.aberturaTotal,
      aberturaFinalized: cur.aberturaFinalized,
      reportTotal: cur.reportTotal,
      reportFinalized: cur.reportFinalized,
      autoCount: cur.autoCount,
      visualTotalItems: cur.visualTotalItems,
      visualGoalDays: cur.visualGoalDays,
      visualDaysWithEntry: cur.visualDaysWithEntry,
      visualGoal: goal,
      taskRows: cur.taskRows,
      taskDone: cur.taskDone,
      taskTotal: cur.taskTotal,
      invCount: cur.invCount,
      invValueCents: cur.invValueCents,
      series: series,
      prev: prev,
    );
  }

  Future<_Bucket> _computeBucket(DateTime? from, DateTime? to, int goal) async {
    bool inRange(DateTime d) {
      if (from != null && d.isBefore(from)) return false;
      if (to != null && d.isAfter(to)) return false;
      return true;
    }

    final shiftIds = await ShiftService.instance.allShiftIdsDesc();
    Duration totalWorked = Duration.zero;
    Duration totalPaused = Duration.zero;
    int shiftCount = 0;
    final dailyWorked = <DateTime, Duration>{};
    for (final id in shiftIds) {
      final events = await ShiftService.instance.eventsForShift(id);
      if (events.isEmpty) continue;
      final day = currentServiceDay(events.first.timestamp);
      if (!inRange(day)) continue;
      final worked = computeWorked(events);
      final paused = computePaused(events);
      totalWorked += worked;
      totalPaused += paused;
      shiftCount++;
      dailyWorked.update(day, (v) => v + worked, ifAbsent: () => worked);
    }

    final trucks = await TruckService.instance.all();
    int truckCount = 0;
    int totalPallets = 0;
    for (final t in trucks) {
      if (!inRange(currentServiceDay(t.arrivalTime))) continue;
      truckCount++;
      totalPallets += t.totalPallets;
    }

    final openings = await OpeningListService.instance.history();
    int aberturaTotal = 0;
    int aberturaFinalized = 0;
    for (final o in openings) {
      if (!inRange(o.serviceDay)) continue;
      aberturaTotal++;
      if (o.isFinalized) aberturaFinalized++;
    }

    final reports = await ReportListService.instance.history();
    int reportTotal = 0;
    int reportFinalized = 0;
    for (final r in reports) {
      if (!inRange(r.serviceDay)) continue;
      reportTotal++;
      if (r.isFinalized) reportFinalized++;
    }

    final autos = await AutoListService.instance.history();
    int autoCount = 0;
    for (final a in autos) {
      if (!inRange(currentServiceDay(a.createdAt))) continue;
      autoCount++;
    }

    final visuals = await VisualListService.instance.all();
    final visualByDay = <DateTime, int>{};
    int visualTotalItems = 0;
    for (final v in visuals) {
      final day = currentServiceDay(v.createdAt);
      if (!inRange(day)) continue;
      visualTotalItems += v.itensPicados;
      visualByDay.update(day, (s) => s + v.itensPicados,
          ifAbsent: () => v.itensPicados);
    }
    final visualDaysWithEntry = visualByDay.length;
    final visualGoalDays =
        visualByDay.values.where((items) => items >= goal).length;

    final tasks = await DailyTasksService.instance.history();
    int taskRows = 0;
    int taskDone = 0;
    int taskTotal = 0;
    for (final t in tasks) {
      if (!inRange(t.serviceDay)) continue;
      taskRows++;
      final isSaturday = t.serviceDay.weekday == DateTime.saturday;
      final openingEntries =
          await OpeningListService.instance.entriesForServiceDay(t.serviceDay);
      final aberturaDone = openingEntries.any((o) => o.isFinalized);
      final reportEntries =
          await ReportListService.instance.entriesForServiceDay(t.serviceDay);
      final relatorioDone = reportEntries.any((r) => r.isFinalized);
      final visualEntries =
          await VisualListService.instance.entriesForServiceDay(t.serviceDay);
      final visualItens =
          visualEntries.fold<int>(0, (s, e) => s + e.itensPicados);
      final visualDone = visualItens >= goal;
      final autoEntries =
          await AutoListService.instance.entriesForServiceDay(t.serviceDay);
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
        t.kiwiFecho,
        if (isSaturday) t.limpezaMaquinaVoltas,
      ];
      taskTotal += flags.length;
      taskDone += flags.where((v) => v).length;
    }

    final invs = await InventoryService.instance.history();
    int invCount = 0;
    int invValueCents = 0;
    for (final inv in invs) {
      if (!inRange(currentServiceDay(inv.createdAt))) continue;
      invCount++;
      invValueCents += inv.valueCents;
    }

    return _Bucket(
      totalWorked: totalWorked,
      totalPaused: totalPaused,
      shiftCount: shiftCount,
      truckCount: truckCount,
      totalPallets: totalPallets,
      aberturaTotal: aberturaTotal,
      aberturaFinalized: aberturaFinalized,
      reportTotal: reportTotal,
      reportFinalized: reportFinalized,
      autoCount: autoCount,
      visualTotalItems: visualTotalItems,
      visualGoalDays: visualGoalDays,
      visualDaysWithEntry: visualDaysWithEntry,
      taskRows: taskRows,
      taskDone: taskDone,
      taskTotal: taskTotal,
      invCount: invCount,
      invValueCents: invValueCents,
      dailyWorked: dailyWorked,
    );
  }

  String _fmtDur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  String _fmtEuros(int cents) {
    final v = cents / 100;
    return NumberFormat.currency(locale: 'pt_PT', symbol: '€').format(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: SafeArea(
        child: FutureBuilder<_Stats>(
          future: _future,
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final s = snap.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _rangeSelector(),
                const SizedBox(height: 16),
                _sectionTitle('Tarefas Diárias', tab: _tabTasks),
                _sectionCard(
                  tab: _tabTasks,
                  title: s.taskTotal == 0
                      ? 'Sem registos'
                      : '${s.taskDone}/${s.taskTotal} tarefas concluídas',
                  child: _ProgressRow(
                    label: s.taskRows == 0
                        ? 'Sem dias com tarefas'
                        : '${s.taskRows} dia(s) com registos',
                    value: s.taskTotal == 0 ? 0 : s.taskDone / s.taskTotal,
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Listas'),
                _kpiGrid([
                  _Kpi(
                    'Aberturas concluídas',
                    s.aberturaTotal == 0
                        ? '—'
                        : '${s.aberturaFinalized}/${s.aberturaTotal}',
                    Icons.list_alt,
                    AppColors.green,
                    tab: _tabOpening,
                    delta:
                        _deltaInt(s.aberturaFinalized, s.prev?.aberturaFinalized),
                  ),
                  _Kpi(
                    'Relatórios concluídos',
                    s.reportTotal == 0
                        ? '—'
                        : '${s.reportFinalized}/${s.reportTotal}',
                    Icons.summarize,
                    AppColors.green,
                    tab: _tabReport,
                    delta:
                        _deltaInt(s.reportFinalized, s.prev?.reportFinalized),
                  ),
                  _Kpi('Listas automáticas', '${s.autoCount}', Icons.bolt,
                      AppColors.black,
                      tab: _tabAuto,
                      delta: _deltaInt(s.autoCount, s.prev?.autoCount)),
                  _Kpi(
                    'Itens picados',
                    NumberFormat.decimalPattern('pt_PT')
                        .format(s.visualTotalItems),
                    Icons.visibility,
                    AppColors.black,
                    tab: _tabVisual,
                    delta:
                        _deltaInt(s.visualTotalItems, s.prev?.visualTotalItems),
                  ),
                ]),
                const SizedBox(height: 12),
                _sectionCard(
                  tab: _tabVisual,
                  title: 'Objetivo visual (${s.visualGoal} itens/dia)',
                  child: _ProgressRow(
                    label: s.visualDaysWithEntry == 0
                        ? 'Sem registos'
                        : '${s.visualGoalDays}/${s.visualDaysWithEntry} dias atingidos',
                    value: s.visualDaysWithEntry == 0
                        ? 0
                        : s.visualGoalDays / s.visualDaysWithEntry,
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Camiões', tab: _tabTrucks),
                _kpiGrid([
                  _Kpi('Receções', '${s.truckCount}', Icons.local_shipping,
                      AppColors.green,
                      tab: _tabTrucks,
                      delta: _deltaInt(s.truckCount, s.prev?.truckCount)),
                  _Kpi('Paletes totais', '${s.totalPallets}',
                      Icons.inventory_2, AppColors.black,
                      tab: _tabTrucks,
                      delta: _deltaInt(s.totalPallets, s.prev?.totalPallets)),
                  _Kpi(
                    'Média de paletes',
                    s.truckCount == 0
                        ? '—'
                        : (s.totalPallets / s.truckCount).toStringAsFixed(1),
                    Icons.bar_chart,
                    AppColors.black,
                    tab: _tabTrucks,
                  ),
                ]),
                const SizedBox(height: 16),
                _sectionTitle('Inventários', tab: _tabInventory),
                _kpiGrid([
                  _Kpi('Inventários', '${s.invCount}', Icons.assignment,
                      AppColors.green,
                      tab: _tabInventory,
                      delta: _deltaInt(s.invCount, s.prev?.invCount)),
                  _Kpi(
                    'Valor total',
                    _fmtEuros(s.invValueCents),
                    Icons.euro,
                    s.invValueCents >= 0 ? AppColors.green : Colors.redAccent,
                    tab: _tabInventory,
                    delta: _deltaCents(s.invValueCents, s.prev?.invValueCents),
                  ),
                ]),
                const SizedBox(height: 16),
                _sectionTitle('Turnos', tab: _tabShifts),
                _kpiGrid([
                  _Kpi('Total trabalhado', _fmtDur(s.totalWorked),
                      Icons.schedule, AppColors.green,
                      tab: _tabShifts,
                      delta: _deltaDur(s.totalWorked, s.prev?.totalWorked)),
                  _Kpi('Em pausa', _fmtDur(s.totalPaused),
                      Icons.pause_circle, AppColors.greenDark,
                      tab: _tabShifts,
                      delta: _deltaDur(s.totalPaused, s.prev?.totalPaused)),
                  _Kpi('Turnos', '${s.shiftCount}', Icons.work_outline,
                      AppColors.black,
                      tab: _tabShifts,
                      delta: _deltaInt(s.shiftCount, s.prev?.shiftCount)),
                  _Kpi(
                    'Média por turno',
                    s.shiftCount == 0
                        ? '—'
                        : _fmtDur(Duration(
                            seconds: s.totalWorked.inSeconds ~/ s.shiftCount)),
                    Icons.timelapse,
                    AppColors.black,
                    tab: _tabShifts,
                  ),
                ]),
                const SizedBox(height: 16),
                _sectionCard(
                  tab: _tabShifts,
                  title: 'Horas trabalhadas',
                  child: SizedBox(
                    height: 180,
                    child: _BarChart(series: s.series),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _rangeSelector() {
    return SegmentedButton<_Range>(
      segments: const [
        ButtonSegment(value: _Range.week, label: Text('7 dias')),
        ButtonSegment(value: _Range.month, label: Text('30 dias')),
        ButtonSegment(value: _Range.allTime, label: Text('Tudo')),
      ],
      selected: {_range},
      onSelectionChanged: (s) => _setRange(s.first),
    );
  }

  Widget _sectionTitle(String text, {int? tab}) {
    final inner = Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          if (tab != null)
            const Icon(Icons.chevron_right, size: 20, color: Colors.black45),
        ],
      ),
    );
    if (tab == null) return inner;
    return InkWell(
      onTap: () => _openHistory(context, tab),
      child: inner,
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    int? tab,
  }) {
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: tab == null
          ? content
          : InkWell(
              onTap: () => _openHistory(context, tab),
              child: content,
            ),
    );
  }

  Widget _kpiGrid(List<_Kpi> kpis) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: kpis.map((k) => _KpiCard(kpi: k)).toList(),
    );
  }
}

class _Bucket {
  _Bucket({
    required this.totalWorked,
    required this.totalPaused,
    required this.shiftCount,
    required this.truckCount,
    required this.totalPallets,
    required this.aberturaTotal,
    required this.aberturaFinalized,
    required this.reportTotal,
    required this.reportFinalized,
    required this.autoCount,
    required this.visualTotalItems,
    required this.visualGoalDays,
    required this.visualDaysWithEntry,
    required this.taskRows,
    required this.taskDone,
    required this.taskTotal,
    required this.invCount,
    required this.invValueCents,
    required this.dailyWorked,
  });
  final Duration totalWorked;
  final Duration totalPaused;
  final int shiftCount;
  final int truckCount;
  final int totalPallets;
  final int aberturaTotal;
  final int aberturaFinalized;
  final int reportTotal;
  final int reportFinalized;
  final int autoCount;
  final int visualTotalItems;
  final int visualGoalDays;
  final int visualDaysWithEntry;
  final int taskRows;
  final int taskDone;
  final int taskTotal;
  final int invCount;
  final int invValueCents;
  final Map<DateTime, Duration> dailyWorked;
}

class _Stats {
  _Stats({
    required this.totalWorked,
    required this.totalPaused,
    required this.shiftCount,
    required this.truckCount,
    required this.totalPallets,
    required this.aberturaTotal,
    required this.aberturaFinalized,
    required this.reportTotal,
    required this.reportFinalized,
    required this.autoCount,
    required this.visualTotalItems,
    required this.visualGoalDays,
    required this.visualDaysWithEntry,
    required this.visualGoal,
    required this.taskRows,
    required this.taskDone,
    required this.taskTotal,
    required this.invCount,
    required this.invValueCents,
    required this.series,
    this.prev,
  });
  final _Bucket? prev;
  final Duration totalWorked;
  final Duration totalPaused;
  final int shiftCount;
  final int truckCount;
  final int totalPallets;
  final int aberturaTotal;
  final int aberturaFinalized;
  final int reportTotal;
  final int reportFinalized;
  final int autoCount;
  final int visualTotalItems;
  final int visualGoalDays;
  final int visualDaysWithEntry;
  final int visualGoal;
  final int taskRows;
  final int taskDone;
  final int taskTotal;
  final int invCount;
  final int invValueCents;
  final List<_DayBar> series;
}

class _DayBar {
  const _DayBar({required this.day, required this.worked});
  final DateTime day;
  final Duration worked;
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final isNegative = text.startsWith('-');
    final isZero = text == '0' || text == '+0' || text == '±0';
    final color = isZero
        ? Colors.black45
        : (isNegative ? Colors.redAccent : AppColors.green);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String? _deltaInt(int cur, int? prev) {
  if (prev == null) return null;
  final d = cur - prev;
  if (d == 0) return '±0';
  return d > 0 ? '+$d' : '$d';
}

String? _deltaDur(Duration cur, Duration? prev) {
  if (prev == null) return null;
  final mins = cur.inMinutes - prev.inMinutes;
  if (mins == 0) return '±0';
  final sign = mins > 0 ? '+' : '-';
  final abs = mins.abs();
  final h = abs ~/ 60;
  final m = abs % 60;
  if (h == 0) return '$sign${m}m';
  return m == 0 ? '$sign${h}h' : '$sign${h}h${m.toString().padLeft(2, '0')}';
}

String? _deltaCents(int cur, int? prev) {
  if (prev == null) return null;
  final d = cur - prev;
  if (d == 0) return '±0€';
  final sign = d > 0 ? '+' : '-';
  return '$sign${(d.abs() / 100).toStringAsFixed(0)}€';
}

class _Kpi {
  const _Kpi(this.label, this.value, this.icon, this.color,
      {this.tab, this.delta});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int? tab;
  final String? delta;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});
  final _Kpi kpi;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(kpi.icon, color: kpi.color, size: 22),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              kpi.value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  kpi.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
              if (kpi.delta != null) _DeltaBadge(text: kpi.delta!),
            ],
          ),
        ],
      ),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: kpi.tab == null
          ? content
          : InkWell(
              onTap: () => _openHistory(context, kpi.tab!),
              child: content,
            ),
    );
  }
}

void _openHistory(BuildContext context, int tab) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => HistoricoScreen(initialTab: tab),
  ));
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 1) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
            Text('$pct%',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1).toDouble(),
            minHeight: 8,
            color: AppColors.green,
            backgroundColor: AppColors.grey,
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.series});
  final List<_DayBar> series;

  @override
  Widget build(BuildContext context) {
    final maxHours = series
        .map((b) => b.worked.inMinutes / 60.0)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = (maxHours <= 0 ? 1.0 : (maxHours * 1.15)).ceilToDouble();
    final showEvery = series.length > 14 ? 5 : 1;
    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 8 ? 4 : 2,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.grey, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY > 8 ? 4 : 2,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= series.length) return const SizedBox();
                if (i % showEvery != 0) return const SizedBox();
                final d = series[i].day;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('d/M').format(d),
                    style:
                        const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < series.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: series[i].worked.inMinutes / 60.0,
                  color: AppColors.green,
                  width: series.length > 14 ? 6 : 12,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
