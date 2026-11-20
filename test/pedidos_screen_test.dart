import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/pedido.dart';
import 'package:livre_servico_app/services/pedido_service.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<void> openPedidos(WidgetTester tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Pedidos'));
  }

  testWidgets('a pedido is created, then finalized', (tester) async {
    await openPedidos(tester);
    expect(find.text('Sem pedidos registados.'), findsOneWidget);

    await tapAndSettle(tester, find.text('Novo'));
    // The number is required.
    await tapAndSettle(tester, find.text('Criar pedido'));
    expect(find.text('Obrigatório'), findsOneWidget);
    expect(await dbCall(tester, PedidoService.instance.history), isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Número do pedido'),
      '4521',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Fornecedor (opcional)'),
      'Unilever',
    );
    await tapAndSettle(tester, find.text('Criar pedido'));
    final created = await dbCall(tester, PedidoService.instance.history);
    expect(created.single.numero, '4521');
    expect(created.single.supplier, 'Unilever');
    expect(created.single.isFinalized, isFalse);

    await tapAndSettle(tester, find.text('Finalizar'));
    expect(find.text('Enviar por WhatsApp?'), findsOneWidget);
    expect(find.textContaining('📝 Pedido nº 4521'), findsOneWidget);
    await tapAndSettle(tester, find.text('Não'));
    // Opens the finalized pedido.
    expect(find.text('Pedido 4521'), findsOneWidget);
    expect(find.text('Unilever'), findsOneWidget);
    final done = await dbCall(tester, PedidoService.instance.history);
    expect(done.single.isFinalized, isTrue);

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text('Pedido 4521'), findsOneWidget);
    expect(find.textContaining('Concluído'), findsOneWidget);
  });

  testWidgets('a pedido past its date shows as late', (tester) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 2));
    await pumpApp(tester, const LivreServicoApp());
    await dbCall(
      tester,
      () => PedidoService.instance.create(
        numero: '77',
        expectedDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
      ),
    );
    await dbCall(tester, () => PedidoService.instance.create(numero: '78'));
    await tapAndSettle(tester, find.text('Pedidos'));
    expect(find.text('1 pedido está atrasado.'), findsOneWidget);
    expect(find.text('Pedido 77 (em curso)'), findsOneWidget);
    expect(find.text('Pedido 78 (em curso)'), findsOneWidget);
    expect(find.textContaining('Atrasado'), findsOneWidget);
  });

  testWidgets('a pedido in progress can be cancelled', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await dbCall(tester, () => PedidoService.instance.create(numero: '90'));
    await tapAndSettle(tester, find.text('Pedidos'));
    await tapAndSettle(tester, find.text('Pedido 90 (em curso)'));
    await tapAndSettle(tester, find.byTooltip('Cancelar pedido'));
    await tapAndSettle(tester, find.text('Cancelar pedido'));
    final List<Pedido> left = await dbCall(
      tester,
      PedidoService.instance.history,
    );
    expect(left, isEmpty);
    expect(find.text('Sem pedidos registados.'), findsOneWidget);
  });
}
