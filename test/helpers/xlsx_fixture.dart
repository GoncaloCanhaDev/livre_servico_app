import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// A minimal .xlsx with a "Plano" and a "Horário" sheet, shaped like the
/// store's monthly file. Rows start at A1; a [String] becomes a shared (or,
/// with [inlineStrings], inline) string, a [num] a number cell, null nothing.
/// With [horarioFirst] the Horário sheet is sheet1.xml and comes first.
Uint8List buildXlsx({
  required List<List<Object?>> plano,
  required List<List<Object?>> horario,
  bool horarioFirst = false,
  bool inlineStrings = false,
}) {
  final shared = <String>[];
  String esc(String s) => const HtmlEscape(HtmlEscapeMode.element).convert(s);

  String colName(int i) {
    var n = i + 1;
    var s = '';
    while (n > 0) {
      final r = (n - 1) % 26;
      s = String.fromCharCode(65 + r) + s;
      n = (n - 1) ~/ 26;
    }
    return s;
  }

  String sheet(List<List<Object?>> rows) {
    final b = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>',
    );
    for (var r = 0; r < rows.length; r++) {
      b.write('<row r="${r + 1}">');
      for (var c = 0; c < rows[r].length; c++) {
        final v = rows[r][c];
        final ref = '${colName(c)}${r + 1}';
        if (v is String) {
          if (inlineStrings) {
            b.write('<c r="$ref" t="inlineStr"><is><t>${esc(v)}</t></is></c>');
          } else {
            var i = shared.indexOf(v);
            if (i < 0) {
              shared.add(v);
              i = shared.length - 1;
            }
            b.write('<c r="$ref" t="s"><v>$i</v></c>');
          }
        } else if (v is num) {
          b.write('<c r="$ref"><v>$v</v></c>');
        }
      }
      b.write('</row>');
    }
    b.write('</sheetData></worksheet>');
    return b.toString();
  }

  final planoXml = sheet(plano);
  final horarioXml = sheet(horario);
  final first = horarioFirst ? ('Horário', horarioXml) : ('Plano', planoXml);
  final second = horarioFirst ? ('Plano', planoXml) : ('Horário', horarioXml);

  final workbook =
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<sheets><sheet name="${first.$1}" sheetId="1" r:id="rId1"/>'
      '<sheet name="${second.$1}" sheetId="2" r:id="rId2"/></sheets></workbook>';
  const rels =
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
      '</Relationships>';
  final sst = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
  );
  for (final s in shared) {
    sst.write('<si><t>${esc(s)}</t></si>');
  }
  sst.write('</sst>');

  final archive = Archive();
  void add(String name, String text) {
    final bytes = utf8.encode(text);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  add('xl/workbook.xml', workbook);
  add('xl/_rels/workbook.xml.rels', rels);
  add('xl/sharedStrings.xml', sst.toString());
  add('xl/worksheets/sheet1.xml', first.$2);
  add('xl/worksheets/sheet2.xml', second.$2);
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

/// The Plano of a small January 2027, like the real file's layout.
List<List<Object?>> samplePlano({
  Object? a1 = 'Janeiro 2027',
  String firstHeader = 'Q\n31',
}) => [
  [a1],
  [
    'Secção / Nº Colaborador',
    'Nome Colaborador',
    firstHeader,
    'S\n01',
    'S\n02',
    'D\n03',
    46388,
  ],
  ['0129 Livre Serviço'],
  ['Dia'],
  [null, 'Ana Lopes', 'G82', 'FO', 711, ''],
  ['Noite'],
  [null, 'Rui Sá', 'W82', '.FO', 'LIBR', 'XYZ'],
  ['Resumo'],
  ['Abertura:', null, 2, 0],
];

/// The codes sheet: code, entrada, pausa, pausa, saída; times as text or
/// day fractions, a code repeated.
List<List<Object?>> sampleHorario() => [
  ['Código', 'Entrada', 'Pausa', '', 'Saída'],
  ['G82', '06:00:00', '10:00:00', '11:00:00', '15:00:00'],
  ['W82', 22 / 24, 0, 0, 7 / 24],
  ['0711', '07:00:00', '00:00:00', '00:00:00', '11:00:00'],
  ['0711', '07:00:00', '00:00:00', '00:00:00', '11:00:00'],
];
