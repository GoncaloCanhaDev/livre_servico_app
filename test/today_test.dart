import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/horario.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/today.dart';

Person _p(int id, String name) => Person()
  ..id = id
  ..fullName = name
  ..team = 'livre_servico'
  ..createdAt = DateTime(2026);

final _codigos = {
  'H73': HorarioCodigo.fromJson('H73', {
    'entrada': '07:00',
    'pausa': '12:00-13:00',
    'saida': '16:00',
  }),
  'W82': HorarioCodigo.fromJson('W82', {
    'entrada': '22:00',
    'pausa': '03:00-04:00',
    'saida': '07:00',
  }),
  'U1': HorarioCodigo.fromJson('U1', {'entrada': '20:00', 'saida': '24:00'}),
};

/// October 2026 with [rows] (name → codes for days 1, 2, …; FO after).
HorarioIndex _index(List<Person> people, Map<String, List<String>> rows) =>
    HorarioIndex(
      Horarios(
        codigos: _codigos,
        ausencias: const {'FO': 'Folga', 'F': 'Férias'},
        meses: {
          '2026-10': {
            for (final r in rows.entries)
              r.key: [
                ...r.value,
                for (var i = r.value.length; i < 31; i++) 'FO',
              ],
          },
        },
      ),
      people,
    );

List<String> _pending(
  DailyTasks? t,
  DateTime now, {
  bool abertura = false,
  bool relatorio = false,
  bool visual = false,
  bool auto = false,
}) => pendingDailyTasks(
  t,
  aberturaDone: abertura,
  relatorioDone: relatorio,
  visualDone: visual,
  autoDone: auto,
  now: now,
);

void main() {
  group('HorarioCodigo.spanOn', () {
    test('a day shift runs on its own date', () {
      final s = _codigos['H73']!.spanOn(DateTime(2026, 10, 8));
      expect(s.start, DateTime(2026, 10, 8, 7));
      expect(s.end, DateTime(2026, 10, 8, 16));
    });

    test('a night shift ends the next morning', () {
      final s = _codigos['W82']!.spanOn(DateTime(2026, 10, 31));
      expect(s.start, DateTime(2026, 10, 31, 22));
      expect(s.end, DateTime(2026, 11, 1, 7));
    });

    test('24:00 is the next midnight', () {
      final s = _codigos['U1']!.spanOn(DateTime(2026, 10, 8));
      expect(s.end, DateTime(2026, 10, 9));
    });
  });

  group('onShiftAt', () {
    final ana = _p(1, 'Ana Silva');
    final rui = _p(2, 'Rui Costa');
    final eva = _p(3, 'Eva Lopes');
    final idx = _index(
      [ana, rui, eva],
      {
        'Ana Silva': ['H73', 'H73'],
        'Rui Costa': ['W82', 'FO'],
        'Eva Lopes': ['F', 'W82'],
      },
    );

    test('lists who is inside their shift, earliest start first', () {
      expect(
        onShiftAt(idx, [
          ana,
          rui,
          eva,
        ], DateTime(2026, 10, 1, 10)).map((s) => s.person.fullName),
        ['Ana Silva'],
      );
      expect(
        onShiftAt(idx, [
          ana,
          rui,
          eva,
        ], DateTime(2026, 10, 2, 23)).map((s) => s.person.fullName),
        ['Eva Lopes'],
      );
    });

    test("includes a night shift that started the day before", () {
      final now = DateTime(2026, 10, 2, 6, 30);
      expect(onShiftAt(idx, [ana, rui, eva], now).map((s) => s.person.id), [
        rui.id,
      ]);
    });

    test('the end of a shift is outside it', () {
      expect(onShiftAt(idx, [ana], DateTime(2026, 10, 1, 16)), isEmpty);
      expect(onShiftAt(idx, [ana], DateTime(2026, 10, 1, 7)), hasLength(1));
    });

    test('an ausência entered in the app wins', () {
      final away = _p(1, 'Ana Silva')
        ..ausencias = [
          Ausencia()
            ..tipo = AusenciaTipo.baixa
            ..start = DateTime(2026, 10, 1)
            ..end = DateTime(2026, 10, 5),
        ];
      expect(onShiftAt(idx, [away], DateTime(2026, 10, 1, 10)), isEmpty);
    });
  });

  group('shiftCountsOn', () {
    test('counts day and night shifts, not absences', () {
      final people = [_p(1, 'Ana'), _p(2, 'Rui'), _p(3, 'Eva'), _p(4, 'Ivo')];
      final idx = _index(people, {
        'Ana': ['H73'],
        'Rui': ['W82'],
        'Eva': ['F'],
        'Ivo': ['U1'],
      });
      expect(shiftCountsOn(idx, people, DateTime(2026, 10, 1, 5)), (
        dia: 1,
        noite: 2,
      ));
      expect(shiftCountsOn(idx, people, DateTime(2026, 10, 2)), (
        dia: 0,
        noite: 0,
      ));
    });
  });

  group('pendingDailyTasks', () {
    test('without a row everything open is to do', () {
      expect(_pending(null, DateTime(2026, 10, 8, 9)), [
        'Kiwi Abertura',
        'Alterações de Preço',
        'Verificação de Temperaturas',
        'Lista de Abertura',
        'Relatório das Listas',
        'Preenchimento do Quadro',
        'Lista Visual',
        'Lista Automática',
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
      expect(
        _pending(t, DateTime(2026, 10, 8, 15), abertura: true, visual: true),
        ['Relatório das Listas', 'Lista Automática'],
      );
      expect(
        _pending(
          t,
          DateTime(2026, 10, 9, 2),
          abertura: true,
          relatorio: true,
          visual: true,
          auto: true,
        ),
        ['Validades · Noite'],
      );
      t.validadesNoite = true;
      expect(
        _pending(
          t,
          DateTime(2026, 10, 9, 2),
          abertura: true,
          relatorio: true,
          visual: true,
          auto: true,
        ),
        isEmpty,
      );
    });
  });

  group('shortName', () {
    test('first and last name', () {
      expect(shortName('Ana Maria  Silva '), 'Ana Silva');
      expect(shortName('Rui'), 'Rui');
    });
  });
}
