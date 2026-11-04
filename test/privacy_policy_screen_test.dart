import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/privacy_policy.dart';
import 'package:livre_servico_app/screens/privacy_policy_screen.dart';

void main() {
  Future<bool?> open(WidgetTester tester, {required bool accept}) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => PrivacyPolicyScreen(accept: accept),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('creating an account: accepted only at the end of the text', (
    tester,
  ) async {
    await open(tester, accept: true);
    expect(find.text('Política de Privacidade'), findsOneWidget);
    expect(find.text(privacyPolicy.first.title), findsOneWidget);
    final accept = find.text('Li e aceito');
    await tester.scrollUntilVisible(accept, 400);
    await tester.ensureVisible(accept);
    await tester.pumpAndSettle();
    expect(find.text(privacyPolicy.last.title), findsOneWidget);
    await tester.tap(accept);
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyScreen), findsNothing);
  });

  testWidgets('reading it later: nothing to accept', (tester) async {
    await open(tester, accept: false);
    await tester.scrollUntilVisible(find.text(privacyPolicy.last.title), 400);
    expect(find.text('Li e aceito'), findsNothing);
  });

  test('every section has text and the version is dated', () {
    for (final s in privacyPolicy) {
      expect(s.paragraphs, isNotEmpty, reason: s.title);
    }
    expect(privacyPolicyVersion, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
  });
}
