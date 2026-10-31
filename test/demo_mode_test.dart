import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/screens/settings_screen.dart';
import 'package:livre_servico_app/services/demo_data.dart';
import 'package:livre_servico_app/services/account_service.dart';
import 'package:livre_servico_app/services/demo_mode.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  test('?demo in the address opens the demo', () {
    expect(isDemoUrl(Uri.parse('https://x.pages.dev/?demo=1')), isTrue);
    expect(isDemoUrl(Uri.parse('https://x.pages.dev/?demo')), isTrue);
    expect(isDemoUrl(Uri.parse('https://x.pages.dev/')), isFalse);
    expect(isDemoUrl(Uri.parse('https://x.pages.dev/?demonio=1')), isFalse);
  });

  test('the addresses in and out of the demo', () {
    final page = Uri.parse('https://x.pages.dev/?demo=1#/');
    expect(isDemoUrl(demoAddress(page, demo: false)), isFalse);
    expect(demoAddress(page, demo: false).toString(), 'https://x.pages.dev/');
    final home = Uri.parse('https://x.pages.dev/');
    expect(
      demoAddress(home, demo: true).toString(),
      'https://x.pages.dev/?demo=1',
    );
  });

  group('in demo mode', () {
    setUp(() async {
      DemoMode.active = true;
      await openAppDb();
    });
    tearDown(() async {
      DemoMode.active = false;
      AccountService.instance.store = null;
      await closeAppDb();
    });

    testWidgets('Home shows the banner and the example store', (tester) async {
      await dbCall(tester, seedDemo);
      await pumpApp(tester, const LivreServicoApp());
      expect(find.text('Modo demonstração — nada é guardado'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
      expect(find.textContaining('visita da área'), findsOneWidget);
    });

    testWidgets('Definições hides what needs a real account', (tester) async {
      await dbCall(tester, seedDemo);
      await pumpApp(tester, const LivreServicoApp());
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          );
      await settle(tester);
      for (final t in [
        'Conta e Sincronização',
        'Exportar Dados',
        'Importar Dados',
        'Apagar Todos os Dados',
      ]) {
        expect(find.text(t), findsNothing, reason: t);
      }
      expect(find.text('Política de Privacidade'), findsOneWidget);
    });

    test('the online database is never used', () {
      expect(AccountService.instance.isConfigured, isFalse);
    });

    test('the database is a fresh one in memory', () async {
      final executor = await DemoMode.inMemoryDatabase();
      expect(executor, isNotNull);
    });
  });
}
