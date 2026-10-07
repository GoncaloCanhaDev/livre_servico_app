import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auto_list.dart';
import '../models/daily_tasks.dart';
import '../models/info_entry.dart';
import '../models/inventory.dart';
import '../models/opening_list.dart';
import '../models/person.dart';
import '../models/report_list.dart';
import '../models/truck_reception.dart';
import '../models/visual_list.dart';
import '../models/weekly_tasks.dart';
import 'person_service.dart';
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
    await file.writeAsString(jsonEncode(payload));
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
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    return {
      'version': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
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

    List<Map<String, dynamic>> items(String key) {
      final v = raw[key];
      if (v is! List) return const [];
      return v.cast<Map<String, dynamic>>();
    }

    await _isar.writeTxn(() async {
      await _isar.truckReceptions.clear();
      await _isar.openingLists.clear();
      await _isar.autoLists.clear();
      await _isar.reportLists.clear();
      await _isar.visualLists.clear();
      await _isar.dailyTasks.clear();
      await _isar.weeklyTasks.clear();
      await _isar.inventorys.clear();
      await _isar.infoEntrys.clear();
      await _isar.persons.clear();

      await _isar.truckReceptions.importJson(items('TruckReception'));
      await _isar.openingLists.importJson(items('OpeningList'));
      await _isar.autoLists.importJson(items('AutoList'));
      await _isar.reportLists.importJson(items('ReportList'));
      await _isar.visualLists.importJson(items('VisualList'));
      await _isar.dailyTasks.importJson(items('DailyTasks'));
      await _isar.weeklyTasks.importJson(items('WeeklyTasks'));
      await _isar.inventorys.importJson(items('Inventory'));
      await _isar.infoEntrys.importJson(items('InfoEntry'));
      await _isar.persons.importJson(items('Person'));
    });

    // A backup taken before multi-manager support has `managerUuid`
    // populated but no `managerUuids`; without this, the teams view would
    // show a flat hierarchy until the next app launch's
    // startup migration runs. Must stay outside the writeTxn above —
    // migrateManagerUuids() opens its own transaction internally.
    await PersonService.instance.migrateManagerUuids();
  }
}
