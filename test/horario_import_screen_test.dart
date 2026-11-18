import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/horario_xlsx.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/horario_import_screen.dart';
import 'package:livre_servico_app/services/horario_service.dart';
import 'package:livre_servico_app/services/person_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:livre_servico_app/theme.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';
import 'helpers/xlsx_fixture.dart';

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

  final parsed = parseHorarioXlsx(
    buildXlsx(plano: samplePlano(), horario: sampleHorario()),
  );

  testWidgets('shows matches and saves the month', (tester) async {
    final ana = await addPerson(tester, 'Ana Lopes');
    await addPerson(tester, 'Bruno Costa');
    await pumpApp(
      tester,
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: HorarioImportScreen(parsed: parsed),
      ),
    );

    expect(find.textContaining('janeiro de 2027'), findsOneWidget);
    expect(find.text('Rui Sá'), findsOneWidget);
    expect(find.text('Sem correspondência'), findsOneWidget);
    expect(find.textContaining('XYZ'), findsOneWidget);

    await tapAndSettle(tester, find.text('Importar'));

    final months = await dbCall(tester, HorarioService.instance.months);
    final m = months.single;
    expect(m.linhas[0].personId, ana.syncUuid);
    expect(m.linhas[1].personId, isNull);
  });

  testWidgets('an unmatched line can be given a person', (tester) async {
    await addPerson(tester, 'Ana Lopes');
    final bruno = await addPerson(tester, 'Bruno Costa');
    await pumpApp(
      tester,
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: HorarioImportScreen(parsed: parsed),
      ),
    );

    await tapAndSettle(tester, find.text('Sem correspondência'));
    await tapAndSettle(tester, find.text('Bruno Costa').last);
    expect(find.text('Sem correspondência'), findsNothing);

    await tapAndSettle(tester, find.text('Importar'));
    final m = (await dbCall(tester, HorarioService.instance.months)).single;
    expect(m.linhas[1].personId, bruno.syncUuid);
  });
}
