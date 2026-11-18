import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/horario.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/planning.dart';
import 'package:livre_servico_app/models/today.dart';
import 'package:livre_servico_app/screens/people_sections.dart';

Person _p(String name, String uuid, {List<int> folgas = const []}) => Person()
  ..fullName = name
  ..syncUuid = uuid
  ..team = 'livre_servico'
  ..folgas = [...folgas]
  ..createdAt = DateTime(2026);

/// January 2027 (first column 31/12) with [lines]: uuid → codes.
HorarioIndex _index(Map<String, List<String>> lines) => HorarioIndex([
  HorarioMes()
    ..month = DateTime(2027, 1)
    ..firstDay = DateTime(2026, 12, 31)
    ..codigos = {
      'G82': (entrada: 360, saida: 900),
      'W82': (entrada: 1320, saida: 420),
    }
    ..linhas = [
      for (final e in lines.entries)
        HorarioLinha()
          ..nome = e.key
          ..personId = e.key
          ..codigos = e.value,
    ]
    ..importedAt = DateTime(2026, 12, 20),
]);

void main() {
  // 4 January 2027 is a Monday; column 4.
  final monday = DateTime(2027, 1, 4);

  test('a scheduled shift beats a fixed folga', () {
    final ana = _p('Ana', 'ana', folgas: [DateTime.monday]);
    final h = _index({
      'ana': ['', '', '', '', 'G82'],
    });
    expect(offLabelOn(ana, monday), 'Folga');
    expect(offLabelOn(ana, monday, horario: h), isNull);
    final span = shiftSpanOn(ana, monday, horario: h)!;
    expect(span.start, DateTime(2027, 1, 4, 6));
    expect(span.end, DateTime(2027, 1, 4, 15));
    expect(shiftTextOn(ana, monday, horario: h), '06:00–15:00');
  });

  test('a scheduled folga with no fixed folga', () {
    final ana = _p('Ana', 'ana');
    final h = _index({
      'ana': ['', '', '', '', '', 'FO'],
    });
    final tuesday = DateTime(2027, 1, 5);
    expect(offLabelOn(ana, tuesday, horario: h), 'Folga');
    expect(awayTagOn(ana, tuesday, horario: h), isNull);
    expect(offNoteOn(ana, tuesday, horario: h), 'Folga');
    expect(shiftSpanOn(ana, tuesday, horario: h), isNull);
  });

  test('scheduled férias read until their last day', () {
    final ana = _p('Ana', 'ana');
    final h = _index({
      'ana': ['', '', '', '', 'F', 'F', 'F', 'G82'],
    });
    expect(offLabelOn(ana, monday, horario: h), 'Férias até 6/1');
    expect(awayTagOn(ana, monday, horario: h), 'Férias');
    expect(offNoteOn(ana, monday, horario: h), 'até 6/1');
  });

  test("an ausência in the app beats the horário", () {
    final ana = _p('Ana', 'ana')
      ..ausencias = [
        Ausencia()
          ..tipo = AusenciaTipo.baixa
          ..start = monday
          ..end = monday,
      ];
    final h = _index({
      'ana': ['', '', '', '', 'G82'],
    });
    expect(offLabelOn(ana, monday, horario: h), startsWith(AusenciaTipo.baixa.label));
    expect(onShiftAt([ana], DateTime(2027, 1, 4, 10), horario: h), isEmpty);
  });

  test("a person's own hours don't replace a scheduled shift", () {
    final ana = _p('Ana', 'ana')
      ..shiftStart = 8 * 60
      ..shiftEnd = 12 * 60;
    final h = _index({
      'ana': ['', '', '', '', 'G82'],
    });
    expect(shiftSpanOn(ana, monday, horario: h)!.start, DateTime(2027, 1, 4, 6));
    expect(shiftSpanOn(ana, DateTime(2027, 1, 10), horario: h)!.start,
        DateTime(2027, 1, 10, 8));
  });

  test('a night shift is on at 03:00 the next morning', () {
    final rui = _p('Rui', 'rui');
    final h = _index({
      'rui': ['', '', '', '', 'W82'],
    });
    final on = onShiftAt([rui], DateTime(2027, 1, 5, 3), horario: h);
    expect(on.single.person, rui);
    expect(on.single.end, DateTime(2027, 1, 5, 7));
    expect(onShiftAt([rui], DateTime(2027, 1, 5, 3)), isEmpty);
    expect(shiftCountsOn([rui], monday, horario: h), (dia: 0, noite: 1));
  });

  test('people sections put those off on the horário last', () {
    final ana = _p('Ana', 'ana');
    final bia = _p('Bia', 'bia');
    final h = _index({
      'ana': ['', '', '', '', 'FO'],
      'bia': ['', '', '', '', 'G82'],
    });
    final s = buildPeopleSections([ana, bia], offDay: monday, horario: h);
    expect(s.expand((x) => x.people).map((p) => p.fullName), ['Bia', 'Ana']);
  });
}
