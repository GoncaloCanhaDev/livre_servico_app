import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/local_row.dart';
import '../models/vasilhame.dart';
import 'local_db.dart';
import 'settings_service.dart';
import 'share_file.dart';
import 'sync_engine.dart';

class BackupService {
  BackupService._();
  static final instance = BackupService._();

  static const _formatVersion = 1;

  LocalDb get _db => LocalDb.instance;

  /// The collections a backup carries, by their key in its "collections".
  /// (Backups from before 0.61.0 also have "horarios", now ignored.)
  List<LocalCollection<SyncedRow>> get _backedUp => _db.collections;

  Future<ShareResult> exportToFile() async {
    final payload = await _buildPayload();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    // Indented so the file can be edited by hand (e.g. its "vasilhame").
    final result = await shareJsonFile(
      const JsonEncoder.withIndent('  ').convert(payload),
      name: 'livre_servico_backup_$timestamp.json',
      subject: 'Cópia de segurança - Livre Serviço',
    );
    return result;
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
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    final settings = SettingsService.instance;
    return {
      'version': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      // First, so it is easy to find and edit by hand.
      'vasilhame': [for (final v in settings.vasilhame) v.toJson()],
      'settings': {'visualGoal': settings.visualGoal},
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
    // The import replaced rows here without the server: the next sync
    // pushes them all and pulls the store's rows again, keeping whichever
    // copy of each was saved last.
    await SyncEngine.forgetCursors(await SharedPreferences.getInstance());

    final settings = SettingsService.instance;
    if (vasilhame != null) await settings.setVasilhame(vasilhame);
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
