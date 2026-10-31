import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// A fresh SQLite database in the browser's memory (the same `sqlite3.wasm`
/// the saved one uses), for the demo.
Future<QueryExecutor> openDemoDatabase() async {
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  return WasmDatabase.inMemory(sqlite3);
}
