import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/diagnostic.dart';
import 'package:livre_servico_app/screens/diagnostic_screen.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_PT'));

  group('clockOffsetText', () {
    test('under two seconds is right', () {
      expect(clockOffsetText(const Duration(milliseconds: 1500)), 'Certo');
      expect(clockOffsetText(const Duration(milliseconds: -900)), 'Certo');
    });

    test('the server ahead means the phone is behind', () {
      expect(clockOffsetText(const Duration(seconds: 8)), 'Atrasado 8 s');
      expect(
        clockOffsetText(const Duration(minutes: -3, seconds: -12)),
        'Adiantado 3 min 12 s',
      );
      expect(
        clockOffsetText(const Duration(hours: 1, seconds: 5)),
        'Atrasado 1 h 5 s',
      );
    });

    test('a minute off is worth saying', () {
      expect(clockOffsetWorrying(const Duration(seconds: 59)), isFalse);
      expect(clockOffsetWorrying(const Duration(minutes: -1)), isTrue);
    });
  });

  group('autoMarkBlockedReason', () {
    test('a phone that may not mark says so', () {
      expect(
        autoMarkBlockedReason(canAutoMark: false, connected: true, synced: true),
        contains('não marca'),
      );
    });

    test('connected, it waits for this session to sync', () {
      expect(
        autoMarkBlockedReason(canAutoMark: true, connected: true, synced: false),
        contains('primeira sincronização'),
      );
      expect(
        autoMarkBlockedReason(canAutoMark: true, connected: true, synced: true),
        isNull,
      );
      expect(
        autoMarkBlockedReason(
          canAutoMark: true,
          connected: false,
          synced: false,
        ),
        isNull,
      );
    });
  });

  test('diagTimeText leaves the date out today', () {
    final now = DateTime(2026, 11, 20, 18);
    expect(diagTimeText(DateTime(2026, 11, 20, 9, 5, 3), now: now), '09:05:03');
    expect(
      diagTimeText(DateTime(2026, 11, 18, 9, 5, 3), now: now),
      '18/11 09:05:03',
    );
    expect(diagTimeText(null), '—');
  });

  test('durationText', () {
    expect(durationText(const Duration(milliseconds: 320)), '320 ms');
    expect(durationText(const Duration(milliseconds: 1400)), '1,4 s');
  });

  test('diagnosticText lists every section and flags warnings', () {
    final text = diagnosticText(
      const [
        DiagSection('Sincronização', [
          DiagLine('Estado', 'Sem ligação', warn: true),
        ]),
        DiagSection('Este aparelho', [DiagLine('Versão', '1.0.0')]),
      ],
      at: DateTime(2026, 11, 20, 14, 2, 31),
      version: '1.0.0',
    );
    expect(text, contains('Livre Serviço Companion 1.0.0'));
    expect(text, contains('20/11/2026 14:02:31'));
    expect(text, contains('SINCRONIZAÇÃO\n! Estado: Sem ligação'));
    expect(text, contains('ESTE APARELHO\nVersão: 1.0.0'));
  });

  group('screen', () {
    setUp(openAppDb);
    tearDown(closeAppDb);

    testWidgets('signed out, it says the data stays here and marks tasks', (
      tester,
    ) async {
      await pumpApp(tester, const LivreServicoApp());
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(builder: (_) => const DiagnosticScreen()),
          );
      await settle(tester);

      expect(find.text('Sincronização'), findsOneWidget);
      expect(find.textContaining('Sem'), findsWidgets);
      expect(find.text('Tarefas marcadas sozinhas'), findsOneWidget);
      expect(find.text('Ativo'), findsOneWidget);
      expect(find.text('Verificar tarefas agora'), findsOneWidget);
      expect(find.text('Sincronizar agora'), findsNothing);
    });
  });
}
