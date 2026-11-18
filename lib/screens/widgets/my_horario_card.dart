import 'package:flutter/material.dart';

import '../../models/horario.dart';
import '../../models/opening_list.dart';
import '../../models/person.dart';
import '../../services/account_service.dart';
import '../../services/horario_service.dart';
import '../../services/local_db.dart';
import '../../services/person_service.dart';
import '../../theme.dart';
import '../horarios_screen.dart';

const _weekdayShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

/// [person]'s days in the horário from [from] through [days] days, one line
/// each: "Seg 4" and "06:00–15:00" or "Folga". Days the horário says
/// nothing about are left out.
class HorarioDaysList extends StatelessWidget {
  const HorarioDaysList({
    super.key,
    required this.person,
    required this.index,
    required this.from,
    this.days = 7,
  });

  final Person person;
  final HorarioIndex index;
  final DateTime from;
  final int days;

  @override
  Widget build(BuildContext context) {
    final today = currentServiceDay();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final d in index.nextDays(person, from, days))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    '${_weekdayShort[d.date.weekday - 1]} ${d.date.day}',
                    style: TextStyle(
                      fontWeight: d.date == today
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: horarioColor(context, d.tipo),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    d.text,
                    style: TextStyle(
                      color: d.isShift
                          ? context.colors.onSurface
                          : d.tipo == HorarioTipo.ausente
                          ? context.warningText
                          : context.muted,
                      fontWeight: d.isShift ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// On Home, for an account linked to a person on the horário: their next
/// seven days. Opens Horários.
class MyHorarioCard extends StatefulWidget {
  const MyHorarioCard({super.key});

  @override
  State<MyHorarioCard> createState() => _MyHorarioCardState();
}

class _MyHorarioCardState extends State<MyHorarioCard> {
  Person? _me;

  @override
  void initState() {
    super.initState();
    PersonService.instance.addListener(_load);
    AccountService.instance.addListener(_load);
    HorarioService.instance.addListener(_changed);
    _load();
  }

  @override
  void dispose() {
    PersonService.instance.removeListener(_load);
    AccountService.instance.removeListener(_load);
    HorarioService.instance.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final id = AccountService.instance.store?.personId;
    final me = id == null
        ? null
        : await LocalDb.instance.persons.firstWhere((p) => p.syncUuid == id);
    if (mounted) setState(() => _me = me);
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    final index = HorarioService.instance.index;
    final today = currentServiceDay();
    if (me == null || index.nextDays(me, today, 7).isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HorariosScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Os meus próximos dias',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.muted),
                ],
              ),
              const SizedBox(height: 8),
              HorarioDaysList(person: me, index: index, from: today),
            ],
          ),
        ),
      ),
    );
  }
}
