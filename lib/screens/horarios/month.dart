part of '../horarios_screen.dart';

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final String month;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final name = monthName(month);
    return Row(
      children: [
        IconButton(
          tooltip: 'Mês anterior',
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrevious,
        ),
        Expanded(
          child: Text(
            '${name[0].toUpperCase()}${name.substring(1)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          tooltip: 'Mês seguinte',
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// The month as on paper: names down the side (fixed), days across
/// (scrolling, starting near today), one code per cell, and at the bottom how
/// many work each day de dia and de noite. Tapping a cell says what the code
/// means.
class _MonthGrid extends StatefulWidget {
  const _MonthGrid({
    super.key,
    required this.horarios,
    required this.month,
    required this.today,
    required this.index,
  });

  final Horarios horarios;
  final String month;
  final DateTime today;
  final HorarioIndex index;

  @override
  State<_MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<_MonthGrid> {
  static const _cellWidth = 46.0;
  static const _rowHeight = 32.0;
  static const _nameWidth = 116.0;

  late final ScrollController _scroll;

  bool get _isCurrentMonth => monthKey(widget.today) == widget.month;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController(
      initialScrollOffset: _isCurrentMonth
          ? ((widget.today.day - 3).clamp(0, 31)) * _cellWidth
          : 0,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _explain(String name, DateTime day, String code) {
    final h = widget.horarios;
    final person = widget.index.personOf(widget.month, name);
    final meaning =
        h.codigos[code]?.forPerson(person).timesText ??
        h.ausencias[code] ??
        'Código sem horário';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$name · ${DateFormat("d MMM", 'pt_PT').format(day)}\n'
            '$code · $meaning',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.horarios;
    final rows = h.meses[widget.month]!;
    final parts = widget.month.split('-');
    final year = int.parse(parts[0]);
    final mon = int.parse(parts[1]);
    final days = DateTime(year, mon + 1, 0).day;
    final counts = [for (var d = 1; d <= days; d++) dayCounts(h, rows, d)];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _cell(const SizedBox(), width: _nameWidth),
              for (final name in rows.keys)
                _cell(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  width: _nameWidth,
                ),
              for (final label in ['Dia', 'Noite'])
                _cell(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nº $label',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  width: _nameWidth,
                  color: context.tint(Colors.green),
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var d = 1; d <= days; d++)
                        _dayHeader(DateTime(year, mon, d)),
                    ],
                  ),
                  for (final e in rows.entries)
                    Row(
                      children: [
                        for (var d = 1; d <= days; d++)
                          _cell(
                            Text(
                              e.value[d - 1],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: e.value[d - 1] == folgaCode
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                color: e.value[d - 1] == folgaCode
                                    ? context.faint
                                    : null,
                              ),
                            ),
                            color: _cellColor(context, h, e.value[d - 1]),
                            today: _isCurrentMonth && d == widget.today.day,
                            onTap: () => _explain(
                              e.key,
                              DateTime(year, mon, d),
                              e.value[d - 1],
                            ),
                          ),
                      ],
                    ),
                  for (final noite in [false, true])
                    Row(
                      children: [
                        for (var d = 1; d <= days; d++)
                          _cell(
                            Text(
                              '${noite ? counts[d - 1].noite : counts[d - 1].dia}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            color: context.tint(Colors.green),
                            today: _isCurrentMonth && d == widget.today.day,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(
    Widget child, {
    double width = _cellWidth,
    Color? color,
    bool today = false,
    VoidCallback? onTap,
  }) {
    final border = BorderSide(color: context.hairline);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: _rowHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: today
              ? Border.all(color: context.colors.primary, width: 1.5)
              : Border(right: border, bottom: border),
        ),
        child: child,
      ),
    );
  }

  /// Weekday initial over the day number; weekends bold and shaded.
  Widget _dayHeader(DateTime day) {
    const letters = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final weekend = day.weekday >= DateTime.saturday;
    final style = TextStyle(
      fontSize: 10,
      height: 1.1,
      fontWeight: weekend ? FontWeight.w800 : FontWeight.w500,
    );
    return _cell(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(letters[day.weekday - 1], style: style),
          Text('${day.day}', style: style),
        ],
      ),
      color: weekend ? context.tint(Colors.grey, 100) : null,
      today: _isCurrentMonth && day.day == widget.today.day,
    );
  }
}

/// Per line of [month]: hours at work (without pausas), shifts and days of
/// each absence, beside the person's contracted hours a week when known.
class _MonthTotals extends StatelessWidget {
  const _MonthTotals({
    required this.horarios,
    required this.month,
    required this.index,
  });

  final Horarios horarios;
  final String month;
  final HorarioIndex index;

  @override
  Widget build(BuildContext context) {
    final rows = horarios.meses[month]!;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(Icons.functions, color: context.colors.primary),
        title: const Text(
          'Totais do mês',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Horas sem pausas · turnos · ausências'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final e in rows.entries)
            _totalRow(
              context,
              e.key,
              summarizeLine(
                horarios,
                e.value,
                person: index.personOf(month, e.key),
              ),
              index.personOf(month, e.key)?.weeklyHours,
            ),
        ],
      ),
    );
  }

  Widget _totalRow(
    BuildContext context,
    String name,
    ({int minutes, int shifts, Map<String, int> ausencias}) s,
    int? weeklyHours,
  ) {
    final details = [
      '${s.shifts} turno${s.shifts == 1 ? '' : 's'}',
      for (final e in s.ausencias.entries)
        '${horarios.ausencias[e.key] ?? e.key} ${e.value}',
      if (weeklyHours != null) 'contrato ${weeklyHours}h/semana',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                Text(
                  details,
                  style: TextStyle(fontSize: 12, color: context.muted),
                ),
              ],
            ),
          ),
          Text(
            hoursText(s.minutes),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// The codes used in [month] with their times, then the absence codes.
class _Legend extends StatelessWidget {
  const _Legend({required this.horarios, required this.month});

  final Horarios horarios;
  final String month;

  @override
  Widget build(BuildContext context) {
    final used = {for (final line in horarios.meses[month]!.values) ...line};
    final shifts = [
      for (final e in horarios.codigos.entries)
        if (used.contains(e.key)) e,
    ]..sort((a, b) => a.value.entrada.compareTo(b.value.entrada));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.info_outline, color: context.colors.primary),
        title: const Text(
          'Códigos deste mês',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final e in shifts)
            _LegendRow(
              code: e.key,
              text: e.value.timesText,
              color: _cellColor(context, horarios, e.key),
            ),
          const Divider(),
          for (final e in horarios.ausencias.entries)
            _LegendRow(
              code: e.key,
              text: e.value,
              color: _cellColor(context, horarios, e.key),
            ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.code, required this.text, this.color});

  final String code;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: context.hairline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
