import 'fold_text.dart';
import 'horario_xlsx.dart';
import 'local_row.dart';
import 'person.dart';

/// "2027-01" for any day of January 2027: the key of a month online.
String monthKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// One month of the store's horário, imported from its Excel file:
/// self-contained, with the hours of every code it uses.
class HorarioMes with SyncFields {
  HorarioMes();

  factory HorarioMes.fromJson(Map<String, dynamic> j) {
    final m = HorarioMes()
      ..month = dateFromJsonOr(j['month'], DateTime(2000))
      ..firstDay = dateFromJsonOr(j['firstDay'], DateTime(2000))
      ..codigos = {
        if (j['codigos'] case final Map<String, dynamic> c)
          for (final e in c.entries)
            if (e.value case final Map<String, dynamic> v)
              e.key: (
                entrada: intFromJson(v['entrada']),
                saida: intFromJson(v['saida']),
              ),
      }
      ..linhas = [
        for (final l in mapsFromJson(j['linhas'])) HorarioLinha.fromJson(l),
      ]
      ..importedAt = dateFromJsonOr(j['importedAt'], DateTime(2000))
      ..importedBy = stringFromJson(j['importedBy']);
    syncFieldsFromJson(m, j);
    return m;
  }

  /// From a file read by [parseHorarioXlsx]: [personIds] gives the linked
  /// person's `syncUuid` for each Excel name (null or missing: none).
  factory HorarioMes.fromParsed(
    ParsedHorario parsed,
    Map<String, String?> personIds, {
    required String importedBy,
  }) => HorarioMes()
    ..month = parsed.month
    ..firstDay = parsed.firstDay
    ..codigos = {...parsed.codigos}
    ..linhas = [
      for (final l in parsed.linhas)
        HorarioLinha()
          ..nome = l.nome
          ..grupo = l.grupo
          ..personId = personIds[l.nome]
          ..codigos = [...l.codigos],
    ]
    ..importedAt = DateTime.now()
    ..importedBy = importedBy;

  /// Day 1 of the month.
  late DateTime month;

  /// The date of the first column (the last day of the month before).
  late DateTime firstDay;

  /// Entrada and saída, in minutes after midnight, of each shift code used.
  Map<String, ({int entrada, int saida})> codigos = {};

  List<HorarioLinha> linhas = [];

  late DateTime importedAt;
  String importedBy = '';

  /// How many day columns the lines have.
  int get days =>
      linhas.fold(0, (n, l) => l.codigos.length > n ? l.codigos.length : n);

  /// The column of [day], or null outside this month's columns.
  int? columnOf(DateTime day) {
    final i = _dateOnly(day).difference(firstDay).inHours;
    final col = (i / 24).round();
    return col >= 0 && col < days ? col : null;
  }

  /// The date of column [col].
  DateTime dateOf(int col) =>
      DateTime(firstDay.year, firstDay.month, firstDay.day + col);

  /// What [linha] has on column [col], or null for an empty cell.
  HorarioDia? dayAt(HorarioLinha linha, int col) {
    final code = col < linha.codigos.length ? linha.codigos[col] : '';
    if (code.isEmpty) return null;
    final hours = codigos[code];
    return HorarioDia(
      date: dateOf(col),
      code: code,
      entrada: hours?.entrada,
      saida: hours?.saida,
      offLabel: hours == null ? (horarioOffCodes[code] ?? code) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'month': dateToJson(month),
    'firstDay': dateToJson(firstDay),
    'codigos': {
      for (final e in codigos.entries)
        e.key: {'entrada': e.value.entrada, 'saida': e.value.saida},
    },
    'linhas': [for (final l in linhas) l.toJson()],
    'importedAt': dateToJson(importedAt),
    'importedBy': importedBy,
  };
}

/// One person's line: the name as written in the Excel file, its group
/// there (Dia / Noite) and the person it was linked to on import.
class HorarioLinha {
  HorarioLinha();

  factory HorarioLinha.fromJson(Map<String, dynamic> j) => HorarioLinha()
    ..nome = stringFromJson(j['nome'])
    ..grupo = stringFromJson(j['grupo'])
    ..personId = stringOrNull(j['personId'])
    ..codigos = stringsFromJson(j['codigos']);

  String nome = '';
  String grupo = '';

  /// The linked person's `syncUuid`; null when nobody was chosen.
  String? personId;

  /// One code per day column, '' when empty.
  List<String> codigos = [];

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'grupo': grupo,
    'personId': personId,
    'codigos': codigos,
  };
}

/// The kind of a day in the horário, for its colour.
enum HorarioTipo {
  abertura('Abertura'),
  intermedio('Intermédio'),
  fecho('Fecho'),
  noite('Noite'),
  folga('Folga'),
  ausente('Ausente');

  const HorarioTipo(this.label);
  final String label;
}

/// A person's day in the horário: a shift ([entrada]–[saida]) or a day off
/// ([offLabel]).
class HorarioDia {
  const HorarioDia({
    required this.date,
    required this.code,
    this.entrada,
    this.saida,
    this.offLabel,
    this.changed,
    this.fromProfile = false,
  });

  /// The day as changed in the app by [c]: a shift when it has hours (its
  /// code may then be '', hours only).
  factory HorarioDia.fromChange(HorarioAlteracao c) {
    final shift = c.entrada != null && c.saida != null;
    return HorarioDia(
      date: _dateOnly(c.date),
      code: c.code,
      entrada: shift ? c.entrada : null,
      saida: shift ? c.saida : null,
      offLabel: shift ? null : (horarioOffCodes[c.code] ?? c.code),
      changed: c,
    );
  }

  final DateTime date;
  final String code;
  final int? entrada;
  final int? saida;

  /// "Folga", "Férias"… or the code itself; null for a shift.
  final String? offLabel;

  /// The change made in the app this day comes from; null when it is the
  /// imported file's.
  final HorarioAlteracao? changed;

  /// Whether the person's profile (folgas, hours) changed the file's day.
  final bool fromProfile;

  bool get isShift => entrada != null && saida != null;

  /// When the shift runs: from the entrada on [date] to the saída, the next
  /// day when it is at or before the entrada.
  ({DateTime start, DateTime end}) spanOn() {
    final e = entrada ?? 0;
    final s = saida ?? 0;
    // Built from the date's fields, not by adding minutes, so a shift on
    // the day the clocks change still starts at its own hour.
    return (
      start: DateTime(date.year, date.month, date.day, 0, e),
      end: DateTime(
        date.year,
        date.month,
        date.day,
        0,
        s <= e ? s + 24 * 60 : s,
      ),
    );
  }

  HorarioTipo get tipo {
    final e = entrada;
    if (e == null || saida == null) {
      return horarioOffCodes[code] == 'Folga'
          ? HorarioTipo.folga
          : HorarioTipo.ausente;
    }
    if (e < 5 * 60 || e >= 20 * 60) return HorarioTipo.noite;
    if (e < 9 * 60) return HorarioTipo.abertura;
    if (e < 12 * 60) return HorarioTipo.intermedio;
    return HorarioTipo.fecho;
  }

  /// "06:00–15:00", or the [offLabel].
  String get text =>
      isShift ? '${_hhmm(entrada!)}–${_hhmm(saida!)}' : offLabel!;

  /// "06–15", "06:30–15", or the code of a day off: for narrow grids.
  String get shortText {
    if (!isShift) return code;
    String t(int m) => m % 60 == 0
        ? _two(m ~/ 60 % 24)
        : '${_two(m ~/ 60 % 24)}:${_two(m % 60)}';
    return '${t(entrada!)}–${t(saida!)}';
  }
}

String _two(int n) => n.toString().padLeft(2, '0');
String _hhmm(int m) => '${_two(m ~/ 60 % 24)}:${_two(m % 60)}';

/// The loaded months, answering what each person does on each day. A day
/// covered by two months (the columns just outside a month) is read from
/// the month it belongs to; from the other only while that one is missing.
class HorarioIndex {
  HorarioIndex(
    List<HorarioMes> months, {
    List<HorarioAlteracao> changes = const [],
  }) : _months = [...months]..sort((a, b) => a.month.compareTo(b.month)),
       _byKey = {for (final m in months) monthKey(m.month): m},
       _changes = {
         for (final c in changes) alteracaoKey(c.personId, c.date): c,
       };

  static final empty = HorarioIndex(const []);

  final List<HorarioMes> _months;
  final Map<String, HorarioMes> _byKey;
  final Map<String, HorarioAlteracao> _changes;

  /// The changes made in the app to days of [month] (its own days).
  List<HorarioAlteracao> changesIn(DateTime month) => [
    for (final c in _changes.values)
      if (c.date.year == month.year && c.date.month == month.month) c,
  ]..sort((a, b) => a.date.compareTo(b.date));

  /// How many times each shift code is used in [month]'s file, for offering
  /// the usual ones first.
  Map<String, int> codeUsage(DateTime month) {
    final m = monthOf(month);
    final counts = <String, int>{};
    if (m == null) return counts;
    for (final l in m.linhas) {
      for (final c in l.codigos) {
        if (m.codigos.containsKey(c)) counts[c] = (counts[c] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<HorarioMes> get months => List.unmodifiable(_months);

  bool hasMonth(DateTime month) => _byKey.containsKey(monthKey(month));

  HorarioMes? monthOf(DateTime month) => _byKey[monthKey(month)];

  /// The month read for [day], or null when none covers it.
  HorarioMes? monthCovering(DateTime day) {
    final own = _byKey[monthKey(day)];
    if (own != null && own.columnOf(day) != null) return own;
    for (final m in _months.reversed) {
      if (m.columnOf(day) != null) return m;
    }
    return null;
  }

  /// [p]'s day on [day]'s date, or null when the horário says nothing: a
  /// change made in the app, else [baseDayOf].
  HorarioDia? dayOf(Person p, DateTime day) {
    if (p.syncUuid.isEmpty) return null;
    if (_changes[alteracaoKey(p.syncUuid, day)] case final c?) {
      return _fromChange(c);
    }
    return baseDayOf(p, day);
  }

  /// [p]'s day as the file has it, with their profile on top: their folgas
  /// (when they have some) decide which days are folgas, and their hours
  /// (both set) those of every working day. The file's other days off
  /// (férias, ausências) stay, and so does a folga there is no shift for.
  HorarioDia? baseDayOf(Person p, DateTime day) {
    final file = fileDayOf(p, day);
    if (file == null) return null;
    final off = !file.isShift;
    final folga = off && file.tipo == HorarioTipo.folga;
    if (off && !folga) return file;
    final start = p.shiftStart;
    final end = p.shiftEnd;
    final hasHours = start != null && end != null;
    if (p.folgas.isNotEmpty) {
      if (p.folgas.contains(file.date.weekday)) {
        return folga
            ? file
            : HorarioDia(
                date: file.date,
                code: 'FO',
                offLabel: 'Folga',
                fromProfile: true,
              );
      }
      if (folga && !hasHours) return file;
    } else if (folga) {
      return file;
    }
    if (!hasHours || (file.entrada == start && file.saida == end)) return file;
    return HorarioDia(
      date: file.date,
      code: '',
      entrada: start,
      saida: end,
      fromProfile: true,
    );
  }

  /// A change's day: null for '' with no hours (nothing that day).
  static HorarioDia? _fromChange(HorarioAlteracao c) =>
      c.code.isEmpty && (c.entrada == null || c.saida == null)
      ? null
      : HorarioDia.fromChange(c);

  /// [p]'s day on [day]'s date as the imported file has it.
  HorarioDia? fileDayOf(Person p, DateTime day) {
    if (p.syncUuid.isEmpty) return null;
    final m = monthCovering(day);
    if (m == null) return null;
    for (final l in m.linhas) {
      if (l.personId == p.syncUuid) return m.dayAt(l, m.columnOf(day)!);
    }
    return null;
  }

  /// The last day of the run of the same code as [p]'s on [day] (the end of
  /// their férias, say), or null when the horário says nothing that day.
  DateTime? lastDayOfSameCode(Person p, DateTime day) {
    final first = dayOf(p, day);
    if (first == null) return null;
    var last = _dateOnly(day);
    for (var i = 1; i < 400; i++) {
      final next = DateTime(last.year, last.month, last.day + 1);
      if (dayOf(p, next)?.code != first.code) break;
      last = next;
    }
    return last;
  }

  /// [p]'s days in the horário from [from]'s date through [days] days.
  List<HorarioDia> nextDays(Person p, DateTime from, int days) {
    final start = _dateOnly(from);
    return [
      for (var i = 0; i < days; i++)
        ?dayOf(p, DateTime(start.year, start.month, start.day + i)),
    ];
  }

  /// Every line of the month read for [day], with its day (null: empty);
  /// for a line whose person is in [people] (by `syncUuid`), as [dayOf].
  List<({HorarioLinha linha, HorarioDia? dia})> linesOn(
    DateTime day, {
    Map<String, Person> people = const {},
  }) {
    final m = monthCovering(day);
    if (m == null) return const [];
    final col = m.columnOf(day)!;
    return [
      for (final l in m.linhas)
        (
          linha: l,
          dia: switch (people[l.personId]) {
            final p? => dayOf(p, day),
            null => switch (l.personId == null
                ? null
                : _changes[alteracaoKey(l.personId!, day)]) {
              final c? => _fromChange(c),
              null => m.dayAt(l, col),
            },
          },
        ),
    ];
  }
}

/// The name as compared when matching: no case, accents or extra spaces.
String foldName(String name) =>
    foldText(name).trim().replaceAll(RegExp(r'\s+'), ' ');

/// The person each Excel [names] line is for, or null when unclear: a
/// choice made on an earlier import ([previous]) of someone still among
/// [people], else the one person with that name, else the one whose name
/// starts with its first word and ends with its last. Never guesses between
/// two, and never gives the same person to two names.
Map<String, Person?> matchHorarioNames(
  List<String> names,
  List<Person> people, {
  List<HorarioMes> previous = const [],
}) {
  final byUuid = {for (final p in people) p.syncUuid: p};
  final remembered = <String, Person>{};
  for (final m in [...previous]..sort((a, b) => a.month.compareTo(b.month))) {
    for (final l in m.linhas) {
      if (byUuid[l.personId] case final p?) remembered[foldName(l.nome)] = p;
    }
  }

  Person? only(Iterable<Person> found) =>
      found.length == 1 ? found.single : null;

  final taken = <Person>{};
  final result = <String, Person?>{};
  for (final name in names) {
    final n = foldName(name);
    final words = n.split(' ');
    var p =
        remembered[n] ??
        only(people.where((p) => foldName(p.fullName) == n)) ??
        (words.length < 2
            ? null
            : only(
                people.where((p) {
                  final full = foldName(p.fullName);
                  return full.startsWith('${words.first} ') &&
                      full.endsWith(' ${words.last}');
                }),
              ));
    if (p != null && !taken.add(p)) p = null;
    result[name] = p;
  }
  return result;
}

/// "ana/2027-01-12": a change's key online, one per person and day.
String alteracaoKey(String personId, DateTime date) =>
    '$personId/${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// A person's day changed in the app (someone off sick, called in on a
/// folga, a swap): wins over the imported file until undone, and survives
/// a re-import when the importer keeps it.
class HorarioAlteracao with SyncFields {
  HorarioAlteracao();

  factory HorarioAlteracao.fromJson(Map<String, dynamic> j) {
    final a = HorarioAlteracao()
      ..date = dateFromJsonOr(j['date'], DateTime(2000))
      ..personId = stringFromJson(j['personId'])
      ..code = stringFromJson(j['code'])
      ..entrada = intOrNull(j['entrada'])
      ..saida = intOrNull(j['saida'])
      ..fileCode = stringFromJson(j['fileCode'])
      ..changedBy = stringFromJson(j['changedBy'])
      ..changedAt = dateFromJsonOr(j['changedAt'], DateTime(2000));
    syncFieldsFromJson(a, j);
    return a;
  }

  /// The day (midnight).
  late DateTime date;

  /// The person's `syncUuid`.
  String personId = '';

  /// The code now ('' for nothing that day).
  String code = '';

  /// The code's entrada and saída when it is a shift.
  int? entrada;
  int? saida;

  /// What the imported file said that day ('' for nothing).
  String fileCode = '';

  String changedBy = '';
  late DateTime changedAt;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'date': dateToJson(date),
    'personId': personId,
    'code': code,
    'entrada': entrada,
    'saida': saida,
    'fileCode': fileCode,
    'changedBy': changedBy,
    'changedAt': dateToJson(changedAt),
  };
}

/// The [changes] a newly read file disagrees with: on a day inside its
/// columns, for a person on it ([personIds]: Excel name → `syncUuid`),
/// with another code than the file's that day.
List<({HorarioAlteracao change, String newFileCode})> changesAgainstFile(
  ParsedHorario parsed,
  Map<String, String?> personIds,
  List<HorarioAlteracao> changes,
) {
  final codesOf = <String, List<String>>{
    for (final l in parsed.linhas) ?personIds[l.nome]: l.codigos,
  };
  final found = <({HorarioAlteracao change, String newFileCode})>[];
  for (final c in changes) {
    final codes = codesOf[c.personId];
    if (codes == null) continue;
    final col = (_dateOnly(c.date).difference(parsed.firstDay).inHours / 24)
        .round();
    if (col < 0 || col >= codes.length) continue;
    final hoursOnly = c.code.isEmpty && c.entrada != null;
    if (hoursOnly || codes[col] != c.code) {
      found.add((change: c, newFileCode: codes[col]));
    }
  }
  return found..sort((a, b) => a.change.date.compareTo(b.change.date));
}
