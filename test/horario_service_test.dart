import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/horario.dart';
import 'package:livre_servico_app/models/horario_xlsx.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/services/horario_service.dart';
import 'package:livre_servico_app/services/local_db.dart';

import 'helpers/app_db.dart';
import 'helpers/xlsx_fixture.dart';

Person _p(String name, String uuid) => Person()
  ..fullName = name
  ..syncUuid = uuid
  ..createdAt = DateTime(2026);

void main() {
  setUp(() async {
    await openAppDb();
    await HorarioService.instance.load();
  });
  tearDown(closeAppDb);

  final service = HorarioService.instance;
  final ana = _p('Ana Lopes', 'ana');
  ParsedHorario parsed() => parseHorarioXlsx(
    buildXlsx(plano: samplePlano(), horario: sampleHorario()),
  );

  test('save makes the month readable through the index', () async {
    await service.save(parsed(), {'Ana Lopes': ana, 'Rui Sá': null},
        importedBy: 'Gonçalo');
    expect(service.index.dayOf(ana, DateTime(2026, 12, 31))!.code, 'G82');
    final m = (await service.months()).single;
    expect(m.importedBy, 'Gonçalo');
    expect(m.linhas[1].personId, isNull);
  });

  test('saving the same month again keeps one row', () async {
    await service.save(parsed(), {'Ana Lopes': ana}, importedBy: 'A');
    await service.save(parsed(), {'Ana Lopes': null}, importedBy: 'B');
    final months = await service.months();
    expect(months, hasLength(1));
    expect(months.single.importedBy, 'B');
    expect(service.index.dayOf(ana, DateTime(2026, 12, 31)), isNull);
  });

  test('delete removes the month', () async {
    await service.save(parsed(), {'Ana Lopes': ana}, importedBy: 'A');
    await service.delete(DateTime(2027, 1));
    expect(await service.months(), isEmpty);
    expect(service.index.hasMonth(DateTime(2027, 1)), isFalse);
  });

  test('a month from the server updates the index', () async {
    final m = HorarioMes.fromParsed(parsed(), {'Ana Lopes': 'ana'},
        importedBy: 'X')
      ..syncUuid = 'srv'
      ..syncUpdatedAt = DateTime.now();
    final c = LocalDb.instance.horarioMeses;
    await c.applyRemote([
      (key: '2027-01', data: c.syncData(m), updatedAt: m.syncUpdatedAt),
    ]);
    LocalDb.notifyRemoteChanges({'HorarioMes'});
    await pumpEventQueue();
    expect(service.index.dayOf(ana, DateTime(2027, 1, 1))!.offLabel, 'Folga');
  });

  group('changes', () {
    final rui = _p('Rui Sá', 'rui');
    final dec31 = DateTime(2026, 12, 31);
    Future<void> imported() => service.save(
      parsed(),
      {'Ana Lopes': ana, 'Rui Sá': rui},
      importedBy: 'A',
    );

    test('change wins, a change back to the file removes it', () async {
      await imported();
      await service.change(ana, dec31, 'A', by: 'Gonçalo');
      final d = service.index.dayOf(ana, dec31)!;
      expect((d.offLabel, d.changed!.fileCode, d.changed!.changedBy),
          ('Ausência', 'G82', 'Gonçalo'));
      await service.change(ana, dec31, 'G82', by: 'Gonçalo');
      expect(service.index.dayOf(ana, dec31)!.changed, isNull);
      expect(await LocalDb.instance.horarioAlteracoes.all(), isEmpty);
    });

    test('a known code takes its hours from the month, a new one keeps its own',
        () async {
      await imported();
      await service.change(ana, DateTime(2027, 1, 1), 'w82', by: 'G');
      expect(service.index.dayOf(ana, DateTime(2027, 1, 1))!.text, '22:00–07:00');
      await service.change(ana, DateTime(2027, 1, 2), 'X10',
          entrada: 600, saida: 1080, by: 'G');
      expect(service.index.dayOf(ana, DateTime(2027, 1, 2))!.text, '10:00–18:00');
    });

    test('swap exchanges two days, an empty side included', () async {
      await imported();
      // 3 January: Ana has nothing, Rui has XYZ.
      final jan3 = DateTime(2027, 1, 3);
      await service.swap(ana, rui, dec31, by: 'G');
      expect(service.index.dayOf(ana, dec31)!.code, 'W82');
      expect(service.index.dayOf(rui, dec31)!.code, 'G82');
      await service.swap(ana, rui, jan3, by: 'G');
      expect(service.index.dayOf(ana, jan3)!.code, 'XYZ');
      expect(service.index.dayOf(rui, jan3), isNull);
    });

    test('revert goes back to the file', () async {
      await imported();
      await service.change(ana, dec31, 'FO', by: 'G');
      await service.revert(ana, dec31);
      expect(service.index.dayOf(ana, dec31)!.code, 'G82');
    });

    test('re-import: dropped and caught-up changes go, the rest stay', () async {
      await imported();
      await service.change(ana, dec31, 'A', by: 'G'); // kept
      await service.change(rui, dec31, 'FO', by: 'G'); // dropped
      // The file still says FO here: kept.
      await service.change(ana, DateTime(2027, 1, 1), 'G82', by: 'G');
      await service.save(
        parsed(),
        {'Ana Lopes': ana, 'Rui Sá': rui},
        importedBy: 'B',
        drop: {alteracaoKey('rui', dec31)},
      );
      expect(service.index.dayOf(ana, dec31)!.offLabel, 'Ausência');
      expect(service.index.dayOf(rui, dec31)!.code, 'W82');
      expect(service.index.dayOf(ana, DateTime(2027, 1, 1))!.code, 'G82');
    });

    test('re-import drops a change the file now agrees with', () async {
      await imported();
      await service.change(ana, dec31, 'A', by: 'G');
      final again = parseHorarioXlsx(buildXlsx(
        plano: samplePlano()..[4] = [null, 'Ana Lopes', 'A', 'FO', 711, ''],
        horario: sampleHorario(),
      ));
      await service.save(again, {'Ana Lopes': ana, 'Rui Sá': rui}, importedBy: 'B');
      expect(await LocalDb.instance.horarioAlteracoes.all(), isEmpty);
      expect(service.index.dayOf(ana, dec31)!.offLabel, 'Ausência');
    });
  });
}
