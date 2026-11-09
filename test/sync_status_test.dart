import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:livre_servico_app/screens/widgets/sync_status.dart';
import 'package:livre_servico_app/services/sync_service.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_PT'));

  test('pendingText', () {
    expect(pendingText(0), 'Tudo enviado.');
    expect(pendingText(1), '1 alteração por enviar.');
    expect(pendingText(4), '4 alterações por enviar.');
  });

  test('syncStatusText says the day only when it was not today', () {
    final sync = SyncService.instance;
    expect(syncStatusText(sync), 'Ainda não sincronizou.');
    sync.lastSyncedAt = DateTime(2026, 11, 9, 14, 2);
    expect(
      syncStatusText(sync, now: DateTime(2026, 11, 9, 18)),
      'Sincronizado às 14:02.',
    );
    expect(
      syncStatusText(sync, now: DateTime(2026, 11, 10, 8)),
      'Sincronizado a 09/11 às 14:02.',
    );
    sync.lastSyncedAt = null;
  });
}
