import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/auto_list.dart';
import '../models/daily_tasks.dart';
import '../models/info_entry.dart';
import '../models/inventory.dart';
import '../models/notification_log.dart';
import '../models/opening_list.dart';
import '../models/product.dart';
import '../models/report_list.dart';
import '../models/shift_event.dart';
import '../models/truck_reception.dart';
import '../models/visual_list.dart';
import 'shift_service.dart';

class BackupService {
  BackupService._();
  static final instance = BackupService._();

  static const _formatVersion = 1;

  Isar get _isar => ShiftService.instance.isar;

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
    return Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Cópia de segurança - Livre Serviço',
    );
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
    final bytes = picked.bytes ??
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
    await _isar.writeTxn(() async {
      await _isar.shiftEvents.clear();
      await _isar.truckReceptions.clear();
      await _isar.products.clear();
      await _isar.openingLists.clear();
      await _isar.autoLists.clear();
      await _isar.reportLists.clear();
      await _isar.visualLists.clear();
      await _isar.dailyTasks.clear();
      await _isar.inventorys.clear();
      await _isar.infoEntrys.clear();
      await _isar.notificationLogs.clear();
    });
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    return {
      'version': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'collections': {
        'ShiftEvent': await _isar.shiftEvents.where().exportJson(),
        'TruckReception': await _isar.truckReceptions.where().exportJson(),
        'Product': await _isar.products.where().exportJson(),
        'OpeningList': await _isar.openingLists.where().exportJson(),
        'AutoList': await _isar.autoLists.where().exportJson(),
        'ReportList': await _isar.reportLists.where().exportJson(),
        'VisualList': await _isar.visualLists.where().exportJson(),
        'DailyTasks': await _isar.dailyTasks.where().exportJson(),
        'Inventory': await _isar.inventorys.where().exportJson(),
        'InfoEntry': await _isar.infoEntrys.where().exportJson(),
        'NotificationLog':
            await _isar.notificationLogs.where().exportJson(),
      },
    };
  }

  Future<void> _applyPayload(Map<String, dynamic> payload) async {
    final version = payload['version'];
    if (version is! int || version > _formatVersion) {
      throw FormatException(
          'Versão da cópia de segurança não suportada: $version');
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
      await _isar.shiftEvents.clear();
      await _isar.truckReceptions.clear();
      await _isar.products.clear();
      await _isar.openingLists.clear();
      await _isar.autoLists.clear();
      await _isar.reportLists.clear();
      await _isar.visualLists.clear();
      await _isar.dailyTasks.clear();
      await _isar.inventorys.clear();
      await _isar.infoEntrys.clear();
      await _isar.notificationLogs.clear();

      await _isar.shiftEvents.importJson(items('ShiftEvent'));
      await _isar.truckReceptions.importJson(items('TruckReception'));
      await _isar.products.importJson(items('Product'));
      await _isar.openingLists.importJson(items('OpeningList'));
      await _isar.autoLists.importJson(items('AutoList'));
      await _isar.reportLists.importJson(items('ReportList'));
      await _isar.visualLists.importJson(items('VisualList'));
      await _isar.dailyTasks.importJson(items('DailyTasks'));
      await _isar.inventorys.importJson(items('Inventory'));
      await _isar.infoEntrys.importJson(items('InfoEntry'));
      await _isar.notificationLogs.importJson(items('NotificationLog'));
    });
  }
}
