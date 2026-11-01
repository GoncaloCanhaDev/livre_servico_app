import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/app_version.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/release_notes.dart';
import 'package:livre_servico_app/screens/widgets/release_notes_dialog.dart';
import 'package:livre_servico_app/services/settings_service.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

const _notes = <ReleaseNote>[
  (version: '1.2.0', items: ['c']),
  (version: '1.1.0', items: ['b']),
  (version: '1.0.0', items: ['a']),
];

void main() {
  test('compareVersions reads each part as a number', () {
    expect(compareVersions('0.10.0', '0.9.9'), greaterThan(0));
    expect(compareVersions('0.75.1+182', '0.75.1'), 0);
    expect(compareVersions('1.0', '1.0.1'), lessThan(0));
    expect(newerVersion('0.9.0', '0.10.0'), '0.10.0');
    expect(newerVersion(null, '0.1.0'), '0.1.0');
    expect(newerVersion(null, null), isNull);
  });

  test('unseenReleaseNotes: after the seen version, up to the current', () {
    List<String> versions(String? seen, String current) => [
      for (final n in unseenReleaseNotes(seen, current, notes: _notes))
        n.version,
    ];
    expect(versions('1.0.0', '1.2.0'), ['1.2.0', '1.1.0']);
    expect(versions('0.9.0', '1.1.5'), ['1.1.0', '1.0.0']);
    expect(versions('1.2.0', '1.2.3'), isEmpty);
    expect(versions(null, '1.2.0'), isEmpty);
  });

  test('the notes are newest first and none is newer than the app', () {
    for (var i = 1; i < releaseNotes.length; i++) {
      expect(
        compareVersions(releaseNotes[i - 1].version, releaseNotes[i].version),
        greaterThan(0),
      );
    }
    for (final n in releaseNotes) {
      expect(compareVersions(n.version, appVersion), lessThanOrEqualTo(0));
      expect(n.items, isNotEmpty);
    }
  });

  group('the popup on Home', () {
    tearDown(closeAppDb);

    testWidgets('shows once after an update', (tester) async {
      await openAppDb(prefs: {'releaseNotesSeen': releaseNotesBaseline});
      resetReleaseNotesCheck();
      await pumpApp(tester, const LivreServicoApp());
      expect(find.byType(ReleaseNotesDialog), findsOneWidget);
      await tapAndSettle(tester, find.text('Entendido'));
      expect(find.byType(ReleaseNotesDialog), findsNothing);
      expect(SettingsService.instance.releaseNotesSeen, appVersion);
    });

    testWidgets('not on a first install', (tester) async {
      await openAppDb();
      resetReleaseNotesCheck();
      await pumpApp(tester, const LivreServicoApp());
      expect(find.byType(ReleaseNotesDialog), findsNothing);
      expect(SettingsService.instance.releaseNotesSeen, appVersion);
    });

    testWidgets('not when this version was already seen', (tester) async {
      await openAppDb(prefs: {'releaseNotesSeen': appVersion});
      resetReleaseNotesCheck();
      await pumpApp(tester, const LivreServicoApp());
      expect(find.byType(Dialog), findsNothing);
    });
  });
}
