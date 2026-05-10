import 'package:isar_community/isar.dart';

part 'truck_reception.g.dart';

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
    }
  }
}

@embedded
class PalletCount {
  @enumerated
  PalletCategory category = PalletCategory.dph;
  int total = 0;
  int mistas = 0;
}

@collection
class TruckReception {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime arrivalTime;

  String? licensePlate;
  String? supplier;
  String? notes;

  List<PalletCount> pallets = [];

  int get totalPallets =>
      pallets.fold(0, (sum, p) => sum + p.total);
  int get totalMistas =>
      pallets.fold(0, (sum, p) => sum + p.mistas);
}
