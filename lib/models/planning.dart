import 'horario.dart';
import 'person.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The ausência of [p] that covers [day] (any time that day), or null.
Ausencia? ausenciaOn(Person p, DateTime day) {
  final d = _dateOnly(day);
  for (final a in p.ausencias) {
    if (!d.isBefore(_dateOnly(a.start)) && !d.isAfter(_dateOnly(a.end))) {
      return a;
    }
  }
  return null;
}

/// Why [p] is off on [day], in three forms: the full [label] ("Férias até
/// 14/10", "Folga"), the orange [tag] ("Férias"; none for a folga) and the
/// [note] beside the tag ("até 14/10", "Folga"). Null when working.
///
/// An ausência entered in the app wins; otherwise, when [horario] has a line
/// for [p] that month, its code decides (a shift means working); otherwise
/// the fixed weekly folgas do.
({String label, String? tag, String note})? _offOn(
  Person p,
  DateTime day,
  HorarioIndex? horario,
) {
  String until(DateTime end) => 'até ${end.day}/${end.month}';
  if (ausenciaOn(p, day) case final a?) {
    return (
      label: '${a.tipo.label} ${until(a.end)}',
      tag: a.tipo.label,
      note: until(a.end),
    );
  }
  if (horario != null && horario.hasLine(p, day)) {
    final code = horario.codeOn(p, day)!;
    final name = horario.horarios.ausencias[code];
    if (name == null) return null;
    if (code == folgaCode) return (label: name, tag: null, note: name);
    final end = horario.runEnd(p, day);
    return (label: '$name ${until(end)}', tag: name, note: until(end));
  }
  if (p.folgas.contains(day.weekday)) {
    return (label: 'Folga', tag: null, note: 'Folga');
  }
  return null;
}

/// Why [p] is not working on [day]: "Férias até 14/10" (an ausência wins),
/// "Folga", or null when they are working. See [_offOn] for [horario].
String? offLabelOn(Person p, DateTime day, {HorarioIndex? horario}) =>
    _offOn(p, day, horario)?.label;

/// The tag shown on [p] while an ausência covers [day] ("Férias", "Baixa"…),
/// or null. A folga gets no tag.
String? awayTagOn(Person p, DateTime day, {HorarioIndex? horario}) =>
    _offOn(p, day, horario)?.tag;

/// [offLabelOn] without the part the tag already says: "até 14/10" during an
/// ausência, "Folga", or null when they are working.
String? offNoteOn(Person p, DateTime day, {HorarioIndex? horario}) =>
    _offOn(p, day, horario)?.note;

/// "07:00–16:00" when [horario] has [p] on a shift on [day], else null. [p]'s
/// own entrada and saída, when set, replace the code's.
String? horarioTextOn(Person p, DateTime day, HorarioIndex? horario) =>
    horario?.shiftOn(p, day)?.shortText;

/// [p]'s ausências that have not ended before [today], by start date.
List<Ausencia> upcomingAusencias(Person p, DateTime today) {
  final d = _dateOnly(today);
  return p.ausencias.where((a) => !_dateOnly(a.end).isBefore(d)).toList()
    ..sort((a, b) => a.start.compareTo(b.start));
}

/// The tag shown on a person's birthday.
const birthdayTag = '🎂 Faz anos';

/// Whether [day] is [p]'s birthday ([Person.dateOfBirth]); a 29 February
/// birthday falls on the 28th outside leap years.
bool isBirthdayOn(Person p, DateTime day) {
  final dob = p.dateOfBirth;
  if (dob == null || dob.month != day.month) return false;
  if (dob.month == 2 && dob.day == 29 && DateTime(day.year, 2, 29).month == 3) {
    return day.day == 28;
  }
  return dob.day == day.day;
}

/// The birthdays in [people] from [today] through the next [days] days,
/// soonest first (then by name), each with its date.
List<({Person person, DateTime date})> upcomingBirthdays(
  List<Person> people,
  DateTime today, {
  int days = 7,
}) {
  final start = _dateOnly(today);
  final found = <({Person person, DateTime date})>[];
  for (var i = 0; i <= days; i++) {
    final day = DateTime(start.year, start.month, start.day + i);
    final born = people.where((p) => isBirthdayOn(p, day)).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    found.addAll([for (final p in born) (person: p, date: day)]);
  }
  return found;
}

/// Time since [from] in whole months: "4 anos e 7 meses", "1 ano", "5 meses",
/// or "menos de 1 mês".
String tenureText(DateTime from, DateTime today) {
  final months = _wholeMonths(from, today);
  if (months < 1) return 'menos de 1 mês';
  final years = months ~/ 12;
  final rest = months % 12;
  final y = years == 1 ? '1 ano' : '$years anos';
  final m = rest == 1 ? '1 mês' : '$rest meses';
  if (years == 0) return m;
  if (rest == 0) return y;
  return '$y e $m';
}

/// Whole months from [from] to [today]; a month counts once its day is
/// reached.
int _wholeMonths(DateTime from, DateTime today) {
  final months = (today.year - from.year) * 12 + today.month - from.month;
  return today.day < from.day ? months - 1 : months;
}

/// "Em formação" in [p]'s first month at Pingo Doce ([Person.hireDate]),
/// "Novo" / "Nova" until six months, otherwise (or without a date) null.
String? tenureTagOf(Person p, DateTime today) {
  final hired = p.hireDate;
  if (hired == null) return null;
  final months = _wholeMonths(hired, today);
  if (months < 1) return 'Em formação';
  if (months < 6) return p.genero == Genero.feminino ? 'Nova' : 'Novo';
  return null;
}

const weekdayShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

/// "Seg, Qui, Dom" for [DateTime.weekday] values, in week order.
String folgasText(List<int> weekdays) =>
    ([...weekdays]..sort()).map((d) => weekdayShort[d - 1]).join(', ');

/// "07:00" for [minutes] after midnight.
String timeText(int minutes) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// "07:00–15:00", or null unless both ends of [p]'s horário are set.
String? horarioText(Person p) {
  final start = p.shiftStart;
  final end = p.shiftEnd;
  if (start == null || end == null) return null;
  return '${timeText(start)}–${timeText(end)}';
}

const _monthShort = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun', //
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

/// "5 out", "1–14 out", "28 set – 3 out" or "28 dez 2026 – 3 jan 2027".
String ausenciaRangeText(Ausencia a) {
  final s = a.start;
  final e = a.end;
  String dm(DateTime d) => '${d.day} ${_monthShort[d.month - 1]}';
  if (s.year != e.year) return '${dm(s)} ${s.year} – ${dm(e)} ${e.year}';
  if (s.month != e.month) return '${dm(s)} – ${dm(e)}';
  if (s.day != e.day) return '${s.day}–${dm(e)}';
  return dm(s);
}
