import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import 'fold_text.dart';

/// Off codes of the store's horário and what the app calls them.
const horarioOffCodes = {
  'FO': 'Folga',
  '.FO': 'Folga',
  'F': 'Férias',
  'A': 'Ausência',
  'LP': 'Licença parental',
};

/// Off codes with no meaning of their own: shown as the code, never warned
/// about on import.
const ignoredOffCodes = {'DC', 'DO', 'LIBR'};

/// One person's line in the Plano sheet.
class ParsedLinha {
  ParsedLinha({required this.nome, required this.grupo, required this.codigos});

  final String nome;

  /// 'Dia', 'Noite', or '' before any group row.
  final String grupo;

  /// One per day column, normalized ([normalizeHorarioCode]), '' for empty.
  final List<String> codigos;
}

/// A month read from the store's horário Excel file.
class ParsedHorario {
  ParsedHorario({
    required this.month,
    required this.firstDay,
    required this.days,
    required this.codigos,
    required this.linhas,
    required this.semHorario,
  });

  /// Day 1 of the month.
  final DateTime month;

  /// The date of the first day column (the day before [month]).
  final DateTime firstDay;

  /// How many day columns.
  final int days;

  /// The shift codes the Plano uses, with entrada and saída in minutes
  /// after midnight.
  final Map<String, ({int entrada, int saida})> codigos;

  final List<ParsedLinha> linhas;

  /// Codes used in the Plano with no hours in the Horário sheet and no
  /// meaning as an off code.
  final Set<String> semHorario;
}

/// "G82" for " g82 ", "0711" for "711" (a code Excel kept as a number).
String normalizeHorarioCode(String raw) {
  var c = raw.trim().toUpperCase();
  if (c.endsWith('.0') && RegExp(r'^\d+\.0$').hasMatch(c)) {
    c = c.substring(0, c.length - 2);
  }
  if (c.isNotEmpty && c.length < 4 && RegExp(r'^\d+$').hasMatch(c)) {
    c = c.padLeft(4, '0');
  }
  return c;
}

const _months = {
  'janeiro': 1, 'fevereiro': 2, 'marco': 3, 'abril': 4, 'maio': 5, //
  'junho': 6, 'julho': 7, 'agosto': 8, 'setembro': 9, 'outubro': 10,
  'novembro': 11, 'dezembro': 12,
};

/// Reads the store's horário file: people, groups and one code per day from
/// the "Plano" sheet, each code's entrada and saída from the "Horário"
/// sheet. Throws a [FormatException] in Portuguese when it can't.
ParsedHorario parseHorarioXlsx(Uint8List bytes) {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    throw const FormatException('Não é um ficheiro Excel (.xlsx).');
  }
  String? text(String path) {
    final f = zip.findFile(path);
    return f == null ? null : utf8.decode(f.content, allowMalformed: true);
  }

  final workbook = text('xl/workbook.xml');
  final rels = text('xl/_rels/workbook.xml.rels');
  if (workbook == null || rels == null) {
    throw const FormatException('Não é um ficheiro Excel (.xlsx).');
  }
  final targets = <String, String>{
    for (final r in XmlDocument.parse(rels).findAllElements('Relationship'))
      r.getAttribute('Id') ?? '': r.getAttribute('Target') ?? '',
  };
  final sheets = <String, String>{};
  for (final s in XmlDocument.parse(workbook).findAllElements('sheet')) {
    final id = s.attributes
        .firstWhere(
          (a) => a.name.local == 'id',
          orElse: () => XmlAttribute(XmlName.qualified('id'), ''),
        )
        .value;
    var target = targets[id];
    if (target == null) continue;
    target = target.startsWith('/') ? target.substring(1) : 'xl/$target';
    sheets[foldText(s.getAttribute('name') ?? '').trim()] = target;
  }

  final shared = <String>[];
  if (text('xl/sharedStrings.xml') case final sst?) {
    for (final si in XmlDocument.parse(sst).findAllElements('si')) {
      shared.add(si.findAllElements('t').map((t) => t.innerText).join());
    }
  }

  List<Map<int, String>> rows(String? path) {
    final xml = path == null ? null : text(path);
    if (xml == null) return const [];
    final out = <Map<int, String>>[];
    for (final row in XmlDocument.parse(xml).findAllElements('row')) {
      final r = int.tryParse(row.getAttribute('r') ?? '') ?? out.length + 1;
      while (out.length < r) {
        out.add({});
      }
      final cells = out[r - 1];
      var next = 0;
      for (final c in row.findElements('c')) {
        final col = _column(c.getAttribute('r')) ?? next;
        next = col + 1;
        final type = c.getAttribute('t');
        String? v;
        if (type == 'inlineStr') {
          v = c.findAllElements('t').map((t) => t.innerText).join();
        } else {
          v = c.getElement('v')?.innerText;
          if (v != null && type == 's') {
            final i = int.tryParse(v);
            v = i != null && i < shared.length ? shared[i] : '';
          }
        }
        if (v != null && v.isNotEmpty) cells[col] = v;
      }
    }
    return out;
  }

  final plano = rows(sheets['plano'] ?? sheets.values.firstOrNull);
  if (plano.length < 2) {
    throw const FormatException('Falta a folha Plano.');
  }

  // Day columns: from C, while row 2 reads like "Q\n31".
  final header = plano[1];
  final dayNumbers = <int>[];
  final dayRe = RegExp(r'^[A-Za-z]\s*(\d{1,2})$');
  for (var col = 2; ; col++) {
    final m = dayRe.firstMatch((header[col] ?? '').trim());
    if (m == null) break;
    dayNumbers.add(int.parse(m.group(1)!));
  }
  if (dayNumbers.isEmpty) {
    throw const FormatException(
      'A linha 2 da folha Plano não tem os dias do mês.',
    );
  }

  DateTime? monthOf(String? v) {
    if (v == null) return null;
    final serial = double.tryParse(v);
    if (serial != null) {
      if (serial < 1) return null;
      final d = DateTime.utc(1899, 12, 30).add(Duration(days: serial.floor()));
      return DateTime(d.year, d.month);
    }
    final m = RegExp(r'([a-z]+)\D*(\d{4})').firstMatch(foldText(v));
    final month = m == null ? null : _months[m.group(1)];
    return month == null ? null : DateTime(int.parse(m!.group(2)!), month);
  }

  var month = monthOf(plano[0][0]);
  if (month == null) {
    for (final e in header.entries) {
      if (e.key >= 2 + dayNumbers.length) {
        month = monthOf(e.value);
        if (month != null) break;
      }
    }
  }
  if (month == null) {
    throw const FormatException('Não foi possível ler o mês em A1.');
  }
  final firstDay = DateTime(month.year, month.month, 0);
  for (var i = 0; i < dayNumbers.length; i++) {
    if (DateTime(firstDay.year, firstDay.month, firstDay.day + i).day !=
        dayNumbers[i]) {
      throw const FormatException('Os dias da linha 2 não batem com o mês.');
    }
  }

  final linhas = <ParsedLinha>[];
  var grupo = '';
  for (final row in plano.skip(2)) {
    final a = (row[0] ?? '').trim();
    final b = (row[1] ?? '').trim();
    if (a.isNotEmpty) {
      final folded = foldText(a);
      if (folded.startsWith('resumo')) break;
      if (folded == 'dia') grupo = 'Dia';
      if (folded == 'noite') grupo = 'Noite';
      continue;
    }
    if (b.isEmpty) continue;
    linhas.add(
      ParsedLinha(
        nome: b.replaceAll(RegExp(r'\s+'), ' '),
        grupo: grupo,
        codigos: [
          for (var i = 0; i < dayNumbers.length; i++)
            normalizeHorarioCode(row[2 + i] ?? ''),
        ],
      ),
    );
  }

  final used = {
    for (final l in linhas)
      for (final c in l.codigos)
        if (c.isNotEmpty && !horarioOffCodes.containsKey(c)) c,
  };
  final codigos = <String, ({int entrada, int saida})>{};
  for (final row in rows(sheets['horario']).skip(1)) {
    final code = normalizeHorarioCode(row[0] ?? '');
    if (!used.contains(code) || codigos.containsKey(code)) continue;
    final entrada = _minutes(row[1]);
    final saida = _minutes(row[4]);
    if (entrada == null || saida == null) continue;
    codigos[code] = (entrada: entrada, saida: saida);
  }

  return ParsedHorario(
    month: month,
    firstDay: firstDay,
    days: dayNumbers.length,
    codigos: codigos,
    linhas: linhas,
    semHorario: {
      for (final c in used)
        if (!codigos.containsKey(c) && !ignoredOffCodes.contains(c)) c,
    },
  );
}

/// The 0-based column of a cell reference like "AK5".
int? _column(String? ref) {
  if (ref == null) return null;
  var n = 0;
  for (final u in ref.codeUnits) {
    if (u < 65 || u > 90) break;
    n = n * 26 + u - 64;
  }
  return n == 0 ? null : n - 1;
}

/// Minutes after midnight from "07:00:00", "7:00" or a day fraction.
int? _minutes(String? v) {
  if (v == null) return null;
  final t = RegExp(r'^(\d{1,2}):([0-5]\d)').firstMatch(v.trim());
  if (t != null) {
    final m = int.parse(t.group(1)!) * 60 + int.parse(t.group(2)!);
    return m <= 24 * 60 ? m : null;
  }
  final f = double.tryParse(v);
  if (f == null || f < 0) return null;
  final m = ((f - f.floor()) * 24 * 60).round();
  return m == 24 * 60 ? 0 : m;
}
