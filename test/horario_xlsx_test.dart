import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/horario_xlsx.dart';

import 'helpers/xlsx_fixture.dart';

void main() {
  ParsedHorario parse({
    bool horarioFirst = false,
    bool inlineStrings = false,
    Object? a1 = 'Janeiro 2027',
  }) => parseHorarioXlsx(
    buildXlsx(
      plano: samplePlano(a1: a1),
      horario: sampleHorario(),
      horarioFirst: horarioFirst,
      inlineStrings: inlineStrings,
    ),
  );

  test('reads month and first day', () {
    final h = parse();
    expect(h.month, DateTime(2027, 1, 1));
    expect(h.firstDay, DateTime(2026, 12, 31));
    expect(h.days, 4);
  });

  test('reads people, groups and codes, stopping at Resumo', () {
    final h = parse();
    expect(h.linhas, hasLength(2));
    expect(h.linhas[0].nome, 'Ana Lopes');
    expect(h.linhas[0].grupo, 'Dia');
    expect(h.linhas[0].codigos, ['G82', 'FO', '0711', '']);
    expect(h.linhas[1].nome, 'Rui Sá');
    expect(h.linhas[1].grupo, 'Noite');
    expect(h.linhas[1].codigos, ['W82', '.FO', 'LIBR', 'XYZ']);
  });

  test('reads entrada and saida from text or day fractions', () {
    final h = parse();
    expect(h.codigos['G82'], (entrada: 360, saida: 900));
    expect(h.codigos['W82'], (entrada: 1320, saida: 420));
    expect(h.codigos['0711'], (entrada: 420, saida: 660));
    expect(h.codigos.containsKey('FO'), isFalse);
  });

  test('lists codes without hours, leaving out the ignored off codes', () {
    expect(parse().semHorario, {'XYZ'});
  });

  test('finds sheets by name, not position', () {
    final h = parse(horarioFirst: true);
    expect(h.linhas, hasLength(2));
    expect(h.codigos['G82'], (entrada: 360, saida: 900));
  });

  test('reads inline strings', () {
    final h = parse(inlineStrings: true);
    expect(h.linhas[1].codigos, ['W82', '.FO', 'LIBR', 'XYZ']);
    expect(h.codigos['G82'], (entrada: 360, saida: 900));
  });

  test('month from a date serial in A1', () {
    expect(parse(a1: 46388).month, DateTime(2027, 1, 1));
  });

  test('month from the date in row 2 when A1 is unreadable', () {
    expect(parse(a1: 'Horário LS').month, DateTime(2027, 1, 1));
  });

  test('rejects a file that is not an xlsx', () {
    expect(
      () => parseHorarioXlsx(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });

  test("rejects day headers that don't match the month", () {
    final bytes = buildXlsx(
      plano: samplePlano(firstHeader: 'Q\n30'),
      horario: sampleHorario(),
    );
    expect(() => parseHorarioXlsx(bytes), throwsFormatException);
  });

  test('normalizes codes', () {
    expect(normalizeHorarioCode(' g82 '), 'G82');
    expect(normalizeHorarioCode('711'), '0711');
    expect(normalizeHorarioCode('.fo'), '.FO');
  });
}
