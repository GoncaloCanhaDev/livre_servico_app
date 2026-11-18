import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/horario.dart';
import '../models/horario_xlsx.dart';
import '../models/person.dart';
import 'local_db.dart';
import 'sync_meta.dart';

/// The store's horários, one [HorarioMes] per month imported from its Excel
/// file, and the [index] the screens and the planning helpers read.
class HorarioService extends ChangeNotifier {
  HorarioService._() {
    LocalDb.listenRemote(const {'HorarioMes'}, load);
  }
  static final HorarioService instance = HorarioService._();

  LocalDb get _db => LocalDb.instance;

  HorarioIndex _index = HorarioIndex.empty;

  /// What each person does each day, from the months loaded by [load].
  HorarioIndex get index => _index;

  /// Reads the months again and rebuilds [index]; called at startup, after
  /// changes here and when the server sends some.
  Future<void> load() async {
    _index = HorarioIndex(await _db.horarioMeses.all());
    notifyListeners();
  }

  /// Newest month first.
  Future<List<HorarioMes>> months() async =>
      (await _db.horarioMeses.all())
        ..sort((a, b) => b.month.compareTo(a.month));

  /// Saves [parsed] with each Excel name linked to its person in [matches]
  /// (none: null), replacing that month if it was imported before.
  Future<void> save(
    ParsedHorario parsed,
    Map<String, Person?> matches, {
    required String importedBy,
  }) async {
    final key = monthKey(parsed.month);
    final old = await _db.horarioMeses.where(
      (m) => monthKey(m.month) == key,
    );
    final row = HorarioMes.fromParsed(parsed, {
      for (final e in matches.entries) e.key: e.value?.syncUuid,
    }, importedBy: importedBy);
    // Online the month is one row (keyed by the month): keep its uuid.
    if (old.isNotEmpty) {
      row
        ..id = old.first.id
        ..syncUuid = old.first.syncUuid;
    }
    SyncMeta.stamp(row);
    await _db.transaction(() async {
      await _db.horarioMeses.put(row);
      for (final extra in old.skip(1)) {
        await _db.horarioMeses.softDelete(extra.id);
      }
    });
    await load();
  }

  Future<void> delete(DateTime month) async {
    final key = monthKey(month);
    for (final m in await _db.horarioMeses.where(
      (m) => monthKey(m.month) == key,
    )) {
      await _db.horarioMeses.softDelete(m.id);
    }
    await load();
  }

  /// Asks for the Excel file and reads it (in the background); null when
  /// cancelled. Throws a [FormatException] when it can't be read.
  Future<ParsedHorario?> pickFile() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Ficheiro vazio ou inacessível.');
    }
    return compute(parseHorarioXlsx, bytes);
  }
}
