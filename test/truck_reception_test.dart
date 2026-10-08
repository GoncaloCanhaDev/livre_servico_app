import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/truck_reception.dart';

void main() {
  test('Adicionar lists the departamentos in order', () {
    expect(truckDepartments.map((d) => d.label).toList(), [
      'DPH',
      'Mercearia',
      'Bebidas',
      'Bazar',
      'Congelados',
      'Charcutaria',
      'Iogurtes',
      'Meal Solutions',
      'Talho',
      'Peixaria',
      'Bem Estar',
      'Padaria',
      'Fruta',
      'Prodout',
    ]);
    expect(truckDepartments.map((d) => d.id).toSet(), hasLength(14));
  });

  group('palete label', () {
    test('a departamento', () {
      final p = PalletCount()..department = 'iogurtes';
      expect(p.label, 'Iogurtes');
    });

    test('an old row falls back to its category', () {
      final p = PalletCount()..category = PalletCategory.leite;
      expect(p.label, 'Leite');
    });

    test('an unknown departamento shows its id', () {
      final p = PalletCount()..department = 'algo';
      expect(p.label, 'algo');
    });
  });

  test('the title carries the type when there is one', () {
    final t = TruckReception()..arrivalTime = DateTime(2026, 10, 8);
    expect(truckTitle(t), 'Camião');
    t.type = TruckType.naoPereciveis;
    expect(truckTitle(t), 'Camião · Não Perecíveis');
  });

  test('totalExpositores adds up every line', () {
    final t = TruckReception()
      ..arrivalTime = DateTime(2026, 10, 8)
      ..expositores = [
        Expositor()
          ..amount = 3
          ..content = 'Coca-Cola',
        Expositor()
          ..amount = 1
          ..content = 'Milka',
      ];
    expect(t.totalExpositores, 4);
  });
}
