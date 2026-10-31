import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/aviso.dart';
import 'package:livre_servico_app/services/aviso_service.dart';

import 'helpers/app_db.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  final service = AvisoService.instance;

  Future<List<Aviso>> onHome(String personId) async => avisosOnHome(
    await service.all(),
    await service.vistos(),
    personId,
    DateTime.now(),
  );

  test('send then markSeen: off Home', () async {
    final a = await service.send(
      '  Falta a validade da noite ',
      ['ana', 'rui'],
      fromPersonId: 'chefe',
      fromName: 'Zé',
    );
    expect(a.text, 'Falta a validade da noite');
    expect(a.syncUuid, isNotEmpty);
    expect((await onHome('ana')).single.syncUuid, a.syncUuid);
    await service.markSeen(a, 'ana');
    expect(await onHome('ana'), isEmpty);
    expect(await onHome('rui'), hasLength(1));
  });

  test('markSeen twice keeps one row', () async {
    final a = await service.send(
      'x',
      ['ana'],
      fromPersonId: 'c',
      fromName: 'C',
    );
    await service.markSeen(a, 'ana');
    await service.markSeen(a, 'ana');
    expect(await service.vistos(), hasLength(1));
  });

  test('delete hides it', () async {
    final a = await service.send(
      'x',
      ['ana'],
      fromPersonId: 'c',
      fromName: 'C',
    );
    await service.delete(a);
    expect(await onHome('ana'), isEmpty);
    expect(avisosSent(await service.all(), 'c', DateTime.now()), isEmpty);
  });
}
