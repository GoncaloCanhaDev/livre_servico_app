import 'package:flutter_test/flutter_test.dart';
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
    expect(ValidadesTurno.manha.openNote, 'Aberta até às 14h');
    expect(ValidadesTurno.noite.openNote, 'Aberta até às 5h');
    expect(ValidadesTurno.noite.notYetNote, 'Abre às 19h');
  });
}
