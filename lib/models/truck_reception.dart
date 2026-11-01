import 'package:intl/intl.dart';

import 'local_row.dart';
import 'names.dart';

/// The old palete categories, kept only to read receptions saved before
/// [truckDepartments] existed. Stored by index, so never reorder them.
enum PalletCategory {
  frescosCharcutaria,
  frescosIogurtes,
  dph,
  bebidas,
  mercearia,
  bazar,
  leite,
  animal,
  vasilhame,
  congelados,
}

extension PalletCategoryLabel on PalletCategory {
  String get label {
    switch (this) {
      case PalletCategory.frescosCharcutaria:
        return 'Frescos – Charcutaria';
      case PalletCategory.frescosIogurtes:
        return 'Frescos – Iogurtes';
      case PalletCategory.dph:
        return 'DPH';
      case PalletCategory.bebidas:
        return 'Bebidas';
      case PalletCategory.mercearia:
        return 'Mercearia';
      case PalletCategory.bazar:
        return 'Bazar';
      case PalletCategory.leite:
        return 'Leite';
      case PalletCategory.animal:
        return 'Animal';
      case PalletCategory.vasilhame:
        return 'Vasilhame';
      case PalletCategory.congelados:
        return 'Congelados';
    }
  }
}

/// What kind of camião a reception was. Stored on [TruckReception.type] by
/// name.
enum TruckType {
  pereciveis('Perecíveis'),
  naoPereciveis('Não Perecíveis');

  const TruckType(this.label);
  final String label;
}

/// A departamento paletes can be counted for. [id] is what
/// [PalletCount.department] stores (the team id where there is one).
class TruckDepartment {
  const TruckDepartment(this.id, this.label);
  final String id;
  final String label;
}

/// Every departamento, in the order Adicionar lists them.
const truckDepartments = [
  TruckDepartment('dph', 'DPH'),
  TruckDepartment('mercearia', 'Mercearia'),
  TruckDepartment('bebidas', 'Bebidas'),
  TruckDepartment('bazar', 'Bazar'),
  TruckDepartment('congelados', 'Congelados'),
  TruckDepartment('charcutaria', 'Charcutaria'),
  TruckDepartment('iogurtes', 'Iogurtes'),
  TruckDepartment('meal_solutions', 'Meal Solutions'),
  TruckDepartment('talho', 'Talho'),
  TruckDepartment('peixaria', 'Peixaria'),
  TruckDepartment('bem_estar', 'Bem Estar'),
  TruckDepartment('padaria', 'Padaria'),
  TruckDepartment('fruta', 'Fruta'),
  TruckDepartment('prodout', 'Prodout'),
];

class PalletCount {
  PalletCount();

  factory PalletCount.fromJson(Map<String, dynamic> j) => PalletCount()
    ..category =
        enumFromJson(PalletCategory.values, j['category']) ?? PalletCategory.dph
    ..department = stringOrNull(j['department'])
    ..total = intFromJson(j['total'])
    ..mistas = intFromJson(j['mistas']);

  Map<String, dynamic> toJson() => {
    'category': category.index,
    'department': department,
    'total': total,
    'mistas': mistas,
  };

  /// Legacy — only read when [department] is null.
  PalletCategory category = PalletCategory.dph;

  /// A [TruckDepartment.id]; null on receptions saved before departamentos.
  String? department;
  int total = 0;
  int mistas = 0;

  /// The departamento's name, or the old category's for older rows.
  String get label {
    final id = department;
    if (id == null) return category.label;
    for (final d in truckDepartments) {
      if (d.id == id) return d.label;
    }
    return id;
  }
}

/// A number of expositores carrying the same thing ("3 · Coca-Cola").
class Expositor {
  Expositor();

  factory Expositor.fromJson(Map<String, dynamic> j) => Expositor()
    ..amount = intFromJson(j['amount'])
    ..content = stringFromJson(j['content']);

  Map<String, dynamic> toJson() => {'amount': amount, 'content': content};

  int amount = 0;
  String content = '';
}

class SentVasilhameItem {
  SentVasilhameItem();

  factory SentVasilhameItem.fromJson(Map<String, dynamic> j) =>
      SentVasilhameItem()
        ..productName = stringFromJson(j['productName'])
        ..amount = intFromJson(j['amount']);

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'amount': amount,
  };

  String productName = '';
  int amount = 0;
}

class TruckReception with SyncFields {
  TruckReception();

  factory TruckReception.fromJson(Map<String, dynamic> j) {
    final t = TruckReception()
      ..createdByInitials = stringOrNull(j['createdByInitials'])
      ..createdByNames = stringsFromJson(j['createdByNames'])
      ..arrivalTime = dateFromJsonOr(j['arrivalTime'], DateTime(2000))
      ..type = enumFromJson(TruckType.values, j['type'])
      ..licensePlate = stringOrNull(j['licensePlate'])
      ..supplier = stringOrNull(j['supplier'])
      ..notes = stringOrNull(j['notes'])
      ..issues = stringOrNull(j['issues'])
      ..pallets = [
        for (final p in mapsFromJson(j['pallets'])) PalletCount.fromJson(p),
      ]
      ..sentVasilhame = [
        for (final v in mapsFromJson(j['sentVasilhame']))
          SentVasilhameItem.fromJson(v),
      ]
      ..expositores = [
        for (final e in mapsFromJson(j['expositores'])) Expositor.fromJson(e),
      ];
    syncFieldsFromJson(t, j);
    return t;
  }

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdByInitials': createdByInitials,
    'createdByNames': createdByNames,
    'arrivalTime': dateToJson(arrivalTime),
    'type': type?.name,
    'licensePlate': licensePlate,
    'supplier': supplier,
    'notes': notes,
    'issues': issues,
    'pallets': [for (final p in pallets) p.toJson()],
    'sentVasilhame': [for (final v in sentVasilhame) v.toJson()],
    'expositores': [for (final e in expositores) e.toJson()],
  };

  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  late DateTime arrivalTime;

  /// Null on receptions saved before the type existed.
  TruckType? type;

  String? licensePlate;
  String? supplier;
  String? notes;

  /// Optional free-text note for problems with this delivery (shortages,
  /// damaged goods, wrong products, etc.) — left null on a normal reception.
  String? issues;

  List<PalletCount> pallets = [];
  List<SentVasilhameItem> sentVasilhame = [];
  List<Expositor> expositores = [];

  int get totalPallets => pallets.fold(0, (sum, p) => sum + p.total);
  int get totalMistas => pallets.fold(0, (sum, p) => sum + p.mistas);
  int get totalExpositores => expositores.fold(0, (sum, e) => sum + e.amount);
}

/// "Camião · Congelados", or just "Camião" for older receptions.
String truckTitle(TruckReception t) =>
    t.type == null ? 'Camião' : 'Camião · ${t.type!.label}';

/// The WhatsApp message for a reception, sent when it is saved and again
/// from Histórico.
String truckWhatsAppText(TruckReception t) {
  final dateFmt = DateFormat("d/MM/y, HH:mm", 'pt_PT');
  final lines = StringBuffer();
  lines.writeln('🚛 Receção de Camião');
  if (t.type != null) lines.writeln('Tipo: ${t.type!.label}');
  lines.writeln('Hora: ${dateFmt.format(t.arrivalTime)}');
  if (t.licensePlate != null) {
    lines.writeln('Matrícula: ${t.licensePlate}');
  }
  if (t.supplier != null) lines.writeln('Fornecedor: ${t.supplier}');
  for (final p in t.pallets) {
    final mista = p.mistas > 0
        ? ' (${p.mistas} mista${p.mistas > 1 ? 's' : ''})'
        : '';
    lines.writeln('${p.label}: ${p.total}$mista');
  }
  lines.writeln('Total: ${t.totalPallets} paletes, ${t.totalMistas} mistas');
  final names = resolveNames(t.createdByNames, t.createdByInitials);
  if (names.isNotEmpty) lines.writeln('Por: ${joinNames(names)}');

  if (t.expositores.isNotEmpty) {
    lines.writeln('\nExpositores:');
    for (final e in t.expositores) {
      lines.writeln(
        e.content.isEmpty ? '- ${e.amount}' : '- ${e.amount} · ${e.content}',
      );
    }
  }

  if (t.sentVasilhame.isNotEmpty) {
    lines.writeln('\n📦 Vasilhame Enviado:');
    for (final v in t.sentVasilhame) {
      lines.writeln('- ${v.productName}: ${v.amount}');
    }
  }

  if (t.issues != null) lines.writeln('\n⚠️ Problemas: ${t.issues}');
  if (t.notes != null) lines.writeln('\nNotas: ${t.notes}');
  return lines.toString().trim();
}
