import 'dart:convert';

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

  /// Pages through the open tutorial to the end, checking it shows [steps].
  Future<void> pageThrough(
    WidgetTester tester,
    List<TutorialStep> steps,
  ) async {
    expect(find.byType(TutorialScreen), findsOneWidget);
    expect(find.text('1 de ${steps.length}'), findsOneWidget);
    for (final step in steps) {
      // The sketch's bar may repeat the title.
      expect(find.text(step.title), findsWidgets);
      await tapAndSettle(
        tester,
        find.text(step == steps.last ? 'Concluir' : 'Seguinte'),
      );
    }
    expect(find.byType(TutorialScreen), findsNothing);
  }

  testWidgets('the tutorial opens from Home and finishing it hides the card', (
    tester,
  ) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Primeira vez na aplicação?'));
    await pageThrough(tester, tutorialSteps);
    expect(pendingTutorialSections(), isEmpty);
    expect(find.text('Primeira vez na aplicação?'), findsNothing);
  });

  testWidgets('closing the card hides it', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.byTooltip('Fechar'));
    expect(find.text('Primeira vez na aplicação?'), findsNothing);
    expect(pendingTutorialSections(), isEmpty);
  });

  testWidgets('the tutorial opens from Definições, whole or by section', (
    tester,
  ) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.byIcon(Icons.settings));
    await tapAndSettle(tester, find.text('Tutorial'));
    expect(find.byType(TutorialIndexScreen), findsOneWidget);
    await tapAndSettle(tester, find.text('Ver tudo'));
    expect(find.text('1 de ${tutorialSteps.length}'), findsOneWidget);
    await tapAndSettle(tester, find.text('Saltar'));

    final listas = tutorialSections.firstWhere((s) => s.id == 'listas2');
    // The title, and its one page's title under it.
    await tapAndSettle(tester, find.text(listas.title).first);
    await pageThrough(tester, listas.steps);
  });

  test('every section has its own id', () {
    final ids = [for (final s in tutorialSections) s.id];
    expect(ids.toSet(), hasLength(ids.length));
  });

  group('changed sections show again', () {
    setUp(() async {
      await closeAppDb();
    });

    testWidgets('after the tutorial from before sections', (tester) async {
      await openAppDb(prefs: {'tutorialSeen': true});
      await pumpApp(tester, const LivreServicoApp());
      expect(find.text('Primeira vez na aplicação?'), findsNothing);
      expect(find.text('Novidades'), findsOneWidget);
      expect(
        [for (final s in pendingTutorialSections()) s.id],
        ['inicio', 'listas2', 'listas'],
      );

      await tapAndSettle(tester, find.text('Novidades'));
      await pageThrough(tester, [
        for (final s in pendingTutorialSections()) ...s.steps,
      ]);
      expect(find.text('Novidades'), findsNothing);
    });

    testWidgets('when a section\'s version goes up', (tester) async {
      final tarefas = tutorialSections.firstWhere((s) => s.id == 'tarefas');
      await openAppDb(
        prefs: {
          'tutorialSeenVersions': jsonEncode({
            for (final s in tutorialSections)
              s.id: s == tarefas ? s.version - 1 : s.version,
          }),
        },
      );
      await pumpApp(tester, const LivreServicoApp());
      expect(find.textContaining('Mudou: Tarefas.'), findsOneWidget);
      await tapAndSettle(tester, find.byTooltip('Fechar'));
      expect(find.text('Novidades'), findsNothing);
      expect(
        SettingsService.instance.tutorialSeenVersion('tarefas'),
        tarefas.version,
      );
    });
  });
}
