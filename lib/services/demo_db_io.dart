import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// A fresh SQLite database in memory, for the demo (and its tests).
Future<QueryExecutor> openDemoDatabase() async => NativeDatabase.memory();
