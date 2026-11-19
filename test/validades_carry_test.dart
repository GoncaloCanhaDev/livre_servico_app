import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/not_done.dart';
import 'package:livre_servico_app/models/validades.dart';
import 'package:livre_servico_app/services/daily_tasks_service.dart';

import 'helpers/app_db.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  final service = DailyTasksService.instance;
  final day = DateTime(2026, 11, 19, 5);

  test('the Manhã\'s leftovers are added to the same day\'s Noite', () async {
    final t = await service.forDay(day)
      ..verificacaoValidades = true
      ..verificacaoValidadesCount = 10
      ..validadesNoiteCount = 2
      ..validadesManhaLeft = 4;
    await service.save(t);

    expect(await service.carryValidades(t, ValidadesTurno.manha, 4), isTrue);
    final saved = (await service.find(day))!;
    expect(saved.validadesNoiteCount, 6);
    expect(saved.validadesNoiteCarried, 4);
    expect(saved.validadesManhaLeft, 4);
    expect(saved.verificacaoValidadesCount, 10);
  });

  test('the Noite\'s leftovers go to the next day\'s Manhã', () async {
    final t = await service.forDay(day)
      ..validadesNoite = true
      ..validadesNoiteLeft = 3;
    await service.save(t);

    expect(await service.carryValidades(t, ValidadesTurno.noite, 3), isTrue);
    final next = (await service.find(DateTime(2026, 11, 20, 5)))!;
    expect(next.verificacaoValidadesCount, 3);
    expect(next.validadesManhaCarried, 3);
  });

  test('nothing is added to a window already marked', () async {
    final t = await service.forDay(day)
      ..notDone = {
        'validades_noite': NotDone(byNames: ['Ana'], reason: 'x', at: day),
      };
    await service.save(t);

    expect(await service.carryValidades(t, ValidadesTurno.manha, 5), isFalse);
    expect((await service.find(day))!.validadesNoiteCount, 0);
    expect(await service.carryValidades(t, ValidadesTurno.manha, 0), isFalse);
  });

  test('the new fields survive the JSON round trip', () {
    final t = DailyTasks.fromJson(
      (DailyTasks()
            ..serviceDay = day
            ..validadesManhaLeft = 1
            ..validadesManhaCarried = 2
            ..validadesNoiteLeft = 3
            ..validadesNoiteCarried = 4)
          .toJson(),
    );
    expect(
      [
        t.validadesManhaLeft,
        t.validadesManhaCarried,
        t.validadesNoiteLeft,
        t.validadesNoiteCarried,
      ],
      [1, 2, 3, 4],
    );
  });
}
