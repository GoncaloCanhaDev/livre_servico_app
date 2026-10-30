import 'daily_tasks.dart';
import 'person.dart';
import 'planning.dart';
import 'teams.dart';
import 'validades.dart';

/// A person inside their shift, and when it started and ends.
typedef OnShift = ({Person person, DateTime start, DateTime end});

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// When [p]'s own shift (`shiftStart`/`shiftEnd`) runs if it starts on
/// [day]'s date; one ending at or before its start ends the next day. Null
/// unless both ends are set.
({DateTime start, DateTime end})? shiftSpanOn(Person p, DateTime day) {
  final start = p.shiftStart;
  final end = p.shiftEnd;
  if (start == null || end == null) return null;
  final d = _dateOnly(day);
  return (
    start: d.add(Duration(minutes: start)),
    end: d.add(Duration(minutes: end <= start ? end + 24 * 60 : end)),
  );
}

/// [p]'s shift on [day]'s date, unless they are off that day (a folga or an
/// ausência, see [offLabelOn]).
({DateTime start, DateTime end})? _workingSpanOn(Person p, DateTime day) =>
    offLabelOn(p, day) == null ? shiftSpanOn(p, day) : null;

/// Who of [people] is inside their shift at [now] (a night shift from the day
/// before included), earliest start first, then by name.
List<OnShift> onShiftAt(List<Person> people, DateTime now) {
  final today = _dateOnly(now);
  final found = <OnShift>[];
  for (final p in people) {
    for (final day in [
      DateTime(today.year, today.month, today.day - 1),
      today,
    ]) {
      final span = _workingSpanOn(p, day);
      if (span == null) continue;
      if (!now.isBefore(span.start) && now.isBefore(span.end)) {
        found.add((person: p, start: span.start, end: span.end));
        break;
      }
    }
  }
  found.sort((a, b) {
    final byStart = a.start.compareTo(b.start);
    return byStart != 0
        ? byStart
        : a.person.fullName.compareTo(b.person.fullName);
  });
  return found;
}

/// How many of [people] work a day and a night shift on [day]'s date: a
/// night shift starts at 20:00 or later, or ends the next day.
({int dia, int noite}) shiftCountsOn(List<Person> people, DateTime day) {
  var dia = 0;
  var noite = 0;
  for (final p in people) {
    final span = _workingSpanOn(p, day);
    if (span == null) continue;
    if (span.start.hour >= 20 || span.end.day != span.start.day) {
      noite++;
    } else {
      dia++;
    }
  }
  return (dia: dia, noite: noite);
}

/// The Diárias still to do at [now], in the Tarefas order: [t] is the
/// service day's row (null when none was saved yet) and the flags say
/// whether the tasks ticked by other screens are done. A Validades part only
/// counts while its window is open.
List<String> pendingDailyTasks(
  DailyTasks? t, {
  required bool aberturaDone,
  required bool relatorioDone,
  required bool visualDone,
  required bool autoDone,
  required DateTime now,
}) {
  bool open(ValidadesTurno turno) =>
      validadesStateAt(turno, now) == ValidadesState.open;
  return [
    if (!(t?.kiwiAbertura ?? false)) 'Kiwi Abertura',
    if (!(t?.alteracoesPreco ?? false)) 'Alterações de Preço',
    if (!(t?.verificacaoTemperaturas ?? false)) 'Verificação de Temperaturas',
    if (!aberturaDone) 'Lista de Abertura',
    if (!relatorioDone) 'Relatório das Listas',
    if (!(t?.preenchimentoQuadro ?? false)) 'Preenchimento do Quadro',
    if (!visualDone) 'Lista Visual',
    if (!autoDone) 'Lista Automática',
    if (!(t?.verificacaoValidades ?? false) && open(ValidadesTurno.manha))
      ValidadesTurno.manha.label,
    if (!(t?.validadesNoite ?? false) && open(ValidadesTurno.noite))
      ValidadesTurno.noite.label,
    if (!(t?.kiwiFecho ?? false)) 'Kiwi Fecho',
  ];
}

/// The Livre Serviço turno at work at [now]: Noite from 19:00 until the
/// service day ends at 05:00, Dia otherwise.
Turno turnoAt(DateTime now) =>
    now.hour >= 19 || now.hour < 5 ? Turno.noite : Turno.dia;

/// "Ana Silva" for "Ana Maria Silva": the first and last names.
String shortName(String fullName) {
  final words = fullName.trim().split(RegExp(r'\s+'));
  return words.length < 2 ? words.single : '${words.first} ${words.last}';
}
