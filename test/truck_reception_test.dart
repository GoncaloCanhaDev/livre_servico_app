import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:livre_servico_app/models/truck_reception.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_PT'));

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

  group('WhatsApp message', () {
    test('a full reception', () {
      final t = TruckReception()
        ..arrivalTime = DateTime(2026, 10, 8, 6, 30)
        ..type = TruckType.pereciveis
        ..licensePlate = 'AA-00-BB'
        ..supplier = 'Azambuja'
        ..createdByNames = ['Ana', 'Rui', 'Joana']
        ..pallets = [
          PalletCount()
            ..department = 'iogurtes'
            ..total = 4
            ..mistas = 1,
          PalletCount()
            ..department = 'talho'
            ..total = 2
            ..mistas = 2,
          PalletCount()
            ..department = 'fruta'
            ..total = 3,
        ]
        ..expositores = [
          Expositor()
            ..amount = 3
            ..content = 'Coca-Cola',
          Expositor()..amount = 1,
        ]
        ..sentVasilhame = [
          SentVasilhameItem()
            ..productName = 'Palete'
            ..amount = 5,
        ]
        ..issues = 'Falta 1 palete'
        ..notes = 'Chegou cedo';
      expect(
        truckWhatsAppText(t),
        '🚛 Receção de Camião\n'
        'Tipo: Perecíveis\n'
        'Hora: 8/10/2026, 06:30\n'
        'Matrícula: AA-00-BB\n'
        'Fornecedor: Azambuja\n'
        'Iogurtes: 4 (1 mista)\n'
        'Talho: 2 (2 mistas)\n'
        'Fruta: 3\n'
        'Total: 9 paletes, 3 mistas\n'
        'Por: Ana, Rui e Joana\n'
        '\n'
        'Expositores:\n'
        '- 3 · Coca-Cola\n'
        '- 1\n'
        '\n'
        '📦 Vasilhame Enviado:\n'
        '- Palete: 5\n'
        '\n'
        '⚠️ Problemas: Falta 1 palete\n'
        '\n'
        'Notas: Chegou cedo',
      );
    });

    test('an old reception: no type, the legacy name, nothing optional', () {
      final t = TruckReception()
        ..arrivalTime = DateTime(2026, 1, 2, 23, 5)
        ..createdByInitials = 'Ana';
      expect(
        truckWhatsAppText(t),
        '🚛 Receção de Camião\n'
        'Hora: 2/01/2026, 23:05\n'
        'Total: 0 paletes, 0 mistas\n'
        'Por: Ana',
      );
    });
  });
}
