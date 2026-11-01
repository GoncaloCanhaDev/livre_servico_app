import 'package:flutter/material.dart';

import '../../app_version.dart';
import '../../models/release_notes.dart';
import '../../services/account_service.dart';
import '../../services/demo_mode.dart';
import '../../services/settings_service.dart';
import '../../theme.dart';

/// Whether this run of the app already checked (Home can be built again).
bool _checked = false;

/// After an update, the first time Home opens: the "Novidades" of every
/// version since the one last seen, on this device or (signed in) on this
/// account anywhere. Seen once closed, on both. Nothing on a first install,
/// for a version with no notes, or in the demo.
Future<void> showReleaseNotesIfNew(BuildContext context) async {
  if (_checked || DemoMode.active) return;
  _checked = true;
  final settings = SettingsService.instance;
  final account = await AccountService.instance.releaseNotesSeen();
  final seen = newerVersion(settings.releaseNotesSeen, account);
  final notes = unseenReleaseNotes(seen, appVersion);

  Future<void> markSeen() async {
    await settings.setReleaseNotesSeen(appVersion);
    if (account == null || compareVersions(account, appVersion) < 0) {
      await AccountService.instance.setReleaseNotesSeen(appVersion);
    }
  }

  if (notes.isEmpty) {
    // A first install, a version with nothing to tell, or seen elsewhere.
    if (seen == null || compareVersions(seen, appVersion) < 0) {
      await markSeen();
    } else if (settings.releaseNotesSeen != seen) {
      await settings.setReleaseNotesSeen(seen);
    }
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => ReleaseNotesDialog(notes: notes),
  );
  await markSeen();
}

class ReleaseNotesDialog extends StatelessWidget {
  const ReleaseNotesDialog({super.key, required this.notes});

  final List<ReleaseNote> notes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.new_releases_outlined),
      title: const Text('Novidades'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final n in notes) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 6),
                  child: Text(
                    'Versão ${n.version}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.muted,
                    ),
                  ),
                ),
                for (final item in n.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

/// For tests: check again as if the app had just started.
@visibleForTesting
void resetReleaseNotesCheck() => _checked = false;
