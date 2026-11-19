part of '../horarios_screen.dart';

const _weekdayShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

/// Monday to Sunday: names down the side, one cell a day. Fits a phone
/// without scrolling sideways.
class _WeekTab extends StatefulWidget {
  const _WeekTab(this.view);

  final _HorarioView view;

  @override
  State<_WeekTab> createState() => _WeekTabState();
}

DateTime _mondayOf(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));

class _WeekTabState extends State<_WeekTab> {
  DateTime _monday = _mondayOf(currentServiceDay());

  void _move(int weeks) => setState(
    () => _monday = DateTime(
      _monday.year,
      _monday.month,
      _monday.day + 7 * weeks,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(_monday.year, _monday.month, _monday.day + i),
    ];
    final sunday = days.last;
    final fmt = DateFormat('d MMM', 'pt_PT');
    final stepper = _Stepper(
      label: '${fmt.format(_monday)} – ${fmt.format(sunday)}',
      onPrevious: () => _move(-1),
      onNext: () => _move(1),
      onToday: _monday == _mondayOf(currentServiceDay())
          ? null
          : () => setState(() => _monday = _mondayOf(currentServiceDay())),
    );

    // Every line in any of the week's months, once (by person, else name).
    final perDay = [
      for (final d in days) view.index.linesOn(d, people: view.people),
    ];
    final keys = <String>[];
    final linhaOf = <String, HorarioLinha>{};
    for (final lines in perDay) {
      for (final l in lines) {
        final key = l.linha.personId ?? 'nome:${l.linha.nome}';
        if (linhaOf.containsKey(key)) continue;
        keys.add(key);
        linhaOf[key] = l.linha;
      }
    }
    if (keys.isEmpty) {
      return Column(
        children: [
          stepper,
          Expanded(child: _NoHorario(view, _monday)),
        ],
      );
    }
    HorarioDia? dayOf(String key, int i) {
      for (final l in perDay[i]) {
        if ((l.linha.personId ?? 'nome:${l.linha.nome}') == key) return l.dia;
      }
      return null;
    }

    final today = currentServiceDay();
    return LayoutBuilder(
      builder: (context, box) {
        // The days first (at least 28 px each), the names in what is left.
        final cell = ((box.maxWidth - 16 - 72) / 7 - 2).clamp(28.0, 110.0);
        final nameWidth = (box.maxWidth - 16 - 7 * (cell + 2)).clamp(
          0.0,
          200.0,
        );
        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            stepper,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  SizedBox(width: nameWidth),
                  for (var i = 0; i < 7; i++)
                    SizedBox(
                      width: cell + 2,
                      child: Text(
                        '${_weekdayShort[i]}\n${days[i].day}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: days[i] == today
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: days[i] == today
                              ? context.colors.primary
                              : context.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            for (final g in _groups([for (final k in keys) linhaOf[k]!])) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                child: Text(
                  g.grupo,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.muted,
                  ),
                ),
              ),
              for (final l in g.linhas)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: nameWidth,
                        child: Text(
                          shortName(view.nameOf(l)),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      for (var i = 0; i < 7; i++)
                        () {
                          final dia = dayOf(l.personId ?? 'nome:${l.nome}', i);
                          final key = l.personId == null
                              ? null
                              : alteracaoKey(l.personId!, days[i]);
                          return _Cell(
                            dia,
                            key: key == null ? null : ValueKey('cell-$key'),
                            width: cell,
                            today: days[i] == today,
                            changeKey: key,
                            onTap: view.tapOf(context, l, days[i], dia),
                          );
                        }(),
                    ],
                  ),
                ),
            ],
            const _Legend(),
          ],
        );
      },
    );
  }
}
