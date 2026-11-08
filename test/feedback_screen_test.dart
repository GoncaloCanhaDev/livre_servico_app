import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:livre_servico_app/services/account_service.dart';
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

  test('the export lists every message, those to deal with first', () async {
    await initializeDateFormatting('pt_PT');
    final FeedbackItem done = (
      id: 'a',
      kind: FeedbackKind.sugestao,
      message: 'Um modo escuro.\n',
      email: 'ana@example.com',
      storeName: 'Loja 1',
      personName: 'Ana',
      appVersion: '0.80.0',
      platform: 'android',
      createdAt: DateTime(2026, 10, 1, 9, 5),
      doneAt: DateTime(2026, 10, 2, 10),
    );
    final FeedbackItem open = (
      id: 'b',
      kind: FeedbackKind.erro,
      message: 'Fecha ao abrir Pessoas.',
      email: 'rui@example.com',
      storeName: null,
      personName: null,
      appVersion: '',
      platform: 'web',
      createdAt: DateTime(2026, 11, 3, 14, 30),
      doneAt: null,
    );

    final text = feedbackExportText([
      done,
      open,
    ], now: DateTime(2026, 11, 8, 12));

    expect(
      text,
      contains(
        'Exportado em 8/11/2026 12:00 · 2 mensagens (1 por tratar, 1 tratada)',
      ),
    );
    expect(text.indexOf('POR TRATAR'), lessThan(text.indexOf('TRATADOS')));
    expect(
      text,
      contains(
        '[1] Erro · 3/11/2026 14:30\nDe: rui@example.com · Sem loja\nVersão: web',
      ),
    );
    expect(
      text,
      contains(
        '[2] Sugestão · 1/10/2026 09:05\nDe: Ana · ana@example.com · Loja 1',
      ),
    );
    expect(
      text,
      contains(
        'Versão: v0.80.0 · android\nTratado em 2/10/2026 10:00\n\nUm modo escuro.\n',
      ),
    );
    expect(text, contains('Fecha ao abrir Pessoas.'));
  });
}
