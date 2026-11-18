import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/opening_list.dart';
import 'package:livre_servico_app/models/horario.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/horario_import_screen.dart';
import 'package:livre_servico_app/screens/horarios_screen.dart';
import 'package:livre_servico_app/services/horario_service.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/person_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:livre_servico_app/theme.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<Person> addPerson(WidgetTester tester, String name) async {
    final p = Person()
      ..fullName = name
      ..collaboratorNumber = ''
      ..createdAt = DateTime(2026, 1, 1);
    SyncMeta.stamp(p);
    await dbCall(tester, () => PersonService.instance.save(p));
    return p;
  }

  /// This month with Ana on G82 and Rui on W82 every day, and Bia off;
  /// with [columns], a file with only that many day columns.
  Future<void> seedMonth(WidgetTester tester, {int columns = 35}) async {
    final ana = await addPerson(tester, 'Ana Lopes');
    final rui = await addPerson(tester, 'Rui Sá');
    final bia = await addPerson(tester, 'Bia Reis');
    final today = currentServiceDay();
    final month = DateTime(today.year, today.month);
    HorarioLinha line(Person p, String grupo, String code) => HorarioLinha()
      ..nome = p.fullName
      ..grupo = grupo
      ..personId = p.syncUuid
      ..codigos = List.filled(columns, code);
    final m = HorarioMes()
      ..month = month
      ..firstDay = DateTime(month.year, month.month, 0)
      ..codigos = {
        'G82': (entrada: 360, saida: 900),
        'W82': (entrada: 1320, saida: 420),
      }
      ..linhas = [
        line(ana, 'Dia', 'G82'),
        line(bia, 'Dia', 'FO'),
        line(rui, 'Noite', 'W82'),
      ]
      ..importedAt = DateTime.now()
      ..importedBy = 'Teste';
    SyncMeta.stamp(m);
    await dbCall(tester, () => LocalDb.instance.horarioMeses.put(m));
    await dbCall(tester, HorarioService.instance.load);
  }

  Future<void> open(WidgetTester tester) => pumpApp(
    tester,
    MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: const HorariosScreen(),
    ),
  );

  testWidgets('Dia lists who works by group and who is off', (tester) async {
    await seedMonth(tester);
    await open(tester);
    expect(find.text('Ana Lopes'), findsOneWidget);
    expect(find.text('06:00–15:00'), findsOneWidget);
    expect(find.text('Noite'), findsWidgets);
    expect(find.text('22:00–07:00'), findsOneWidget);
    expect(find.text('Fora'), findsOneWidget);
    expect(find.text('Folga'), findsOneWidget);
  });

  testWidgets('Semana shows the seven days', (tester) async {
    await seedMonth(tester);
    await open(tester);
    await tapAndSettle(tester, find.text('Semana'));
    for (final d in ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']) {
      expect(find.textContaining(d), findsWidgets);
    }
    expect(find.text('06–15'), findsWidgets);
  });

  testWidgets('Mês shows the month', (tester) async {
    await seedMonth(tester);
    await open(tester);
    await tapAndSettle(tester, find.text('Mês'));
    expect(find.text(monthTitle(currentServiceDay())), findsOneWidget);
    expect(find.text('22–07'), findsWidgets);
  });

  testWidgets('Mês copes with a file shorter than the month', (tester) async {
    await seedMonth(tester, columns: 5);
    await open(tester);
    await tapAndSettle(tester, find.text('Mês'));
    expect(tester.takeException(), isNull);
    expect(find.text(monthTitle(currentServiceDay())), findsOneWidget);
  });

  testWidgets('without a horário: says so and offers the import', (
    tester,
  ) async {
    await open(tester);
    expect(find.textContaining('Ainda não há horário'), findsOneWidget);
    expect(find.text('Importar horário'), findsOneWidget);
  });
}
