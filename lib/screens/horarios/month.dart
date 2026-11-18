part of '../horarios_screen.dart';

/// The whole month like the Excel file: names fixed on the left, the days
/// scrolling sideways, today's column marked.
class _MonthTab extends StatefulWidget {
  const _MonthTab(this.view);

  final _HorarioView view;

  @override
  State<_MonthTab> createState() => _MonthTabState();
}

class _MonthTabState extends State<_MonthTab> {
  DateTime _month = DateTime(currentServiceDay().year, currentServiceDay().month);

  void _move(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    final m = view.index.monthOf(_month);
    final thisMonth = DateTime(currentServiceDay().year, currentServiceDay().month);
    final stepper = _Stepper(
      label: monthTitle(_month),
      onPrevious: () => _move(-1),
      onNext: () => _move(1),
      onToday: _month == thisMonth
          ? null
          : () => setState(() => _month = thisMonth),
    );
    if (m == null) {
      return Column(
        children: [
          stepper,
          Expanded(child: _NoHorario(view, _month)),
        ],
      );
    }
    final last = DateTime(_month.year, _month.month + 1, 0).day;
    final days = [
      for (var d = 1; d <= last; d++) DateTime(_month.year, _month.month, d),
    ];
    final today = currentServiceDay();
    const cell = 44.0;
    const rowHeight = 38.0;
    final groups = _groups(m.linhas);

    // Names on the left, the same rows as the grid on the right.
    final nameRows = <Widget>[const SizedBox(height: 40)];
    final gridRows = <Widget>[
      SizedBox(
        height: 40,
        child: Row(
          children: [
            for (final d in days)
              SizedBox(
                width: cell + 2,
                child: Text(
                  '${_weekdayShort[d.weekday - 1]}\n${d.day}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: d == today ? FontWeight.w800 : FontWeight.w500,
                    color: d == today
                        ? context.colors.primary
                        : d.weekday == DateTime.sunday
                        ? context.warningText
                        : context.muted,
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
    for (final g in groups) {
      final heading = Text(
        g.grupo,
        style: TextStyle(fontWeight: FontWeight.w700, color: context.muted),
      );
      nameRows.add(
        SizedBox(
          height: 28,
          child: Align(alignment: Alignment.bottomLeft, child: heading),
        ),
      );
      gridRows.add(const SizedBox(height: 28));
      for (final l in g.linhas) {
        nameRows.add(
          SizedBox(
            height: rowHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                shortName(view.nameOf(l)),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        );
        gridRows.add(
          SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                for (final d in days)
                  _Cell(
                    switch (m.columnOf(d)) {
                      final col? => m.dayAt(l, col),
                      null => null,
                    },
                    width: cell,
                    today: d == today,
                  ),
              ],
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        stepper,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: nameRows,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: gridRows,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Importado por ${m.importedBy.isEmpty ? '—' : m.importedBy} a '
            '${DateFormat("d 'de' MMMM, HH:mm", 'pt_PT').format(m.importedAt)}.',
            style: TextStyle(color: context.muted, fontSize: 12),
          ),
        ),
        const _Legend(),
      ],
    );
  }
}
