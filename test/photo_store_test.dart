import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/info_entry.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/photo_store.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The store's photos online, in memory.
class FakePhotoRemote implements PhotoRemote {
  final files = <String, Uint8List>{};

  @override
  Future<void> upload(String name, Uint8List bytes) async =>
      files[name] = bytes;

  @override
  Future<Uint8List> download(String name) async =>
      files[name] ?? (throw StateError('404'));
}

final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 1, 2, 3]);

void main() {
  final store = PhotoStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalDb.init(executor: NativeDatabase.memory());
    store.remote = null;
  });
  tearDown(() => LocalDb.instance.close());

  test('a saved photo loads back by its reference', () async {
    final ref = await store.add(jpeg);
    expect(PhotoStore.isRef(ref), isTrue);
    expect(ref, endsWith('.jpg'));
    expect(await store.load(ref), jpeg);

    await store.remove(ref);
    expect(await store.load(ref), isNull);
  });

  test('photos are uploaded once, then downloaded where missing', () async {
    final remote = FakePhotoRemote();
    store.remote = remote;
    final ref = await store.add(jpeg);

    await store.uploadPending();
    expect(remote.files.values.single, jpeg);
    remote.files.clear();
    await store.uploadPending();
    expect(remote.files, isEmpty);

    // Another device: only the store has it.
    await store.remove(ref);
    remote.files[ref.substring('photo:'.length)] = jpeg;
    expect(await store.load(ref), jpeg);
    remote.files.clear();
    expect(await store.load(ref), jpeg, reason: 'kept after downloading');
  });

  test('a photo nobody has loads as null', () async {
    store.remote = FakePhotoRemote();
    expect(await store.load('photo:gone.jpg'), isNull);
    expect(await store.load('/old/path.jpg'), isNull);
  });

  test('photo files from earlier versions move into the store', () async {
    final dir = await Directory.systemTemp.createTemp('photos');
    addTearDown(() => dir.delete(recursive: true));
    final personFile = File('${dir.path}/ana.jpg')..writeAsBytesSync(jpeg);
    final infoFile = File('${dir.path}/info.jpg')..writeAsBytesSync(jpeg);

    final ana = Person()
      ..fullName = 'Ana'
      ..createdAt = DateTime(2026)
      ..photoPath = personFile.path;
    SyncMeta.stamp(ana);
    final rui = Person()
      ..fullName = 'Rui'
      ..createdAt = DateTime(2026)
      ..photoPath = '${dir.path}/missing.jpg';
    SyncMeta.stamp(rui);
    await LocalDb.instance.persons.putAll([ana, rui]);
    final entry = InfoEntry()
      ..bucket = 'protocolos'
      ..title = 'X'
      ..description = ''
      ..createdAt = DateTime(2026)
      ..photoPaths = [infoFile.path, '${dir.path}/missing.jpg'];
    SyncMeta.stamp(entry);
    await LocalDb.instance.infoEntries.put(entry);

    await store.migrateLegacy();

    final people = {
      for (final p in await LocalDb.instance.persons.all()) p.fullName: p,
    };
    expect(await store.load(people['Ana']!.photoPath!), jpeg);
    expect(people['Rui']!.photoPath, isNull);
    final photos = (await LocalDb.instance.infoEntries.all()).single.photoPaths;
    expect(photos, hasLength(1));
    expect(await store.load(photos.single), jpeg);
    expect(personFile.existsSync(), isFalse);
    expect(infoFile.existsSync(), isFalse);

    // Only once.
    ana.photoPath = '${dir.path}/again.jpg';
    await LocalDb.instance.persons.put(ana);
    await store.migrateLegacy();
    expect(
      (await LocalDb.instance.persons.get(ana.id))!.photoPath,
      '${dir.path}/again.jpg',
    );
  });
}
