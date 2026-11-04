import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/not_done.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/teams.dart';
import 'package:livre_servico_app/models/today.dart';

Person _p(int id, String name) => Person()
  ..id = id
  ..fullName = name
  ..team = 'livre_servico'
  ..createdAt = DateTime(2026);

/// [p] with their own shift, [start] and [end] in "07:00" form.
Person _shift(Person p, String start, String end) {
  int m(String t) =>
      int.parse(t.split(':')[0]) * 60 + int.parse(t.split(':')[1]);
  return p
    ..shiftStart = m(start)
    ..shiftEnd = m(end);
}

List<String> _pending(DailyTasks? t, DateTime now, {bool visivel = true}) =>
    pendingDailyTasks(t, visivelDone: visivel, now: now);

void main() {
  group('shiftSpanOn', () {
    test('a day shift runs on its own date', () {
      final p = _shift(_p(1, 'Ana'), '07:00', '16:00');
      final span = shiftSpanOn(p, DateTime(2026, 10, 1))!;
      expect(span.start, DateTime(2026, 10, 1, 7));
      expect(span.end, DateTime(2026, 10, 1, 16));
    });

    test('a night shift ends the next morning', () {
      final p = _shift(_p(1, 'Ana'), '22:00', '07:00');
      final span = shiftSpanOn(p, DateTime(2026, 10, 1))!;
      expect(span.start, DateTime(2026, 10, 1, 22));
      expect(span.end, DateTime(2026, 10, 2, 7));
    });

    test('needs both ends', () {
      expect(
        shiftSpanOn(_p(1, 'Ana')..shiftStart = 420, DateTime(2026)),
        isNull,
      );
    });
  });

  group('onShiftAt', () {
    // Thursday 1 October 2026.
    final ana = _shift(_p(1, 'Ana'), '07:00', '16:00');
    final rui = _shift(_p(2, 'Rui'), '22:00', '07:00');
    final bea = _shift(_p(3, 'Bea'), '06:00', '14:00');
    final noShift = _p(4, 'Zé');

    test('lists who is inside their shift, earliest start first', () {
      final at = onShiftAt([ana, rui, bea, noShift], DateTime(2026, 10, 1, 10));
      expect(at.map((s) => s.person.fullName), ['Bea', 'Ana']);
    });

    test('includes a night shift that started the day before', () {
      final at = onShiftAt([ana, rui, bea], DateTime(2026, 10, 1, 6, 30));
      expect(at.map((s) => s.person.fullName), ['Rui', 'Bea']);
    });

    test('the end of a shift is outside it', () {
      expect(onShiftAt([ana], DateTime(2026, 10, 1, 16)), isEmpty);
    });

    test('nobody on a folga or an ausência', () {
      final folga = _shift(_p(5, 'Eva'), '07:00', '16:00')..folgas = [4];
      final away = _shift(_p(6, 'Ivo'), '07:00', '16:00')
        ..ausencias = [
          Ausencia()
            ..tipo = AusenciaTipo.ferias
            ..start = DateTime(2026, 9, 28)
            ..end = DateTime(2026, 10, 2),
        ];
      expect(onShiftAt([folga, away], DateTime(2026, 10, 1, 10)), isEmpty);
    });
  });

  group('shiftCountsOn', () {
    test('counts day and night shifts, not folgas', () {
      final counts = shiftCountsOn([
        _shift(_p(1, 'Ana'), '07:00', '16:00'),
        _shift(_p(2, 'Rui'), '22:00', '07:00'),
        _shift(_p(3, 'Bea'), '20:00', '24:00'),
        _shift(_p(4, 'Eva'), '07:00', '16:00')..folgas = [4],
        _p(5, 'Zé'),
      ], DateTime(2026, 10, 1));
      expect(counts, (dia: 1, noite: 2));
    });
  });

  group('pendingDailyTasks', () {
    test('a task marked Não feita is not pending', () {
      final t = DailyTasks()
        ..serviceDay = DateTime(2026, 10, 8, 5)
        ..notDone = {
          'kiwi_abertura': NotDone(byNames: ['Ana'], reason: 'Sem sistema'),
          'verificacao_validades': NotDone(byNames: ['Ana'], reason: 'x'),
        };
      final pending = _pending(t, DateTime(2026, 10, 8, 9));
      expect(pending, isNot(contains('Kiwi Abertura')));
      expect(pending, isNot(contains('Validades · Manhã')));
      expect(pending, contains('Kiwi Fecho'));
    });

    test('without a row everything open is to do', () {
      expect(_pending(null, DateTime(2026, 10, 8, 9), visivel: false), [
        'Kiwi Abertura',
        'Alterações de Preço',
        'Verificação de Temperaturas',
        'Preenchimento do Quadro',
        'Lista Visível',
        'Validades · Manhã',
        'Kiwi Fecho',
      ]);
    });

    test('leaves out what is done and validades windows not open', () {
      final t = DailyTasks()
        ..serviceDay = DateTime(2026, 10, 8, 5)
        ..kiwiAbertura = true
        ..alteracoesPreco = true
        ..verificacaoTemperaturas = true
        ..preenchimentoQuadro = true
        ..kiwiFecho = true;
      expect(_pending(t, DateTime(2026, 10, 8, 15)), isEmpty);
      expect(_pending(t, DateTime(2026, 10, 9, 2)), ['Validades · Noite']);
      t.validadesNoite = true;
      expect(_pending(t, DateTime(2026, 10, 9, 2)), isEmpty);
    });
  });

  group('shortName', () {
    test('first and last name', () {
      expect(shortName('Ana Maria  Silva '), 'Ana Silva');
      expect(shortName('Rui'), 'Rui');
    });
  });

  group('turnoAt', () {
    test('Noite from 19:00 to 05:00, Dia otherwise', () {
      expect(turnoAt(DateTime(2026, 10, 8, 18, 59)), Turno.dia);
      expect(turnoAt(DateTime(2026, 10, 8, 19)), Turno.noite);
      expect(turnoAt(DateTime(2026, 10, 9, 4, 59)), Turno.noite);
      expect(turnoAt(DateTime(2026, 10, 9, 5)), Turno.dia);
    });
  });
}
