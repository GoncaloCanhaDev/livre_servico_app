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
    LocalDb.listenRemote(const {'HorarioMes', 'HorarioAlteracao'}, load);
  }
  static final HorarioService instance = HorarioService._();

  LocalDb get _db => LocalDb.instance;

  HorarioIndex _index = HorarioIndex.empty;

  /// What each person does each day, from the months loaded by [load].
  HorarioIndex get index => _index;

  /// Reads the months again and rebuilds [index]; called at startup, after
  /// changes here and when the server sends some.
  Future<void> load() async {
    _index = HorarioIndex(
      await _db.horarioMeses.all(),
      changes: await _db.horarioAlteracoes.all(),
    );
    notifyListeners();
  }

  /// Newest month first.
  Future<List<HorarioMes>> months() async =>
      (await _db.horarioMeses.all())
        ..sort((a, b) => b.month.compareTo(a.month));

  /// Saves [parsed] with each Excel name linked to its person in [matches]
  /// (none: null), replacing that month if it was imported before.
  ///
  /// The changes made in the app to that month's days stay, except those
  /// whose key ([alteracaoKey]) is in [drop] and those the file now agrees
  /// with; the kept ones remember the new file's code.
  Future<void> save(
    ParsedHorario parsed,
    Map<String, Person?> matches, {
    required String importedBy,
    Set<String> drop = const {},
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
    final personIds = {
      for (final e in matches.entries) e.key: e.value?.syncUuid,
    };
    final against = {
      for (final a in changesAgainstFile(
        parsed,
        personIds,
        await _db.horarioAlteracoes.all(),
      ))
        a.change.id: a.newFileCode,
    };
    final onFile = {for (final id in personIds.values) ?id};
    final first = parsed.firstDay;
    final last = DateTime(first.year, first.month, first.day + parsed.days - 1);
    final inFile = await _db.horarioAlteracoes.where(
      (a) =>
          onFile.contains(a.personId) &&
          !a.date.isBefore(first) &&
          !a.date.isAfter(last),
    );
    await _db.transaction(() async {
      await _db.horarioMeses.put(row);
      for (final extra in old.skip(1)) {
        await _db.horarioMeses.softDelete(extra.id);
      }
      for (final a in inFile) {
        final fileCode = against[a.id];
        if (fileCode == null ||
            drop.contains(alteracaoKey(a.personId, a.date))) {
          await _db.horarioAlteracoes.softDelete(a.id);
        } else if (fileCode != a.fileCode) {
          a.fileCode = fileCode;
          SyncMeta.stamp(a);
          await _db.horarioAlteracoes.put(a);
        }
      }
    });
    await load();
  }

  /// Sets [p]'s day [day] to [code] (normalized; '' for nothing), with
  /// [entrada] and [saida] for a shift code the month doesn't know. The
  /// same as the imported file: the change goes.
  Future<void> change(
    Person p,
    DateTime day,
    String code, {
    int? entrada,
    int? saida,
    required String by,
  }) async {
    final d = DateTime(day.year, day.month, day.day);
    final c = normalizeHorarioCode(code);
    final file = _index.fileDayOf(p, d);
    final key = alteracaoKey(p.syncUuid, d);
    final existing = await _db.horarioAlteracoes.firstWhere(
      (a) => alteracaoKey(a.personId, a.date) == key,
    );
    if (c == (file?.code ?? '')) {
      if (existing != null) await _db.horarioAlteracoes.softDelete(existing.id);
      await load();
      return;
    }
    final known = _index.monthCovering(d)?.codigos[c];
    final row = (existing ?? HorarioAlteracao())
      ..date = d
      ..personId = p.syncUuid
      ..code = c
      ..entrada = known?.entrada ?? entrada
      ..saida = known?.saida ?? saida
      ..fileCode = file?.code ?? ''
      ..changedBy = by
      ..changedAt = DateTime.now();
    SyncMeta.stamp(row);
    await _db.horarioAlteracoes.put(row);
    await load();
  }

  /// Exchanges [a]'s and [b]'s days on [day].
  Future<void> swap(
    Person a,
    Person b,
    DateTime day, {
    required String by,
  }) async {
    final dayA = _index.dayOf(a, day);
    final dayB = _index.dayOf(b, day);
    await _db.transaction(() async {
      await change(
        a,
        day,
        dayB?.code ?? '',
        entrada: dayB?.entrada,
        saida: dayB?.saida,
        by: by,
      );
      await change(
        b,
        day,
        dayA?.code ?? '',
        entrada: dayA?.entrada,
        saida: dayA?.saida,
        by: by,
      );
    });
  }

  /// Back to what the imported file says on [day].
  Future<void> revert(Person p, DateTime day) async {
    final key = alteracaoKey(p.syncUuid, day);
    for (final a in await _db.horarioAlteracoes.where(
      (a) => alteracaoKey(a.personId, a.date) == key,
    )) {
      await _db.horarioAlteracoes.softDelete(a.id);
    }
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
