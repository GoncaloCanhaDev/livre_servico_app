import 'daily_tasks.dart';
import 'horario.dart';
import 'person.dart';
import 'planning.dart';
import 'task_window.dart';
import 'teams.dart';
import 'validades.dart';

/// A person inside their shift, and when it started and ends.
typedef OnShift = ({Person person, DateTime start, DateTime end});

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// When [p]'s shift runs if it starts on [day]'s date; one ending at or
/// before its start ends the next day. A day in the [horario] decides (null
/// when it is a day off); otherwise [p]'s own `shiftStart`/`shiftEnd`, null
/// unless both ends are set.
({DateTime start, DateTime end})? shiftSpanOn(
  Person p,
  DateTime day, {
  HorarioIndex? horario,
}) {
  if (horario?.dayOf(p, day) case final d?) {
    return d.isShift ? d.spanOn() : null;
  }
  final start = p.shiftStart;
  final end = p.shiftEnd;
  if (start == null || end == null) return null;
  // From the date's fields, not by adding minutes, so on the day the
  // clocks change the shift still starts at its own hour (as `spanOn`).
  return (
    start: DateTime(day.year, day.month, day.day, 0, start),
    end: DateTime(
      day.year,
      day.month,
      day.day,
      0,
      end <= start ? end + 24 * 60 : end,
    ),
  );
}

/// [p]'s shift on [day]'s date, unless they are off that day (a folga or an
/// ausência, see [offLabelOn]).
({DateTime start, DateTime end})? _workingSpanOn(
  Person p,
  DateTime day,
  HorarioIndex? horario,
) => offLabelOn(p, day, horario: horario) == null
    ? shiftSpanOn(p, day, horario: horario)
    : null;

/// Who of [people] is inside their shift at [now] (a night shift from the day
/// before included), earliest start first, then by name.
List<OnShift> onShiftAt(
  List<Person> people,
  DateTime now, {
  HorarioIndex? horario,
}) {
  final today = _dateOnly(now);
  final found = <OnShift>[];
  for (final p in people) {
    for (final day in [
      DateTime(today.year, today.month, today.day - 1),
      today,
    ]) {
      final span = _workingSpanOn(p, day, horario);
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
({int dia, int noite}) shiftCountsOn(
  List<Person> people,
  DateTime day, {
  HorarioIndex? horario,
}) {
  var dia = 0;
  var noite = 0;
  for (final p in people) {
    final span = _workingSpanOn(p, day, horario);
    if (span == null) continue;
    final scheduled = horario?.dayOf(p, day);
    final night = scheduled != null
        ? scheduled.tipo == HorarioTipo.noite
        : span.start.hour >= 20 || span.end.day != span.start.day;
    if (night) {
      noite++;
    } else {
      dia++;
    }
  }
  return (dia: dia, noite: noite);
}

/// The Diárias still to do at [now], in the Tarefas order: [t] is the
/// service day's row (null when none was saved yet), [visivelDone] and
/// [automaticaDone] say whether a Listas 2.0 Visível or Automáticas was
/// saved that day (which tick the lists). A task marked Não feita isn't
/// pending. A Validades part counts from when its window opens (it can
/// still be marked after the window, until the day ends). [windowFor]
/// gives the windows a Chefe set (`TaskWindowService`).
List<String> pendingDailyTasks(
  DailyTasks? t, {
  required bool visivelDone,
  bool automaticaDone = false,
  required DateTime now,
  TaskWindow Function(String key)? windowFor,
}) {
  bool open(ValidadesTurno turno) =>
      validadesStateAt(turno, now, window: windowFor?.call(turno.taskKey)) !=
      ValidadesState.notYet;
  // Done, or marked Não feita (`DailyTasks.notDone`).
  bool settled(bool? done, String key) =>
      (done ?? false) || (t?.notDone.containsKey(key) ?? false);
  return [
    if (!settled(t?.kiwiAbertura, 'kiwi_abertura')) 'Kiwi Abertura',
    if (!settled(t?.alteracoesPreco, 'alteracoes_preco')) 'Alterações de Preço',
    if (!settled(t?.verificacaoTemperaturas, 'verificacao_temperaturas'))
      'Verificação de Temperaturas',
    if (!settled(t?.preenchimentoQuadro, 'preenchimento_quadro'))
      'Preenchimento do Quadro',
    if (!visivelDone && !settled(t?.listaVisivel, 'lista_visivel'))
      'Lista Visível',
    if (!automaticaDone && !settled(t?.listaAutomatica, 'lista_automatica'))
      'Lista Automática',
    if (!settled(t?.verificacaoValidades, 'verificacao_validades') &&
        open(ValidadesTurno.manha))
      ValidadesTurno.manha.label,
    if (!settled(t?.validadesNoite, 'validades_noite') &&
        open(ValidadesTurno.noite))
      ValidadesTurno.noite.label,
    if (!settled(t?.kiwiFecho, 'kiwi_fecho')) 'Kiwi Fecho',
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
