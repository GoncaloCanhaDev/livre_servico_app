import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/historico_search.dart';
import 'package:livre_servico_app/models/inventory.dart';
import 'package:livre_servico_app/models/opening_list.dart';
import 'package:livre_servico_app/models/pedido.dart';
import 'package:livre_servico_app/models/truck_reception.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_PT'));

  group('matchesQuery', () {
    test('every word must appear, ignoring case and accents', () {
      expect(matchesQuery('Receção · João Simões', 'joao simoes'), isTrue);
      expect(matchesQuery('Receção · João Simões', 'SIMÕES rec'), isTrue);
      expect(matchesQuery('Receção · João Simões', 'joao ana'), isFalse);
    });

    test('an empty query matches everything', () {
      expect(matchesQuery('x', '  '), isTrue);
    });
  });

  test('dateWords reads as numbers and in words', () {
    final w = dateWords(DateTime(2026, 10, 8, 14));
    expect(matchesQuery(w, '8/10/2026'), isTrue);
    expect(matchesQuery(w, '8 de outubro'), isTrue);
    expect(matchesQuery(w, 'quinta'), isTrue);
  });

  test('a camião is found by matrícula, fornecedor, names and paletes', () {
    final t = TruckReception()
      ..arrivalTime = DateTime(2026, 10, 8, 6)
      ..licensePlate = 'AA-12-BB'
      ..supplier = 'Unilever'
      ..createdByNames = ['Rui Costa']
      ..expositores = [
        Expositor()
          ..amount = 2
          ..content = 'Coca-Cola',
      ];
    final text = truckSearchText(t);
    for (final q in ['aa-12', 'unilever', 'rui', 'coca']) {
      expect(matchesQuery(text, q), isTrue, reason: q);
    }
  });

  test('an inventário by name and code, a pedido by número', () {
    final inv = Inventory()
      ..name = 'Iogurtes'
      ..code = '123456'
      ..valueCents = 1050
      ..createdAt = DateTime(2026, 10, 8);
    expect(matchesQuery(inventorySearchText(inv), '12345'), isTrue);
    expect(matchesQuery(inventorySearchText(inv), 'iogurte'), isTrue);
    final p = Pedido()
      ..createdAt = DateTime(2026, 10, 8)
      ..numero = '4500123'
      ..supplier = 'Nestlé';
    expect(matchesQuery(pedidoSearchText(p), '4500123 nestle'), isTrue);
  });

  test('tarefas and abertura by who did them', () {
    final t = DailyTasks()
      ..serviceDay = DateTime(2026, 10, 8, 5)
      ..kiwiFechoByNames = ['Eva Lopes'];
    expect(matchesQuery(dailyTasksSearchText(t), 'eva'), isTrue);
    expect(matchesQuery(dailyTasksSearchText(t), 'rui'), isFalse);
    final o = OpeningList()
      ..serviceDay = DateTime(2026, 10, 8, 5)
      ..oplsByNames = ['Ana Silva'];
    expect(matchesQuery(openingSearchText(o), 'ana'), isTrue);
  });
}
