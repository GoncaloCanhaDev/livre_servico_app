import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/horario.dart';
import 'package:livre_servico_app/models/horario_xlsx.dart';
import 'package:livre_servico_app/models/person.dart';

Person _p(String name, String uuid) => Person()
  ..fullName = name
  ..createdAt = DateTime(2026)
  ..syncUuid = uuid;

const _codigos = {
  'F82': (entrada: 300, saida: 840),
  'G82': (entrada: 360, saida: 900),
  'J74': (entrada: 540, saida: 1080),
  'M79': (entrada: 720, saida: 1260),
  'W82': (entrada: 1320, saida: 420),
  'A78': (entrada: 0, saida: 540),
};

/// A month whose first column is the day before [month], with one line for
/// person 'ana' holding [codes] from that first column on.
HorarioMes _month(DateTime month, List<String> codes, {String uuid = 'ana'}) =>
    HorarioMes()
      ..month = month
      ..firstDay = DateTime(month.year, month.month, 0)
      ..codigos = {
        for (final e in _codigos.entries)
          e.key: (entrada: e.value.entrada, saida: e.value.saida),
      }
      ..linhas = [
        HorarioLinha()
          ..nome = 'Ana Lopes'
          ..grupo = 'Dia'
          ..personId = uuid
          ..codigos = codes,
      ]
      ..importedAt = DateTime(2026, 12, 20)
      ..importedBy = 'Gonçalo';

void main() {
  final ana = _p('Ana Lopes', 'ana');
  final jan = DateTime(2027, 1);

  test('round-trips through JSON', () {
    final m = _month(jan, ['G82', 'FO', '', 'W82']);
    final back = HorarioMes.fromJson(m.toJson());
    expect(back.month, jan);
    expect(back.firstDay, DateTime(2026, 12, 31));
    expect(back.codigos['W82'], (entrada: 1320, saida: 420));
    expect(back.linhas.single.personId, 'ana');
    expect(back.linhas.single.grupo, 'Dia');
    expect(back.linhas.single.codigos, ['G82', 'FO', '', 'W82']);
    expect(back.importedBy, 'Gonçalo');
  });

  group('dayOf', () {
    // Columns: 31/12, 1/1, 2/1, 3/1, 4/1, 5/1, 6/1.
    final index = HorarioIndex([
      _month(jan, ['G82', 'FO', 'F', 'LIBR', '', 'W82', 'XYZ']),
    ]);

    test('a shift has its hours and text', () {
      final d = index.dayOf(ana, DateTime(2026, 12, 31, 14))!;
      expect(d.isShift, isTrue);
      expect(d.code, 'G82');
      expect(d.text, '06:00–15:00');
      expect(d.tipo, HorarioTipo.abertura);
    });

    test('off codes have a label', () {
      expect(index.dayOf(ana, DateTime(2027, 1, 1))!.offLabel, 'Folga');
      expect(index.dayOf(ana, DateTime(2027, 1, 1))!.tipo, HorarioTipo.folga);
      expect(index.dayOf(ana, DateTime(2027, 1, 2))!.offLabel, 'Férias');
      expect(
        index.dayOf(ana, DateTime(2027, 1, 2))!.tipo,
        HorarioTipo.ausente,
      );
      expect(index.dayOf(ana, DateTime(2027, 1, 3))!.offLabel, 'LIBR');
      expect(index.dayOf(ana, DateTime(2027, 1, 6))!.offLabel, 'XYZ');
      expect(index.dayOf(ana, DateTime(2027, 1, 3))!.isShift, isFalse);
    });

    test('an empty cell, another person or a day not covered is null', () {
      expect(index.dayOf(ana, DateTime(2027, 1, 4)), isNull);
      expect(index.dayOf(_p('Rui', 'rui'), DateTime(2027, 1, 1)), isNull);
      expect(index.dayOf(ana, DateTime(2027, 1, 20)), isNull);
    });

    test('a night shift ends the next morning', () {
      final span = index.dayOf(ana, DateTime(2027, 1, 5))!.spanOn();
      expect(span.start, DateTime(2027, 1, 5, 22));
      expect(span.end, DateTime(2027, 1, 6, 7));
    });
  });

  test('tipo from the entrada', () {
    HorarioTipo tipo(String code) =>
        HorarioIndex([_month(jan, [code])]).dayOf(ana, DateTime(2026, 12, 31))!.tipo;
    expect(tipo('F82'), HorarioTipo.abertura);
    expect(tipo('J74'), HorarioTipo.intermedio);
    expect(tipo('M79'), HorarioTipo.fecho);
    expect(tipo('W82'), HorarioTipo.noite);
    expect(tipo('A78'), HorarioTipo.noite);
  });

  group('a day in two months', () {
    // January's last column is 1 February (FO); February's own is G82.
    final janCodes = List.filled(33, 'J74')..[32] = 'FO';
    final january = _month(jan, janCodes);
    final february = _month(DateTime(2027, 2), ['F82', 'G82']);

    test("the month the day belongs to wins, whatever the order", () {
      for (final months in [
        [january, february],
        [february, january],
      ]) {
        expect(HorarioIndex(months).dayOf(ana, DateTime(2027, 2, 1))!.code, 'G82');
        expect(HorarioIndex(months).dayOf(ana, DateTime(2027, 1, 31))!.code, 'J74');
      }
    });

    test('a spill day is used when its own month is missing', () {
      expect(HorarioIndex([january]).dayOf(ana, DateTime(2027, 2, 1))!.code, 'FO');
    });
  });

  test('lastDayOfSameCode ends the run of one code', () {
    final index = HorarioIndex([
      _month(jan, ['G82', 'F', 'F', 'F', 'G82']),
    ]);
    expect(index.lastDayOfSameCode(ana, DateTime(2027, 1, 1)), DateTime(2027, 1, 3));
    expect(index.lastDayOfSameCode(ana, DateTime(2027, 1, 3)), DateTime(2027, 1, 3));
  });

  test('nextDays lists the covered days from a date', () {
    final index = HorarioIndex([
      _month(jan, ['G82', 'FO', '', 'W82']),
    ]);
    final days = index.nextDays(ana, DateTime(2026, 12, 31, 10), 7);
    expect(days.map((d) => d.code), ['G82', 'FO', 'W82']);
  });

  test('linesOn gives each line with its day', () {
    final index = HorarioIndex([
      _month(jan, ['G82', 'FO']),
    ]);
    final lines = index.linesOn(DateTime(2027, 1, 1));
    expect(lines.single.linha.nome, 'Ana Lopes');
    expect(lines.single.dia!.offLabel, 'Folga');
    expect(index.linesOn(DateTime(2027, 3, 1)), isEmpty);
  });

  test('monthKey', () {
    expect(monthKey(DateTime(2027, 1, 15)), '2027-01');
  });

  group('matchHorarioNames', () {
    final americo = _p('Américo Pinto David', 'a1');
    final rui = _p('Rui Sá', 'r1');

    test('exact name, ignoring case, accents and spaces', () {
      final m = matchHorarioNames(['rui  sa'], [americo, rui]);
      expect(m['rui  sa'], rui);
    });

    test('first and last name', () {
      expect(matchHorarioNames(['Américo David'], [americo, rui])['Américo David'], americo);
    });

    test('an exact match beats first and last', () {
      final short = _p('Ana Lopes', 'x1');
      final long = _p('Ana Maria Lopes', 'x2');
      expect(matchHorarioNames(['Ana Lopes'], [long, short])['Ana Lopes'], short);
    });

    test('two possible people: no match', () {
      final m = matchHorarioNames(['Ana Lopes'], [
        _p('Ana Rita Lopes', 'x1'),
        _p('Ana Sofia Lopes', 'x2'),
      ]);
      expect(m['Ana Lopes'], isNull);
      expect(m.containsKey('Ana Lopes'), isTrue);
    });

    test("a previous month's choice is remembered", () {
      final previous = _month(jan, ['G82'], uuid: 'r1')
        ..linhas.single.nome = 'Zé';
      expect(matchHorarioNames(['Zé'], [americo, rui], previous: [previous])['Zé'], rui);
    });

    test('a previous choice of someone no longer here is dropped', () {
      final previous = _month(jan, ['G82'], uuid: 'gone')
        ..linhas.single.nome = 'Rui Sá';
      expect(matchHorarioNames(['Rui Sá'], [americo, rui], previous: [previous])['Rui Sá'], rui);
    });

    test('never the same person for two names', () {
      final m = matchHorarioNames(['Rui Sá', 'rui sa'], [rui]);
      expect(m['Rui Sá'], rui);
      expect(m['rui sa'], isNull);
    });
  });

  group('changes', () {
    HorarioAlteracao change(String code, DateTime date, {int? e, int? s}) =>
        HorarioAlteracao()
          ..date = date
          ..personId = 'ana'
          ..code = code
          ..entrada = e
          ..saida = s
          ..fileCode = 'G82'
          ..changedBy = 'Gonçalo'
          ..changedAt = DateTime(2027, 1, 1, 9);

    final month = _month(jan, ['G82', 'G82', 'G82']);

    test('a change wins over the file and is marked', () {
      final index = HorarioIndex([month], changes: [change('FO', DateTime(2027, 1, 1))]);
      final d = index.dayOf(ana, DateTime(2027, 1, 1, 15))!;
      expect(d.offLabel, 'Folga');
      expect(d.changed!.changedBy, 'Gonçalo');
      expect(index.fileDayOf(ana, DateTime(2027, 1, 1))!.code, 'G82');
      expect(index.dayOf(ana, DateTime(2027, 1, 2))!.changed, isNull);
    });

    test('a change to a shift carries its hours', () {
      final index = HorarioIndex([month],
          changes: [change('X99', DateTime(2027, 1, 1), e: 600, s: 1080)]);
      expect(index.dayOf(ana, DateTime(2027, 1, 1))!.text, '10:00–18:00');
    });

    test('an empty change means nothing that day', () {
      final index = HorarioIndex([month], changes: [change('', DateTime(2027, 1, 1))]);
      expect(index.dayOf(ana, DateTime(2027, 1, 1)), isNull);
    });

    test('a change on a day no month covers', () {
      final index = HorarioIndex([month],
          changes: [change('G82', DateTime(2027, 3, 3), e: 360, s: 900)]);
      expect(index.dayOf(ana, DateTime(2027, 3, 3))!.code, 'G82');
      expect(index.nextDays(ana, DateTime(2027, 3, 3), 1), hasLength(1));
    });

    test('linesOn shows the change', () {
      final index = HorarioIndex([month], changes: [change('A', DateTime(2027, 1, 1))]);
      expect(index.linesOn(DateTime(2027, 1, 1)).single.dia!.offLabel, 'Ausência');
    });

    test('changesIn and codeUsage', () {
      final index = HorarioIndex([month], changes: [change('A', DateTime(2027, 1, 1))]);
      expect(index.changesIn(jan), hasLength(1));
      expect(index.changesIn(DateTime(2027, 2)), isEmpty);
      expect(index.codeUsage(jan)['G82'], 3);
    });

    test('round-trips through JSON', () {
      final c = change('X99', DateTime(2027, 1, 1), e: 600, s: 1080);
      final back = HorarioAlteracao.fromJson(c.toJson());
      expect((back.code, back.entrada, back.saida, back.fileCode, back.personId),
          ('X99', 600, 1080, 'G82', 'ana'));
      expect(back.date, DateTime(2027, 1, 1));
      expect(alteracaoKey('ana', DateTime(2027, 1, 12, 8)), 'ana/2027-01-12');
    });

    test('changesAgainstFile lists only changes the new file disagrees with', () {
      final parsed = ParsedHorario(
        month: jan,
        firstDay: DateTime(2026, 12, 31),
        days: 3,
        codigos: const {'G82': (entrada: 360, saida: 900)},
        linhas: [ParsedLinha(nome: 'Ana Lopes', grupo: 'Dia', codigos: ['G82', 'FO', 'G82'])],
        semHorario: const {},
      );
      final found = changesAgainstFile(parsed, {'Ana Lopes': 'ana'}, [
        change('A', DateTime(2026, 12, 31)), // file G82: differs
        change('FO', DateTime(2027, 1, 1)), // file FO: equal
        change('A', DateTime(2027, 2, 10)), // outside the file
      ]);
      expect(found.single.change.date, DateTime(2026, 12, 31));
      expect(found.single.newFileCode, 'G82');
    });
  });
}
