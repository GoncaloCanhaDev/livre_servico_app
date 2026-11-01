import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/custom_task.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/not_done.dart';
import 'package:livre_servico_app/models/weekly_tasks.dart';

void main() {
  final at = DateTime(2026, 11, 1, 16, 30);
  NotDone n() => NotDone(byNames: ['Ana Silva'], reason: 'Sem tempo', at: at);

  void expectSame(NotDone? a) {
    expect(a, isNotNull);
    expect(a!.byNames, ['Ana Silva']);
    expect(a.reason, 'Sem tempo');
    expect(a.at, at);
  }

  test('DailyTasks keeps its Não feita tasks through JSON', () {
    final t = DailyTasks()
      ..serviceDay = DateTime(2026, 11, 1, 5)
      ..notDone = {'kiwi_fecho': n()};
    final back = DailyTasks.fromJson(t.toJson());
    expect(back.notDone.keys, ['kiwi_fecho']);
    expectSame(back.notDone['kiwi_fecho']);
  });

  test('WeeklyTasks keeps its Não feita tasks through JSON', () {
    final w = WeeklyTasks()
      ..serviceWeek = DateTime(2026, 10, 26, 5)
      ..notDone = {'verificar_1a': n()};
    expectSame(WeeklyTasks.fromJson(w.toJson()).notDone['verificar_1a']);
  });

  test('a CustomTaskEntry keeps its Não feita through JSON', () {
    final e = CustomTaskEntry()
      ..taskUuid = 'u'
      ..periodKey = DateTime(2026, 11, 1, 5)
      ..notDone = n();
    expectSame(CustomTaskEntry.fromJson(e.toJson()).notDone);
  });

  test('rows saved before Não feita read with none', () {
    final t = DailyTasks.fromJson({'serviceDay': 0});
    expect(t.notDone, isEmpty);
    final e = CustomTaskEntry.fromJson({'taskUuid': 'u'});
    expect(e.notDone, isNull);
  });
}
