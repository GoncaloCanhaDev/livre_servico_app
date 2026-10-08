import 'fold_text.dart';
import 'person.dart';

/// One shift code of the Pingo Doce horário ("H73"): entrada, optional
/// pausa and saída, in minutes after midnight. A saída at or before the
/// entrada (or 24:00) is on the next day.
class HorarioCodigo {
  const HorarioCodigo({required this.entrada, required this.saida, this.pausa});

  final int entrada;
  final int saida;
  final (int, int)? pausa;

  /// Reads `{"entrada": "07:00", "pausa": "12:00-13:00", "saida": "16:00"}`
  /// (pausa optional); [code] names the code in errors.
  factory HorarioCodigo.fromJson(String code, Object? json) {
    if (json is! Map) {
      throw FormatException(
        'Código $code: era esperado { "entrada", "saida" }.',
      );
    }
    int time(Object? v, String field) {
      final m = RegExp(
        r'^(\d{1,2}):([0-5]\d)$',
      ).firstMatch('${v ?? ''}'.trim());
      final minutes = m == null
          ? null
          : int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
      if (minutes == null || minutes > 24 * 60) {
        throw FormatException(
          'Código $code: "$field" deve ser uma hora como 07:00 (tem "$v").',
        );
      }
      return minutes;
    }

    final pausa = json['pausa'];
    (int, int)? p;
    if (pausa != null && '$pausa'.trim().isNotEmpty) {
      final parts = '$pausa'.split('-');
      if (parts.length != 2) {
        throw FormatException(
          'Código $code: "pausa" deve ser como 12:00-13:00 (tem "$pausa").',
        );
      }
      p = (time(parts[0], 'pausa'), time(parts[1], 'pausa'));
    }
    return HorarioCodigo(
      entrada: time(json['entrada'], 'entrada'),
      saida: time(json['saida'], 'saida'),
      pausa: p,
    );
  }

  Map<String, String> toJson() => {
    'entrada': _hhmm(entrada),
    if (pausa case (final a, final b)) 'pausa': '${_hhmm(a)}-${_hhmm(b)}',
    'saida': _hhmm(saida),
  };

  /// Starts at 20:00 or later, or ends after midnight.
  bool get noturno => entrada >= 20 * 60 || saida <= entrada || saida > 24 * 60;

  /// "07:00–16:00", plus " (pausa 12:00–13:00)" when there is one.
  String get timesText {
    final base = '${_hhmm(entrada)}–${_hhmm(saida)}';
    return switch (pausa) {
      (final a, final b) => '$base (pausa ${_hhmm(a)}–${_hhmm(b)})',
      null => base,
    };
  }

  /// "07:00–16:00", without the pausa.
  String get shortText => '${_hhmm(entrada)}–${_hhmm(saida)}';

  /// When this shift runs if it is on [day]'s date: from the entrada that
  /// day to the saída, the next day for a night shift.
  ({DateTime start, DateTime end}) spanOn(DateTime day) => (
    start: DateTime(day.year, day.month, day.day, 0, entrada),
    end: DateTime(
      day.year,
      day.month,
      day.day,
      0,
      saida <= entrada ? saida + 24 * 60 : saida,
    ),
  );
}

String _hhmm(int minutes) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// The absence code for a folga: no tag, no "até".
const folgaCode = 'FO';

/// "2026-10" for any day of October 2026.
String monthKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}';

final _monthPattern = RegExp(r'^(\d{4})-(0[1-9]|1[0-2])$');

int _daysIn(String month) {
  final m = _monthPattern.firstMatch(month)!;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!) + 1, 0).day;
}

/// Every saved horário: the shift codes, the absence codes (FO, F…) with
/// their names, and per month ("2026-10") one line of codes per name, day
/// 1 first.
class Horarios {
  const Horarios({
    required this.codigos,
    required this.ausencias,
    required this.meses,
  });

  static const empty = Horarios(codigos: {}, ausencias: {}, meses: {});

  final Map<String, HorarioCodigo> codigos;
  final Map<String, String> ausencias;
  final Map<String, Map<String, List<String>>> meses;

  /// The horários file: `tipo`, `versao`, `codigos`, `ausencias` and
  /// `meses`, each line a space-separated string of codes.
  Map<String, dynamic> toJson() => {
    'tipo': 'horarios',
    'versao': 1,
    'codigos': {for (final e in codigos.entries) e.key: e.value.toJson()},
    'ausencias': ausencias,
    'meses': {
      for (final month in meses.keys.toList()..sort())
        month: {
          for (final row in meses[month]!.entries) row.key: row.value.join(' '),
        },
    },
  };
}

/// What a horários file brings: each part null when the file doesn't have
/// it; a month mapped to null is to be deleted.
class HorariosFile {
  const HorariosFile({this.codigos, this.ausencias, this.meses = const {}});

  final Map<String, HorarioCodigo>? codigos;
  final Map<String, String>? ausencias;
  final Map<String, Map<String, List<String>>?> meses;
}

/// Reads and checks a horários file against its own codes, or [current]'s
/// when it has none: months as AAAA-MM, one code per day of the month, every
/// code known. Throws a [FormatException] saying what is wrong.
HorariosFile parseHorariosFile(
  Map<String, dynamic> json, {
  required Horarios current,
}) {
  Map<String, HorarioCodigo>? codigos;
  if (json['codigos'] case final raw?) {
    if (raw is! Map) {
      throw const FormatException('"codigos" deve ser um objeto { }.');
    }
    codigos = {
      for (final e in raw.entries)
        '${e.key}'.trim().toUpperCase(): HorarioCodigo.fromJson(
          '${e.key}',
          e.value,
        ),
    };
  }

  Map<String, String>? ausencias;
  if (json['ausencias'] case final raw?) {
    if (raw is! Map) {
      throw const FormatException('"ausencias" deve ser um objeto { }.');
    }
    ausencias = {
      for (final e in raw.entries)
        '${e.key}'.trim().toUpperCase(): '${e.value}'.trim(),
    };
  }

  final known = {
    ...(codigos ?? current.codigos).keys,
    ...(ausencias ?? current.ausencias).keys,
  };
  final meses = <String, Map<String, List<String>>?>{};
  final rawMeses = json['meses'] ?? const {};
  if (rawMeses is! Map) {
    throw const FormatException('"meses" deve ser um objeto { }.');
  }
  for (final e in rawMeses.entries) {
    final month = '${e.key}'.trim();
    if (!_monthPattern.hasMatch(month)) {
      throw FormatException(
        'Mês "$month": deve ser escrito como AAAA-MM, por exemplo 2026-10.',
      );
    }
    final rows = e.value;
    if (rows == null) {
      meses[month] = null;
      continue;
    }
    if (rows is! Map) {
      throw FormatException('$month: era esperado { "Nome": "códigos" }.');
    }
    final days = _daysIn(month);
    meses[month] = {
      for (final r in rows.entries)
        '${r.key}'.trim(): _parseLine(
          month,
          '${r.key}'.trim(),
          r.value,
          days,
          known,
        ),
    };
  }
  return HorariosFile(codigos: codigos, ausencias: ausencias, meses: meses);
}

List<String> _parseLine(
  String month,
  String name,
  Object? raw,
  int days,
  Set<String> known,
) {
  final codes = switch (raw) {
    String s => s.trim().split(RegExp(r'\s+')),
    List l => [for (final c in l) '$c'.trim()],
    _ => throw FormatException(
      '$month · $name: era esperado um texto com os códigos.',
    ),
  }.where((c) => c.isNotEmpty).map((c) => c.toUpperCase()).toList();
  if (codes.length != days) {
    throw FormatException(
      '$month · $name: tem ${codes.length} dias, o mês tem $days.',
    );
  }
  for (final (i, c) in codes.indexed) {
    if (!known.contains(c)) {
      throw FormatException(
        '$month · $name: dia ${i + 1} tem o código $c, que não existe.',
      );
    }
  }
  return codes;
}

/// [current] with [file] applied: its codes and ausências replace the saved
/// ones when present, and each of its months replaces (or, when null,
/// deletes) that month; other months are kept.
Horarios mergeHorarios(Horarios current, HorariosFile file) {
  final meses = {...current.meses};
  for (final e in file.meses.entries) {
    if (e.value case final rows?) {
      meses[e.key] = rows;
    } else {
      meses.remove(e.key);
    }
  }
  return Horarios(
    codigos: file.codigos ?? current.codigos,
    ausencias: file.ausencias ?? current.ausencias,
    meses: meses,
  );
}

/// The person in [people] a horário line named [name] is for: the same full
/// name, else the same first and last names, else (for a lone first name)
/// the only person with that first name; null when none or ambiguous.
/// Accents and case are ignored.
Person? personForRow(String name, List<Person> people) {
  List<String> words(String s) =>
      foldText(s).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final row = words(name);
  if (row.isEmpty) return null;

  Person? only(bool Function(List<String> w) test) {
    final found = [
      for (final p in people)
        if (words(p.fullName) case final w when w.isNotEmpty && test(w)) p,
    ];
    return found.length == 1 ? found.single : null;
  }

  return only((w) => w.join(' ') == row.join(' ')) ??
      (row.length > 1
          ? only((w) => w.first == row.first && w.last == row.last)
          : only((w) => w.first == row.first));
}

/// [Horarios] linked to [people]: which line is whose, per month.
class HorarioIndex {
  HorarioIndex(this.horarios, List<Person> people) {
    for (final e in horarios.meses.entries) {
      final byPerson = <int, List<String>>{};
      final unmatched = <String>[];
      for (final row in e.value.entries) {
        if (personForRow(row.key, people) case final p?) {
          byPerson[p.id] = row.value;
        } else {
          unmatched.add(row.key);
        }
      }
      _byMonth[e.key] = byPerson;
      _unmatched[e.key] = unmatched;
    }
  }

  final Horarios horarios;
  final _byMonth = <String, Map<int, List<String>>>{};
  final _unmatched = <String, List<String>>{};

  /// [p]'s code on [day] (its date), or null without a line that month.
  String? codeOn(Person p, DateTime day) =>
      _byMonth[monthKey(day)]?[p.id]?[day.day - 1];

  /// Whether [p] has a line for [day]'s month.
  bool hasLine(Person p, DateTime day) =>
      _byMonth[monthKey(day)]?.containsKey(p.id) ?? false;

  /// Names in [month] that matched nobody.
  List<String> unmatched(String month) => _unmatched[month] ?? const [];

  /// The last day of the run of [p]'s code on [day], following the saved
  /// months.
  DateTime runEnd(Person p, DateTime day) {
    final code = codeOn(p, day);
    var end = DateTime(day.year, day.month, day.day);
    while (true) {
      final next = DateTime(end.year, end.month, end.day + 1);
      if (code == null || codeOn(p, next) != code) return end;
      end = next;
    }
  }
}
