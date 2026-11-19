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

  late Person ana;

  /// This month with Ana on G82 and Rui on W82 every day, and Bia off;
  /// with [columns], a file with only that many day columns.
  Future<void> seedMonth(WidgetTester tester, {int columns = 35}) async {
    ana = await addPerson(tester, 'Ana Lopes');
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

  testWidgets('a day is changed from the week and marked', (tester) async {
    await seedMonth(tester);
    await open(tester);
    await tapAndSettle(tester, find.text('Semana'));
    final today = currentServiceDay();
    final key = alteracaoKey(ana.syncUuid, today);
    await tapAndSettle(tester, find.byKey(ValueKey('cell-$key')));
    expect(find.textContaining('No ficheiro: G82'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const ValueKey('code-A')));
    expect(
      HorarioService.instance.index.dayOf(ana, today)!.offLabel,
      'Ausência',
    );
    expect(find.byKey(ValueKey('changed-$key')), findsOneWidget);
  });

  testWidgets('a changed day can be put back', (tester) async {
    await seedMonth(tester);
    final today = currentServiceDay();
    await dbCall(
      tester,
      () => HorarioService.instance.change(ana, today, 'FO', by: 'Gonçalo'),
    );
    await open(tester);
    await tapAndSettle(tester, find.text('Ana Lopes'));
    expect(find.textContaining('Alterado por Gonçalo'), findsOneWidget);
    await tapAndSettle(tester, find.text('Repor o do ficheiro'));
    expect(HorarioService.instance.index.dayOf(ana, today)!.code, 'G82');
  });

  testWidgets('a day is changed to hours only', (tester) async {
    await seedMonth(tester);
    await open(tester);
    await tapAndSettle(tester, find.text('Semana'));
    final today = currentServiceDay();
    final key = alteracaoKey(ana.syncUuid, today);
    await tapAndSettle(tester, find.byKey(ValueKey('cell-$key')));
    await tapAndSettle(tester, find.text('Só horas'));
    await tester.enterText(find.widgetWithText(TextField, 'Entrada'), '9:00');
    await tester.enterText(find.widgetWithText(TextField, 'Saída'), '18');
    await tapAndSettle(tester, find.text('Guardar'));
    final d = HorarioService.instance.index.dayOf(ana, today)!;
    expect((d.code, d.text), ('', '09:00–18:00'));
    expect(
      find.descendant(
        of: find.byKey(ValueKey('cell-$key')),
        matching: find.text('09–18'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(ValueKey('changed-$key')), findsOneWidget);
  });

  testWidgets('the profile hours show over the file', (tester) async {
    await seedMonth(tester);
    ana
      ..shiftStart = 540
      ..shiftEnd = 960;
    SyncMeta.stamp(ana);
    await dbCall(tester, () => PersonService.instance.save(ana));
    await open(tester);
    expect(find.text('09:00–16:00'), findsOneWidget);
    await tapAndSettle(tester, find.text('Ana Lopes'));
    expect(find.textContaining('Perfil: 09:00–16:00'), findsOneWidget);
    expect(find.textContaining('No ficheiro: G82'), findsOneWidget);
  });
}
