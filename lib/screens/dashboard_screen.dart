import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/justification.dart';
import '../models/opening_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/inventory_service.dart';
import '../services/justification_service.dart';
import '../services/opening_list_service.dart';
import '../services/report_list_service.dart';
import '../services/settings_service.dart';
import '../services/shift_service.dart';
import '../services/truck_service.dart';
import '../services/visual_list_service.dart';
import '../theme.dart';
import 'historico_screen.dart';
import 'widgets/missed_day_sheet.dart';

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
    final cur = await _computeBucket(curFrom, null, today, goal);
    _Bucket? prev;
    if (days != null && curFrom != null) {
      final prevFrom = curFrom.subtract(Duration(days: days));
      final prevTo = curFrom.subtract(const Duration(days: 1));
      prev = await _computeBucket(prevFrom, prevTo, prevTo, goal);
    }
    final daysSpan = days ?? 30;
    final series = <_DayBar>[];
    for (var i = daysSpan - 1; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final w = cur.dailyWorked[d] ?? Duration.zero;
      series.add(_DayBar(day: d, worked: w));
    }
    return _Stats(bucket: cur, prev: prev, visualGoal: goal, series: series);
  }

  Future<_Bucket> _computeBucket(
      DateTime? from, DateTime? to, DateTime referenceDay, int goal) async {
    bool inRange(DateTime d) {
      if (from != null && d.isBefore(from)) return false;
      if (to != null && d.isAfter(to)) return false;
      return true;
    }
    DateTime? minDayInData;
    void track(DateTime d) {
      if (minDayInData == null || d.isBefore(minDayInData!)) minDayInData = d;
    }

    final shiftIds = await ShiftService.instance.allShiftIdsDesc();
    Duration totalWorked = Duration.zero;
    Duration totalPaused = Duration.zero;
    int shiftCount = 0;
    Duration longestShift = Duration.zero;
    Duration shortestShift = Duration.zero;
    final dailyWorked = <DateTime, Duration>{};
    final shiftByWeekday = <int, Duration>{};
    int startHourSum = 0;
    int endHourSum = 0;
    int shiftStartCount = 0;
    int shiftEndCount = 0;
    final hourBucket = <int, int>{}; // arrival hours by hour-of-day
    for (final id in shiftIds) {
      final events = await ShiftService.instance.eventsForShift(id);
      if (events.isEmpty) continue;
      final day = currentServiceDay(events.first.timestamp);
      if (!inRange(day)) continue;
      track(day);
      final worked = computeWorked(events);
      final paused = computePaused(events);
      totalWorked += worked;
      totalPaused += paused;
      shiftCount++;
      if (worked > longestShift) longestShift = worked;
      if (shortestShift == Duration.zero || worked < shortestShift) {
        shortestShift = worked;
      }
      dailyWorked.update(day, (v) => v + worked, ifAbsent: () => worked);
      shiftByWeekday.update(day.weekday, (v) => v + worked,
          ifAbsent: () => worked);
      final startedAt = events.first.timestamp;
      startHourSum += startedAt.hour;
      shiftStartCount++;
      hourBucket.update(startedAt.hour, (v) => v + 1, ifAbsent: () => 1);
      final endedAt = events.last.timestamp;
      if (endedAt != startedAt) {
        endHourSum += endedAt.hour;
        shiftEndCount++;
      }
    }
    final avgStartHour =
        shiftStartCount == 0 ? null : startHourSum / shiftStartCount;
    final avgEndHour = shiftEndCount == 0 ? null : endHourSum / shiftEndCount;

    final trucks = await TruckService.instance.all();
    int truckCount = 0;
    int totalPallets = 0;
    int totalMistas = 0;
    int maxPalletsInTruck = 0;
    final truckByWeekday = <int, int>{};
    final truckPalletsByDay = <DateTime, int>{};
    final truckArrivalByHour = <int, int>{};
    final palletsPerTruck = <int>[];
    for (final t in trucks) {
      final day = currentServiceDay(t.arrivalTime);
      if (!inRange(day)) continue;
      track(day);
      truckCount++;
      totalPallets += t.totalPallets;
      totalMistas += t.totalMistas;
      palletsPerTruck.add(t.totalPallets);
      if (t.totalPallets > maxPalletsInTruck) maxPalletsInTruck = t.totalPallets;
      truckByWeekday.update(day.weekday, (v) => v + 1, ifAbsent: () => 1);
      truckPalletsByDay.update(day, (v) => v + t.totalPallets,
          ifAbsent: () => t.totalPallets);
      truckArrivalByHour.update(t.arrivalTime.hour, (v) => v + 1,
          ifAbsent: () => 1);
    }
    palletsPerTruck.sort();
    final medianPalletsTruck = palletsPerTruck.isEmpty
        ? 0
        : palletsPerTruck[palletsPerTruck.length ~/ 2];
    final biggestTruckDayPallets = truckPalletsByDay.values.isEmpty
        ? 0
        : truckPalletsByDay.values.reduce((a, b) => a > b ? a : b);

    final openings = await OpeningListService.instance.history();
    int aberturaTotal = 0;
    int aberturaFinalized = 0;
    int aberturaItems = 0;
    int aberturaCongelados = 0;
    int aberturaOpls = 0;
    int aberturaNaoPereciveis = 0;
    DateTime? aberturaLastDay;
    final aberturaByWeekday = <int, int>{};
    final aberturaFinalizedDays = <DateTime>{};
    for (final o in openings) {
      if (!inRange(o.serviceDay)) continue;
      track(o.serviceDay);
      aberturaTotal++;
      if (o.isFinalized) {
        aberturaFinalized++;
        aberturaFinalizedDays.add(o.serviceDay);
      }
      aberturaItems += o.total;
      aberturaCongelados += o.congelados;
      aberturaOpls += o.opls;
      aberturaNaoPereciveis += o.naoPereciveis;
      aberturaLastDay = aberturaLastDay == null ||
              o.serviceDay.isAfter(aberturaLastDay)
          ? o.serviceDay
          : aberturaLastDay;
      aberturaByWeekday.update(o.serviceDay.weekday, (v) => v + 1,
          ifAbsent: () => 1);
    }

    final reports = await ReportListService.instance.history();
    int reportTotal = 0;
    int reportFinalized = 0;
    int reportItems = 0;
    int reportDiasSemVendas = 0;
    int reportRegularizacoes = 0;
    int reportMassiva = 0;
    int reportRepetidos = 0;
    DateTime? reportLastDay;
    final reportByWeekday = <int, int>{};
    final reportFinalizedDays = <DateTime>{};
    for (final r in reports) {
      if (!inRange(r.serviceDay)) continue;
      track(r.serviceDay);
      reportTotal++;
      if (r.isFinalized) {
        reportFinalized++;
        reportFinalizedDays.add(r.serviceDay);
      }
      reportItems += r.total;
      reportDiasSemVendas += r.diasSemVendas;
      reportRegularizacoes += r.regularizacoes;
      reportMassiva += r.massiva;
      reportRepetidos += r.repetidos;
      reportLastDay =
          reportLastDay == null || r.serviceDay.isAfter(reportLastDay)
              ? r.serviceDay
              : reportLastDay;
      reportByWeekday.update(r.serviceDay.weekday, (v) => v + 1,
          ifAbsent: () => 1);
    }

    final autos = await AutoListService.instance.history();
    int autoCount = 0;
    int autoItems = 0;
    int autoCongelados = 0;
    int autoOpls = 0;
    int autoNaoPereciveis = 0;
    DateTime? autoLastDay;
    final autoByWeekday = <int, int>{};
    final autoDays = <DateTime>{};
    for (final a in autos) {
      final day = currentServiceDay(a.createdAt);
      if (!inRange(day)) continue;
      track(day);
      autoCount++;
      autoDays.add(day);
      autoItems += a.total;
      autoCongelados += a.congelados;
      autoOpls += a.opls;
      autoNaoPereciveis += a.naoPereciveis;
      autoLastDay =
          autoLastDay == null || day.isAfter(autoLastDay) ? day : autoLastDay;
      autoByWeekday.update(day.weekday, (v) => v + 1, ifAbsent: () => 1);
    }

    final visuals = await VisualListService.instance.all();
    final visualByDay = <DateTime, int>{};
    int visualTotalItems = 0;
    int visualQuebraCents = 0;
    int visualBeneficioCents = 0;
    final visualByWeekday = <int, int>{};
    for (final v in visuals) {
      final day = currentServiceDay(v.createdAt);
      if (!inRange(day)) continue;
      track(day);
      visualTotalItems += v.itensPicados;
      visualQuebraCents += v.quebraCents;
      visualBeneficioCents += v.beneficioCents;
      visualByDay.update(day, (s) => s + v.itensPicados,
          ifAbsent: () => v.itensPicados);
      visualByWeekday.update(day.weekday, (v2) => v2 + v.itensPicados,
          ifAbsent: () => v.itensPicados);
    }
    final visualDaysWithEntry = visualByDay.length;
    final visualGoalDays =
        visualByDay.values.where((items) => items >= goal).length;
    final visualBestDayItems = visualByDay.values.isEmpty
        ? 0
        : visualByDay.values.reduce((a, b) => a > b ? a : b);
    final visualWorstDayItems = visualByDay.values.isEmpty
        ? 0
        : visualByDay.values.reduce((a, b) => a < b ? a : b);
    final sortedDayItems = visualByDay.values.toList()..sort();
    final visualMedianItems = sortedDayItems.isEmpty
        ? 0
        : sortedDayItems[sortedDayItems.length ~/ 2];
    int visualStreak = 0;
    int visualBestStreak = 0;
    final sortedDays = visualByDay.keys.toList()..sort();
    DateTime? prevDay;
    for (final d in sortedDays) {
      final items = visualByDay[d] ?? 0;
      if (items >= goal) {
        if (prevDay != null &&
            d.difference(prevDay).inDays == 1) {
          visualStreak++;
        } else {
          visualStreak = 1;
        }
        if (visualStreak > visualBestStreak) visualBestStreak = visualStreak;
      } else {
        visualStreak = 0;
      }
      prevDay = d;
    }

    final tasks = await DailyTasksService.instance.history();
    final taskByDay = <DateTime, dynamic>{};
    int taskRows = 0;
    int taskPrecoSum = 0;
    int taskValidadesSum = 0;
    for (final t in tasks) {
      if (!inRange(t.serviceDay)) continue;
      track(t.serviceDay);
      taskByDay[t.serviceDay] = t;
      taskRows++;
      taskPrecoSum += t.alteracoesPrecoCount;
      taskValidadesSum += t.verificacaoValidadesCount;
    }

    // Determine effective range for "expected daily" calculations.
    final effectiveFrom = from ?? minDayInData ?? referenceDay;
    final effectiveTo = to ?? referenceDay;
    int daysInRange = 0;
    int saturdaysInRange = 0;
    final allDaysInRange = <DateTime>[];
    if (!effectiveFrom.isAfter(effectiveTo)) {
      for (var d = effectiveFrom;
          !d.isAfter(effectiveTo);
          d = d.add(const Duration(days: 1))) {
        daysInRange++;
        if (d.weekday == DateTime.saturday) saturdaysInRange++;
        allDaysInRange.add(d);
      }
    }
    final aberturaDoneDays = aberturaFinalizedDays.length;
    final reportDoneDays = reportFinalizedDays.length;
    final autoDoneDays = autoDays.length;

    // Load justifications for this range, indexed by kind.
    final justRows = await JustificationService.instance.all();
    final justByKind = <String, Set<DateTime>>{};
    for (final j in justRows) {
      if (!inRange(j.serviceDay)) continue;
      justByKind.putIfAbsent(j.kind, () => <DateTime>{}).add(j.serviceDay);
    }
    Set<DateTime> just(String k) => justByKind[k] ?? const {};

    List<DateTime> missed(bool Function(DateTime) failed, String kind) {
      final js = just(kind);
      return [
        for (final d in allDaysInRange)
          if (failed(d) && !js.contains(d)) d
      ];
    }

    List<DateTime> justified(bool Function(DateTime) failed, String kind) {
      final js = just(kind);
      return [
        for (final d in allDaysInRange)
          if (failed(d) && js.contains(d)) d
      ];
    }

    final aberturaMissedDays = missed(
        (d) => !aberturaFinalizedDays.contains(d), JustificationKind.opening);
    final aberturaJustifiedDays = justified(
        (d) => !aberturaFinalizedDays.contains(d), JustificationKind.opening);
    final reportMissedDays = missed(
        (d) => !reportFinalizedDays.contains(d), JustificationKind.report);
    final reportJustifiedDays = justified(
        (d) => !reportFinalizedDays.contains(d), JustificationKind.report);
    final autoMissedDays =
        missed((d) => !autoDays.contains(d), JustificationKind.auto);
    final autoJustifiedDays =
        justified((d) => !autoDays.contains(d), JustificationKind.auto);
    final visualMissedDays = missed(
        (d) => (visualByDay[d] ?? 0) < goal, JustificationKind.visual);
    final visualJustifiedDays = justified(
        (d) => (visualByDay[d] ?? 0) < goal, JustificationKind.visual);

    int taskDone = 0;
    int taskTotal = 0;
    final taskDoneByName = <String, int>{};
    final taskTotalByName = <String, int>{};
    final taskMissedDays = <DateTime>[];
    void bump(String name, bool done) {
      taskTotalByName.update(name, (v) => v + 1, ifAbsent: () => 1);
      if (done) {
        taskDoneByName.update(name, (v) => v + 1, ifAbsent: () => 1);
      } else {
        taskDoneByName.putIfAbsent(name, () => 0);
      }
    }

    for (final day in allDaysInRange) {
      final t = taskByDay[day];
      final isSaturday = day.weekday == DateTime.saturday;
      final aberturaDone = aberturaFinalizedDays.contains(day);
      final relatorioDone = reportFinalizedDays.contains(day);
      final visualDone = (visualByDay[day] ?? 0) >= goal;
      final autoDone = autoDays.contains(day);

      bump('Kiwi abertura', t?.kiwiAbertura ?? false);
      bump('Alterações de preço', t?.alteracoesPreco ?? false);
      bump('Verificação temperaturas', t?.verificacaoTemperaturas ?? false);
      bump('Lista abertura', aberturaDone);
      bump('Relatório', relatorioDone);
      bump('Preenchimento quadro', t?.preenchimentoQuadro ?? false);
      bump('Visual', visualDone);
      bump('Lista automática', autoDone);
      bump('Verificação validades', t?.verificacaoValidades ?? false);
      bump('Kiwi fecho', t?.kiwiFecho ?? false);
      if (isSaturday) {
        bump('Limpeza máquina voltas', t?.limpezaMaquinaVoltas ?? false);
      }

      final flags = <bool>[
        t?.kiwiAbertura ?? false,
        t?.alteracoesPreco ?? false,
        t?.verificacaoTemperaturas ?? false,
        aberturaDone,
        relatorioDone,
        t?.preenchimentoQuadro ?? false,
        visualDone,
        autoDone,
        t?.verificacaoValidades ?? false,
        t?.kiwiFecho ?? false,
        if (isSaturday) t?.limpezaMaquinaVoltas ?? false,
      ];
      taskTotal += flags.length;
      final dayDone = flags.where((v) => v).length;
      taskDone += dayDone;
      if (dayDone < flags.length) taskMissedDays.add(day);
    }
    final taskJustSet = just(JustificationKind.tasks);
    final taskJustifiedDays =
        taskMissedDays.where(taskJustSet.contains).toList();
    taskMissedDays.removeWhere(taskJustSet.contains);

    final invs = await InventoryService.instance.history();
    int invCount = 0;
    int invValueCents = 0;
    int invMaxValueCents = 0;
    final invByWeekday = <int, int>{};
    final invByDayCents = <DateTime, int>{};
    final invValuesCents = <int>[];
    for (final inv in invs) {
      final day = currentServiceDay(inv.createdAt);
      if (!inRange(day)) continue;
      track(day);
      invCount++;
      invValueCents += inv.valueCents;
      invValuesCents.add(inv.valueCents);
      if (inv.valueCents > invMaxValueCents) invMaxValueCents = inv.valueCents;
      invByWeekday.update(day.weekday, (v) => v + 1, ifAbsent: () => 1);
      invByDayCents.update(day, (v) => v + inv.valueCents,
          ifAbsent: () => inv.valueCents);
    }
    invValuesCents.sort();
    final invMedianValueCents = invValuesCents.isEmpty
        ? 0
        : invValuesCents[invValuesCents.length ~/ 2];
    final invBiggestDayCents = invByDayCents.values.isEmpty
        ? 0
        : invByDayCents.values.reduce((a, b) => a > b ? a : b);

    return _Bucket(
      daysInRange: daysInRange,
      saturdaysInRange: saturdaysInRange,
      aberturaDoneDays: aberturaDoneDays,
      reportDoneDays: reportDoneDays,
      autoDoneDays: autoDoneDays,
      aberturaMissedDays: aberturaMissedDays,
      reportMissedDays: reportMissedDays,
      autoMissedDays: autoMissedDays,
      visualMissedDays: visualMissedDays,
      taskMissedDays: taskMissedDays,
      aberturaJustifiedDays: aberturaJustifiedDays,
      reportJustifiedDays: reportJustifiedDays,
      autoJustifiedDays: autoJustifiedDays,
      visualJustifiedDays: visualJustifiedDays,
      taskJustifiedDays: taskJustifiedDays,
      totalWorked: totalWorked,
      totalPaused: totalPaused,
      shiftCount: shiftCount,
      longestShift: longestShift,
      shortestShift: shortestShift,
      shiftByWeekday: shiftByWeekday,
      avgStartHour: avgStartHour,
      avgEndHour: avgEndHour,
      shiftStartByHour: hourBucket,
      truckCount: truckCount,
      totalPallets: totalPallets,
      totalMistas: totalMistas,
      maxPalletsInTruck: maxPalletsInTruck,
      medianPalletsTruck: medianPalletsTruck,
      biggestTruckDayPallets: biggestTruckDayPallets,
      truckByWeekday: truckByWeekday,
      truckArrivalByHour: truckArrivalByHour,
      aberturaTotal: aberturaTotal,
      aberturaFinalized: aberturaFinalized,
      aberturaItems: aberturaItems,
      aberturaCongelados: aberturaCongelados,
      aberturaOpls: aberturaOpls,
      aberturaNaoPereciveis: aberturaNaoPereciveis,
      aberturaLastDay: aberturaLastDay,
      aberturaByWeekday: aberturaByWeekday,
      reportTotal: reportTotal,
      reportFinalized: reportFinalized,
      reportItems: reportItems,
      reportDiasSemVendas: reportDiasSemVendas,
      reportRegularizacoes: reportRegularizacoes,
      reportMassiva: reportMassiva,
      reportRepetidos: reportRepetidos,
      reportLastDay: reportLastDay,
      reportByWeekday: reportByWeekday,
      autoCount: autoCount,
      autoItems: autoItems,
      autoCongelados: autoCongelados,
      autoOpls: autoOpls,
      autoNaoPereciveis: autoNaoPereciveis,
      autoLastDay: autoLastDay,
      autoByWeekday: autoByWeekday,
      visualTotalItems: visualTotalItems,
      visualQuebraCents: visualQuebraCents,
      visualBeneficioCents: visualBeneficioCents,
      visualGoalDays: visualGoalDays,
      visualDaysWithEntry: visualDaysWithEntry,
      visualBestDayItems: visualBestDayItems,
      visualWorstDayItems: visualWorstDayItems,
      visualMedianItems: visualMedianItems,
      visualBestStreak: visualBestStreak,
      visualByWeekday: visualByWeekday,
      taskRows: taskRows,
      taskDone: taskDone,
      taskTotal: taskTotal,
      taskPrecoSum: taskPrecoSum,
      taskValidadesSum: taskValidadesSum,
      taskDoneByName: taskDoneByName,
      taskTotalByName: taskTotalByName,
      invCount: invCount,
      invValueCents: invValueCents,
      invMaxValueCents: invMaxValueCents,
      invMedianValueCents: invMedianValueCents,
      invBiggestDayCents: invBiggestDayCents,
      invByWeekday: invByWeekday,
      dailyWorked: dailyWorked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estatísticas'),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Geral'),
              Tab(text: 'Turnos'),
              Tab(text: 'Camiões'),
              Tab(text: 'Aberturas'),
              Tab(text: 'Auto'),
              Tab(text: 'Relatórios'),
              Tab(text: 'Visual'),
              Tab(text: 'Tarefas'),
              Tab(text: 'Inventários'),
            ],
          ),
        ),
        body: SafeArea(
          child: FutureBuilder<_Stats>(
            future: _future,
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final s = snap.data!;
              void refresh() => setState(() {
                    _future = _load();
                  });
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: _rangeSelector(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(stats: s),
                        _ShiftsTab(stats: s),
                        _TrucksTab(stats: s),
                        _OpeningTab(stats: s, onRefresh: refresh),
                        _AutoTab(stats: s, onRefresh: refresh),
                        _ReportTab(stats: s, onRefresh: refresh),
                        _VisualTab(stats: s, onRefresh: refresh),
                        _TasksTab(stats: s, onRefresh: refresh),
                        _InventoryTab(stats: s),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
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
      onSelectionChanged: (sel) => _setRange(sel.first),
    );
  }
}

// ============================================================================
// Tabs
// ============================================================================

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.stats});
  final _Stats stats;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    final b = s.bucket;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Tarefas Diárias', tab: _tabTasks),
        _sectionCard(
          tab: _tabTasks,
          title: b.taskTotal == 0
              ? 'Sem registos'
              : '${b.taskDone}/${b.taskTotal} tarefas concluídas',
          child: _ProgressRow(
            label: b.taskRows == 0
                ? 'Sem dias com tarefas'
                : '${b.taskRows} dia(s) com registos',
            value: b.taskTotal == 0 ? 0 : b.taskDone / b.taskTotal,
          ),
        ),
        const SizedBox(height: 16),
        _sectionTitle('Listas'),
        _kpiGrid([
          _Kpi(
            'Aberturas',
            b.daysInRange == 0
                ? '—'
                : '${b.aberturaDoneDays}/${b.daysInRange}',
            Icons.list_alt,
            AppColors.green,
            tab: _tabOpening,
            delta: _deltaInt(b.aberturaDoneDays, s.prev?.aberturaDoneDays),
          ),
          _Kpi(
            'Relatórios',
            b.daysInRange == 0
                ? '—'
                : '${b.reportDoneDays}/${b.daysInRange}',
            Icons.summarize,
            AppColors.green,
            tab: _tabReport,
            delta: _deltaInt(b.reportDoneDays, s.prev?.reportDoneDays),
          ),
          _Kpi(
              'Listas auto',
              b.daysInRange == 0
                  ? '—'
                  : '${b.autoDoneDays}/${b.daysInRange}',
              Icons.bolt,
              AppColors.black,
              tab: _tabAuto,
              delta: _deltaInt(b.autoDoneDays, s.prev?.autoDoneDays)),
          _Kpi(
            'Itens picados',
            NumberFormat.decimalPattern('pt_PT').format(b.visualTotalItems),
            Icons.visibility,
            AppColors.black,
            tab: _tabVisual,
            delta: _deltaInt(b.visualTotalItems, s.prev?.visualTotalItems),
          ),
        ]),
        const SizedBox(height: 12),
        _sectionCard(
          tab: _tabVisual,
          title: 'Objetivo visual (${s.visualGoal} itens/dia)',
          child: _ProgressRow(
            label: b.daysInRange == 0
                ? 'Sem dias'
                : '${b.visualGoalDays}/${b.daysInRange} dias atingidos',
            value: b.daysInRange == 0
                ? 0
                : b.visualGoalDays / b.daysInRange,
          ),
        ),
        const SizedBox(height: 16),
        _sectionTitle('Camiões', tab: _tabTrucks),
        _kpiGrid([
          _Kpi('Receções', '${b.truckCount}', Icons.local_shipping,
              AppColors.green,
              tab: _tabTrucks,
              delta: _deltaInt(b.truckCount, s.prev?.truckCount)),
          _Kpi('Paletes totais', '${b.totalPallets}', Icons.inventory_2,
              AppColors.black,
              tab: _tabTrucks,
              delta: _deltaInt(b.totalPallets, s.prev?.totalPallets)),
          _Kpi(
            'Média de paletes',
            b.truckCount == 0
                ? '—'
                : (b.totalPallets / b.truckCount).toStringAsFixed(1),
            Icons.bar_chart,
            AppColors.black,
            tab: _tabTrucks,
          ),
        ]),
        const SizedBox(height: 16),
        _sectionTitle('Inventários', tab: _tabInventory),
        _kpiGrid([
          _Kpi('Inventários', '${b.invCount}', Icons.assignment,
              AppColors.green,
              tab: _tabInventory,
              delta: _deltaInt(b.invCount, s.prev?.invCount)),
          _Kpi(
            'Valor total',
            _fmtEuros(b.invValueCents),
            Icons.euro,
            b.invValueCents >= 0 ? AppColors.green : Colors.redAccent,
            tab: _tabInventory,
            delta: _deltaCents(b.invValueCents, s.prev?.invValueCents),
          ),
        ]),
        const SizedBox(height: 16),
        _sectionTitle('Turnos', tab: _tabShifts),
        _kpiGrid([
          _Kpi('Total trabalhado', _fmtDur(b.totalWorked), Icons.schedule,
              AppColors.green,
              tab: _tabShifts,
              delta: _deltaDur(b.totalWorked, s.prev?.totalWorked)),
          _Kpi('Em pausa', _fmtDur(b.totalPaused), Icons.pause_circle,
              AppColors.greenDark,
              tab: _tabShifts,
              delta: _deltaDur(b.totalPaused, s.prev?.totalPaused)),
          _Kpi('Turnos', '${b.shiftCount}', Icons.work_outline, AppColors.black,
              tab: _tabShifts,
              delta: _deltaInt(b.shiftCount, s.prev?.shiftCount)),
          _Kpi(
            'Média por turno',
            b.shiftCount == 0
                ? '—'
                : _fmtDur(Duration(
                    seconds: b.totalWorked.inSeconds ~/ b.shiftCount)),
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
  }
}

class _ShiftsTab extends StatelessWidget {
  const _ShiftsTab({required this.stats});
  final _Stats stats;
  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final avg = b.shiftCount == 0
        ? '—'
        : _fmtDur(Duration(seconds: b.totalWorked.inSeconds ~/ b.shiftCount));
    final avgPause = b.shiftCount == 0
        ? '—'
        : _fmtDur(Duration(seconds: b.totalPaused.inSeconds ~/ b.shiftCount));
    final pausePct = b.totalWorked.inSeconds == 0
        ? 0.0
        : b.totalPaused.inSeconds /
            (b.totalWorked.inSeconds + b.totalPaused.inSeconds);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kpiGrid([
          _Kpi('Turnos', '${b.shiftCount}', Icons.work_outline,
              AppColors.green, tab: _tabShifts,
              delta: _deltaInt(b.shiftCount, stats.prev?.shiftCount)),
          _Kpi('Total trabalhado', _fmtDur(b.totalWorked), Icons.schedule,
              AppColors.green, tab: _tabShifts,
              delta: _deltaDur(b.totalWorked, stats.prev?.totalWorked)),
          _Kpi('Em pausa', _fmtDur(b.totalPaused), Icons.pause_circle,
              AppColors.greenDark, tab: _tabShifts,
              delta: _deltaDur(b.totalPaused, stats.prev?.totalPaused)),
          _Kpi('Média por turno', avg, Icons.timelapse, AppColors.black,
              tab: _tabShifts),
          _Kpi('Pausa média', avgPause, Icons.coffee, AppColors.black,
              tab: _tabShifts),
          _Kpi('% pausa', '${(pausePct * 100).round()}%', Icons.pie_chart,
              AppColors.black, tab: _tabShifts),
          _Kpi('Mais longo', _fmtDur(b.longestShift), Icons.trending_up,
              AppColors.black, tab: _tabShifts),
          _Kpi('Mais curto', _fmtDur(b.shortestShift), Icons.trending_down,
              AppColors.black, tab: _tabShifts),
          _Kpi(
              'Início médio',
              b.avgStartHour == null
                  ? '—'
                  : '${b.avgStartHour!.toStringAsFixed(1)}h',
              Icons.login,
              AppColors.black,
              tab: _tabShifts),
          _Kpi(
              'Fim médio',
              b.avgEndHour == null
                  ? '—'
                  : '${b.avgEndHour!.toStringAsFixed(1)}h',
              Icons.logout,
              AppColors.black,
              tab: _tabShifts),
        ]),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabShifts,
          title: 'Horas trabalhadas',
          child: SizedBox(height: 200, child: _BarChart(series: stats.series)),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabShifts,
          title: 'Horas por dia da semana',
          child: _WeekdayBars(
            values: {
              for (final e in b.shiftByWeekday.entries)
                e.key: e.value.inMinutes / 60.0,
            },
            unit: 'h',
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabShifts,
          title: 'Início de turno por hora',
          child: _HourBars(values: b.shiftStartByHour),
        ),
      ],
    );
  }
}

class _TrucksTab extends StatelessWidget {
  const _TrucksTab({required this.stats});
  final _Stats stats;
  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final avg = b.truckCount == 0
        ? '—'
        : (b.totalPallets / b.truckCount).toStringAsFixed(1);
    final busiest = _busiestWeekday(b.truckByWeekday);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kpiGrid([
          _Kpi('Receções', '${b.truckCount}', Icons.local_shipping,
              AppColors.green, tab: _tabTrucks,
              delta: _deltaInt(b.truckCount, stats.prev?.truckCount)),
          _Kpi('Paletes totais', '${b.totalPallets}', Icons.inventory_2,
              AppColors.black, tab: _tabTrucks,
              delta: _deltaInt(b.totalPallets, stats.prev?.totalPallets)),
          _Kpi('Mistas', '${b.totalMistas}', Icons.merge_type,
              AppColors.black, tab: _tabTrucks,
              delta: _deltaInt(b.totalMistas, stats.prev?.totalMistas)),
          _Kpi('Média paletes/camião', avg, Icons.bar_chart, AppColors.black,
              tab: _tabTrucks),
          _Kpi('Mediana paletes', '${b.medianPalletsTruck}', Icons.show_chart,
              AppColors.black, tab: _tabTrucks),
          _Kpi('Maior camião', '${b.maxPalletsInTruck}', Icons.trending_up,
              AppColors.black, tab: _tabTrucks),
          _Kpi('Dia com mais paletes', '${b.biggestTruckDayPallets}',
              Icons.calendar_month, AppColors.black, tab: _tabTrucks),
          _Kpi('Dia mais ativo', busiest ?? '—', Icons.event,
              AppColors.greenDark, tab: _tabTrucks),
        ]),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabTrucks,
          title: 'Receções por dia da semana',
          child: _WeekdayBars(
            values: {
              for (final e in b.truckByWeekday.entries) e.key: e.value.toDouble()
            },
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabTrucks,
          title: 'Chegadas por hora',
          child: _HourBars(values: b.truckArrivalByHour),
        ),
      ],
    );
  }
}

class _OpeningTab extends StatelessWidget {
  const _OpeningTab({required this.stats, required this.onRefresh});
  final _Stats stats;
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final fails = (b.daysInRange - b.aberturaDoneDays).clamp(0, b.daysInRange);
    final rate =
        b.daysInRange == 0 ? 0.0 : b.aberturaDoneDays / b.daysInRange;
    final avgItems = b.aberturaTotal == 0
        ? '—'
        : (b.aberturaItems / b.aberturaTotal).toStringAsFixed(1);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kpiGrid([
          _Kpi('Dias concluídos', '${b.aberturaDoneDays}/${b.daysInRange}',
              Icons.check_circle, AppColors.green, tab: _tabOpening,
              delta: _deltaInt(
                  b.aberturaDoneDays, stats.prev?.aberturaDoneDays)),
          _Kpi('Falhas', '$fails', Icons.cancel, Colors.redAccent,
              tab: _tabOpening),
          _Kpi('Registos', '${b.aberturaTotal}', Icons.list_alt,
              AppColors.black, tab: _tabOpening,
              delta: _deltaInt(b.aberturaTotal, stats.prev?.aberturaTotal)),
          _Kpi('Itens totais', '${b.aberturaItems}', Icons.layers,
              AppColors.black, tab: _tabOpening,
              delta: _deltaInt(b.aberturaItems, stats.prev?.aberturaItems)),
          _Kpi('Média itens/lista', avgItems, Icons.bar_chart,
              AppColors.black, tab: _tabOpening),
          _Kpi('Última',
              b.aberturaLastDay == null ? '—' : _fmtDay(b.aberturaLastDay!),
              Icons.event, AppColors.black, tab: _tabOpening),
        ]),
        const SizedBox(height: 12),
        _sectionCard(
          tab: _tabOpening,
          title: 'Taxa de conclusão',
          child: _ProgressRow(
            label: '${(rate * 100).round()}%',
            value: rate,
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.aberturaMissedDays,
            justified: b.aberturaJustifiedDays,
            kind: JustificationKind.opening,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabOpening,
          title: 'Composição de itens',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BreakdownRow(
                  label: 'Congelados', value: b.aberturaCongelados,
                  total: b.aberturaItems),
              _BreakdownRow(
                  label: 'OPLs', value: b.aberturaOpls,
                  total: b.aberturaItems),
              _BreakdownRow(
                  label: 'Não perecíveis', value: b.aberturaNaoPereciveis,
                  total: b.aberturaItems),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabOpening,
          title: 'Por dia da semana',
          child: _WeekdayBars(
            values: {
              for (final e in b.aberturaByWeekday.entries)
                e.key: e.value.toDouble()
            },
          ),
        ),
      ],
    );
  }
}

class _AutoTab extends StatelessWidget {
  const _AutoTab({required this.stats, required this.onRefresh});
  final _Stats stats;
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final busiest = _busiestWeekday(b.autoByWeekday);
    final avgItems = b.autoCount == 0
        ? '—'
        : (b.autoItems / b.autoCount).toStringAsFixed(1);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kpiGrid([
          _Kpi('Dias concluídos', '${b.autoDoneDays}/${b.daysInRange}',
              Icons.check_circle, AppColors.green, tab: _tabAuto,
              delta: _deltaInt(b.autoDoneDays, stats.prev?.autoDoneDays)),
          _Kpi(
              'Falhas',
              '${(b.daysInRange - b.autoDoneDays).clamp(0, b.daysInRange)}',
              Icons.cancel,
              Colors.redAccent,
              tab: _tabAuto),
          _Kpi('Registos', '${b.autoCount}', Icons.bolt, AppColors.black,
              tab: _tabAuto,
              delta: _deltaInt(b.autoCount, stats.prev?.autoCount)),
          _Kpi('Itens totais', '${b.autoItems}', Icons.layers,
              AppColors.black, tab: _tabAuto,
              delta: _deltaInt(b.autoItems, stats.prev?.autoItems)),
          _Kpi('Média itens/lista', avgItems, Icons.bar_chart,
              AppColors.black, tab: _tabAuto),
          _Kpi('Última',
              b.autoLastDay == null ? '—' : _fmtDay(b.autoLastDay!),
              Icons.event, AppColors.black, tab: _tabAuto),
          _Kpi('Dia mais ativo', busiest ?? '—', Icons.calendar_today,
              AppColors.greenDark, tab: _tabAuto),
        ]),
        const SizedBox(height: 12),
        _sectionCard(
          tab: _tabAuto,
          title: 'Taxa diária',
          child: _ProgressRow(
            label: b.daysInRange == 0
                ? 'Sem dias'
                : '${b.autoDoneDays}/${b.daysInRange} dias',
            value: b.daysInRange == 0
                ? 0
                : b.autoDoneDays / b.daysInRange,
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.autoMissedDays,
            justified: b.autoJustifiedDays,
            kind: JustificationKind.auto,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabAuto,
          title: 'Composição de itens',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BreakdownRow(
                  label: 'Congelados',
                  value: b.autoCongelados,
                  total: b.autoItems),
              _BreakdownRow(
                  label: 'OPLs', value: b.autoOpls, total: b.autoItems),
              _BreakdownRow(
                  label: 'Não perecíveis',
                  value: b.autoNaoPereciveis,
                  total: b.autoItems),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabAuto,
          title: 'Por dia da semana',
          child: _WeekdayBars(
            values: {
              for (final e in b.autoByWeekday.entries)
                e.key: e.value.toDouble()
            },
          ),
        ),
      ],
    );
  }
}

class _ReportTab extends StatelessWidget {
  const _ReportTab({required this.stats, required this.onRefresh});
  final _Stats stats;
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final fails = (b.daysInRange - b.reportDoneDays).clamp(0, b.daysInRange);
    final rate = b.daysInRange == 0 ? 0.0 : b.reportDoneDays / b.daysInRange;
    final avgItems = b.reportTotal == 0
        ? '—'
        : (b.reportItems / b.reportTotal).toStringAsFixed(1);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kpiGrid([
          _Kpi('Dias concluídos', '${b.reportDoneDays}/${b.daysInRange}',
              Icons.check_circle, AppColors.green, tab: _tabReport,
              delta:
                  _deltaInt(b.reportDoneDays, stats.prev?.reportDoneDays)),
          _Kpi('Falhas', '$fails', Icons.cancel, Colors.redAccent,
              tab: _tabReport),
          _Kpi('Registos', '${b.reportTotal}', Icons.summarize,
              AppColors.black, tab: _tabReport,
              delta: _deltaInt(b.reportTotal, stats.prev?.reportTotal)),
          _Kpi('Itens totais', '${b.reportItems}', Icons.layers,
              AppColors.black, tab: _tabReport,
              delta: _deltaInt(b.reportItems, stats.prev?.reportItems)),
          _Kpi('Média itens/relatório', avgItems, Icons.bar_chart,
              AppColors.black, tab: _tabReport),
          _Kpi('Último',
              b.reportLastDay == null ? '—' : _fmtDay(b.reportLastDay!),
              Icons.event, AppColors.black, tab: _tabReport),
        ]),
        const SizedBox(height: 12),
        _sectionCard(
          tab: _tabReport,
          title: 'Taxa de conclusão',
          child: _ProgressRow(
              label: '${(rate * 100).round()}%', value: rate),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.reportMissedDays,
            justified: b.reportJustifiedDays,
            kind: JustificationKind.report,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabReport,
          title: 'Composição de itens',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BreakdownRow(
                  label: 'Dias sem vendas',
                  value: b.reportDiasSemVendas,
                  total: b.reportItems),
              _BreakdownRow(
                  label: 'Regularizações',
                  value: b.reportRegularizacoes,
                  total: b.reportItems),
              _BreakdownRow(
                  label: 'Massiva',
                  value: b.reportMassiva,
                  total: b.reportItems),
              _BreakdownRow(
                  label: 'Repetidos',
                  value: b.reportRepetidos,
                  total: b.reportItems),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabReport,
          title: 'Por dia da semana',
          child: _WeekdayBars(
            values: {
              for (final e in b.reportByWeekday.entries)
                e.key: e.value.toDouble()
            },
          ),
        ),
      ],
    );
  }
}

class _VisualTab extends StatelessWidget {
  const _VisualTab({required this.stats, required this.onRefresh});
  final _Stats stats;
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final avg = b.visualDaysWithEntry == 0
        ? '—'
        : (b.visualTotalItems / b.visualDaysWithEntry).toStringAsFixed(0);
    final liquido = b.visualBeneficioCents - b.visualQuebraCents;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kpiGrid([
          _Kpi(
              'Itens picados',
              NumberFormat.decimalPattern('pt_PT').format(b.visualTotalItems),
              Icons.visibility,
              AppColors.green,
              tab: _tabVisual,
              delta: _deltaInt(
                  b.visualTotalItems, stats.prev?.visualTotalItems)),
          _Kpi('Média/dia', avg, Icons.bar_chart, AppColors.black,
              tab: _tabVisual),
          _Kpi('Mediana/dia', '${b.visualMedianItems}', Icons.show_chart,
              AppColors.black, tab: _tabVisual),
          _Kpi('Dias com registo', '${b.visualDaysWithEntry}/${b.daysInRange}',
              Icons.event_available, AppColors.black, tab: _tabVisual),
          _Kpi(
              'Dias objetivo', '${b.visualGoalDays}/${b.daysInRange}',
              Icons.flag, AppColors.greenDark, tab: _tabVisual,
              delta: _deltaInt(b.visualGoalDays, stats.prev?.visualGoalDays)),
          _Kpi(
              'Falhas',
              '${(b.daysInRange - b.visualGoalDays).clamp(0, b.daysInRange)}',
              Icons.cancel,
              Colors.redAccent,
              tab: _tabVisual),
          _Kpi('Maior sequência', '${b.visualBestStreak} dias',
              Icons.local_fire_department, AppColors.black, tab: _tabVisual),
          _Kpi('Melhor dia', '${b.visualBestDayItems}', Icons.trending_up,
              AppColors.black, tab: _tabVisual),
          _Kpi('Pior dia', '${b.visualWorstDayItems}', Icons.trending_down,
              AppColors.black, tab: _tabVisual),
          _Kpi('Quebra', _fmtEuros(b.visualQuebraCents), Icons.remove_circle,
              Colors.redAccent, tab: _tabVisual,
              delta:
                  _deltaCents(b.visualQuebraCents, stats.prev?.visualQuebraCents)),
          _Kpi('Benefício', _fmtEuros(b.visualBeneficioCents),
              Icons.add_circle, AppColors.green, tab: _tabVisual,
              delta: _deltaCents(
                  b.visualBeneficioCents, stats.prev?.visualBeneficioCents)),
          _Kpi('Líquido', _fmtEuros(liquido), Icons.balance,
              liquido >= 0 ? AppColors.green : Colors.redAccent,
              tab: _tabVisual),
        ]),
        const SizedBox(height: 12),
        _sectionCard(
          tab: _tabVisual,
          title: 'Objetivo (${stats.visualGoal} itens/dia)',
          child: _ProgressRow(
            label: b.daysInRange == 0
                ? 'Sem dias'
                : '${b.visualGoalDays}/${b.daysInRange} dias atingidos',
            value: b.daysInRange == 0
                ? 0
                : b.visualGoalDays / b.daysInRange,
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.visualMissedDays,
            justified: b.visualJustifiedDays,
            kind: JustificationKind.visual,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabVisual,
          title: 'Itens por dia da semana',
          child: _WeekdayBars(
            values: {
              for (final e in b.visualByWeekday.entries)
                e.key: e.value.toDouble()
            },
          ),
        ),
      ],
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab({required this.stats, required this.onRefresh});
  final _Stats stats;
  final VoidCallback onRefresh;
  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final rate = b.taskTotal == 0 ? 0.0 : b.taskDone / b.taskTotal;
    final entries = b.taskTotalByName.keys.toList()..sort();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kpiGrid([
          _Kpi('Concluídas', '${b.taskDone}/${b.taskTotal}',
              Icons.check_circle, AppColors.green, tab: _tabTasks,
              delta: _deltaInt(b.taskDone, stats.prev?.taskDone)),
          _Kpi('Falhas', '${b.taskTotal - b.taskDone}', Icons.cancel,
              Colors.redAccent, tab: _tabTasks),
          _Kpi('Dias com registos', '${b.taskRows}/${b.daysInRange}',
              Icons.event, AppColors.black, tab: _tabTasks),
          _Kpi('Alterações de preço', '${b.taskPrecoSum}', Icons.price_change,
              AppColors.black, tab: _tabTasks,
              delta: _deltaInt(b.taskPrecoSum, stats.prev?.taskPrecoSum)),
          _Kpi('Validades verificadas', '${b.taskValidadesSum}',
              Icons.event_busy, AppColors.black, tab: _tabTasks,
              delta:
                  _deltaInt(b.taskValidadesSum, stats.prev?.taskValidadesSum)),
        ]),
        const SizedBox(height: 12),
        _sectionCard(
          tab: _tabTasks,
          title: 'Taxa global de conclusão',
          child: _ProgressRow(label: '${(rate * 100).round()}%', value: rate),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.taskMissedDays,
            justified: b.taskJustifiedDays,
            kind: JustificationKind.tasks,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabTasks,
          title: 'Por tarefa',
          child: Column(
            children: [
              for (final name in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ProgressRow(
                    label:
                        '$name (${b.taskDoneByName[name] ?? 0}/${b.taskTotalByName[name]})',
                    value: (b.taskTotalByName[name] ?? 0) == 0
                        ? 0
                        : (b.taskDoneByName[name] ?? 0) /
                            (b.taskTotalByName[name] ?? 1),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.stats});
  final _Stats stats;
  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final avg = b.invCount == 0
        ? '—'
        : _fmtEuros((b.invValueCents / b.invCount).round());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kpiGrid([
          _Kpi('Inventários', '${b.invCount}', Icons.assignment,
              AppColors.green, tab: _tabInventory,
              delta: _deltaInt(b.invCount, stats.prev?.invCount)),
          _Kpi('Valor total', _fmtEuros(b.invValueCents), Icons.euro,
              b.invValueCents >= 0 ? AppColors.green : Colors.redAccent,
              tab: _tabInventory,
              delta: _deltaCents(b.invValueCents, stats.prev?.invValueCents)),
          _Kpi('Média por inventário', avg, Icons.bar_chart, AppColors.black,
              tab: _tabInventory),
          _Kpi('Mediana', _fmtEuros(b.invMedianValueCents), Icons.show_chart,
              AppColors.black, tab: _tabInventory),
          _Kpi('Maior inventário', _fmtEuros(b.invMaxValueCents),
              Icons.trending_up, AppColors.black, tab: _tabInventory),
          _Kpi('Maior dia', _fmtEuros(b.invBiggestDayCents),
              Icons.calendar_today, AppColors.black, tab: _tabInventory),
        ]),
        const SizedBox(height: 16),
        _sectionCard(
          tab: _tabInventory,
          title: 'Por dia da semana',
          child: _WeekdayBars(
            values: {
              for (final e in b.invByWeekday.entries)
                e.key: e.value.toDouble()
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Helpers (shared)
// ============================================================================

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

String _fmtDay(DateTime d) => DateFormat('d/M/yyyy').format(d);

String? _busiestWeekday(Map<int, int> by) {
  if (by.isEmpty) return null;
  final top = by.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return _weekdayName(top.key);
}

String _weekdayName(int wd) {
  const names = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  return names[(wd - 1).clamp(0, 6)];
}

Widget _sectionTitle(String text, {int? tab}) {
  return Builder(builder: (ctx) {
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
    return InkWell(onTap: () => _openHistory(ctx, tab), child: inner);
  });
}

Widget _sectionCard({
  required String title,
  required Widget child,
  int? tab,
}) {
  return Builder(builder: (ctx) {
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
          : InkWell(onTap: () => _openHistory(ctx, tab), child: content),
    );
  });
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

// ============================================================================
// Data classes
// ============================================================================

class _Bucket {
  _Bucket({
    required this.daysInRange,
    required this.saturdaysInRange,
    required this.aberturaDoneDays,
    required this.reportDoneDays,
    required this.autoDoneDays,
    required this.aberturaMissedDays,
    required this.reportMissedDays,
    required this.autoMissedDays,
    required this.visualMissedDays,
    required this.taskMissedDays,
    required this.aberturaJustifiedDays,
    required this.reportJustifiedDays,
    required this.autoJustifiedDays,
    required this.visualJustifiedDays,
    required this.taskJustifiedDays,
    required this.totalWorked,
    required this.totalPaused,
    required this.shiftCount,
    required this.longestShift,
    required this.shortestShift,
    required this.shiftByWeekday,
    required this.avgStartHour,
    required this.avgEndHour,
    required this.shiftStartByHour,
    required this.truckCount,
    required this.totalPallets,
    required this.totalMistas,
    required this.maxPalletsInTruck,
    required this.medianPalletsTruck,
    required this.biggestTruckDayPallets,
    required this.truckByWeekday,
    required this.truckArrivalByHour,
    required this.aberturaTotal,
    required this.aberturaFinalized,
    required this.aberturaItems,
    required this.aberturaCongelados,
    required this.aberturaOpls,
    required this.aberturaNaoPereciveis,
    required this.aberturaLastDay,
    required this.aberturaByWeekday,
    required this.reportTotal,
    required this.reportFinalized,
    required this.reportItems,
    required this.reportDiasSemVendas,
    required this.reportRegularizacoes,
    required this.reportMassiva,
    required this.reportRepetidos,
    required this.reportLastDay,
    required this.reportByWeekday,
    required this.autoCount,
    required this.autoItems,
    required this.autoCongelados,
    required this.autoOpls,
    required this.autoNaoPereciveis,
    required this.autoLastDay,
    required this.autoByWeekday,
    required this.visualTotalItems,
    required this.visualQuebraCents,
    required this.visualBeneficioCents,
    required this.visualGoalDays,
    required this.visualDaysWithEntry,
    required this.visualBestDayItems,
    required this.visualWorstDayItems,
    required this.visualMedianItems,
    required this.visualBestStreak,
    required this.visualByWeekday,
    required this.taskRows,
    required this.taskDone,
    required this.taskTotal,
    required this.taskPrecoSum,
    required this.taskValidadesSum,
    required this.taskDoneByName,
    required this.taskTotalByName,
    required this.invCount,
    required this.invValueCents,
    required this.invMaxValueCents,
    required this.invMedianValueCents,
    required this.invBiggestDayCents,
    required this.invByWeekday,
    required this.dailyWorked,
  });
  final int daysInRange;
  final int saturdaysInRange;
  final int aberturaDoneDays;
  final int reportDoneDays;
  final int autoDoneDays;
  final List<DateTime> aberturaMissedDays;
  final List<DateTime> reportMissedDays;
  final List<DateTime> autoMissedDays;
  final List<DateTime> visualMissedDays;
  final List<DateTime> taskMissedDays;
  final List<DateTime> aberturaJustifiedDays;
  final List<DateTime> reportJustifiedDays;
  final List<DateTime> autoJustifiedDays;
  final List<DateTime> visualJustifiedDays;
  final List<DateTime> taskJustifiedDays;
  final Duration totalWorked;
  final Duration totalPaused;
  final int shiftCount;
  final Duration longestShift;
  final Duration shortestShift;
  final Map<int, Duration> shiftByWeekday;
  final double? avgStartHour;
  final double? avgEndHour;
  final Map<int, int> shiftStartByHour;
  final int truckCount;
  final int totalPallets;
  final int totalMistas;
  final int maxPalletsInTruck;
  final int medianPalletsTruck;
  final int biggestTruckDayPallets;
  final Map<int, int> truckByWeekday;
  final Map<int, int> truckArrivalByHour;
  final int aberturaTotal;
  final int aberturaFinalized;
  final int aberturaItems;
  final int aberturaCongelados;
  final int aberturaOpls;
  final int aberturaNaoPereciveis;
  final DateTime? aberturaLastDay;
  final Map<int, int> aberturaByWeekday;
  final int reportTotal;
  final int reportFinalized;
  final int reportItems;
  final int reportDiasSemVendas;
  final int reportRegularizacoes;
  final int reportMassiva;
  final int reportRepetidos;
  final DateTime? reportLastDay;
  final Map<int, int> reportByWeekday;
  final int autoCount;
  final int autoItems;
  final int autoCongelados;
  final int autoOpls;
  final int autoNaoPereciveis;
  final DateTime? autoLastDay;
  final Map<int, int> autoByWeekday;
  final int visualTotalItems;
  final int visualQuebraCents;
  final int visualBeneficioCents;
  final int visualGoalDays;
  final int visualDaysWithEntry;
  final int visualBestDayItems;
  final int visualWorstDayItems;
  final int visualMedianItems;
  final int visualBestStreak;
  final Map<int, int> visualByWeekday;
  final int taskRows;
  final int taskDone;
  final int taskTotal;
  final int taskPrecoSum;
  final int taskValidadesSum;
  final Map<String, int> taskDoneByName;
  final Map<String, int> taskTotalByName;
  final int invCount;
  final int invValueCents;
  final int invMaxValueCents;
  final int invMedianValueCents;
  final int invBiggestDayCents;
  final Map<int, int> invByWeekday;
  final Map<DateTime, Duration> dailyWorked;
}

class _Stats {
  _Stats({
    required this.bucket,
    required this.visualGoal,
    required this.series,
    this.prev,
  });
  final _Bucket bucket;
  final _Bucket? prev;
  final int visualGoal;
  final List<_DayBar> series;
}

class _DayBar {
  const _DayBar({required this.day, required this.worked});
  final DateTime day;
  final Duration worked;
}

// ============================================================================
// Deltas
// ============================================================================

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

// ============================================================================
// KPI card
// ============================================================================

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

// ============================================================================
// Progress + charts
// ============================================================================

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
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
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

class _MissedDays extends StatelessWidget {
  const _MissedDays({
    required this.missed,
    required this.justified,
    required this.kind,
    required this.onChanged,
  });
  final List<DateTime> missed;
  final List<DateTime> justified;
  final String kind;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (missed.isEmpty && justified.isEmpty) {
      return const Text('Sem falhas no período.',
          style: TextStyle(fontSize: 13, color: AppColors.green));
    }
    final fmt = DateFormat("EEE d/M", 'pt_PT');
    final all = <_DayChip>[
      for (final d in missed) _DayChip(day: d, justifiedFlag: false),
      for (final d in justified) _DayChip(day: d, justifiedFlag: true),
    ]..sort((a, b) => b.day.compareTo(a.day));
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final c in all)
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () async {
              final changed = await showMissedDaySheet(
                context: context,
                day: c.day,
                kind: kind,
              );
              if (changed == true) onChanged();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (c.justifiedFlag ? Colors.amber : Colors.redAccent)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: (c.justifiedFlag ? Colors.amber : Colors.redAccent)
                        .withValues(alpha: 0.6)),
              ),
              child: Text(
                fmt.format(c.day),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.justifiedFlag
                        ? Colors.amber.shade800
                        : Colors.redAccent),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayChip {
  const _DayChip({required this.day, required this.justifiedFlag});
  final DateTime day;
  final bool justifiedFlag;
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.total,
  });
  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child:
                      Text(label, style: const TextStyle(fontSize: 13))),
              Text('$value (${(pct * 100).round()}%)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0, 1).toDouble(),
              minHeight: 6,
              color: AppColors.green,
              backgroundColor: AppColors.grey,
            ),
          ),
        ],
      ),
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

class _WeekdayBars extends StatelessWidget {
  const _WeekdayBars({required this.values, this.unit = ''});
  final Map<int, double> values; // 1=Mon..7=Sun
  final String unit;

  @override
  Widget build(BuildContext context) {
    final maxV =
        values.values.fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = (maxV <= 0 ? 1.0 : maxV * 1.2).ceilToDouble();
    const names = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.grey, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}$unit',
                  style:
                      const TextStyle(fontSize: 10, color: Colors.black54),
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
                  if (i < 1 || i > 7) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      names[i - 1],
                      style: const TextStyle(
                          fontSize: 10, color: Colors.black54),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var d = 1; d <= 7; d++)
              BarChartGroupData(
                x: d,
                barRods: [
                  BarChartRodData(
                    toY: values[d] ?? 0,
                    color: AppColors.green,
                    width: 14,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HourBars extends StatelessWidget {
  const _HourBars({required this.values});
  final Map<int, int> values; // hour 0..23 -> count

  @override
  Widget build(BuildContext context) {
    final maxV = values.values.fold<double>(0, (a, b) => a > b ? a : b.toDouble());
    final maxY = (maxV <= 0 ? 1.0 : maxV * 1.2).ceilToDouble();
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.grey, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style:
                      const TextStyle(fontSize: 10, color: Colors.black54),
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
                interval: 3,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i > 23) return const SizedBox();
                  if (i % 3 != 0) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${i}h',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black54)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var h = 0; h < 24; h++)
              BarChartGroupData(
                x: h,
                barRods: [
                  BarChartRodData(
                    toY: (values[h] ?? 0).toDouble(),
                    color: AppColors.green,
                    width: 6,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
