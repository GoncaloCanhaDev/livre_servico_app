import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// A fresh SQLite database in the browser's memory (the same `sqlite3.wasm`
/// the saved one uses), for the demo. The wasm build has no file system of
/// its own: one kept in memory is registered as the default, or opening
/// fails with "no such vfs".
Future<QueryExecutor> openDemoDatabase() async {
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return WasmDatabase.inMemory(sqlite3);
}
