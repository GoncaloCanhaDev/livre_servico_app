import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/info_contacts.dart';
import '../models/info_entry.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

/// Reads and writes the Informações entries and their photos.
class InfoService {
  InfoService._();
  static final InfoService instance = InfoService._();

  Isar get _isar => ShiftService.instance.isar;

  /// Every entry that hasn't been deleted, oldest first.
  Future<List<InfoEntry>> all() async {
    final rows = await _isar.infoEntrys
        .filter()
        .syncDeletedAtIsNull()
        .findAll();
    return rows..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> save(InfoEntry e) async {
    SyncMeta.stamp(e);
    await _isar.writeTxn(() => _isar.infoEntrys.put(e));
  }

  /// Soft-deletes [e] and removes its photo files.
  Future<void> delete(InfoEntry e) async {
    SyncMeta.softDelete(e);
    await _isar.writeTxn(() => _isar.infoEntrys.put(e));
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
    await _isar.writeTxn(() => _isar.infoEntrys.putAll(rows));
  }

  /// Copies the picked photo at [sourcePath] into the app's folder and
  /// returns the copy's path.
  Future<String> storePhoto(String sourcePath) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/info_photos');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
    final dest = '${dir.path}/${const Uuid().v4()}.$ext';
    await File(sourcePath).copy(dest);
    return dest;
  }

  void deletePhoto(String path) {
    try {
      File(path).deleteSync();
    } catch (_) {}
  }
}
