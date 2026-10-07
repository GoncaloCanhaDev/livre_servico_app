import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/justification.dart';
import '../models/opening_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/inventory_service.dart';
import '../services/justification_service.dart';
import '../services/opening_list_service.dart';
import '../services/person_history_service.dart';
import '../services/person_service.dart';
import '../services/report_list_service.dart';
import '../services/settings_service.dart';
import '../services/truck_service.dart';
import '../services/visual_list_service.dart';
import '../theme.dart';
import 'historico_screen.dart';
import 'widgets/missed_day_sheet.dart';

// Indexes mirror HistoricoScreen._tabNames.
const int _tabTrucks = 1;
const int _tabOpening = 2;
const int _tabAuto = 3;
const int _tabReport = 4;
const int _tabVisual = 5;
const int _tabTasks = 6;
const int _tabInventory = 7;

enum _Range { week, month, year, allTime }

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
    final settings = SettingsService.instance;
    final goal = settings.visualGoal;
    final autoGoal = settings.autoGoal;
    final int? days = switch (_range) {
      _Range.week => 7,
      _Range.month => 30,
      _Range.year => 365,
      _Range.allTime => null,
    };
    final DateTime? curFrom = days == null
        ? null
        : today.subtract(Duration(days: days - 1));
    final cur = await _computeBucket(curFrom, null, today, goal, autoGoal);
    _Bucket? prev;
    if (days != null && curFrom != null) {
      final prevFrom = curFrom.subtract(Duration(days: days));
      final prevTo = curFrom.subtract(const Duration(days: 1));
      prev = await _computeBucket(prevFrom, prevTo, prevTo, goal, autoGoal);
    }
    return _Stats(bucket: cur, prev: prev, visualGoal: goal);
  }

  Future<_Bucket> _computeBucket(
    DateTime? from,
    DateTime? to,
    DateTime referenceDay,
    int goal,
    int autoGoal,
  ) async {
    bool inRange(DateTime d) {
      if (from != null && d.isBefore(from)) return false;
      if (to != null && d.isAfter(to)) return false;
      return true;
    }

    DateTime? minDayInData;
    void track(DateTime d) {
      if (minDayInData == null || d.isBefore(minDayInData!)) minDayInData = d;
    }

    final trucks = await TruckService.instance.all();
    int truckCount = 0;
    int totalPallets = 0;
    for (final t in trucks) {
      final day = currentServiceDay(t.arrivalTime);
      if (!inRange(day)) continue;
      track(day);
      truckCount++;
      totalPallets += t.totalPallets;
    }

    final openings = await OpeningListService.instance.history();
    int aberturaTotal = 0;
    final aberturaFinalizedByDay = <DateTime, int>{};
    for (final o in openings) {
      if (!inRange(o.serviceDay)) continue;
      track(o.serviceDay);
      aberturaTotal++;
      if (o.isFinalized) {
        aberturaFinalizedByDay.update(
          o.serviceDay,
          (v) => v + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final reports = await ReportListService.instance.history();
    int reportTotal = 0;
    final reportFinalizedByDay = <DateTime, int>{};
    for (final r in reports) {
      if (!inRange(r.serviceDay)) continue;
      track(r.serviceDay);
      reportTotal++;
      if (r.isFinalized) {
        reportFinalizedByDay.update(
          r.serviceDay,
          (v) => v + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final autos = await AutoListService.instance.history();
    int autoCount = 0;
    final autoByDay = <DateTime, int>{};
    for (final a in autos) {
      final day = currentServiceDay(a.createdAt);
      if (!inRange(day)) continue;
      track(day);
      autoCount++;
      autoByDay.update(day, (v) => v + 1, ifAbsent: () => 1);
    }

    final visuals = await VisualListService.instance.all();
    final visualByDay = <DateTime, int>{};
    int visualTotalItems = 0;
    int visualQuebraCents = 0;
    int visualBeneficioCents = 0;
    for (final v in visuals) {
      final day = currentServiceDay(v.createdAt);
      if (!inRange(day)) continue;
      track(day);
      visualTotalItems += v.itensPicados;
      visualQuebraCents += v.quebraCents;
      visualBeneficioCents += v.beneficioCents;
      visualByDay.update(
        day,
        (s) => s + v.itensPicados,
        ifAbsent: () => v.itensPicados,
      );
    }
    final visualGoalDays = visualByDay.values
        .where((items) => items >= goal)
        .length;

    final tasks = await DailyTasksService.instance.history();
    final taskByDay = <DateTime, dynamic>{};
    int taskRows = 0;
    for (final t in tasks) {
      if (!inRange(t.serviceDay)) continue;
      track(t.serviceDay);
      taskByDay[t.serviceDay] = t;
      taskRows++;
    }

    // Determine effective range for "expected daily" calculations.
    final effectiveFrom = from ?? minDayInData ?? referenceDay;
    final effectiveTo = to ?? referenceDay;
    int daysInRange = 0;
    final allDaysInRange = <DateTime>[];
    if (!effectiveFrom.isAfter(effectiveTo)) {
      for (
        var d = effectiveFrom;
        !d.isAfter(effectiveTo);
        d = d.add(const Duration(days: 1))
      ) {
        daysInRange++;
        allDaysInRange.add(d);
      }
    }
    bool aberturaGoalMet(DateTime d) => (aberturaFinalizedByDay[d] ?? 0) >= 1;
    bool reportGoalMet(DateTime d) => (reportFinalizedByDay[d] ?? 0) >= 1;
    bool autoGoalMet(DateTime d) => (autoByDay[d] ?? 0) >= autoGoal;

    final aberturaDoneDays = allDaysInRange.where(aberturaGoalMet).length;
    final reportDoneDays = allDaysInRange.where(reportGoalMet).length;
    final autoDoneDays = allDaysInRange.where(autoGoalMet).length;

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
          if (failed(d) && !js.contains(d)) d,
      ];
    }

    List<DateTime> justified(bool Function(DateTime) failed, String kind) {
      final js = just(kind);
      return [
        for (final d in allDaysInRange)
          if (failed(d) && js.contains(d)) d,
      ];
    }

    final aberturaMissedDays = missed(
      (d) => !aberturaGoalMet(d),
      JustificationKind.opening,
    );
    final aberturaJustifiedDays = justified(
      (d) => !aberturaGoalMet(d),
      JustificationKind.opening,
    );
    final reportMissedDays = missed(
      (d) => !reportGoalMet(d),
      JustificationKind.report,
    );
    final reportJustifiedDays = justified(
      (d) => !reportGoalMet(d),
      JustificationKind.report,
    );
    final autoMissedDays = missed(
      (d) => !autoGoalMet(d),
      JustificationKind.auto,
    );
    final autoJustifiedDays = justified(
      (d) => !autoGoalMet(d),
      JustificationKind.auto,
    );
    final visualMissedDays = missed(
      (d) => (visualByDay[d] ?? 0) < goal,
      JustificationKind.visual,
    );
    final visualJustifiedDays = justified(
      (d) => (visualByDay[d] ?? 0) < goal,
      JustificationKind.visual,
    );

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
      final aberturaDone = aberturaGoalMet(day);
      final relatorioDone = reportGoalMet(day);
      final visualDone = (visualByDay[day] ?? 0) >= goal;
      final autoDone = autoGoalMet(day);

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
      ];
      taskTotal += flags.length;
      final dayDone = flags.where((v) => v).length;
      taskDone += dayDone;
      if (dayDone < flags.length) taskMissedDays.add(day);
    }
    final taskJustSet = just(JustificationKind.tasks);
    final taskJustifiedDays = taskMissedDays
        .where(taskJustSet.contains)
        .toList();
    taskMissedDays.removeWhere(taskJustSet.contains);

    final invs = await InventoryService.instance.history();
    int invCount = 0;
    int invValueCents = 0;
    for (final inv in invs) {
      final day = currentServiceDay(inv.createdAt);
      if (!inRange(day)) continue;
      track(day);
      invCount++;
      invValueCents += inv.valueCents;
    }

    return _Bucket(
      daysInRange: daysInRange,
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
      truckCount: truckCount,
      totalPallets: totalPallets,
      aberturaTotal: aberturaTotal,
      reportTotal: reportTotal,
      autoCount: autoCount,
      visualTotalItems: visualTotalItems,
      visualQuebraCents: visualQuebraCents,
      visualBeneficioCents: visualBeneficioCents,
      visualGoalDays: visualGoalDays,
      taskRows: taskRows,
      taskDone: taskDone,
      taskTotal: taskTotal,
      taskDoneByName: taskDoneByName,
      taskTotalByName: taskTotalByName,
      invCount: invCount,
      invValueCents: invValueCents,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estatísticas'),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Resumo'),
              Tab(text: 'Listas'),
              Tab(text: 'Pessoas'),
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
                        _ListsTab(stats: s, onRefresh: refresh),
                        const _PeopleTab(),
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
        ButtonSegment(value: _Range.week, label: Text('Semana')),
        ButtonSegment(value: _Range.month, label: Text('Mês')),
        ButtonSegment(value: _Range.year, label: Text('Ano')),
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
            b.daysInRange == 0 ? '—' : '${b.aberturaDoneDays}/${b.daysInRange}',
            Icons.list_alt,
            AppColors.green,
            tab: _tabOpening,
            delta: _deltaInt(b.aberturaDoneDays, s.prev?.aberturaDoneDays),
          ),
          _Kpi(
            'Relatórios',
            b.daysInRange == 0 ? '—' : '${b.reportDoneDays}/${b.daysInRange}',
            Icons.summarize,
            AppColors.green,
            tab: _tabReport,
            delta: _deltaInt(b.reportDoneDays, s.prev?.reportDoneDays),
          ),
          _Kpi(
            'Listas auto',
            b.daysInRange == 0 ? '—' : '${b.autoDoneDays}/${b.daysInRange}',
            Icons.bolt,
            AppColors.black,
            tab: _tabAuto,
            delta: _deltaInt(b.autoDoneDays, s.prev?.autoDoneDays),
          ),
          _Kpi(
            'Itens picados',
            NumberFormat.decimalPattern('pt_PT').format(b.visualTotalItems),
            Icons.visibility,
            AppColors.black,
            tab: _tabVisual,
            delta: _deltaInt(b.visualTotalItems, s.prev?.visualTotalItems),
          ),
        ]),
        const SizedBox(height: 16),
        _sectionTitle('Camiões', tab: _tabTrucks),
        _kpiGrid([
          _Kpi(
            'Receções',
            '${b.truckCount}',
            Icons.local_shipping,
            AppColors.green,
            tab: _tabTrucks,
            delta: _deltaInt(b.truckCount, s.prev?.truckCount),
          ),
          _Kpi(
            'Paletes totais',
            '${b.totalPallets}',
            Icons.inventory_2,
            AppColors.black,
            tab: _tabTrucks,
            delta: _deltaInt(b.totalPallets, s.prev?.totalPallets),
          ),
        ]),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ListsTab extends StatelessWidget {
  const _ListsTab({required this.stats, required this.onRefresh});
  final _Stats stats;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final b = stats.bucket;
    final avgPallets = b.truckCount == 0
        ? '—'
        : (b.totalPallets / b.truckCount).toStringAsFixed(1);
    final liquido = b.visualBeneficioCents - b.visualQuebraCents;
    final taskNames = b.taskTotalByName.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Camiões', tab: _tabTrucks),
        _kpiGrid([
          _Kpi(
            'Receções',
            '${b.truckCount}',
            Icons.local_shipping,
            AppColors.green,
            tab: _tabTrucks,
            delta: _deltaInt(b.truckCount, stats.prev?.truckCount),
          ),
          _Kpi(
            'Paletes totais',
            '${b.totalPallets}',
            Icons.inventory_2,
            AppColors.black,
            tab: _tabTrucks,
          ),
          _Kpi(
            'Média/camião',
            avgPallets,
            Icons.bar_chart,
            AppColors.black,
            tab: _tabTrucks,
          ),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('Abertura', tab: _tabOpening),
        _kpiGrid([
          _Kpi(
            'Dias concluídos',
            '${b.aberturaDoneDays}/${b.daysInRange}',
            Icons.check_circle,
            AppColors.green,
            tab: _tabOpening,
          ),
          _Kpi(
            'Registos',
            '${b.aberturaTotal}',
            Icons.list_alt,
            AppColors.black,
            tab: _tabOpening,
          ),
        ]),
        const SizedBox(height: 8),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.aberturaMissedDays,
            justified: b.aberturaJustifiedDays,
            kind: JustificationKind.opening,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Auto', tab: _tabAuto),
        _kpiGrid([
          _Kpi(
            'Dias concluídos',
            '${b.autoDoneDays}/${b.daysInRange}',
            Icons.check_circle,
            AppColors.green,
            tab: _tabAuto,
          ),
          _Kpi(
            'Registos',
            '${b.autoCount}',
            Icons.bolt,
            AppColors.black,
            tab: _tabAuto,
          ),
        ]),
        const SizedBox(height: 8),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.autoMissedDays,
            justified: b.autoJustifiedDays,
            kind: JustificationKind.auto,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Relatório', tab: _tabReport),
        _kpiGrid([
          _Kpi(
            'Dias concluídos',
            '${b.reportDoneDays}/${b.daysInRange}',
            Icons.check_circle,
            AppColors.green,
            tab: _tabReport,
          ),
          _Kpi(
            'Registos',
            '${b.reportTotal}',
            Icons.summarize,
            AppColors.black,
            tab: _tabReport,
          ),
        ]),
        const SizedBox(height: 8),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.reportMissedDays,
            justified: b.reportJustifiedDays,
            kind: JustificationKind.report,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Visual', tab: _tabVisual),
        _kpiGrid([
          _Kpi(
            'Itens picados',
            NumberFormat.decimalPattern('pt_PT').format(b.visualTotalItems),
            Icons.visibility,
            AppColors.green,
            tab: _tabVisual,
          ),
          _Kpi(
            'Dias objetivo',
            '${b.visualGoalDays}/${b.daysInRange}',
            Icons.flag,
            AppColors.black,
            tab: _tabVisual,
          ),
          _Kpi(
            'Líquido',
            _fmtEuros(liquido),
            Icons.balance,
            liquido >= 0 ? AppColors.green : Colors.redAccent,
            tab: _tabVisual,
          ),
        ]),
        const SizedBox(height: 8),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.visualMissedDays,
            justified: b.visualJustifiedDays,
            kind: JustificationKind.visual,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Inventário', tab: _tabInventory),
        _kpiGrid([
          _Kpi(
            'Inventários',
            '${b.invCount}',
            Icons.assignment,
            AppColors.green,
            tab: _tabInventory,
            delta: _deltaInt(b.invCount, stats.prev?.invCount),
          ),
          _Kpi(
            'Valor total',
            _fmtEuros(b.invValueCents),
            Icons.euro,
            b.invValueCents >= 0 ? AppColors.green : Colors.redAccent,
            tab: _tabInventory,
          ),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('Tarefas Diárias', tab: _tabTasks),
        _sectionCard(
          tab: _tabTasks,
          title: b.taskTotal == 0
              ? 'Sem registos'
              : '${b.taskDone}/${b.taskTotal} tarefas concluídas',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final name in taskNames)
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
        const SizedBox(height: 8),
        _sectionCard(
          title: 'Dias com falhas',
          child: _MissedDays(
            missed: b.taskMissedDays,
            justified: b.taskJustifiedDays,
            kind: JustificationKind.tasks,
            onChanged: onRefresh,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PeopleTab extends StatefulWidget {
  const _PeopleTab();
  @override
  State<_PeopleTab> createState() => _PeopleTabState();
}

class _PeopleTabState extends State<_PeopleTab> {
  late Future<_PeopleData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    PersonService.instance.addListener(_reload);
    PersonHistoryService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    PersonService.instance.removeListener(_reload);
    PersonHistoryService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (mounted) setState(() => _future = _load());
  }

  Future<_PeopleData> _load() async {
    final people = await PersonService.instance.all();
    final leaderboard = [
      for (final p in people)
        PersonMonthlyEntry(
          uuid: p.syncUuid,
          fullName: p.fullName,
          collaboratorNumber: p.collaboratorNumber,
          points: p.points,
        ),
    ]..sort((a, b) => b.points.compareTo(a.points));
    final history = PersonHistoryService.instance.history();
    final currentYm =
        PersonHistoryService.instance.currentTrackedYearMonth() ??
        (DateTime.now().year * 100 + DateTime.now().month);
    return _PeopleData(
      currentYear: currentYm ~/ 100,
      currentMonth: currentYm % 100,
      currentLeaderboard: leaderboard,
      history: history,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PeopleData>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snap.data!;
        final monthFmt = DateFormat("MMMM 'de' y", 'pt_PT');
        final currentLabel = monthFmt.format(
          DateTime(data.currentYear, data.currentMonth, 1),
        );
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: 'Este mês · ${_capitalize(currentLabel)}',
              child: data.currentLeaderboard.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Sem pessoas registadas.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : _Leaderboard(entries: data.currentLeaderboard),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Histórico mensal'),
            if (data.history.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Ainda não há meses concluídos.\nOs pontos são guardados aqui automaticamente no início de cada mês.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              for (final snapshot in data.history)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Text(
                      _capitalize(
                        monthFmt.format(
                          DateTime(snapshot.year, snapshot.month, 1),
                        ),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(_historySubtitle(snapshot)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _Leaderboard(entries: snapshot.entries),
                      ),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }

  String _historySubtitle(PersonMonthlySnapshot s) {
    if (s.entries.isEmpty) return 'Sem pontos registados';
    final top = s.entries.first;
    return '${s.entries.length} pessoa(s) · Top: ${top.fullName} (${top.points} pts)';
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

class _PeopleData {
  _PeopleData({
    required this.currentYear,
    required this.currentMonth,
    required this.currentLeaderboard,
    required this.history,
  });
  final int currentYear;
  final int currentMonth;
  final List<PersonMonthlyEntry> currentLeaderboard;
  final List<PersonMonthlySnapshot> history;
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.entries});
  final List<PersonMonthlyEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Sem pontos.', style: TextStyle(color: Colors.black54)),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: i < 3 ? AppColors.greenDark : Colors.black45,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entries[i].fullName.isEmpty
                            ? '(sem nome)'
                            : entries[i].fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (entries[i].collaboratorNumber.isNotEmpty)
                        Text(
                          'Nº ${entries[i].collaboratorNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars,
                        size: 14,
                        color: AppColors.greenDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entries[i].points}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// Helpers (shared)
// ============================================================================

String _fmtEuros(int cents) {
  final v = cents / 100;
  return NumberFormat.currency(locale: 'pt_PT', symbol: '€').format(v);
}

Widget _sectionTitle(String text, {int? tab}) {
  return Builder(
    builder: (ctx) {
      final inner = Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            if (tab != null)
              const Icon(Icons.chevron_right, size: 20, color: Colors.black45),
          ],
        ),
      );
      if (tab == null) return inner;
      return InkWell(onTap: () => _openHistory(ctx, tab), child: inner);
    },
  );
}

Widget _sectionCard({required String title, required Widget child, int? tab}) {
  return Builder(
    builder: (ctx) {
      final content = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
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
    },
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

// ============================================================================
// Data classes
// ============================================================================

class _Bucket {
  _Bucket({
    required this.daysInRange,
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
    required this.truckCount,
    required this.totalPallets,
    required this.aberturaTotal,
    required this.reportTotal,
    required this.autoCount,
    required this.visualTotalItems,
    required this.visualQuebraCents,
    required this.visualBeneficioCents,
    required this.visualGoalDays,
    required this.taskRows,
    required this.taskDone,
    required this.taskTotal,
    required this.taskDoneByName,
    required this.taskTotalByName,
    required this.invCount,
    required this.invValueCents,
  });
  final int daysInRange;
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
  final int truckCount;
  final int totalPallets;
  final int aberturaTotal;
  final int reportTotal;
  final int autoCount;
  final int visualTotalItems;
  final int visualQuebraCents;
  final int visualBeneficioCents;
  final int visualGoalDays;
  final int taskRows;
  final int taskDone;
  final int taskTotal;
  final Map<String, int> taskDoneByName;
  final Map<String, int> taskTotalByName;
  final int invCount;
  final int invValueCents;
}

class _Stats {
  _Stats({required this.bucket, required this.visualGoal, this.prev});
  final _Bucket bucket;
  final _Bucket? prev;
  final int visualGoal;
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
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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

// ============================================================================
// KPI card
// ============================================================================

class _Kpi {
  const _Kpi(
    this.label,
    this.value,
    this.icon,
    this.color, {
    this.tab,
    this.delta,
  });
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  kpi.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
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
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => HistoricoScreen(initialTab: tab)));
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
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            Text(
              '$pct%',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
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
      return const Text(
        'Sem falhas no período.',
        style: TextStyle(fontSize: 13, color: AppColors.green),
      );
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (c.justifiedFlag ? Colors.amber : Colors.redAccent)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (c.justifiedFlag ? Colors.amber : Colors.redAccent)
                      .withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                fmt.format(c.day),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.justifiedFlag
                      ? Colors.amber.shade800
                      : Colors.redAccent,
                ),
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
