import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/account_service.dart';
import '../../services/local_db.dart';
import '../../services/sync_service.dart';
import '../../theme.dart';
import '../diagnostic_screen.dart';

/// How the last sync went, e.g. "Sincronizado às 14:02." (Conta and the
/// sync sheet).
String syncStatusText(SyncService sync, {DateTime? now}) {
  if (sync.isSyncing) return 'A sincronizar…';
  if (sync.lastError case final e?) {
    return 'Não sincronizou: ${accountErrorText(e)}';
  }
  if (sync.lastSyncedAt case final t?) {
    final today = now ?? DateTime.now();
    final sameDay =
        t.year == today.year && t.month == today.month && t.day == today.day;
    final time = DateFormat.Hm('pt_PT').format(t);
    return sameDay
        ? 'Sincronizado às $time.'
        : 'Sincronizado a ${DateFormat('dd/MM', 'pt_PT').format(t)} às $time.';
  }
  return 'Ainda não sincronizou.';
}

/// "Tudo enviado." or how many changes and photos this device still has
/// to send.
String pendingText(int changes, {int photos = 0}) {
  if (changes == 0 && photos == 0) return 'Tudo enviado.';
  final parts = [
    if (changes == 1) '1 alteração',
    if (changes > 1) '$changes alterações',
    if (photos == 1) '1 foto',
    if (photos > 1) '$photos fotos',
  ];
  return '${parts.join(' e ')} por enviar.';
}

/// Rebuilds [builder] when a sync starts or ends and when the app saves
/// something, with the number of changes waiting to be sent.
class _SyncListener extends StatefulWidget {
  const _SyncListener({required this.builder});

  /// [pending] counts the changes and the photos waiting to be sent.
  final Widget Function(BuildContext context, SyncService sync, int pending)
  builder;

  @override
  State<_SyncListener> createState() => _SyncListenerState();
}

class _SyncListenerState extends State<_SyncListener> {
  late final StreamSubscription<String> _writes;

  @override
  void initState() {
    super.initState();
    SyncService.instance.addListener(_changed);
    _writes = LocalDb.localWrites.listen((_) => _changed());
  }

  @override
  void dispose() {
    SyncService.instance.removeListener(_changed);
    _writes.cancel();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sync = SyncService.instance;
    final pending = sync.pendingCount + sync.pendingPhotos;
    return widget.builder(context, sync, pending);
  }
}

/// The app bar's cloud while a store is connected: done, sending, changes
/// waiting (with their count) or offline. Tapping it opens [_SyncSheet].
class SyncStatusButton extends StatelessWidget {
  const SyncStatusButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SyncListener(
      builder: (context, sync, pending) {
        if (!sync.isConnected) return const SizedBox.shrink();
        final (icon, tooltip) = sync.isSyncing
            ? (Icons.cloud_sync, 'A sincronizar')
            : sync.lastError != null
            ? (Icons.cloud_off, 'Sem ligação')
            : pending > 0
            ? (Icons.cloud_upload, 'Por enviar')
            : (Icons.cloud_done, 'Sincronizado');
        return IconButton(
          tooltip: tooltip,
          icon: Badge.count(
            count: pending,
            isLabelVisible: pending > 0,
            child: Icon(
              icon,
              // Amber stands out on the black app bar in both themes.
              color: sync.lastError != null ? Colors.amber.shade400 : null,
            ),
          ),
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (_) => const _SyncSheet(),
          ),
        );
      },
    );
  }
}

class _SyncSheet extends StatelessWidget {
  const _SyncSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _SyncListener(
        builder: (context, sync, pending) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sincronização',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  sync.lastError == null ? Icons.cloud_done : Icons.cloud_off,
                  color: sync.lastError == null ? null : context.warningText,
                ),
                title: Text(syncStatusText(sync)),
              ),
              if (sync.canPush)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    pending == 0 ? Icons.check_circle_outline : Icons.upload,
                  ),
                  title: Text(
                    pendingText(
                      sync.pendingCount,
                      photos: sync.pendingPhotos,
                    ),
                  ),
                  subtitle: pending == 0
                      ? null
                      : Text(
                          'Ficam guardadas neste aparelho e são enviadas '
                          'assim que houver ligação.',
                          style: TextStyle(color: context.muted),
                        ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: sync.isSyncing ? null : sync.syncNow,
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar agora'),
              ),
              TextButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute(builder: (_) => const DiagnosticScreen()),
                  );
                },
                child: const Text('Ver diagnóstico'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
