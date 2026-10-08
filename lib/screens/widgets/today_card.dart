import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/horario.dart';
import '../../models/person.dart';
import '../../models/planning.dart';
import '../../models/opening_list.dart';
import '../../models/teams.dart';
import '../../models/today.dart';
import '../../services/auto_list_service.dart';
import '../../services/daily_tasks_service.dart';
import '../../services/horario_service.dart';
import '../../services/opening_list_service.dart';
import '../../services/pedido_service.dart';
import '../../services/person_service.dart';
import '../../services/report_list_service.dart';
import '../../services/settings_service.dart';
import '../../services/truck_service.dart';
import '../../services/visual_list_service.dart';
import '../../theme.dart';
import '../historico_screen.dart';
import '../horarios_screen.dart';
import '../pedidos_screen.dart';
import '../people_screen.dart';
import '../tasks_screen.dart';

/// What the "Hoje" card shows, read at one moment.
class _TodayData {
  const _TodayData({
    required this.serviceDay,
    required this.hasHorario,
    required this.onShift,
    required this.counts,
    required this.pending,
    required this.overduePedidos,
    required this.trucks,
    required this.pallets,
    required this.missingMonth,
    required this.birthdays,
  });

  final DateTime serviceDay;

  /// Whether this month has a horário for Livre Serviço.
  final bool hasHorario;
  final List<OnShift> onShift;
  final ({int dia, int noite}) counts;
  final List<String> pending;
  final int overduePedidos;
  final int trucks;
  final int pallets;

  /// Next month's key when its horário is due and not imported.
  final String? missingMonth;

  /// Today's birthdays and those in the next 7 days, everyone in Pessoas.
  final List<({Person person, DateTime date})> birthdays;
}

/// The home screen's summary of the service day: who is working now, the
/// daily tasks still to do, a missing next month's horário, birthdays, late
/// pedidos and today's camiões. Each line
/// opens its page.
class TodayCard extends StatefulWidget {
  const TodayCard({super.key});

  @override
  State<TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends State<TodayCard> {
  _TodayData? _data;
  Timer? _clock;

  List<Listenable> get _sources => [
    HorarioService.instance,
    PersonService.instance,
    DailyTasksService.instance,
    OpeningListService.instance,
    ReportListService.instance,
    VisualListService.instance,
    AutoListService.instance,
    PedidoService.instance,
    TruckService.instance,
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _sources) {
      s.addListener(_reload);
    }
    // Shifts start and end and validades windows open while the card shows.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => _reload());
    _reload();
  }

  @override
  void dispose() {
    for (final s in _sources) {
      s.removeListener(_reload);
    }
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    final now = DateTime.now();
    final day = currentServiceDay(now);
    final dayEnd = day.add(const Duration(hours: 24));
    bool inDay(DateTime t) => !t.isBefore(day) && t.isBefore(dayEnd);

    final everyone = await PersonService.instance.all();
    final people = [
      for (final p in everyone)
        if (p.team == livreServicoId) p,
    ];
    final index = HorarioService.instance.index;
    final tasks = await DailyTasksService.instance.find(day);
    final openings = await OpeningListService.instance.entriesForServiceDay(
      day,
    );
    final reports = await ReportListService.instance.entriesForServiceDay(day);
    final visual = await VisualListService.instance.entriesForServiceDay(day);
    final autos = await AutoListService.instance.history();
    final pedidos = await PedidoService.instance.history();
    final trucks = [
      for (final t in await TruckService.instance.all())
        if (inDay(t.arrivalTime)) t,
    ];

    final data = _TodayData(
      serviceDay: day,
      hasHorario: index.horarios.meses.containsKey(monthKey(day)),
      onShift: onShiftAt(index, people, now),
      counts: shiftCountsOn(index, people, day),
      pending: pendingDailyTasks(
        tasks,
        aberturaDone: openings.any((o) => o.isFinalized),
        relatorioDone: reports.any((r) => r.isFinalized),
        visualDone:
            visual.fold(0, (s, e) => s + e.itensPicados) >=
            SettingsService.instance.visualGoal,
        autoDone: autos.any((a) => inDay(a.createdAt)),
        now: now,
      ),
      overduePedidos: pedidos.where((p) => p.isOverdue).length,
      trucks: trucks.length,
      pallets: trucks.fold(0, (s, t) => s + t.totalPallets),
      missingMonth: missingNextMonth(HorarioService.instance.horarios, day),
      birthdays: upcomingBirthdays(everyone, day),
    );
    if (mounted) setState(() => _data = data);
  }

  void _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final d = _data;
    if (d == null) return const SizedBox.shrink();
    final dayText = DateFormat(
      "EEEE, d 'de' MMMM",
      'pt_PT',
    ).format(d.serviceDay);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Hoje · $dayText',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          if (d.hasHorario)
            _Line(
              icon: Icons.groups,
              title: d.onShift.isEmpty
                  ? 'Ninguém em turno agora'
                  : 'A trabalhar agora (${d.onShift.length})',
              text: [
                if (d.onShift.isNotEmpty)
                  d.onShift.map((s) => shortName(s.person.fullName)).join(', '),
                'Hoje: ${d.counts.dia} de dia · ${d.counts.noite} de noite',
              ].join('\n'),
              onTap: () => _open(const HorariosScreen()),
            ),
          _Line(
            icon: d.pending.isEmpty ? Icons.task_alt : Icons.pending_actions,
            color: d.pending.isEmpty ? AppColors.green : Colors.orange.shade800,
            title: d.pending.isEmpty
                ? 'Tarefas diárias feitas'
                : 'Por fazer (${d.pending.length})',
            text: d.pending.isEmpty ? null : d.pending.join(', '),
            onTap: () => _open(const TasksScreen()),
          ),
          if (d.missingMonth case final month?)
            _Line(
              icon: Icons.event_busy,
              color: Colors.orange.shade800,
              title: 'Falta o horário de ${monthName(month)}',
              onTap: () => _open(const HorariosScreen()),
            ),
          if (d.birthdays.isNotEmpty)
            _Line(
              icon: Icons.cake,
              color: Colors.pink.shade400,
              title: 'Aniversários',
              text: [
                for (final b in d.birthdays)
                  '${shortName(b.person.fullName)} · ${_whenText(b.date, d.serviceDay)}',
              ].join('\n'),
              onTap: () => _open(const PeopleScreen()),
            ),
          if (d.overduePedidos > 0)
            _Line(
              icon: Icons.receipt_long,
              color: Colors.red.shade700,
              title: d.overduePedidos == 1
                  ? '1 pedido atrasado'
                  : '${d.overduePedidos} pedidos atrasados',
              onTap: () => _open(const PedidosScreen()),
            ),
          if (d.trucks > 0)
            _Line(
              icon: Icons.local_shipping,
              title: d.trucks == 1
                  ? '1 camião hoje'
                  : '${d.trucks} camiões hoje',
              text: d.pallets == 1 ? '1 palete' : '${d.pallets} paletes',
              onTap: () => _open(const HistoricoScreen(initialTab: 1)),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// "hoje", "amanhã" or the weekday and date ("sábado, 10/10") of [date].
String _whenText(DateTime date, DateTime today) {
  final days = DateTime(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (days == 0) return 'hoje 🎂';
  if (days == 1) return 'amanhã';
  return DateFormat("EEEE, d/M", 'pt_PT').format(date);
}

/// One line of the card: an icon, a bold [title], optional [text] below.
class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.title,
    required this.onTap,
    this.text,
    this.color = AppColors.green,
  });

  final IconData icon;
  final String title;
  final String? text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: text == null ? null : Text(text!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
