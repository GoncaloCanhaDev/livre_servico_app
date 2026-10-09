import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

import 'names.dart';

part 'truck_reception.g.dart';

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

@embedded
class PalletCount {
  /// Legacy — only read when [department] is null.
  @enumerated
  PalletCategory category = PalletCategory.dph;

  /// A [TruckDepartment.id]; null on receptions saved before departamentos.
  String? department;
  int total = 0;
  int mistas = 0;

  /// The departamento's name, or the old category's for older rows.
  @ignore
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
@embedded
class Expositor {
  int amount = 0;
  String content = '';
}

@embedded
class SentVasilhameItem {
  String productName = '';
  int amount = 0;
}

@collection
class TruckReception {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];

  @Index()
  late DateTime arrivalTime;

  /// Null on receptions saved before the type existed.
  @Enumerated(EnumType.name)
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
