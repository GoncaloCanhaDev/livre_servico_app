import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/auto_mark.dart';
import 'package:livre_servico_app/models/custom_task.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/not_done.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/models/task_merge.dart';
import 'package:livre_servico_app/services/server_clock.dart';

final _day = DateTime(2026, 11, 18, 5);
DateTime _at(int h, [int m = 0]) => DateTime(2026, 11, 18, h, m);

/// A copy of the day as one phone has it, saved at [savedAt].
DailyTasks _row(DateTime savedAt) => DailyTasks()
  ..serviceDay = _day
  ..syncUuid = 'u'
  ..syncUpdatedAt = savedAt;

DailyTasks _merge(DailyTasks a, DailyTasks b) {
  Map<String, dynamic> j(DailyTasks t) => t.toJson()
    ..remove('id')
    ..remove('synced');
  final ab = mergeTaskRows(j(a), j(b), dailyTaskFields);
  final ba = mergeTaskRows(j(b), j(a), dailyTaskFields);
  // The same whichever phone merges.
  expect(jsonEncode(ab), jsonEncode(ba));
  return DailyTasks.fromJson(ab);
}

void _manual(DailyTasks t, String key, List<String> who, DateTime at) {
  setDailyDone(t, key, who);
  t.taskStamps = {...t.taskStamps, key: TaskStamp(markedAt: at)};
}

void _auto(DailyTasks t, String key, List<String> who, DateTime at) {
  autoMarkDaily(t, key, who, at);
  t.taskStamps = {...t.taskStamps, key: TaskStamp(markedAt: at)};
}

void main() {
  test('a task marked on one phone only is kept, whoever saved last', () {
    final a = _row(_at(21));
    _manual(a, 'kiwi_fecho', ['Ana'], _at(21));
    final b = _row(_at(22, 1))..alteracoesPrecoCount = 7;
    _auto(b, 'preenchimento_quadro', ['Rui'], _at(22, 1));
    final m = _merge(a, b);
    expect(m.kiwiFechoByNames, ['Ana']);
    expect(m.preenchimentoQuadroByNames, ['Rui']);
    expect(m.autoMarks.keys, ['preenchimento_quadro']);
  });

  test('a mark by hand beats the app, even made later', () {
    final a = _row(_at(22, 30));
    _manual(a, 'kiwi_fecho', ['Ana'], _at(22, 30));
    final b = _row(_at(22, 1));
    _auto(b, 'kiwi_fecho', ['Rui', 'Ana'], _at(22, 1));
    final m = _merge(a, b);
    expect(m.kiwiFechoByNames, ['Ana']);
    expect(m.autoMarks, isEmpty);
  });

  test('two marks by hand: the first one wins', () {
    final a = _row(_at(21, 50));
    _manual(a, 'kiwi_fecho', ['Ana'], _at(21, 50));
    final b = _row(_at(21, 40));
    _manual(b, 'kiwi_fecho', ['Rui'], _at(21, 40));
    expect(_merge(a, b).kiwiFechoByNames, ['Rui']);
  });

  test('a correction wins, and the latest correction', () {
    final a = _row(_at(22, 1));
    _auto(a, 'kiwi_fecho', ['Rui'], _at(22, 1));
    final b = _row(_at(23))
      ..notDone = {
        'kiwi_fecho': NotDone(byNames: ['Rita'], reason: 'Não foi feito'),
      }
      ..taskStamps = {
        'kiwi_fecho': TaskStamp(markedAt: _at(22, 1), editedAt: _at(23)),
      };
    final m = _merge(a, b);
    expect(m.kiwiFecho, isFalse);
    expect(m.notDone['kiwi_fecho']!.reason, 'Não foi feito');
    expect(m.autoMarks, isEmpty);

    final c = _row(_at(23, 30));
    _auto(c, 'kiwi_fecho', ['Rui'], _at(22, 1));
    c.autoMarks['kiwi_fecho']!
      ..confirmedByNames = ['Sofia']
      ..confirmedAt = _at(23, 30);
    c.taskStamps['kiwi_fecho']!.editedAt = _at(23, 30);
    final m2 = _merge(b, c);
    expect(m2.kiwiFecho, isTrue);
    expect(m2.autoMarks['kiwi_fecho']!.confirmedByNames, ['Sofia']);
  });

  test('a number filled in later travels with its task', () {
    final a = _row(_at(8));
    _auto(a, 'alteracoes_preco', ['Ana'], _at(7, 30));
    final b = _row(_at(9))..alteracoesPrecoCount = 40;
    _auto(b, 'alteracoes_preco', ['Ana'], _at(7, 30));
    b.pendingCounts = [];
    b.taskStamps['alteracoes_preco']!.editedAt = _at(9);
    final m = _merge(a, b);
    expect(m.alteracoesPrecoCount, 40);
    expect(m.pendingCounts, isEmpty);
  });

  test('custom entries: by hand beats the app, a correction wins', () {
    Map<String, dynamic> entry({
      required bool auto,
      required DateTime doneAt,
      required List<String> who,
      DateTime? editedAt,
    }) =>
        (CustomTaskEntry()
              ..taskUuid = 't'
              ..periodKey = _day
              ..done = true
              ..doneByNames = who
              ..doneAt = doneAt
              ..editedAt = editedAt
              ..autoMark = auto ? AutoMark(at: doneAt) : null
              ..syncUpdatedAt = doneAt)
            .toJson();
    final manual = entry(auto: false, doneAt: _at(23), who: ['Ana']);
    final auto = entry(auto: true, doneAt: _at(22), who: ['Rui']);
    expect(mergeEntries(manual, auto)['doneByNames'], ['Ana']);
    expect(mergeEntries(auto, manual)['doneByNames'], ['Ana']);
    final fixed = entry(
      auto: false,
      doneAt: _at(22),
      who: ['Rita'],
      editedAt: _at(23, 30),
    );
    expect(mergeEntries(manual, fixed)['doneByNames'], ['Rita']);
  });

  test('ServerClock measures the middle of the round trip', () {
    final sent = DateTime(2026, 11, 18, 10);
    final received = sent.add(const Duration(seconds: 2));
    final server = sent.add(const Duration(minutes: 3, seconds: 1));
    expect(
      ServerClock.measure(sent, server, received),
      const Duration(minutes: 3),
    );
  });

  test('only phones that see the whole schedule mark by themselves', () {
    expect(StoreAccess.full.canAutoMark, isTrue);
    expect(
      const StoreAccess(
        admin: false,
        level: 3,
        team: 'livre_servico',
      ).canAutoMark,
      isTrue,
    );
    expect(
      const StoreAccess(admin: false, level: 3, team: 'talho').canAutoMark,
      isFalse,
    );
    expect(
      const StoreAccess(
        admin: false,
        level: 2,
        team: 'livre_servico',
      ).canAutoMark,
      isFalse,
    );
    expect(const StoreAccess(admin: false, level: 4).canAutoMark, isTrue);
  });
}
