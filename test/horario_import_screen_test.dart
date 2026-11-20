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

  testWidgets('a re-import asks about each change made in the app', (
    tester,
  ) async {
    final ana = await addPerson(tester, 'Ana Lopes');
    final service = HorarioService.instance;
    await dbCall(
      tester,
      () => service.save(parsed, {'Ana Lopes': ana}, importedBy: 'A'),
    );
    await dbCall(
      tester,
      () => service.change(ana, DateTime(2026, 12, 31), 'A', by: 'Gonçalo'),
    );
    await dbCall(
      tester,
      () => service.change(ana, DateTime(2027, 1, 1), 'G82', by: 'Gonçalo'),
    );
    await pumpApp(
      tester,
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: HorarioImportScreen(parsed: parsed),
      ),
    );

    expect(find.text('Alterações feitas na app'), findsOneWidget);
    final first = find.textContaining('Ficheiro G82 → app A');
    await scrollTo(tester, find.textContaining('Ficheiro FO → app G82'));
    // Let the file have 31/12 back; keep 1/1.
    await scrollTo(tester, first);
    await tapAndSettle(
      tester,
      find.ancestor(of: first, matching: find.byType(SwitchListTile)),
    );
    await scrollTo(tester, find.text('Importar'));
    await tapAndSettle(tester, find.text('Importar'));
    await tapAndSettle(tester, find.text('Substituir'));

    expect(service.index.dayOf(ana, DateTime(2026, 12, 31))!.code, 'G82');
    expect(service.index.dayOf(ana, DateTime(2027, 1, 1))!.code, 'G82');
    expect(service.index.dayOf(ana, DateTime(2027, 1, 1))!.changed, isNotNull);
  });
}
