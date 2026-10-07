import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/planning.dart';

Ausencia _a(AusenciaTipo tipo, DateTime start, DateTime end) => Ausencia()
  ..tipo = tipo
  ..start = start
  ..end = end;

Person _p({List<int> folgas = const [], List<Ausencia> ausencias = const []}) =>
    Person()
      ..fullName = 'Ana'
      ..createdAt = DateTime(2026)
      ..folgas = [...folgas]
      ..ausencias = [...ausencias];

void main() {
  // 2026-10-05 is a Monday.
  final monday = DateTime(2026, 10, 5);

  group('ausenciaOn', () {
    final ferias = _a(
      AusenciaTipo.ferias,
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 14),
    );

    test('covers the first and last day, whatever the time', () {
      final p = _p(ausencias: [ferias]);
      expect(ausenciaOn(p, DateTime(2026, 10, 1, 8)), ferias);
      expect(ausenciaOn(p, DateTime(2026, 10, 14, 23, 59)), ferias);
      expect(ausenciaOn(p, DateTime(2026, 9, 30, 23)), isNull);
      expect(ausenciaOn(p, DateTime(2026, 10, 15)), isNull);
    });
  });

  group('offLabelOn', () {
    test('a folga on that weekday', () {
      final p = _p(folgas: [DateTime.monday, DateTime.thursday]);
      expect(offLabelOn(p, monday), 'Folga');
      expect(offLabelOn(p, monday.add(const Duration(days: 1))), isNull);
    });

    test('an ausência beats a folga and says when it ends', () {
      final p = _p(
        folgas: [DateTime.monday],
        ausencias: [
          _a(AusenciaTipo.baixa, DateTime(2026, 10, 2), DateTime(2026, 11, 3)),
        ],
      );
      expect(offLabelOn(p, monday), 'Baixa até 3/11');
    });

    test('working that day', () {
      expect(offLabelOn(_p(), monday), isNull);
    });
  });

  group('tenureText', () {
    final today = DateTime(2026, 10, 7);

    test('years and months', () {
      expect(tenureText(DateTime(2022, 3, 1), today), '4 anos e 7 meses');
    });

    test('singulars', () {
      expect(tenureText(DateTime(2025, 9, 7), today), '1 ano e 1 mês');
      expect(tenureText(DateTime(2025, 10, 7), today), '1 ano');
      expect(tenureText(DateTime(2026, 9, 1), today), '1 mês');
    });

    test('months only', () {
      expect(tenureText(DateTime(2026, 5, 7), today), '5 meses');
    });

    test('a month is not complete before its day', () {
      expect(tenureText(DateTime(2026, 9, 8), today), 'menos de 1 mês');
      expect(tenureText(DateTime(2025, 10, 8), today), '11 meses');
    });

    test('a future date', () {
      expect(tenureText(DateTime(2026, 12, 1), today), 'menos de 1 mês');
    });
  });

  group('text helpers', () {
    test('folgasText lists days in week order', () {
      expect(
        folgasText([DateTime.sunday, DateTime.monday, DateTime.thursday]),
        'Seg, Qui, Dom',
      );
    });

    test('timeText pads hours and minutes', () {
      expect(timeText(7 * 60), '07:00');
      expect(timeText(22 * 60 + 5), '22:05');
    });

    test('horarioText needs both ends', () {
      expect(
        horarioText(
          _p()
            ..shiftStart = 22 * 60
            ..shiftEnd = 6 * 60,
        ),
        '22:00–06:00',
      );
      expect(horarioText(_p()..shiftStart = 7 * 60), isNull);
    });

    test('ausenciaRangeText', () {
      String r(DateTime a, DateTime b) =>
          ausenciaRangeText(_a(AusenciaTipo.ferias, a, b));
      expect(r(DateTime(2026, 10, 5), DateTime(2026, 10, 5)), '5 out');
      expect(r(DateTime(2026, 10, 1), DateTime(2026, 10, 14)), '1–14 out');
      expect(r(DateTime(2026, 9, 28), DateTime(2026, 10, 3)), '28 set – 3 out');
      expect(
        r(DateTime(2026, 12, 28), DateTime(2027, 1, 3)),
        '28 dez 2026 – 3 jan 2027',
      );
    });
  });

  test('upcomingAusencias drops past ones and sorts by start', () {
    final past = _a(
      AusenciaTipo.ferias,
      DateTime(2026, 8, 1),
      DateTime(2026, 8, 15),
    );
    final later = _a(
      AusenciaTipo.formacao,
      DateTime(2026, 12, 1),
      DateTime(2026, 12, 2),
    );
    final now = _a(
      AusenciaTipo.baixa,
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 5),
    );
    expect(upcomingAusencias(_p(ausencias: [later, past, now]), monday), [
      now,
      later,
    ]);
  });
}
