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
