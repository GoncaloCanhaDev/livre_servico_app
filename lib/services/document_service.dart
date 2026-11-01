import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/app_document.dart';
import 'local_db.dart';

/// Where the Documentos are kept online (the `documents` table and bucket
/// in Supabase), or in memory in the demo and the tests.
abstract interface class DocumentRemote {
  Future<List<AppDocument>> list();
  Future<Uint8List> download(String fileName);

  /// The admin only, like [rename] and [remove].
  Future<void> add(String title, Uint8List bytes);
  Future<void> rename(String id, String title);
  Future<void> remove(AppDocument doc);
}

/// The Documentos: PDFs the app's admin keeps for every store, read by
/// everyone with a store. The list is kept on the device (so it shows
/// offline) and refreshed when the page opens; each PDF is downloaded the
/// first time it is opened and kept in `LocalDb`'s files, so it opens again
/// offline. Files of documents no longer listed are dropped.
class DocumentService extends ChangeNotifier {
  DocumentService._();
  static final DocumentService instance = DocumentService._();

  static const _cacheKey = 'documents_cache';

  /// Set while a store is connected (see `AccountService`), or in the demo.
  DocumentRemote? remote;

  /// Whether this account may add, rename and remove documents (the admin).
  bool canManage = false;

  List<AppDocument> _documents = const [];
  bool _loaded = false;

  /// The documents, by title.
  List<AppDocument> get documents => _documents;

  /// Whether the documents can be fetched (a store is connected).
  bool get isAvailable => remote != null;

  Future<void> _loadCache() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return;
    try {
      _documents = sortedDocuments([
        for (final j in (jsonDecode(raw) as List).cast<Map<String, dynamic>>())
          AppDocument.fromJson(j),
      ]);
    } catch (_) {
      _documents = const [];
    }
  }

  /// The documents kept here, then the ones online. Throws when they can't
  /// be fetched (offline), after showing the ones kept here.
  Future<void> refresh() async {
    await _loadCache();
    notifyListeners();
    final r = remote;
    if (r == null) return;
    final docs = sortedDocuments(await r.list());
    _documents = docs;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode([for (final d in docs) d.toJson()]),
    );
    await LocalDb.instance.keepOnlyFiles({for (final d in docs) d.fileName});
    notifyListeners();
  }

  /// Whether [doc]'s PDF is on this device already.
  Future<bool> isKept(AppDocument doc) async =>
      await LocalDb.instance.file(doc.fileName) != null;

  /// [doc]'s PDF: from here, or downloaded (and kept). Throws when it isn't
  /// here and can't be downloaded.
  Future<Uint8List> open(AppDocument doc) async {
    if (await LocalDb.instance.file(doc.fileName) case final bytes?) {
      return bytes;
    }
    final r = remote;
    if (r == null) throw StateError('Sem ligação à loja.');
    final bytes = await r.download(doc.fileName);
    await LocalDb.instance.putFile(doc.fileName, bytes);
    return bytes;
  }

  Future<void> add(String title, Uint8List bytes) async {
    await remote!.add(title.trim(), bytes);
    await refresh();
  }

  Future<void> rename(AppDocument doc, String title) async {
    await remote!.rename(doc.id, title.trim());
    await refresh();
  }

  Future<void> remove(AppDocument doc) async {
    await remote!.remove(doc);
    await refresh();
  }

  /// Forgets everything (for the tests).
  @visibleForTesting
  void reset() {
    remote = null;
    canManage = false;
    _documents = const [];
    _loaded = false;
  }
}

/// A [DocumentRemote] in memory: the demo's example documents, and the
/// tests'.
class MemoryDocumentRemote implements DocumentRemote {
  MemoryDocumentRemote([Map<String, Uint8List> initial = const {}]) {
    initial.forEach(_put);
  }

  final _docs = <String, AppDocument>{};
  final _files = <String, Uint8List>{};

  /// Set to make every call fail, as if offline.
  bool offline = false;

  void _check() {
    if (offline) throw StateError('offline');
  }

  void _put(String title, Uint8List bytes) {
    final id = const Uuid().v4();
    final doc = AppDocument(
      id: id,
      title: title,
      fileName: '$id.pdf',
      size: bytes.length,
      updatedAt: DateTime.now(),
    );
    _docs[id] = doc;
    _files[doc.fileName] = bytes;
  }

  @override
  Future<List<AppDocument>> list() async {
    _check();
    return [..._docs.values];
  }

  @override
  Future<Uint8List> download(String fileName) async {
    _check();
    final bytes = _files[fileName];
    if (bytes == null) throw StateError('Documento não encontrado.');
    return bytes;
  }

  @override
  Future<void> add(String title, Uint8List bytes) async {
    _check();
    _put(title, bytes);
  }

  @override
  Future<void> rename(String id, String title) async {
    _check();
    final d = _docs[id];
    if (d != null) {
      _docs[id] = d.copyWith(title: title, updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> remove(AppDocument doc) async {
    _check();
    _docs.remove(doc.id);
    _files.remove(doc.fileName);
  }
}
