import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/horario.dart';
import 'package:livre_servico_app/models/horario_codigos.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/planning.dart';

Person _p(int id, String name, {List<int> folgas = const []}) => Person()
  ..id = id
  ..fullName = name
  ..team = 'livre_servico'
  ..createdAt = DateTime(2026)
  ..folgas = [...folgas];

/// A month line of [n] days: [first] codes, then H73.
String _line(int n, List<String> first) =>
    [...first, for (var i = first.length; i < n; i++) 'H73'].join(' ');

final _codigos = {
  'H73': {'entrada': '07:00', 'pausa': '12:00-13:00', 'saida': '16:00'},
  'W82': {'entrada': '22:00', 'pausa': '03:00-04:00', 'saida': '07:00'},
  'L3': {'entrada': '11:00', 'saida': '15:00'},
};

Horarios _parse(Map<String, dynamic> file, [Horarios? current]) =>
    mergeHorarios(
      current ?? Horarios.empty,
      parseHorariosFile(file, current: current ?? Horarios.empty),
    );

void main() {
  group('HorarioCodigo', () {
    test('reads times and pausa, and prints them', () {
      final c = HorarioCodigo.fromJson('H73', _codigos['H73']);
      expect(c.entrada, 7 * 60);
      expect(c.saida, 16 * 60);
      expect(c.pausa, (12 * 60, 13 * 60));
      expect(c.timesText, '07:00–16:00 (pausa 12:00–13:00)');
      expect(c.noturno, isFalse);
      expect(
        HorarioCodigo.fromJson('L3', _codigos['L3']).timesText,
        '11:00–15:00',
      );
    });

    test('night codes cross midnight', () {
      final w = HorarioCodigo.fromJson('W82', _codigos['W82']);
      expect(w.noturno, isTrue);
      final u1 = HorarioCodigo.fromJson('U1', {
        'entrada': '20:00',
        'saida': '24:00',
      });
      expect(u1.timesText, '20:00–24:00');
      expect(u1.noturno, isTrue);
    });

    test('a bad time names the code', () {
      expect(
        () => HorarioCodigo.fromJson('X1', {'entrada': '7h', 'saida': '16:00'}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('X1'),
          ),
        ),
      );
    });
  });

  test('the default codes table reads, W82 and W3 included', () {
    final codes = defaultHorarioCodigos();
    expect(codes, hasLength(87));
    expect(codes['W82']!.timesText, '22:00–07:00 (pausa 03:00–04:00)');
    expect(codes['W3']!.timesText, '22:00–02:00');
    expect(codes['S204']!.noturno, isTrue);
    expect(codes['J179']!.timesText, '09:30–18:30 (pausa 13:30–14:30)');
    expect(defaultHorarioAusencias.keys, ['FO', 'F', 'A', 'LP']);
  });

  group('parseHorariosFile', () {
    test('reads codes, ausências and a month', () {
      final h = _parse({
        'codigos': _codigos,
        'ausencias': {'FO': 'Folga', 'F': 'Férias'},
        'meses': {
          '2026-10': {
            'Ana Silva': _line(31, ['FO', 'w82']),
          },
        },
      });
      expect(h.codigos.keys, containsAll(['H73', 'W82', 'L3']));
      expect(h.ausencias['FO'], 'Folga');
      final row = h.meses['2026-10']!['Ana Silva']!;
      expect(row, hasLength(31));
      expect(row.take(3), ['FO', 'W82', 'H73']);
    });

    test('a line also works as a list', () {
      final h = _parse({
        'codigos': _codigos,
        'ausencias': {'FO': 'Folga'},
        'meses': {
          '2026-02': {
            'Ana': [for (var i = 0; i < 28; i++) 'FO'],
          },
        },
      });
      expect(h.meses['2026-02']!['Ana'], hasLength(28));
    });

    test('rejects a wrong number of days', () {
      expect(
        () => _parse({
          'codigos': _codigos,
          'meses': {
            '2026-10': {'Ana': _line(30, [])},
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('2026-10'), contains('Ana'), contains('31')),
          ),
        ),
      );
    });

    test('rejects an unknown code, naming the day', () {
      expect(
        () => _parse({
          'codigos': _codigos,
          'meses': {
            '2026-10': {
              'Ana': _line(31, ['H73', 'K47']),
            },
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('dia 2'), contains('K47')),
          ),
        ),
      );
    });

    test('rejects a badly written month', () {
      expect(
        () => _parse({
          'codigos': _codigos,
          'meses': {'Outubro': {}},
        }),
        throwsFormatException,
      );
    });

    test('checks against the saved codes when the file has none', () {
      final current = _parse({'codigos': _codigos});
      final h = _parse({
        'meses': {
          '2026-10': {
            'Ana': _line(31, ['L3']),
          },
        },
      }, current);
      expect(h.meses['2026-10']!['Ana']!.first, 'L3');
      expect(h.codigos, current.codigos);
    });
  });

  group('mergeHorarios', () {
    final base = _parse({
      'codigos': _codigos,
      'meses': {
        '2026-09': {'Ana': _line(30, [])},
        '2026-10': {'Ana': _line(31, [])},
      },
    });

    test('replaces only the months in the file', () {
      final h = _parse({
        'meses': {
          '2026-10': {
            'Rui': _line(31, ['L3']),
          },
          '2026-11': {'Ana': _line(30, [])},
        },
      }, base);
      expect(h.meses.keys.toSet(), {'2026-09', '2026-10', '2026-11'});
      expect(h.meses['2026-10']!.keys, ['Rui']);
      expect(h.meses['2026-09']!.keys, ['Ana']);
    });

    test('null deletes a month', () {
      final h = _parse({
        'meses': {'2026-09': null},
      }, base);
      expect(h.meses.keys, ['2026-10']);
    });

    test('toJson reads back the same', () {
      final again = _parse(base.toJson());
      expect(again.meses, base.meses);
      expect(again.codigos.keys, base.codigos.keys);
      expect((base.toJson()['meses'] as Map)['2026-10']['Ana'], _line(31, []));
    });
  });

  group('matching names to people', () {
    final people = [
      _p(1, 'Gonçalo Eduardo Canha'),
      _p(2, 'Maria Santos'),
      _p(3, 'Elvis Neves'),
      _p(4, 'Gonçalo Charro'),
    ];

    test('full name, ignoring accents and case', () {
      expect(personForRow('elvis neves', people)?.id, 3);
      expect(personForRow('Goncalo Charro', people)?.id, 4);
    });

    test('first and last name', () {
      expect(personForRow('Gonçalo Canha', people)?.id, 1);
    });

    test('a lone first name when only one person has it', () {
      expect(personForRow('Maria', people)?.id, 2);
      expect(personForRow('Gonçalo', people), isNull);
      expect(personForRow('Joel', people), isNull);
    });
  });

  group('HorarioIndex', () {
    final ana = _p(1, 'Ana Silva', folgas: [DateTime.monday]);
    final rui = _p(2, 'Rui Lopes', folgas: [DateTime.monday]);
    final h = _parse({
      'codigos': _codigos,
      'ausencias': {'FO': 'Folga', 'F': 'Férias', 'A': 'Ausência'},
      'meses': {
        // 2026-10-05 is a Monday.
        '2026-10': {
          'Ana Silva': _line(31, ['F', 'F', 'F', 'FO', 'W82', 'H73', 'F']),
          'Desconhecido': _line(31, []),
        },
        '2026-11': {'Ana Silva': _line(30, [])},
      },
    });
    final index = HorarioIndex(h, [ana, rui]);

    test('the code of a matched person on a day', () {
      expect(index.codeOn(ana, DateTime(2026, 10, 4)), 'FO');
      expect(index.codeOn(ana, DateTime(2026, 10, 5, 23)), 'W82');
      expect(index.codeOn(rui, DateTime(2026, 10, 5)), isNull);
      expect(index.codeOn(ana, DateTime(2026, 12, 1)), isNull);
    });

    test('names without a person', () {
      expect(index.unmatched('2026-10'), ['Desconhecido']);
    });

    test('a run of the same code ends on its last day', () {
      expect(index.runEnd(ana, DateTime(2026, 10, 1)), DateTime(2026, 10, 3));
      expect(index.runEnd(ana, DateTime(2026, 10, 7)), DateTime(2026, 10, 7));
    });

    test('a run continues into the next saved month', () {
      String days(int n, bool Function(int day) ferias) =>
          [for (var d = 1; d <= n; d++) ferias(d) ? 'F' : 'H73'].join(' ');
      final h2 = _parse({
        'codigos': _codigos,
        'ausencias': {'F': 'Férias'},
        'meses': {
          '2026-10': {'Ana Silva': days(31, (d) => d >= 30)},
          '2026-11': {'Ana Silva': days(30, (d) => d <= 2)},
        },
      });
      expect(
        HorarioIndex(h2, [ana]).runEnd(ana, DateTime(2026, 10, 30)),
        DateTime(2026, 11, 2),
      );
    });

    group('in planning', () {
      test('the horário decides folgas and férias over the fixed ones', () {
        // Monday the 5th: fixed folga, but the horário says W82.
        expect(offLabelOn(ana, DateTime(2026, 10, 5), horario: index), isNull);
        expect(offLabelOn(ana, DateTime(2026, 10, 4), horario: index), 'Folga');
        expect(
          offLabelOn(ana, DateTime(2026, 10, 1), horario: index),
          'Férias até 3/10',
        );
        expect(awayTagOn(ana, DateTime(2026, 10, 2), horario: index), 'Férias');
        expect(
          offNoteOn(ana, DateTime(2026, 10, 2), horario: index),
          'até 3/10',
        );
        expect(awayTagOn(ana, DateTime(2026, 10, 4), horario: index), isNull);
        expect(offNoteOn(ana, DateTime(2026, 10, 4), horario: index), 'Folga');
      });

      test('without a horário line the fixed folgas still count', () {
        expect(offLabelOn(rui, DateTime(2026, 10, 5), horario: index), 'Folga');
      });

      test('an ausência entered in the app wins', () {
        final baixa = _p(1, 'Ana Silva')
          ..ausencias = [
            Ausencia()
              ..tipo = AusenciaTipo.baixa
              ..start = DateTime(2026, 10, 5)
              ..end = DateTime(2026, 10, 9),
          ];
        expect(
          offLabelOn(baixa, DateTime(2026, 10, 6), horario: index),
          'Baixa até 9/10',
        );
      });

      test('the shift text of a working day', () {
        expect(horarioTextOn(ana, DateTime(2026, 10, 6), index), '07:00–16:00');
        expect(horarioTextOn(ana, DateTime(2026, 10, 4), index), isNull);
        expect(horarioTextOn(rui, DateTime(2026, 10, 6), index), isNull);
      });
    });
  });
}
