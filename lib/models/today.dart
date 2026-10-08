import 'daily_tasks.dart';
import 'horario.dart';
import 'person.dart';
import 'planning.dart';
import 'teams.dart';
import 'validades.dart';

/// A person inside their horário shift, and that shift.
typedef OnShift = ({Person person, HorarioCodigo shift});

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The shift [p] has on [day]'s date in [index], with their own entrada and
/// saída when set, or null (no line, an absence code, or an ausência entered
/// in the app).
HorarioCodigo? _shiftOn(HorarioIndex index, Person p, DateTime day) {
  if (ausenciaOn(p, day) != null) return null;
  return index.shiftOn(p, day);
}

/// Who of [people] is inside their shift at [now] (a night shift from the day
/// before included), earliest start first, then by name.
List<OnShift> onShiftAt(HorarioIndex index, List<Person> people, DateTime now) {
  final today = _dateOnly(now);
  final found = <(DateTime, OnShift)>[];
  for (final p in people) {
    for (final day in [
      DateTime(today.year, today.month, today.day - 1),
      today,
    ]) {
      final shift = _shiftOn(index, p, day);
      if (shift == null) continue;
      final span = shift.spanOn(day);
      if (!now.isBefore(span.start) && now.isBefore(span.end)) {
        found.add((span.start, (person: p, shift: shift)));
        break;
      }
    }
  }
  found.sort((a, b) {
    final byStart = a.$1.compareTo(b.$1);
    return byStart != 0
        ? byStart
        : a.$2.person.fullName.compareTo(b.$2.person.fullName);
  });
  return [for (final (_, s) in found) s];
}

/// How many of [people] have a day and a night shift on [day]'s date.
({int dia, int noite}) shiftCountsOn(
  HorarioIndex index,
  List<Person> people,
  DateTime day,
) {
  var dia = 0;
  var noite = 0;
  for (final p in people) {
    final shift = _shiftOn(index, p, day);
    if (shift == null) continue;
    if (shift.noturno) {
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
