import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/auto_mark.dart';
import 'package:livre_servico_app/models/custom_task.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/task_window.dart';
import 'package:livre_servico_app/models/weekly_tasks.dart';

Person _p(
  String name,
  String start,
  String end, {
  String team = 'livre_servico',
}) {
  int m(String t) =>
      int.parse(t.split(':')[0]) * 60 + int.parse(t.split(':')[1]);
  return Person()
    ..fullName = name
    ..team = team
    ..createdAt = DateTime(2026)
    ..shiftStart = m(start)
    ..shiftEnd = m(end);
}

final _day = DateTime(2026, 11, 18, 5); // a Wednesday

void main() {
  group('windowSpan', () {
    test('Alterações de Preço: 05:00 to 07:30 the same date', () {
      final s = windowSpan(defaultTaskWindow('alteracoes_preco'), _day);
      expect(s.start, DateTime(2026, 11, 18, 5));
      expect(s.end, DateTime(2026, 11, 18, 7, 30));
    });

    test('Kiwi Fecho: 19:00 to 22:00', () {
      final s = windowSpan(defaultTaskWindow('kiwi_fecho'), _day);
      expect(s.start, DateTime(2026, 11, 18, 19));
      expect(s.end, DateTime(2026, 11, 18, 22));
    });

    test('Validades Noite ends at 05:00 the next date', () {
      final s = windowSpan(defaultTaskWindow('validades_noite'), _day);
      expect(s.start, DateTime(2026, 11, 18, 19));
      expect(s.end, DateTime(2026, 11, 19, 5));
    });

    test('a task with no default takes the whole service day', () {
      final s = windowSpan(defaultTaskWindow('some-uuid'), _day);
      expect(s.start, DateTime(2026, 11, 18, 5));
      expect(s.end, DateTime(2026, 11, 19, 5));
      expect(windowValid(defaultTaskWindow('some-uuid')), isTrue);
    });

    test('a window closing before it opens is not valid', () {
      expect(
        windowValid(TaskWindow(taskKey: 'x', opensAt: 600, closesAt: 540)),
        isFalse,
      );
    });
  });

  group('autoMarkPeople', () {
    final abertura = windowSpan(defaultTaskWindow('kiwi_abertura'), _day);
    final noite = windowSpan(defaultTaskWindow('validades_noite'), _day);

    test('everyone in Livre Serviço whose shift overlaps, earliest first', () {
      final people = [
        _p('Bruno', '07:00', '16:00'),
        _p('Ana', '06:00', '15:00'),
        _p('Carla', '09:00', '18:00'), // starts when the window closes
        _p('Rui', '06:00', '15:00', team: 'talho'),
      ];
      expect(autoMarkPeople(people, abertura), ['Ana', 'Bruno']);
    });

    test('a night shift from the date before counts', () {
      final people = [_p('Ana', '22:00', '07:00')];
      expect(autoMarkPeople(people, abertura), ['Ana']);
    });

    test('a shift after midnight counts for the night window', () {
      final people = [_p('Ana', '00:00', '08:00')];
      expect(autoMarkPeople(people, noite), ['Ana']);
    });

    test('a folga that weekday keeps them out', () {
      final ana = _p('Ana', '06:00', '15:00')..folgas = [DateTime.wednesday];
      expect(autoMarkPeople([ana], abertura), isEmpty);
    });

    test('nobody working gives nobody', () {
      expect(autoMarkPeople([Person()..fullName = 'X'], abertura), isEmpty);
    });
  });

  group('marking a row', () {
    test('an automatic Validades mark leaves the count and left to fill', () {
      final t = DailyTasks()..serviceDay = _day;
      autoMarkDaily(t, 'validades_noite', ['Ana'], DateTime(2026, 11, 19, 6));
      expect(t.validadesNoite, isTrue);
      expect(t.validadesNoiteByNames, ['Ana']);
      expect(t.autoMarks['validades_noite']!.confirmed, isFalse);
      expect(t.pendingCounts, ['validades_noite', 'validades_noite:left']);
      expect(dailySettled(t, 'validades_noite'), isTrue);
    });

    test('Kiwi Abertura has no number', () {
      final t = DailyTasks()..serviceDay = _day;
      autoMarkDaily(t, 'kiwi_abertura', ['Ana'], DateTime(2026, 11, 18, 9));
      expect(t.pendingCounts, isEmpty);
    });

    test('a weekly Verificar leaves its count to fill', () {
      final w = WeeklyTasks()..serviceWeek = DateTime(2026, 11, 16, 5);
      autoMarkWeekly(w, 'verificar_1a', ['Ana'], DateTime(2026, 11, 18));
      expect(w.verificar1a, isTrue);
      expect(w.pendingCounts, ['verificar_1a']);
    });
  });

  group('JSON', () {
    test('the new fields read back', () {
      final t = DailyTasks()
        ..serviceDay = _day
        ..autoMarks = {
          'kiwi_fecho': AutoMark(
            at: DateTime(2026, 11, 18, 22),
            confirmedByNames: ['Rita'],
            confirmedAt: DateTime(2026, 11, 19, 8),
          ),
        }
        ..pendingCounts = ['alteracoes_preco'];
      final back = DailyTasks.fromJson(t.toJson());
      expect(back.autoMarks['kiwi_fecho']!.confirmedByNames, ['Rita']);
      expect(back.autoMarks['kiwi_fecho']!.confirmed, isTrue);
      expect(back.pendingCounts, ['alteracoes_preco']);

      final w = WeeklyTasks()
        ..serviceWeek = _day
        ..autoMarks = {'verificar_1a': AutoMark(at: _day)};
      expect(WeeklyTasks.fromJson(w.toJson()).autoMarks.keys, ['verificar_1a']);

      final e = CustomTaskEntry()
        ..taskUuid = 'u'
        ..periodKey = _day
        ..autoMark = AutoMark(at: _day);
      expect(CustomTaskEntry.fromJson(e.toJson()).autoMark!.at, _day);

      final win = TaskWindow(
        taskKey: 'kiwi_fecho',
        opensAt: 1140,
        closesAt: 1290,
        auto: false,
      );
      final wb = TaskWindow.fromJson(win.toJson());
      expect(
        (wb.taskKey, wb.opensAt, wb.closesAt, wb.auto),
        ('kiwi_fecho', 1140, 1290, false),
      );
    });

    test('rows from before read with nothing automatic', () {
      final t = DailyTasks.fromJson({'serviceDay': 0});
      expect(t.autoMarks, isEmpty);
      expect(t.pendingCounts, isEmpty);
    });
  });
}
