import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/horario.dart';
import '../models/opening_list.dart';
import '../services/horario_service.dart';
import '../theme.dart';

/// The Livre Serviço horários: who is in today, the month as a read-only
/// grid, the codes used, and the file's Exportar / Importar. The horários
/// are only edited in the file.
class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  /// The month shown in the grid; null until there is one.
  String? _month;
  bool _busy = false;

  HorarioService get _service => HorarioService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_changed);
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  /// [_month] if still saved, else the current month, else the latest.
  String? _shownMonth(List<String> months) {
    if (months.isEmpty) return null;
    if (_month case final m? when months.contains(m)) return m;
    final current = monthKey(currentServiceDay());
    return months.contains(current) ? current : months.last;
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await _service.exportFile();
    } catch (e) {
      _snack('Erro ao exportar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final result = await _service.pickAndImport();
      if (result == null || !mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Horários importados'),
          content: Text(
            [
              if (result.meses.isEmpty)
                'O ficheiro não tinha meses; os códigos foram atualizados.'
              else
                'Meses: ${result.meses.map(_monthName).join(', ')}.',
              for (final e in result.unmatched.entries)
                '\n${_monthName(e.key)} — sem correspondência em Pessoas '
                    '(Livre Serviço): ${e.value.join(', ')}.',
            ].join('\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FormatException catch (e) {
      _snack('Erro ao importar: ${e.message}');
    } catch (e) {
      _snack('Erro ao importar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = _service.horarios;
    final months = h.meses.keys.toList()..sort();
    final month = _shownMonth(months);
    final today = currentServiceDay();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários'),
        actions: [
          IconButton(
            tooltip: 'Exportar horários',
            icon: const Icon(Icons.upload_file),
            onPressed: _busy ? null : _export,
          ),
          IconButton(
            tooltip: 'Importar horários',
            icon: const Icon(Icons.download),
            onPressed: _busy ? null : _import,
          ),
        ],
      ),
      body: SafeArea(
        child: month == null
            ? _Empty(onImport: _busy ? null : _import)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _TodayCard(horarios: h, today: today),
                  if (_service.index.unmatched(month) case final names
                      when names.isNotEmpty)
                    _UnmatchedCard(month: month, names: names),
                  const SizedBox(height: 12),
                  _MonthHeader(
                    month: month,
                    onPrevious: switch (months.indexOf(month)) {
                      0 => null,
                      final i => () => setState(() => _month = months[i - 1]),
                    },
                    onNext: months.indexOf(month) == months.length - 1
                        ? null
                        : () => setState(
                            () => _month = months[months.indexOf(month) + 1],
                          ),
                  ),
                  const SizedBox(height: 8),
                  _MonthGrid(
                    key: ValueKey(month),
                    horarios: h,
                    month: month,
                    today: today,
                  ),
                  const SizedBox(height: 12),
                  _MonthTotals(
                    horarios: h,
                    month: month,
                    index: _service.index,
                  ),
                  const SizedBox(height: 12),
                  _Legend(horarios: h, month: month),
                ],
              ),
      ),
    );
  }
}

/// "outubro de 2026" for "2026-10".
String _monthName(String month) {
  final parts = month.split('-');
  return DateFormat(
    "MMMM 'de' y",
    'pt_PT',
  ).format(DateTime(int.parse(parts[0]), int.parse(parts[1])));
}

bool _isNight(Horarios h, String code) => h.codigos[code]?.noturno ?? false;

/// The cell colour for [code]: absences tinted, night shifts darker.
Color? _cellColor(Horarios h, String code) => switch (code) {
  folgaCode => Colors.grey.shade300,
  'F' => Colors.orange.shade100,
  _ when h.ausencias.containsKey(code) => Colors.red.shade100,
  _ when _isNight(h, code) => Colors.indigo.shade50,
  _ => null,
};

class _Empty extends StatelessWidget {
  const _Empty({required this.onImport});

  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            const Text(
              'Sem horários guardados.\nImporta um ficheiro de horários '
              '(JSON) com os meses do Livre Serviço.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.download),
              label: const Text('Importar horários'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Today's lines: who is on a shift (Dia, then Noite, by entrada) and who
/// is off and why.
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.horarios, required this.today});

  final Horarios horarios;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final rows = horarios.meses[monthKey(today)];
    final day = DateFormat("EEEE, d 'de' MMMM", 'pt_PT').format(today);
    final shifts = <(String, String, HorarioCodigo)>[];
    final off = <(String, String)>[];
    for (final e in (rows ?? const <String, List<String>>{}).entries) {
      final code = e.value[today.day - 1];
      if (horarios.codigos[code] case final c?) {
        shifts.add((e.key, code, c));
      } else {
        off.add((e.key, horarios.ausencias[code] ?? code));
      }
    }
    shifts.sort((a, b) => a.$3.entrada.compareTo(b.$3.entrada));
    final dia = [
      for (final s in shifts)
        if (!s.$3.noturno) s,
    ];
    final noite = [
      for (final s in shifts)
        if (s.$3.noturno) s,
    ];

    Widget shiftRow((String, String, HorarioCodigo) s) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(s.$1)),
          Text(
            '${s.$2} · ${s.$3.shortText}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.greenDark,
        ),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoje · ${day[0].toUpperCase()}${day.substring(1)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (rows == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Sem horário para este mês.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else ...[
              heading('Dia (${dia.length})'),
              if (dia.isEmpty) const Text('—'),
              for (final s in dia) shiftRow(s),
              heading('Noite (${noite.length})'),
              if (noite.isEmpty) const Text('—'),
              for (final s in noite) shiftRow(s),
              if (off.isNotEmpty) ...[
                heading('Não trabalham'),
                for (final (name, reason) in off)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        Text(
                          reason,
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _UnmatchedCard extends StatelessWidget {
  const _UnmatchedCard({required this.month, required this.names});

  final String month;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sem correspondência em Pessoas (Livre Serviço): '
                '${names.join(', ')}. Confirma o nome e a equipa da pessoa, '
                'ou corrige o nome no ficheiro.',
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    final name = _monthName(month);
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
  });

  final Horarios horarios;
  final String month;
  final DateTime today;

  @override
  State<_MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<_MonthGrid> {
  static const _cellWidth = 46.0;
  static const _rowHeight = 32.0;
  static const _nameWidth = 116.0;
  static final _countColor = Colors.green.shade50;

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
    final meaning =
        h.codigos[code]?.timesText ?? h.ausencias[code] ?? 'Código sem horário';
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
                  color: _countColor,
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
                                    ? Colors.black45
                                    : null,
                              ),
                            ),
                            color: _cellColor(h, e.value[d - 1]),
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
                            color: _countColor,
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
    const border = BorderSide(color: Colors.black12);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: _rowHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: today
              ? Border.all(color: AppColors.green, width: 1.5)
              : const Border(right: border, bottom: border),
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
      color: weekend ? Colors.grey.shade100 : null,
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
        leading: const Icon(Icons.functions, color: AppColors.green),
        title: const Text(
          'Totais do mês',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Horas sem pausas · turnos · ausências'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final e in rows.entries)
            _totalRow(
              e.key,
              summarizeLine(horarios, e.value),
              index.personOf(month, e.key)?.weeklyHours,
            ),
        ],
      ),
    );
  }

  Widget _totalRow(
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
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
        leading: const Icon(Icons.info_outline, color: AppColors.green),
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
              color: _cellColor(horarios, e.key),
            ),
          const Divider(),
          for (final e in horarios.ausencias.entries)
            _LegendRow(
              code: e.key,
              text: e.value,
              color: _cellColor(horarios, e.key),
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
              border: Border.all(color: Colors.black12),
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
