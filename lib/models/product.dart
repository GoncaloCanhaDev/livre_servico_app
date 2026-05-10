import 'package:isar_community/isar.dart';

import 'truck_reception.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: false)
  late String ean;

  @Index()
  late String sapCode;

  late String name;

  @enumerated
  PalletCategory department = PalletCategory.dph;

  String? notes;

  late DateTime createdAt;
  late DateTime updatedAt;
}

bool isValidEan13(String code) {
  if (code.length != 13) return false;
  if (!RegExp(r'^\d{13}$').hasMatch(code)) return false;
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    final d = int.parse(code[i]);
    sum += (i.isEven) ? d : d * 3;
  }
  final check = (10 - (sum % 10)) % 10;
  return check == int.parse(code[12]);
}
