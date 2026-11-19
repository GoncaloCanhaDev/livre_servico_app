import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/task_window.dart';
import 'package:livre_servico_app/models/validades.dart';

void main() {
  DateTime at(int hour, [int minute = 0]) =>
      DateTime(2026, 10, 8, hour, minute);

  group('Manhã (05–14)', () {
    const m = ValidadesTurno.manha;

    test('opens with the service day at 05:00', () {
      expect(validadesStateAt(m, at(5)), ValidadesState.open);
      expect(validadesStateAt(m, at(13, 59)), ValidadesState.open);
    });

    test('closes at 14:00 until the day ends at 05:00', () {
      expect(validadesStateAt(m, at(14)), ValidadesState.closed);
      expect(validadesStateAt(m, at(23)), ValidadesState.closed);
      expect(validadesStateAt(m, at(4, 59)), ValidadesState.closed);
    });
  });

  group('Noite (19–05)', () {
    const n = ValidadesTurno.noite;

    test('is not open yet before 19:00', () {
      expect(validadesStateAt(n, at(5)), ValidadesState.notYet);
      expect(validadesStateAt(n, at(18, 59)), ValidadesState.notYet);
    });

    test('is open from 19:00 until the day ends at 05:00', () {
      expect(validadesStateAt(n, at(19)), ValidadesState.open);
      expect(validadesStateAt(n, at(0, 30)), ValidadesState.open);
      expect(validadesStateAt(n, at(4, 59)), ValidadesState.open);
    });
  });

  test('notes say when a part opens or closes', () {
    expect(ValidadesTurno.manha.label, 'Validades · Manhã');
    expect(ValidadesTurno.noite.label, 'Validades · Noite');
    expect(ValidadesTurno.manha.defaultWindow.openNote, 'Aberta até às 14h');
    expect(ValidadesTurno.noite.defaultWindow.openNote, 'Aberta até às 5h');
    expect(ValidadesTurno.noite.defaultWindow.notYetNote, 'Abre às 19h');
    expect(
      ValidadesTurno.manha.defaultWindow.lateNote,
      'Era até às 14h — ainda se pode marcar',
    );
  });

  test('an edited window decides, to the minute', () {
    final w = TaskWindow(
      taskKey: 'verificacao_validades',
      opensAt: 6 * 60,
      closesAt: 12 * 60 + 30,
    );
    DateTime at(int h, [int m = 0]) => DateTime(2026, 10, 31, h, m);
    final m = ValidadesTurno.manha;
    expect(validadesStateAt(m, at(5, 59), window: w), ValidadesState.notYet);
    expect(validadesStateAt(m, at(12, 29), window: w), ValidadesState.open);
    expect(validadesStateAt(m, at(12, 30), window: w), ValidadesState.closed);
    expect(w.openNote, 'Aberta até às 12h30');
  });

  group('nextValidadesWindow', () {
    final day = DateTime(2026, 10, 31, 5);

    test('the Manhã passes to the same day\'s Noite', () {
      expect(nextValidadesWindow(day, ValidadesTurno.manha), (
        day,
        ValidadesTurno.noite,
      ));
    });

    test('the Noite passes to the next service day\'s Manhã', () {
      expect(nextValidadesWindow(day, ValidadesTurno.noite), (
        DateTime(2026, 11, 1, 5),
        ValidadesTurno.manha,
      ));
    });
  });
}
