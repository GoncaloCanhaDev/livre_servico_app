import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/screens/claim_person_screen.dart';

void main() {
  /// Opens the picker from a button and returns what it popped with.
  Future<({String? personId, String? name})?> pick(
    WidgetTester tester, {
    required bool canAddNew,
    required Future<void> Function() choose,
  }) async {
    ({String? personId, String? name})? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClaimPersonScreen(
                  storeName: 'Loja X',
                  canAddNew: canAddNew,
                  people: [
                    (id: 'p1', name: 'Ana Silva', number: '12345'),
                    (id: 'p2', name: 'Rui Costa', number: ''),
                  ],
                ),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await choose();
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('picking a person pops with its id', (tester) async {
    final r = await pick(
      tester,
      canAddNew: true,
      choose: () async {
        expect(find.text('Nº 12345'), findsOneWidget);
        expect(find.text('Sem número'), findsOneWidget);
        await tester.tap(find.text('Rui Costa'));
      },
    );
    expect(r, (personId: 'p2', name: null));
  });

  testWidgets('"Não estou na lista" asks for the name', (tester) async {
    final r = await pick(
      tester,
      canAddNew: true,
      choose: () async {
        await tester.tap(find.text('Não estou na lista'));
        await tester.pumpAndSettle();
        expect(find.text('O seu nome'), findsOneWidget);
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();
        // An empty name keeps the dialog open.
        expect(find.text('O seu nome'), findsOneWidget);
        await tester.enterText(find.byType(TextField).last, ' Nova Pessoa ');
        await tester.tap(find.text('Continuar'));
      },
    );
    expect(r, (personId: null, name: 'Nova Pessoa'));
  });

  testWidgets('without canAddNew there is no new person', (tester) async {
    await pick(
      tester,
      canAddNew: false,
      choose: () async => expect(find.text('Não estou na lista'), findsNothing),
    );
  });
}
