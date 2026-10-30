import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/info_contacts.dart';
import '../models/info_entry.dart';
import 'local_db.dart';
import 'photo_store.dart';
import 'sync_meta.dart';

/// Reads and writes the Informações entries and their photos.
class InfoService {
  InfoService._();
  static final InfoService instance = InfoService._();

  LocalDb get _db => LocalDb.instance;

  /// Every entry that hasn't been deleted, oldest first.
  Future<List<InfoEntry>> all() async =>
      (await _db.infoEntries.all())
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<void> save(InfoEntry e) async {
    SyncMeta.stamp(e);
    await _db.infoEntries.put(e);
  }

  /// Soft-deletes [e] and removes its photos from this device.
  Future<void> delete(InfoEntry e) async {
    SyncMeta.softDelete(e);
    await _db.infoEntries.put(e);
    for (final path in e.photoPaths) {
      deletePhoto(path);
    }
  }

  /// Renames the contact group [from] to [to] on every contact in it.
  Future<void> renameGroup(String from, String to) async {
    final rows = [
      for (final e in await all())
        if (isContact(e) && contactGroupOf(e) == from) e,
    ];
    for (final e in rows) {
      e
        ..normalizeContactInPlace()
        ..group = to;
      SyncMeta.stamp(e);
    }
    await _db.infoEntries.putAll(rows);
  }

  /// Saves a picked photo; returns its reference (see [PhotoStore]).
  Future<String> storePhoto(Uint8List bytes) => PhotoStore.instance.add(bytes);

  void deletePhoto(String ref) => unawaited(PhotoStore.instance.remove(ref));
}
