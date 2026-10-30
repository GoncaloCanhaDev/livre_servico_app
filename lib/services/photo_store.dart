import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'legacy_photos_stub.dart' if (dart.library.io) 'legacy_photos_io.dart';
import 'local_db.dart';
import 'sync_meta.dart';

/// Where a connected store keeps its photos online (Supabase Storage).
abstract interface class PhotoRemote {
  Future<void> upload(String name, Uint8List bytes);
  Future<Uint8List> download(String name);
}

/// The photos of people and Informações entries. A row holds a reference,
/// `photo:<name>`; the bytes are in the local database (so photos work the
/// same on the phone and in the browser) and, once synced, online under
/// the store ([remote]). A device that doesn't have a photo yet downloads
/// it the first time it is shown. Photos never change: a new one gets a new
/// name.
class PhotoStore {
  PhotoStore._();
  static final PhotoStore instance = PhotoStore._();

  static const _prefix = 'photo:';
  static const _migratedKey = 'photosMigrated';

  /// Set while a store is connected (see `AccountService`).
  PhotoRemote? remote;

  LocalDb get _db => LocalDb.instance;

  static bool isRef(String? value) => value?.startsWith(_prefix) ?? false;

  static String _name(String ref) => ref.substring(_prefix.length);

  /// Saves [bytes] as a new photo; returns its reference.
  Future<String> add(Uint8List bytes) async {
    final name = '${const Uuid().v4()}.${_isPng(bytes) ? 'png' : 'jpg'}';
    await _db.putPhoto(name, bytes, uploaded: false);
    return '$_prefix$name';
  }

  /// The photo's bytes: from here, or downloaded from the store (and kept);
  /// null when neither has it.
  Future<Uint8List?> load(String ref) async {
    if (!isRef(ref)) return null;
    final name = _name(ref);
    if (await _db.photo(name) case final bytes?) return bytes;
    final r = remote;
    if (r == null) return null;
    try {
      final bytes = await r.download(name);
      await _db.putPhoto(name, bytes, uploaded: true);
      return bytes;
    } catch (_) {
      // Offline, or not uploaded yet by the device that took it.
      return null;
    }
  }

  /// Removes the photo from this device. Online it stays (other devices
  /// may still show rows that point to it until they sync).
  Future<void> remove(String ref) async {
    if (isRef(ref)) await _db.deletePhoto(_name(ref));
  }

  /// Uploads the photos taken here; run with each sync.
  Future<void> uploadPending() async {
    final r = remote;
    if (r == null) return;
    for (final name in await _db.photosToUpload()) {
      final bytes = await _db.photo(name);
      if (bytes == null) continue;
      await r.upload(name, bytes);
      await _db.markPhotoUploaded(name);
    }
  }

  /// Moves photos saved as files by earlier versions into the store, once:
  /// rows then point to them by reference (and are stamped, so the change
  /// syncs). A file that is gone is dropped from its row.
  Future<void> migrateLegacy() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migratedKey) == true) return;
    final moved = <String>[];
    Future<String?> move(String path) async {
      final bytes = await readLegacyPhoto(path);
      if (bytes == null) return null;
      moved.add(path);
      return add(bytes);
    }

    final people = [
      for (final p in await _db.persons.all())
        if (p.photoPath case final path? when !isRef(path)) p,
    ];
    for (final p in people) {
      p.photoPath = await move(p.photoPath!);
      SyncMeta.stamp(p);
    }
    await _db.persons.putAll(people);

    final entries = [
      for (final e in await _db.infoEntries.all())
        if (e.photoPaths.any((path) => !isRef(path))) e,
    ];
    for (final e in entries) {
      e.photoPaths = [
        for (final path in e.photoPaths)
          ?(isRef(path) ? path : await move(path)),
      ];
      SyncMeta.stamp(e);
    }
    await _db.infoEntries.putAll(entries);

    for (final path in moved) {
      await deleteLegacyPhoto(path);
    }
    await prefs.setBool(_migratedKey, true);
  }

  static bool _isPng(Uint8List b) =>
      b.length > 3 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E;
}

/// The image of a [PhotoStore] reference, for `Image`, `CircleAvatar`...
/// Fails (showing the widget's error state) when the photo can't be had.
@immutable
class PhotoImage extends ImageProvider<PhotoImage> {
  const PhotoImage(this.ref);

  final String ref;

  @override
  Future<PhotoImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(PhotoImage key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(codec: _load(decode), scale: 1);

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await PhotoStore.instance.load(ref);
    if (bytes == null) throw StateError('Foto indisponível: $ref');
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) => other is PhotoImage && other.ref == ref;

  @override
  int get hashCode => ref.hashCode;
}
