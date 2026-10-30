import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/horario.dart';
import '../models/local_row.dart';
import '../models/vasilhame.dart';
import 'horario_service.dart';
import 'local_db.dart';
import 'settings_service.dart';

class BackupService {
  BackupService._();
  static final instance = BackupService._();

  static const _formatVersion = 1;

  LocalDb get _db => LocalDb.instance;

  /// The collections a backup carries, by their key in its "collections"
  /// (the horário months travel in "horarios" instead).
  List<LocalCollection<SyncedRow>> get _backedUp => [
    for (final c in _db.collections)
      if (c != _db.horarioMeses) c,
  ];

  static const _lastBackupAtKey = 'last_backup_at';
  static const _lastPromptAtKey = 'last_backup_prompt_at';
  static const _overdueAfter = Duration(days: 7);
  static const _rePromptAfter = Duration(days: 1);

  Future<ShareResult> exportToFile() async {
    final payload = await _buildPayload();
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File('${dir.path}/livre_servico_backup_$timestamp.json');
    // Indented so the file can be edited by hand (e.g. its "vasilhame").
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Cópia de segurança - Livre Serviço',
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupAtKey, DateTime.now().toIso8601String());
    return result;
  }

  Future<DateTime?> lastBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastBackupAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setLastPromptAt(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPromptAtKey, time.toIso8601String());
  }

  Future<bool> isBackupOverdue() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackupRaw = prefs.getString(_lastBackupAtKey);
    final lastBackup = lastBackupRaw == null
        ? null
        : DateTime.tryParse(lastBackupRaw);
    if (lastBackup != null &&
        DateTime.now().difference(lastBackup) < _overdueAfter) {
      return false;
    }
    final lastPromptRaw = prefs.getString(_lastPromptAtKey);
    final lastPrompt = lastPromptRaw == null
        ? null
        : DateTime.tryParse(lastPromptRaw);
    if (lastPrompt != null &&
        DateTime.now().difference(lastPrompt) < _rePromptAfter) {
      return false;
    }
    return true;
  }

  /// Returns true if an import was performed.
  Future<bool> pickAndImport() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null) return false;
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Ficheiro vazio ou inacessível.');
    }
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Formato inválido.');
    }
    await _applyPayload(decoded);
    return true;
  }

  Future<void> clearAll() async {
    for (final c in _backedUp) {
      await c.softDeleteAll();
    }
    await HorarioService.instance.clearMonths();
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    final settings = SettingsService.instance;
    return {
      'version': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      // First, so it is easy to find and edit by hand.
      'vasilhame': [for (final v in settings.vasilhame) v.toJson()],
      'settings': {'visualGoal': settings.visualGoal},
      'horarios': HorarioService.instance.horarios.toJson(),
      'collections': {for (final c in _backedUp) c.name: c.exportJson()},
    };
  }

  Future<void> _applyPayload(Map<String, dynamic> payload) async {
    final version = payload['version'];
    if (version is! int || version > _formatVersion) {
      throw FormatException(
        'Versão da cópia de segurança não suportada: $version',
      );
    }
    final raw = payload['collections'];
    if (raw is! Map) {
      throw const FormatException('Cópia de segurança sem coleções.');
    }

    // Checked before anything is replaced, so a mistake changes nothing.
    final vasilhame = vasilhameFromBackup(payload);
    final horarios = switch (payload['horarios']) {
      final Map<String, dynamic> h => parseHorariosFile(
        h,
        current: HorarioService.instance.horarios,
      ),
      _ => null,
    };

    // Replaces each collection with the file's rows; a collection the file
    // doesn't have (older backups) is left as it is.
    await _db.transaction(() async {
      for (final c in _backedUp) {
        final v = raw[c.name];
        if (v is! List) continue;
        final rows = mapsFromJson(v);
        await c.importJson(
          c == _db.persons ? rows.map(personJsonForImport).toList() : rows,
        );
      }
    });
    await _db.backfillSync();

    final settings = SettingsService.instance;
    if (vasilhame != null) await settings.setVasilhame(vasilhame);
    if (horarios != null) {
      await HorarioService.instance.apply(horarios, replaceAll: true);
    }
    if (payload['settings'] case {'visualGoal': final int goal}) {
      await settings.setVisualGoal(goal);
    }
  }
}

/// [json] (a Person row from a backup file) without the fields removed in
/// 0.32.0 (cargo and manager links), so older backups still import.
Map<String, dynamic> personJsonForImport(Map<String, dynamic> json) =>
    Map.of(json)
      ..remove('role')
      ..remove('managerUuid')
      ..remove('managerUuids');
