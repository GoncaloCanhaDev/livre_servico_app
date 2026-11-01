import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/app_version.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/screens/tutorial_screen.dart';
import 'package:livre_servico_app/services/settings_service.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  testWidgets('Home shows the version next to the title', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    expect(find.text('v$appVersion'), findsOneWidget);
  });

  testWidgets('the tutorial opens from Home and finishing it hides the card', (
    tester,
  ) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Primeira vez na aplicação?'));
    expect(find.byType(TutorialScreen), findsOneWidget);

    for (final step in tutorialSteps) {
      // The sketch's bar may repeat the title.
      expect(find.text(step.title), findsWidgets);
      await tapAndSettle(
        tester,
        find.text(step == tutorialSteps.last ? 'Concluir' : 'Seguinte'),
      );
    }
    expect(find.byType(TutorialScreen), findsNothing);
    expect(SettingsService.instance.tutorialSeen, isTrue);
    expect(find.text('Primeira vez na aplicação?'), findsNothing);
  });

  testWidgets('closing the card hides it', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.byTooltip('Fechar'));
    expect(find.text('Primeira vez na aplicação?'), findsNothing);
  });

  testWidgets('the tutorial opens from Definições', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.byIcon(Icons.settings));
    await tapAndSettle(tester, find.text('Tutorial'));
    expect(find.byType(TutorialScreen), findsOneWidget);
  });
}
