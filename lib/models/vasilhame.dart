/// One item of the vasilhame list offered on a camião ("Enviar
/// Vasilhame"). The list lives in `SettingsService` and is edited by hand in
/// the backup file's `"vasilhame"` section.
class VasilhameItem {
  const VasilhameItem({required this.name, this.code, this.ean});

  final String name;

  /// Shown under the name, e.g. the article code.
  final String? code;

  /// Shown as a barcode when the item is tapped.
  final String? ean;

  Map<String, dynamic> toJson() => {'name': name, 'code': ?code, 'ean': ?ean};
}

/// Reads a JSON list of `{"name", "code"?, "ean"?}` objects. Numbers are
/// taken as text and blank values as missing; throws a [FormatException]
/// naming the first item that is wrong.
List<VasilhameItem> vasilhameFromJson(Object? raw) {
  if (raw is! List) {
    throw const FormatException('Vasilhame: era esperada uma lista entre [ ].');
  }
  String? text(Object? v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  final items = <VasilhameItem>[];
  for (final (i, e) in raw.indexed) {
    if (e is! Map || text(e['name']) == null) {
      throw FormatException('Vasilhame: o artigo nº ${i + 1} não tem "name".');
    }
    items.add(
      VasilhameItem(
        name: text(e['name'])!,
        code: text(e['code']),
        ean: text(e['ean']),
      ),
    );
  }
  return items;
}

/// The `"vasilhame"` section of a backup file, or null when the file has
/// none (older backups), so the current list is kept.
List<VasilhameItem>? vasilhameFromBackup(Map<String, dynamic> payload) =>
    payload.containsKey('vasilhame')
    ? vasilhameFromJson(payload['vasilhame'])
    : null;

/// The Jerónimo Martins "Acessórios Transporte" sheet (SAP code as [code],
/// EAN as [ean]), offered while no list of the user's own has been
/// imported.
const defaultVasilhame = [
  VasilhameItem(
    name: 'Palete CHEP (Azul)',
    code: '748438',
    ean: '2000002521334',
  ),
  VasilhameItem(
    name: 'Palete LPR (Vermelha)',
    code: '748439',
    ean: '2000002521341',
  ),
  VasilhameItem(
    name: 'Palete Normal (Branca)',
    code: '230497',
    ean: '2100000169528',
  ),
  VasilhameItem(
    name: 'Meia Palete CHEP (Azul)',
    code: '748441',
    ean: '2000002521365',
  ),
  VasilhameItem(
    name: 'Meia Palete LPR (Vermelha)',
    code: '748442',
    ean: '2000002521372',
  ),
  VasilhameItem(
    name: 'Meia Palete Normal (Branca)',
    code: '659569',
    ean: '2000001912621',
  ),
  VasilhameItem(
    name: 'Palete Industrial',
    code: '748440',
    ean: '2000002521358',
  ),
  VasilhameItem(name: 'Palete Plástico', code: '264155', ean: '2000000006178'),
  VasilhameItem(
    name: 'Roll Congelados YATN',
    code: '745036',
    ean: '2000002491538',
  ),
  VasilhameItem(name: 'Skate Encaixe', code: '634499', ean: '2000001866214'),
  VasilhameItem(name: 'Grelha', code: '634500', ean: '2000001867235'),
  VasilhameItem(name: 'Carro Pendurados', code: '578262', ean: '2000001800638'),
  VasilhameItem(
    name: 'Carro Pendurados Pequeno',
    code: '597154',
    ean: '2000001819821',
  ),
  VasilhameItem(
    name: 'Caixa Pool Pequena Fruta',
    code: '374888',
    ean: '2000000142128',
  ),
  VasilhameItem(name: 'Caixa Pool Fruta', code: '45439', ean: '2000001073728'),
  VasilhameItem(name: 'Caixa Pool C01', code: '496964', ean: '2000001065525'),
  VasilhameItem(name: 'Caixa Pool C02', code: '374953', ean: '2000000142449'),
  VasilhameItem(name: 'Caixa Pool C03', code: '496965', ean: '2000001065532'),
  VasilhameItem(name: 'Caixa Pool C04', code: '496966', ean: '2000001065549'),
  VasilhameItem(
    name: 'Caixa Pool Nº10 Peixe Pequena',
    code: '498390',
    ean: '2000001073247',
  ),
  VasilhameItem(
    name: 'Caixa Pool Nº11 Peixe Média',
    code: '498394',
    ean: '2000001073254',
  ),
  VasilhameItem(name: 'Caixa Pool JMR', code: '620675', ean: '2000001850541'),
  VasilhameItem(
    name: 'Caixa Plástica Sapateira',
    code: '551560',
    ean: '2000001634042',
  ),
  VasilhameItem(
    name: 'Caixa Artigos de Risco',
    code: '588250',
    ean: '2000001805039',
  ),
  VasilhameItem(name: 'Caixa Panrico', code: '526227', ean: '2000001346686'),
  VasilhameItem(
    name: 'Tabuleiro Massa Fresca',
    code: '623069',
    ean: '2000001853634',
  ),
  VasilhameItem(
    name: 'Skate Massa Fresca',
    code: '623070',
    ean: '2000001853641',
  ),
];
