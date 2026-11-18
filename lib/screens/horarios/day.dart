part of '../horarios_screen.dart';

/// One day: who works in each group (earliest first), then who is off.
class _DayTab extends StatefulWidget {
  const _DayTab(this.view);

  final _HorarioView view;

  @override
  State<_DayTab> createState() => _DayTabState();
}

class _DayTabState extends State<_DayTab> {
  DateTime _day = currentServiceDay();

  void _move(int days) => setState(
    () => _day = DateTime(_day.year, _day.month, _day.day + days),
  );

  String get _label {
    final today = currentServiceDay();
    final date = DateFormat('EEE, d MMM', 'pt_PT').format(_day);
    final diff = _day.difference(today).inHours;
    if (diff.abs() < 12) return 'Hoje · $date';
    if ((diff - 24).abs() < 12) return 'Amanhã · $date';
    if ((diff + 24).abs() < 12) return 'Ontem · $date';
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    final lines = view.index.linesOn(_day);
    final stepper = _Stepper(
      label: _label,
      onPrevious: () => _move(-1),
      onNext: () => _move(1),
      onToday: _dateOnly(_day) == currentServiceDay()
          ? null
          : () => setState(() => _day = currentServiceDay()),
    );
    if (lines.isEmpty) {
      return Column(
        children: [
          stepper,
          Expanded(child: _NoHorario(view, _day)),
        ],
      );
    }
    final dias = {for (final l in lines) l.linha: l.dia};
    final off = [
      for (final l in lines)
        if (l.dia != null && !l.dia!.isShift) l,
    ];
    return ReadableWidth(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          stepper,
          for (final g in _groups([for (final l in lines) l.linha]))
            if (g.linhas.any((l) => dias[l]?.isShift ?? false)) ...[
              _Heading(g.grupo),
              for (final l
                  in g.linhas.where((l) => dias[l]?.isShift ?? false).toList()
                    ..sort((a, b) {
                      final s = dias[a]!.entrada!.compareTo(dias[b]!.entrada!);
                      return s != 0 ? s : view.nameOf(a).compareTo(view.nameOf(b));
                    }))
                _DayRow(
                  name: view.nameOf(l),
                  dia: dias[l]!,
                  onTap: view.tapOf(context, l, _day, dias[l]),
                ),
            ],
          if (off.isNotEmpty) ...[
            const _Heading('Fora'),
            for (final l in off)
              _DayRow(
                name: view.nameOf(l.linha),
                dia: l.dia!,
                onTap: view.tapOf(context, l.linha, _day, l.dia),
              ),
          ],
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w700, color: context.muted),
    ),
  );
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.name, required this.dia, this.onTap});

  final String name;
  final HorarioDia dia;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    onTap: onTap,
    title: Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          name,
          style: TextStyle(color: dia.isShift ? null : context.muted),
        ),
        if (dia.changed != null)
          Text(
            'alterado',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.orange.shade800,
            ),
          ),
      ],
    ),
    trailing: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: horarioColor(context, dia.tipo),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        dia.text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: dia.isShift
              ? context.colors.onSurface
              : dia.tipo == HorarioTipo.ausente
              ? context.warningText
              : context.muted,
        ),
      ),
    ),
  );
}
