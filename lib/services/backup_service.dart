import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auto_list.dart';
import '../models/custom_task.dart';
import '../models/daily_tasks.dart';
import '../models/horario.dart';
import '../models/info_entry.dart';
import '../models/inventory.dart';
import '../models/opening_list.dart';
import '../models/pedido.dart';
import '../models/person.dart';
import '../models/report_list.dart';
import '../models/truck_reception.dart';
import '../models/vasilhame.dart';
import '../models/visual_list.dart';
import '../models/weekly_tasks.dart';
import 'horario_service.dart';
import 'settings_service.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class BackupService {
  BackupService._();
  static final instance = BackupService._();

  static const _formatVersion = 1;

  Isar get _isar => ShiftService.instance.isar;

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
    final result = await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/json'),
    ], subject: 'Cópia de segurança - Livre Serviço');
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return false;
    final picked = result.files.first;
    final bytes =
        picked.bytes ??
        (picked.path != null ? await File(picked.path!).readAsBytes() : null);
    if (bytes == null) {
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
    Future<void> wipe<T>(IsarCollection<T> col) async {
      final rows = await col.where().findAll();
      if (rows.isEmpty) return;
      for (final r in rows) {
        SyncMeta.softDelete(r);
      }
      await _isar.writeTxn(() => col.putAll(rows));
    }

    await wipe(_isar.truckReceptions);
    await wipe(_isar.openingLists);
    await wipe(_isar.autoLists);
    await wipe(_isar.reportLists);
    await wipe(_isar.visualLists);
    await wipe(_isar.dailyTasks);
    await wipe(_isar.weeklyTasks);
    await wipe(_isar.inventorys);
    await wipe(_isar.infoEntrys);
    await wipe(_isar.persons);
    await wipe(_isar.pedidos);
    await wipe(_isar.customTasks);
    await wipe(_isar.customTaskEntrys);
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
      'collections': {
        'TruckReception': await _isar.truckReceptions.where().exportJson(),
        'OpeningList': await _isar.openingLists.where().exportJson(),
        'AutoList': await _isar.autoLists.where().exportJson(),
        'ReportList': await _isar.reportLists.where().exportJson(),
        'VisualList': await _isar.visualLists.where().exportJson(),
        'DailyTasks': await _isar.dailyTasks.where().exportJson(),
        'WeeklyTasks': await _isar.weeklyTasks.where().exportJson(),
        'Inventory': await _isar.inventorys.where().exportJson(),
        'InfoEntry': await _isar.infoEntrys.where().exportJson(),
        'Person': await _isar.persons.where().exportJson(),
        'Pedido': await _isar.pedidos.where().exportJson(),
        'CustomTask': await _isar.customTasks.where().exportJson(),
        'CustomTaskEntry': await _isar.customTaskEntrys.where().exportJson(),
      },
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

    /// Replaces [col] with the file's [key] rows; a collection the file
    /// doesn't have (older backups) is left as it is.
    Future<void> replace<T>(
      IsarCollection<T> col,
      String key, [
      Map<String, dynamic> Function(Map<String, dynamic>)? adapt,
    ]) async {
      final v = raw[key];
      if (v is! List) return;
      final rows = v.cast<Map<String, dynamic>>();
      await col.clear();
      await col.importJson(adapt == null ? rows : rows.map(adapt).toList());
    }

    await _isar.writeTxn(() async {
      await replace(_isar.truckReceptions, 'TruckReception');
      await replace(_isar.openingLists, 'OpeningList');
      await replace(_isar.autoLists, 'AutoList');
      await replace(_isar.reportLists, 'ReportList');
      await replace(_isar.visualLists, 'VisualList');
      await replace(_isar.dailyTasks, 'DailyTasks');
      await replace(_isar.weeklyTasks, 'WeeklyTasks');
      await replace(_isar.inventorys, 'Inventory');
      await replace(_isar.infoEntrys, 'InfoEntry');
      await replace(_isar.persons, 'Person', personJsonForImport);
      await replace(_isar.pedidos, 'Pedido');
      await replace(_isar.customTasks, 'CustomTask');
      await replace(_isar.customTaskEntrys, 'CustomTaskEntry');
    });
    await ShiftService.instance.backfillSync();

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
