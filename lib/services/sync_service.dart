import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auto_list.dart';
import '../models/daily_tasks.dart';
import '../models/info_entry.dart';
import '../models/inventory.dart';
import '../models/inventory_line.dart';
import '../models/justification.dart';
import '../models/notification_log.dart';
import '../models/opening_list.dart';
import '../models/product.dart';
import '../models/report_list.dart';
import '../models/shift_event.dart';
import '../models/truck_reception.dart';
import '../models/visual_list.dart';
import 'auto_list_service.dart';
import 'daily_tasks_service.dart';
import 'inventory_line_service.dart';
import 'inventory_service.dart';
import 'justification_service.dart';
import 'notification_service.dart';
import 'opening_list_service.dart';
import 'product_service.dart';
import 'report_list_service.dart';
import 'shift_service.dart';
import 'truck_service.dart';
import 'visual_list_service.dart';

/// Push/pull sync engine that mirrors every Isar collection to Supabase.
///
/// Phase 4 limitations:
///   * Deletes are NOT yet propagated. Hard-deleting a row locally and then
///     pulling will recreate it. Deletes will be migrated to tombstones in
///     a follow-up pass.
///   * Conflicts are resolved by last-write-wins on `updated_at`. Postgres
///     unique constraints (e.g. one OpeningList per service_day per user)
///     can still reject a push; failures are logged and the row stays
///     unsynced so the next run retries.
class SyncService extends ChangeNotifier {
  SyncService._();
  static final instance = SyncService._();

  static const _prefsPrefix = 'syncLastPulledAt:';
  static const _pushBatch = 100;

  Isar get _isar => ShiftService.instance.isar;
  SupabaseClient get _client => Supabase.instance.client;

  bool _syncing = false;
  String? _lastError;
  DateTime? _lastSyncAt;
  Timer? _timer;
  Timer? _debounce;
  StreamSubscription<AuthState>? _authSub;
  final List<ChangeNotifier> _writeNotifiers = [];
  final List<RealtimeChannel> _realtimeChannels = [];

  bool get syncing => _syncing;
  String? get lastError => _lastError;
  DateTime? get lastSyncAt => _lastSyncAt;

  void start() {
    _timer?.cancel();
    _authSub ??= _client.auth.onAuthStateChange.listen((s) {
      if (s.event == AuthChangeEvent.signedOut) {
        _lastError = null;
        _lastSyncAt = null;
        notifyListeners();
      } else if (s.event == AuthChangeEvent.signedIn) {
        unawaited(syncNow());
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => syncNow());
    _attachWriteListeners();
    _subscribeRealtime();
    unawaited(syncNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _debounce?.cancel();
    _debounce = null;
    _detachWriteListeners();
    _unsubscribeRealtime();
    _authSub?.cancel();
    _authSub = null;
  }

  /// Schedules a sync ~500ms in the future. Successive calls within that
  /// window reset the timer so a burst of writes coalesces into one run.
  void requestSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _debounce = null;
      unawaited(syncNow());
    });
  }

  void _subscribeRealtime() {
    if (_realtimeChannels.isNotEmpty) return;
    final tables = _mappers.map((m) => m.table).toList();
    for (final t in tables) {
      final channel = _client
          .channel('public:$t')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: t,
            callback: (_) => requestSync(),
          )
          .subscribe();
      _realtimeChannels.add(channel);
    }
  }

  void _unsubscribeRealtime() {
    for (final ch in _realtimeChannels) {
      _client.removeChannel(ch);
    }
    _realtimeChannels.clear();
  }

  void _attachWriteListeners() {
    if (_writeNotifiers.isNotEmpty) return;
    final notifiers = <ChangeNotifier>[
      ShiftService.instance,
      TruckService.instance,
      ProductService.instance,
      OpeningListService.instance,
      AutoListService.instance,
      ReportListService.instance,
      VisualListService.instance,
      DailyTasksService.instance,
      InventoryService.instance,
      InventoryLineService.instance,
      NotificationService.instance,
      JustificationService.instance,
    ];
    for (final n in notifiers) {
      n.addListener(requestSync);
    }
    _writeNotifiers.addAll(notifiers);
  }

  void _detachWriteListeners() {
    for (final n in _writeNotifiers) {
      n.removeListener(requestSync);
    }
    _writeNotifiers.clear();
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    _syncing = true;
    _lastError = null;
    notifyListeners();
    try {
      for (final m in _mappers) {
        await _pushOne(m, userId);
        await _pullOne(m, userId);
      }
      _lastSyncAt = DateTime.now();
    } catch (e) {
      _lastError = '$e';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Push
  // ---------------------------------------------------------------------------

  Future<void> _pushOne(_Mapper m, String userId) async {
    final dirty = await m.findDirty(_isar);
    if (dirty.isEmpty) return;
    for (var i = 0; i < dirty.length; i += _pushBatch) {
      final chunk = dirty.sublist(
          i, i + _pushBatch > dirty.length ? dirty.length : i + _pushBatch);
      final payload =
          chunk.map((row) => m.toMap(row, userId: userId)).toList();
      await _client.from(m.table).upsert(payload, onConflict: 'uuid');
      // Mark synced locally.
      for (final row in chunk) {
        (row as dynamic).synced = true;
      }
      await _isar.writeTxn(() => m.putAllLocal(_isar, chunk));
    }
  }

  // ---------------------------------------------------------------------------
  // Pull
  // ---------------------------------------------------------------------------

  Future<void> _pullOne(_Mapper m, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsPrefix${m.table}';
    final cursorStr = prefs.getString(key);
    final cursor = cursorStr == null ? null : DateTime.tryParse(cursorStr);
    final query = _client
        .from(m.table)
        .select()
        .eq('user_id', userId);
    final rows = cursor == null
        ? await query.order('updated_at', ascending: true).limit(2000)
        : await query
            .gt('updated_at', cursor.toIso8601String())
            .order('updated_at', ascending: true)
            .limit(2000);
    if (rows.isEmpty) return;

    DateTime maxSeen = cursor ?? DateTime.fromMillisecondsSinceEpoch(0);
    final toWrite = <dynamic>[];
    for (final raw in rows) {
      final json = Map<String, dynamic>.from(raw as Map);
      final remoteUpdated = DateTime.parse(json['updated_at'] as String);
      if (remoteUpdated.isAfter(maxSeen)) maxSeen = remoteUpdated;
      final uuid = json['uuid'] as String;
      final local = await m.findByUuid(_isar, uuid);
      if (local != null) {
        final localUpdated = (local as dynamic).syncUpdatedAt as DateTime;
        if (!remoteUpdated.isAfter(localUpdated)) continue;
      }
      final row = m.fromMap(json, existing: local);
      (row as dynamic).synced = true;
      toWrite.add(row);
    }
    if (toWrite.isNotEmpty) {
      await _isar.writeTxn(() => m.putAllLocal(_isar, toWrite));
    }
    await prefs.setString(key, maxSeen.toIso8601String());
  }

  // ---------------------------------------------------------------------------
  // Mappers — one per collection.
  // ---------------------------------------------------------------------------

  late final List<_Mapper> _mappers = [
    _shiftEventMapper,
    _truckReceptionMapper,
    _productMapper,
    _openingListMapper,
    _autoListMapper,
    _reportListMapper,
    _visualListMapper,
    _dailyTasksMapper,
    _inventoryMapper,
    _inventoryLineMapper,
    _infoEntryMapper,
    _notificationLogMapper,
    _justificationMapper,
  ];
}

// Top-level helpers --------------------------------------------------------

String? _iso(DateTime? d) => d?.toUtc().toIso8601String();
DateTime? _dt(dynamic v) => v == null ? null : DateTime.parse(v as String);

void _writeSyncMeta(dynamic row, Map<String, dynamic> j) {
  row.syncUuid = j['uuid'] as String;
  row.syncUpdatedAt = DateTime.parse(j['updated_at'] as String);
  row.syncDeletedAt = _dt(j['deleted_at']);
  if (j.containsKey('created_by_initials')) {
    try {
      row.createdByInitials = j['created_by_initials'] as String?;
    } catch (_) {}
  }
}

Map<String, dynamic> _syncMetaToMap(dynamic row, String userId) {
  final map = <String, dynamic>{
    'uuid': row.syncUuid,
    'user_id': userId,
    'updated_at': _iso(row.syncUpdatedAt as DateTime),
    'deleted_at': _iso(row.syncDeletedAt as DateTime?),
  };
  try {
    final initials = row.createdByInitials as String?;
    map['created_by_initials'] = initials;
  } catch (_) {
    // Model doesn't have the field (e.g. NotificationLog).
  }
  return map;
}

// ---------------------------------------------------------------------------
// Mapper definitions
// ---------------------------------------------------------------------------

abstract class _Mapper {
  String get table;
  Future<List<dynamic>> findDirty(Isar isar);
  Future<dynamic> findByUuid(Isar isar, String uuid);
  Future<void> putAllLocal(Isar isar, List<dynamic> rows);
  Map<String, dynamic> toMap(dynamic row, {required String userId});
  dynamic fromMap(Map<String, dynamic> json, {dynamic existing});
}

// ShiftEvent -----------------------------------------------------------------

final _shiftEventMapper = _ShiftEventMapper();

class _ShiftEventMapper extends _Mapper {
  @override
  String get table => 'shift_events';

  @override
  Future<List<ShiftEvent>> findDirty(Isar isar) =>
      isar.shiftEvents.filter().syncedEqualTo(false).findAll();

  @override
  Future<ShiftEvent?> findByUuid(Isar isar, String uuid) =>
      isar.shiftEvents.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.shiftEvents.putAll(rows.cast<ShiftEvent>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as ShiftEvent;
    return {
      ..._syncMetaToMap(r, userId),
      'timestamp': _iso(r.timestamp),
      'type': r.type.name,
      'shift_id': r.shiftId,
      'note': r.note,
    };
  }

  @override
  ShiftEvent fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as ShiftEvent?) ?? ShiftEvent();
    _writeSyncMeta(r, json);
    r.timestamp = DateTime.parse(json['timestamp'] as String);
    r.type = ShiftEventType.values
        .firstWhere((e) => e.name == json['type'] as String);
    r.shiftId = (json['shift_id'] as num).toInt();
    r.note = json['note'] as String?;
    return r;
  }
}

// TruckReception -------------------------------------------------------------

final _truckReceptionMapper = _TruckReceptionMapper();

class _TruckReceptionMapper extends _Mapper {
  @override
  String get table => 'truck_receptions';

  @override
  Future<List<TruckReception>> findDirty(Isar isar) =>
      isar.truckReceptions.filter().syncedEqualTo(false).findAll();

  @override
  Future<TruckReception?> findByUuid(Isar isar, String uuid) =>
      isar.truckReceptions.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.truckReceptions.putAll(rows.cast<TruckReception>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as TruckReception;
    return {
      ..._syncMetaToMap(r, userId),
      'arrival_time': _iso(r.arrivalTime),
      'license_plate': r.licensePlate,
      'supplier': r.supplier,
      'notes': r.notes,
      'pallets': r.pallets
          .map((p) => {
                'category': p.category.name,
                'total': p.total,
                'mistas': p.mistas,
              })
          .toList(),
      'sent_vasilhame': r.sentVasilhame
          .map((s) => {
                'product_name': s.productName,
                'amount': s.amount,
              })
          .toList(),
    };
  }

  @override
  TruckReception fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as TruckReception?) ?? TruckReception();
    _writeSyncMeta(r, json);
    r.arrivalTime = DateTime.parse(json['arrival_time'] as String);
    r.licensePlate = json['license_plate'] as String?;
    r.supplier = json['supplier'] as String?;
    r.notes = json['notes'] as String?;
    r.pallets = ((json['pallets'] as List?) ?? const [])
        .map((p) {
          final m = Map<String, dynamic>.from(p as Map);
          return PalletCount()
            ..category = PalletCategory.values
                .firstWhere((e) => e.name == m['category'] as String)
            ..total = (m['total'] as num).toInt()
            ..mistas = (m['mistas'] as num).toInt();
        })
        .toList();
    r.sentVasilhame = ((json['sent_vasilhame'] as List?) ?? const [])
        .map((s) {
          final m = Map<String, dynamic>.from(s as Map);
          return SentVasilhameItem()
            ..productName = m['product_name'] as String? ?? ''
            ..amount = (m['amount'] as num?)?.toInt() ?? 0;
        })
        .toList();
    return r;
  }
}

// Product --------------------------------------------------------------------

final _productMapper = _ProductMapper();

class _ProductMapper extends _Mapper {
  @override
  String get table => 'products';

  @override
  Future<List<Product>> findDirty(Isar isar) =>
      isar.products.filter().syncedEqualTo(false).findAll();

  @override
  Future<Product?> findByUuid(Isar isar, String uuid) =>
      isar.products.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.products.putAll(rows.cast<Product>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as Product;
    return {
      ..._syncMetaToMap(r, userId),
      'ean': r.ean,
      'sap_code': r.sapCode,
      'name': r.name,
      'department': r.department.name,
      'notes': r.notes,
      'created_at': _iso(r.createdAt),
      'product_updated_at': _iso(r.updatedAt),
    };
  }

  @override
  Product fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as Product?) ?? Product();
    _writeSyncMeta(r, json);
    r.ean = json['ean'] as String;
    r.sapCode = json['sap_code'] as String;
    r.name = json['name'] as String;
    r.department = PalletCategory.values
        .firstWhere((e) => e.name == json['department'] as String);
    r.notes = json['notes'] as String?;
    r.createdAt = DateTime.parse(json['created_at'] as String);
    r.updatedAt = DateTime.parse(json['product_updated_at'] as String);
    return r;
  }
}

// OpeningList ----------------------------------------------------------------

final _openingListMapper = _OpeningListMapper();

class _OpeningListMapper extends _Mapper {
  @override
  String get table => 'opening_lists';

  @override
  Future<List<OpeningList>> findDirty(Isar isar) =>
      isar.openingLists.filter().syncedEqualTo(false).findAll();

  @override
  Future<OpeningList?> findByUuid(Isar isar, String uuid) =>
      isar.openingLists.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.openingLists.putAll(rows.cast<OpeningList>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as OpeningList;
    return {
      ..._syncMetaToMap(r, userId),
      'service_day': _iso(r.serviceDay),
      'congelados': r.congelados,
      'opls': r.opls,
      'nao_pereciveis': r.naoPereciveis,
      'finalized_at': _iso(r.finalizedAt),
    };
  }

  @override
  OpeningList fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as OpeningList?) ?? OpeningList();
    _writeSyncMeta(r, json);
    r.serviceDay = DateTime.parse(json['service_day'] as String);
    r.congelados = (json['congelados'] as num).toInt();
    r.opls = (json['opls'] as num).toInt();
    r.naoPereciveis = (json['nao_pereciveis'] as num).toInt();
    r.finalizedAt = _dt(json['finalized_at']);
    return r;
  }
}

// AutoList -------------------------------------------------------------------

final _autoListMapper = _AutoListMapper();

class _AutoListMapper extends _Mapper {
  @override
  String get table => 'auto_lists';

  @override
  Future<List<AutoList>> findDirty(Isar isar) =>
      isar.autoLists.filter().syncedEqualTo(false).findAll();

  @override
  Future<AutoList?> findByUuid(Isar isar, String uuid) =>
      isar.autoLists.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.autoLists.putAll(rows.cast<AutoList>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as AutoList;
    return {
      ..._syncMetaToMap(r, userId),
      'created_at': _iso(r.createdAt),
      'congelados': r.congelados,
      'opls': r.opls,
      'nao_pereciveis': r.naoPereciveis,
    };
  }

  @override
  AutoList fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as AutoList?) ?? AutoList();
    _writeSyncMeta(r, json);
    r.createdAt = DateTime.parse(json['created_at'] as String);
    r.congelados = (json['congelados'] as num).toInt();
    r.opls = (json['opls'] as num).toInt();
    r.naoPereciveis = (json['nao_pereciveis'] as num).toInt();
    return r;
  }
}

// ReportList -----------------------------------------------------------------

final _reportListMapper = _ReportListMapper();

class _ReportListMapper extends _Mapper {
  @override
  String get table => 'report_lists';

  @override
  Future<List<ReportList>> findDirty(Isar isar) =>
      isar.reportLists.filter().syncedEqualTo(false).findAll();

  @override
  Future<ReportList?> findByUuid(Isar isar, String uuid) =>
      isar.reportLists.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.reportLists.putAll(rows.cast<ReportList>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as ReportList;
    return {
      ..._syncMetaToMap(r, userId),
      'service_day': _iso(r.serviceDay),
      'dias_sem_vendas': r.diasSemVendas,
      'regularizacoes': r.regularizacoes,
      'massiva': r.massiva,
      'repetidos': r.repetidos,
      'finalized_at': _iso(r.finalizedAt),
    };
  }

  @override
  ReportList fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as ReportList?) ?? ReportList();
    _writeSyncMeta(r, json);
    r.serviceDay = DateTime.parse(json['service_day'] as String);
    r.diasSemVendas = (json['dias_sem_vendas'] as num).toInt();
    r.regularizacoes = (json['regularizacoes'] as num).toInt();
    r.massiva = (json['massiva'] as num).toInt();
    r.repetidos = (json['repetidos'] as num).toInt();
    r.finalizedAt = _dt(json['finalized_at']);
    return r;
  }
}

// VisualList -----------------------------------------------------------------

final _visualListMapper = _VisualListMapper();

class _VisualListMapper extends _Mapper {
  @override
  String get table => 'visual_lists';

  @override
  Future<List<VisualList>> findDirty(Isar isar) =>
      isar.visualLists.filter().syncedEqualTo(false).findAll();

  @override
  Future<VisualList?> findByUuid(Isar isar, String uuid) =>
      isar.visualLists.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.visualLists.putAll(rows.cast<VisualList>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as VisualList;
    return {
      ..._syncMetaToMap(r, userId),
      'created_at': _iso(r.createdAt),
      'service_day': _iso(r.serviceDay),
      'itens_picados': r.itensPicados,
      'quebra_cents': r.quebraCents,
      'beneficio_cents': r.beneficioCents,
    };
  }

  @override
  VisualList fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as VisualList?) ?? VisualList();
    _writeSyncMeta(r, json);
    r.createdAt = DateTime.parse(json['created_at'] as String);
    r.serviceDay = DateTime.parse(json['service_day'] as String);
    r.itensPicados = (json['itens_picados'] as num).toInt();
    r.quebraCents = (json['quebra_cents'] as num).toInt();
    r.beneficioCents = (json['beneficio_cents'] as num).toInt();
    return r;
  }
}

// DailyTasks -----------------------------------------------------------------

final _dailyTasksMapper = _DailyTasksMapper();

class _DailyTasksMapper extends _Mapper {
  @override
  String get table => 'daily_tasks';

  @override
  Future<List<DailyTasks>> findDirty(Isar isar) =>
      isar.dailyTasks.filter().syncedEqualTo(false).findAll();

  @override
  Future<DailyTasks?> findByUuid(Isar isar, String uuid) =>
      isar.dailyTasks.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.dailyTasks.putAll(rows.cast<DailyTasks>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as DailyTasks;
    return {
      ..._syncMetaToMap(r, userId),
      'service_day': _iso(r.serviceDay),
      'kiwi_abertura': r.kiwiAbertura,
      'kiwi_abertura_by': r.kiwiAberturaBy,
      'alteracoes_preco': r.alteracoesPreco,
      'alteracoes_preco_by': r.alteracoesPrecoBy,
      'alteracoes_preco_count': r.alteracoesPrecoCount,
      'verificacao_temperaturas': r.verificacaoTemperaturas,
      'verificacao_temperaturas_by': r.verificacaoTemperaturasBy,
      'preenchimento_quadro': r.preenchimentoQuadro,
      'preenchimento_quadro_by': r.preenchimentoQuadroBy,
      'verificacao_validades': r.verificacaoValidades,
      'verificacao_validades_by': r.verificacaoValidadesBy,
      'verificacao_validades_count': r.verificacaoValidadesCount,
      'kiwi_fecho': r.kiwiFecho,
      'kiwi_fecho_by': r.kiwiFechoBy,
      'limpeza_maquina_voltas': r.limpezaMaquinaVoltas,
      'limpeza_maquina_voltas_by': r.limpezaMaquinaVoltasBy,
      'last_updated_at': _iso(r.lastUpdatedAt),
    };
  }

  @override
  DailyTasks fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as DailyTasks?) ?? DailyTasks();
    _writeSyncMeta(r, json);
    r.serviceDay = DateTime.parse(json['service_day'] as String);
    r.kiwiAbertura = json['kiwi_abertura'] as bool? ?? false;
    r.kiwiAberturaBy = json['kiwi_abertura_by'] as String?;
    r.alteracoesPreco = json['alteracoes_preco'] as bool? ?? false;
    r.alteracoesPrecoBy = json['alteracoes_preco_by'] as String?;
    r.alteracoesPrecoCount =
        (json['alteracoes_preco_count'] as num?)?.toInt() ?? 0;
    r.verificacaoTemperaturas =
        json['verificacao_temperaturas'] as bool? ?? false;
    r.verificacaoTemperaturasBy =
        json['verificacao_temperaturas_by'] as String?;
    r.preenchimentoQuadro = json['preenchimento_quadro'] as bool? ?? false;
    r.preenchimentoQuadroBy = json['preenchimento_quadro_by'] as String?;
    r.verificacaoValidades = json['verificacao_validades'] as bool? ?? false;
    r.verificacaoValidadesBy = json['verificacao_validades_by'] as String?;
    r.verificacaoValidadesCount =
        (json['verificacao_validades_count'] as num?)?.toInt() ?? 0;
    r.kiwiFecho = json['kiwi_fecho'] as bool? ?? false;
    r.kiwiFechoBy = json['kiwi_fecho_by'] as String?;
    r.limpezaMaquinaVoltas = json['limpeza_maquina_voltas'] as bool? ?? false;
    r.limpezaMaquinaVoltasBy = json['limpeza_maquina_voltas_by'] as String?;
    r.lastUpdatedAt = _dt(json['last_updated_at']);
    return r;
  }
}

// Inventory ------------------------------------------------------------------

final _inventoryMapper = _InventoryMapper();

class _InventoryMapper extends _Mapper {
  @override
  String get table => 'inventories';

  @override
  Future<List<Inventory>> findDirty(Isar isar) =>
      isar.inventorys.filter().syncedEqualTo(false).findAll();

  @override
  Future<Inventory?> findByUuid(Isar isar, String uuid) =>
      isar.inventorys.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.inventorys.putAll(rows.cast<Inventory>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as Inventory;
    return {
      ..._syncMetaToMap(r, userId),
      'name': r.name,
      'value_cents': r.valueCents,
      'created_at': _iso(r.createdAt),
      'code': r.code,
      'started_at': _iso(r.startedAt),
      'running_since': _iso(r.runningSince),
      'accumulated_seconds': r.accumulatedSeconds,
      'finished_at': _iso(r.finishedAt),
      'final_value_cents': r.finalValueCents,
    };
  }

  @override
  Inventory fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as Inventory?) ?? Inventory();
    _writeSyncMeta(r, json);
    r.name = json['name'] as String;
    r.valueCents = (json['value_cents'] as num).toInt();
    r.createdAt = DateTime.parse(json['created_at'] as String);
    r.code = json['code'] as String?;
    r.startedAt = _dt(json['started_at']);
    r.runningSince = _dt(json['running_since']);
    r.accumulatedSeconds =
        ((json['accumulated_seconds'] as num?) ?? 0).toInt();
    r.finishedAt = _dt(json['finished_at']);
    r.finalValueCents = (json['final_value_cents'] as num?)?.toInt();
    return r;
  }
}

// InventoryLine --------------------------------------------------------------

final _inventoryLineMapper = _InventoryLineMapper();

class _InventoryLineMapper extends _Mapper {
  @override
  String get table => 'inventory_lines';

  @override
  Future<List<InventoryLine>> findDirty(Isar isar) =>
      isar.inventoryLines.filter().syncedEqualTo(false).findAll();

  @override
  Future<InventoryLine?> findByUuid(Isar isar, String uuid) =>
      isar.inventoryLines.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.inventoryLines.putAll(rows.cast<InventoryLine>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as InventoryLine;
    return {
      ..._syncMetaToMap(r, userId),
      'parent_uuid': r.parentUuid,
      'ean': r.ean,
      'product_name': r.productName,
      'count': r.count,
      'created_at': _iso(r.createdAt),
      'updated_at_local': _iso(r.updatedAt),
    };
  }

  @override
  InventoryLine fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as InventoryLine?) ?? InventoryLine();
    _writeSyncMeta(r, json);
    r.parentUuid = json['parent_uuid'] as String;
    r.ean = json['ean'] as String;
    r.productName = json['product_name'] as String?;
    r.count = ((json['count'] as num?) ?? 0).toInt();
    r.createdAt = DateTime.parse(json['created_at'] as String);
    r.updatedAt = DateTime.parse(json['updated_at_local'] as String);
    return r;
  }
}

// InfoEntry ------------------------------------------------------------------

final _infoEntryMapper = _InfoEntryMapper();

class _InfoEntryMapper extends _Mapper {
  @override
  String get table => 'info_entries';

  @override
  Future<List<InfoEntry>> findDirty(Isar isar) =>
      isar.infoEntrys.filter().syncedEqualTo(false).findAll();

  @override
  Future<InfoEntry?> findByUuid(Isar isar, String uuid) =>
      isar.infoEntrys.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.infoEntrys.putAll(rows.cast<InfoEntry>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as InfoEntry;
    return {
      ..._syncMetaToMap(r, userId),
      'bucket': r.bucket,
      'title': r.title,
      'description': r.description,
      'contact': r.contact,
      'created_at': _iso(r.createdAt),
    };
  }

  @override
  InfoEntry fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as InfoEntry?) ?? InfoEntry();
    _writeSyncMeta(r, json);
    r.bucket = json['bucket'] as String;
    r.title = json['title'] as String;
    r.description = json['description'] as String;
    r.contact = json['contact'] as String?;
    r.createdAt = DateTime.parse(json['created_at'] as String);
    return r;
  }
}

// NotificationLog ------------------------------------------------------------

final _notificationLogMapper = _NotificationLogMapper();

class _NotificationLogMapper extends _Mapper {
  @override
  String get table => 'notification_logs';

  @override
  Future<List<NotificationLog>> findDirty(Isar isar) =>
      isar.notificationLogs.filter().syncedEqualTo(false).findAll();

  @override
  Future<NotificationLog?> findByUuid(Isar isar, String uuid) =>
      isar.notificationLogs.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.notificationLogs.putAll(rows.cast<NotificationLog>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as NotificationLog;
    return {
      ..._syncMetaToMap(r, userId),
      'title': r.title,
      'body': r.body,
      'channel': r.channel,
      'scheduled_for': _iso(r.scheduledFor),
      'created_at': _iso(r.createdAt),
    };
  }

  @override
  NotificationLog fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as NotificationLog?) ?? NotificationLog();
    _writeSyncMeta(r, json);
    r.title = json['title'] as String;
    r.body = json['body'] as String;
    r.channel = json['channel'] as String?;
    r.scheduledFor = DateTime.parse(json['scheduled_for'] as String);
    r.createdAt = DateTime.parse(json['created_at'] as String);
    return r;
  }
}


// Justification --------------------------------------------------------------

final _justificationMapper = _JustificationMapper();

class _JustificationMapper extends _Mapper {
  @override
  String get table => 'justifications';

  @override
  Future<List<Justification>> findDirty(Isar isar) =>
      isar.justifications.filter().syncedEqualTo(false).findAll();

  @override
  Future<Justification?> findByUuid(Isar isar, String uuid) =>
      isar.justifications.filter().syncUuidEqualTo(uuid).findFirst();

  @override
  Future<void> putAllLocal(Isar isar, List<dynamic> rows) =>
      isar.justifications.putAll(rows.cast<Justification>());

  @override
  Map<String, dynamic> toMap(dynamic row, {required String userId}) {
    final r = row as Justification;
    return {
      ..._syncMetaToMap(r, userId),
      'service_day': _iso(r.serviceDay),
      'kind': r.kind,
      'reason': r.reason,
    };
  }

  @override
  Justification fromMap(Map<String, dynamic> json, {dynamic existing}) {
    final r = (existing as Justification?) ?? Justification();
    _writeSyncMeta(r, json);
    r.serviceDay = DateTime.parse(json['service_day'] as String);
    r.kind = json['kind'] as String;
    r.reason = json['reason'] as String;
    return r;
  }
}
