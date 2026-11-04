import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/daily_tasks.dart';
import '../../models/pedido.dart';
import '../../models/person.dart';
import '../../models/planning.dart';
import '../../models/opening_list.dart';
import '../../models/teams.dart';
import '../../models/today.dart';
import '../../models/truck_reception.dart';
import '../../services/daily_tasks_service.dart';
import '../../services/pedido_service.dart';
import '../../services/person_service.dart';
import '../../services/truck_service.dart';
import '../../services/visivel2_service.dart';
import '../../theme.dart';
import '../historico_screen.dart';
import '../pedidos_screen.dart';
import '../people_screen.dart';
import '../tasks_screen.dart';

/// What the "Hoje" card shows, read at one moment.
class _TodayData {
  const _TodayData({
    required this.serviceDay,
    required this.hasShifts,
    required this.onShift,
    required this.counts,
    required this.pending,
    required this.overduePedidos,
    required this.trucks,
    required this.pallets,
    required this.birthdays,
  });

  final DateTime serviceDay;

  /// Whether anyone in Livre Serviço has their shift times set.
  final bool hasShifts;
  final List<OnShift> onShift;
  final ({int dia, int noite}) counts;
  final List<String> pending;
  final int overduePedidos;
  final int trucks;
  final int pallets;

  /// Today's birthdays and those in the next 7 days, everyone in Pessoas.
  final List<({Person person, DateTime date})> birthdays;
}

/// The home screen's summary of the service day: who is working now, the
/// daily tasks still to do, birthdays, late pedidos and today's camiões. Each line
/// opens its page.
class TodayCard extends StatefulWidget {
  const TodayCard({super.key});

  @override
  State<TodayCard> createState() => _TodayCardState();
}

/// The rows the card reads from the database for one service day.
class _DayRows {
  const _DayRows({
    required this.day,
    required this.everyone,
    required this.tasks,
    required this.visivelDone,
    required this.pedidos,
    required this.trucks,
  });

  final DateTime day;
  final List<Person> everyone;
  final DailyTasks? tasks;
  final bool visivelDone;
  final List<Pedido> pedidos;
  final List<TruckReception> trucks;
}

class _TodayCardState extends State<TodayCard> {
  _TodayData? _data;
  _DayRows? _rows;
  Timer? _clock;

  List<Listenable> get _sources => [
    PersonService.instance,
    DailyTasksService.instance,
    Visivel2Service.instance,
    PedidoService.instance,
    TruckService.instance,
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _sources) {
      s.addListener(_reload);
    }
    // Shifts start and end and validades windows open while the card shows:
    // recount from the rows already read, unless a new service day began.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_rows?.day == currentServiceDay()) {
        _recount();
      } else {
        _reload();
      }
    });
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

  /// Reads today's rows, then [_recount]s.
  Future<void> _reload() async {
    final day = currentServiceDay();
    final rows = _DayRows(
      day: day,
      everyone: await PersonService.instance.all(),
      tasks: await DailyTasksService.instance.find(day),
      visivelDone: (await Visivel2Service.instance.forServiceDay(
        day,
      )).isNotEmpty,
      pedidos: await PedidoService.instance.openWithDate(),
      trucks: await TruckService.instance.forServiceDay(day),
    );
    if (!mounted) return;
    _rows = rows;
    _recount();
  }

  /// Works out the card from [_rows] and the time now, without reading
  /// the database.
  void _recount() {
    final rows = _rows;
    if (rows == null || !mounted) return;
    final now = DateTime.now();
    final day = rows.day;
    final people = [
      for (final p in rows.everyone)
        if (p.team == livreServicoId) p,
    ];
    setState(() {
      _data = _TodayData(
        serviceDay: day,
        hasShifts: people.any((p) => shiftSpanOn(p, day) != null),
        onShift: onShiftAt(people, now),
        counts: shiftCountsOn(people, day),
        pending: pendingDailyTasks(
          rows.tasks,
          visivelDone: rows.visivelDone,
          now: now,
        ),
        overduePedidos: rows.pedidos.where((p) => p.isOverdue).length,
        trucks: rows.trucks.length,
        pallets: rows.trucks.fold(0, (s, t) => s + t.totalPallets),
        birthdays: upcomingBirthdays(rows.everyone, day),
      );
    });
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
          if (d.hasShifts)
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
              onTap: () => _open(const PeopleScreen()),
            ),
          _Line(
            icon: d.pending.isEmpty ? Icons.task_alt : Icons.pending_actions,
            color: d.pending.isEmpty
                ? context.colors.primary
                : Colors.orange.shade800,
            title: d.pending.isEmpty
                ? 'Tarefas diárias feitas'
                : 'Por fazer (${d.pending.length})',
            text: d.pending.isEmpty ? null : d.pending.join(', '),
            onTap: () => _open(const TasksScreen()),
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
    this.color,
  });

  final IconData icon;
  final String title;
  final String? text;

  /// The theme's primary colour when null.
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color ?? context.colors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: text == null ? null : Text(text!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
