part of '../horarios_screen.dart';

/// Today's lines: who is on a shift (Dia, then Noite, by entrada) and who
/// is off and why. A person's own entrada and saída replace the code's.
class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.horarios,
    required this.today,
    required this.index,
  });

  final Horarios horarios;
  final DateTime today;
  final HorarioIndex index;

  @override
  Widget build(BuildContext context) {
    final rows = horarios.meses[monthKey(today)];
    final day = DateFormat("EEEE, d 'de' MMMM", 'pt_PT').format(today);
    final shifts = <(String, String, HorarioCodigo)>[];
    final off = <(String, String)>[];
    for (final e in (rows ?? const <String, List<String>>{}).entries) {
      final code = e.value[today.day - 1];
      if (horarios.codigos[code] case final c?) {
        final person = index.personOf(monthKey(today), e.key);
        shifts.add((e.key, code, c.forPerson(person)));
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
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: context.colors.secondary,
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
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Sem horário para este mês.',
                  style: TextStyle(color: context.muted),
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
                            style: TextStyle(color: context.muted),
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

/// "Falta o horário de novembro de 2026", with Importar.
class _MissingMonthCard extends StatelessWidget {
  const _MissingMonthCard({required this.month, required this.onImport});

  final String month;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.tint(Colors.orange),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        child: Row(
          children: [
            Icon(Icons.event_busy, color: Colors.orange.shade800),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Falta o horário de ${monthName(month)}.',
                style: TextStyle(
                  color: context.warningText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(onPressed: onImport, child: const Text('Importar')),
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
      color: context.tint(Colors.orange),
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
                style: TextStyle(color: context.warningText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
