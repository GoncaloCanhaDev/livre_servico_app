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
}
