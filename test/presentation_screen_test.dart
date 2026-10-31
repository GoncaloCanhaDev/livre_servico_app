import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/screens/account_screen.dart';
import 'package:livre_servico_app/screens/presentation_screen.dart';
import 'package:livre_servico_app/theme.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<void> open(WidgetTester tester) => pumpApp(
    tester,
    MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: const PresentationScreen(),
    ),
  );

  testWidgets('the page offers the demo, an account and signing in', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Experimentar a demo'), findsWidgets);
    expect(find.text('Criar conta'), findsWidgets);
    expect(find.text('Entrar'), findsWidgets);
    await scrollTo(tester, find.textContaining('não oficial'));
    expect(find.textContaining('não oficial'), findsOneWidget);
  });

  test('the copyright line follows the year', () {
    expect(copyrightLine(DateTime(2026, 10, 31)), '© 2026 Gonçalo Canha');
    expect(copyrightLine(DateTime(2028, 1, 2)), '© 2026–2028 Gonçalo Canha');
  });

  testWidgets('Entrar opens Conta', (tester) async {
    await open(tester);
    await tapAndSettle(tester, find.text('Entrar').first);
    expect(find.byType(AccountScreen), findsOneWidget);
  });
}
