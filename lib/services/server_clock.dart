/// The server's time, as this phone best knows it: its own clock corrected
/// by how far it was from the server's at the last sync ([offset], measured
/// by `SyncService` and kept in `SettingsService.serverClockOffset`, so it
/// also holds offline). Every save is stamped with it (`SyncMeta`), and so
/// is every task marked or corrected (`TaskStamp`), so phones with a wrong
/// clock still compare fairly. Before any sync, the phone's own time.
class ServerClock {
  ServerClock._();

  static Duration offset = Duration.zero;

  static DateTime now() => DateTime.now().add(offset);

  /// The offset from one round trip: the server said [server] between
  /// [sent] and [received] (by this phone's clock).
  static Duration measure(DateTime sent, DateTime server, DateTime received) {
    final mid = sent.add(received.difference(sent) ~/ 2);
    return server.difference(mid);
  }
}

/// A `SyncRemote` that can tell the server's time (`server_now`).
abstract interface class ServerTimeSource {
  Future<DateTime> serverNow();
}
