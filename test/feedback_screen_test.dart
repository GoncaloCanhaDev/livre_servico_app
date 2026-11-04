import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/screens/feedback_screen.dart';

void main() {
  testWidgets('signed out, it says to sign in and sends nothing', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FeedbackScreen()));

    expect(find.textContaining('inicie sessão'), findsOneWidget);
    await tester.tap(find.text('Sugestão'));
    await tester.pump();
    expect(find.text('O que gostava que a aplicação fizesse.'), findsOneWidget);
    final send = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Enviar'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    expect(send.onPressed, isNull);
  });
}
