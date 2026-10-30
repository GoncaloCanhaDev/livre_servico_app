import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/horario.dart';
import '../models/horario_codigos.dart';
import '../models/horario_mes.dart';
import '../models/teams.dart';
import 'local_db.dart';
import 'person_service.dart';

/// What an import brought: the months it saved or deleted, and per month
/// the names that matched nobody in Livre Serviço.
typedef HorariosImport = ({
  List<String> meses,
  Map<String, List<String>> unmatched,
});

/// The Livre Serviço horários: months in [LocalDb] ([HorarioMes]), codes and
/// absence names in shared preferences (defaults until a file brings its
/// own), and an [index] linking each line to its person. They are edited
/// as a JSON file: [exportFile], edit, [pickAndImport].
class HorarioService extends ChangeNotifier {
  HorarioService._();
  static final instance = HorarioService._();

  static const _codigosKey = 'horario_codigos';
  static const _ausenciasKey = 'horario_ausencias';

  LocalDb get _db => LocalDb.instance;
  late SharedPreferences _prefs;

  Horarios _horarios = Horarios.empty;
  Horarios get horarios => _horarios;

  HorarioIndex _index = HorarioIndex(Horarios.empty, const []);
  HorarioIndex get index => _index;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    var codigos = defaultHorarioCodigos();
    var ausencias = Map.of(defaultHorarioAusencias);
    try {
      final saved = parseHorariosFile({
        if (_prefs.getString(_codigosKey) case final c?)
          'codigos': jsonDecode(c),
        if (_prefs.getString(_ausenciasKey) case final a?)
          'ausencias': jsonDecode(a),
      }, current: Horarios.empty);
      codigos = saved.codigos ?? codigos;
      ausencias = saved.ausencias ?? ausencias;
    } on FormatException {
      // Unreadable saved codes: keep the defaults rather than fail startup.
    }
    final months = await _db.horarioMeses.all();
    _horarios = Horarios(
      codigos: codigos,
      ausencias: ausencias,
      meses: {
        for (final m in months)
          m.mes: {for (final l in m.linhas) l.nome: l.codigos},
      },
    );
    await _reindex();
    PersonService.instance.addListener(_reindex);
  }

  /// Links each line to a Livre Serviço person again (after an import or a
  /// change in Pessoas).
  Future<void> _reindex() async {
    final people = await PersonService.instance.all();
    _index = HorarioIndex(_horarios, [
      for (final p in people)
        if (p.team == livreServicoId) p,
    ]);
    notifyListeners();
  }

  /// Saves [file]: its codes and absence names when present, and its months
  /// (null deletes one). With [replaceAll] (restoring a backup) every other
  /// month is removed first.
  Future<HorariosImport> apply(
    HorariosFile file, {
    bool replaceAll = false,
  }) async {
    final base = replaceAll
        ? Horarios(
            codigos: _horarios.codigos,
            ausencias: _horarios.ausencias,
            meses: const {},
          )
        : _horarios;
    final next = mergeHorarios(base, file);
    if (file.codigos case final c?) {
      await _prefs.setString(
        _codigosKey,
        jsonEncode({for (final e in c.entries) e.key: e.value.toJson()}),
      );
    }
    if (file.ausencias case final a?) {
      await _prefs.setString(_ausenciasKey, jsonEncode(a));
    }
    await _db.transaction(() async {
      if (replaceAll) await _db.horarioMeses.clear();
      for (final e in file.meses.entries) {
        // One row per month: a month in the file replaces the saved one.
        await _db.horarioMeses.deleteWhere((m) => m.mes == e.key);
        if (e.value case final rows?) {
          await _db.horarioMeses.put(
            HorarioMes()
              ..mes = e.key
              ..linhas = [
                for (final r in rows.entries)
                  HorarioLinha()
                    ..nome = r.key
                    ..codigos = r.value,
              ],
          );
        }
      }
    });
    _horarios = next;
    await _reindex();
    final months = file.meses.keys.toList()..sort();
    return (
      meses: months,
      unmatched: {
        for (final m in months)
          if (_index.unmatched(m) case final names when names.isNotEmpty)
            m: names,
      },
    );
  }

  /// Removes every saved month (codes are kept), for "Apagar tudo".
  Future<void> clearMonths() async {
    await _db.horarioMeses.clear();
    _horarios = Horarios(
      codigos: _horarios.codigos,
      ausencias: _horarios.ausencias,
      meses: const {},
    );
    await _reindex();
  }

  /// Shares every saved horário as an indented `horarios.json`.
  Future<void> exportFile() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/horarios.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(_horarios.toJson()),
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Horários - Livre Serviço',
      ),
    );
  }

  /// Picks a horários file and applies it; null when nothing was picked.
  /// Throws a [FormatException] saying what is wrong in the file, before
  /// anything is saved.
  Future<HorariosImport?> pickAndImport() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Ficheiro vazio ou inacessível.');
    }
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Era esperado um objeto { } de horários.');
    }
    return apply(parseHorariosFile(decoded, current: _horarios));
  }
}
