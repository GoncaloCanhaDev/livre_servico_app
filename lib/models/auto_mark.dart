import 'daily_tasks.dart';
import 'horario.dart';
import 'local_row.dart';
import 'names.dart';
import 'person.dart';
import 'planning.dart';
import 'task_window.dart';
import 'teams.dart';
import 'today.dart';
import 'weekly_tasks.dart';

/// A task the app marked done by itself after its window (see
/// `AutoMarkService`): when, and who confirmed it was really done. Kept on
/// the Diárias and Semanais rows by task key (`autoMarks`) and on a
/// `CustomTaskEntry` (`autoMark`). Changing who did it makes the mark a
/// manual one (the [AutoMark] goes).
class AutoMark {
  AutoMark({
    required this.at,
    this.confirmedByNames = const [],
    this.confirmedAt,
  });

  factory AutoMark.fromJson(Map<String, dynamic> j) => AutoMark(
    at: dateFromJsonOr(j['at'], noDate),
    confirmedByNames: stringsFromJson(j['confirmedByNames']),
    confirmedAt: dateFromJson(j['confirmedAt']),
  );

  DateTime at;
  List<String> confirmedByNames;
  DateTime? confirmedAt;

  bool get confirmed => confirmedAt != null;

  Map<String, dynamic> toJson() => {
    'at': dateToJson(at),
    'confirmedByNames': confirmedByNames,
    'confirmedAt': dateToJson(confirmedAt),
  };
}

Map<String, AutoMark> autoMarkMapFromJson(Object? v) => {
  if (v is Map)
    for (final e in v.entries)
      if (e.key is String && e.value is Map)
        e.key as String: AutoMark.fromJson(
          Map<String, dynamic>.from(e.value as Map),
        ),
};

Map<String, dynamic> autoMarkMapToJson(Map<String, AutoMark> m) => {
  for (final e in m.entries) e.key: e.value.toJson(),
};

AutoMark? autoMarkFromJson(Object? v) =>
    v is Map ? AutoMark.fromJson(Map<String, dynamic>.from(v)) : null;

/// The `pendingCounts` key saying a Validades window still has to say how
/// many artigos were left.
String leftKey(String taskKey) => '$taskKey:left';

/// The Livre Serviço people of [people] working at some point inside
/// [span] (a shift starting the date before included; days off skipped,
/// see [offLabelOn]): their full names, earliest shift first, then by name.
/// Empty when nobody was there, and the task is then left unmarked.
List<String> autoMarkPeople(
  List<Person> people,
  ({DateTime start, DateTime end}) span, {
  HorarioIndex? horario,
}) {
  final first = DateTime(span.start.year, span.start.month, span.start.day - 1);
  final last = DateTime(span.end.year, span.end.month, span.end.day);
  final found = <({String name, DateTime start})>[];
  for (final p in people) {
    if (p.team != livreServicoId) continue;
    DateTime? earliest;
    for (
      var day = first;
      !day.isAfter(last);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      if (offLabelOn(p, day, horario: horario) != null) continue;
      final shift = shiftSpanOn(p, day, horario: horario);
      if (shift == null) continue;
      if (shift.start.isBefore(span.end) && shift.end.isAfter(span.start)) {
        earliest ??= shift.start;
      }
    }
    if (earliest != null) found.add((name: p.fullName, start: earliest));
  }
  found.sort((a, b) {
    final byStart = a.start.compareTo(b.start);
    return byStart != 0 ? byStart : a.name.compareTo(b.name);
  });
  return [for (final f in found) f.name];
}

/// How many times someone was credited with a task lately and the last
/// time (the period's day), for [pickAutoMarkPerson].
typedef TaskCredit = ({int times, DateTime last});

/// Adds one credit on [day] to [credit].
TaskCredit addCredit(TaskCredit? credit, DateTime day) => (
  times: (credit?.times ?? 0) + 1,
  last: credit == null || day.isAfter(credit.last) ? day : credit.last,
);

/// The one person an automatic mark suggests, in turn: of [candidates]
/// (those on shift, in [autoMarkPeople]'s order), whoever [credited] (by
/// name, over `AutoMarkService.rotationDays`) credits the fewest times,
/// then the longest ago (never first), then the earlier in [candidates].
/// Null when there is nobody.
String? pickAutoMarkPerson(
  List<String> candidates,
  Map<String, TaskCredit> credited,
) {
  String? best;
  TaskCredit? bestCredit;
  for (final name in candidates) {
    final c = credited[name];
    if (best == null) {
      best = name;
      bestCredit = c;
      continue;
    }
    final times = c?.times ?? 0;
    final bestTimes = bestCredit?.times ?? 0;
    final better =
        times < bestTimes ||
        (times == bestTimes &&
            bestCredit != null &&
            (c == null || c.last.isBefore(bestCredit.last)));
    if (better) {
      best = name;
      bestCredit = c;
    }
  }
  return best;
}

/// Whether [key] of [t] was marked, feita or não feita.
bool dailySettled(DailyTasks t, String key) =>
    dailyDone(t, key) || t.notDone.containsKey(key);

bool dailyDone(DailyTasks t, String key) => switch (key) {
  'kiwi_abertura' => t.kiwiAbertura,
  'alteracoes_preco' => t.alteracoesPreco,
  'verificacao_temperaturas' => t.verificacaoTemperaturas,
  'preenchimento_quadro' => t.preenchimentoQuadro,
  'lista_visivel' => t.listaVisivel,
  'lista_automatica' => t.listaAutomatica,
  'verificacao_validades' => t.verificacaoValidades,
  'validades_noite' => t.validadesNoite,
  'kiwi_fecho' => t.kiwiFecho,
  _ => false,
};

/// Sets [key] of [t] done by [who] (or, when [done] is false, not done and
/// with no names). Leaves the count, `autoMarks` and `pendingCounts` alone.
void setDailyDone(
  DailyTasks t,
  String key,
  List<String> who, {
  bool done = true,
}) {
  final names = done ? who : <String>[];
  switch (key) {
    case 'kiwi_abertura':
      t.kiwiAbertura = done;
      t.kiwiAberturaByNames = names;
    case 'alteracoes_preco':
      t.alteracoesPreco = done;
      t.alteracoesPrecoByNames = names;
    case 'verificacao_temperaturas':
      t.verificacaoTemperaturas = done;
      t.verificacaoTemperaturasByNames = names;
    case 'preenchimento_quadro':
      t.preenchimentoQuadro = done;
      t.preenchimentoQuadroByNames = names;
    case 'lista_visivel':
      t.listaVisivel = done;
      t.listaVisivelByNames = names;
    case 'lista_automatica':
      t.listaAutomatica = done;
      t.listaAutomaticaByNames = names;
    case 'verificacao_validades':
      t.verificacaoValidades = done;
      t.verificacaoValidadesByNames = names;
    case 'validades_noite':
      t.validadesNoite = done;
      t.validadesNoiteByNames = names;
    case 'kiwi_fecho':
      t.kiwiFecho = done;
      t.kiwiFechoByNames = names;
  }
}

/// The names [key] of [t] is done by.
List<String> dailyNames(DailyTasks t, String key) => switch (key) {
  'kiwi_abertura' => resolveNames(t.kiwiAberturaByNames, t.kiwiAberturaBy),
  'alteracoes_preco' => resolveNames(
    t.alteracoesPrecoByNames,
    t.alteracoesPrecoBy,
  ),
  'verificacao_temperaturas' => resolveNames(
    t.verificacaoTemperaturasByNames,
    t.verificacaoTemperaturasBy,
  ),
  'preenchimento_quadro' => resolveNames(
    t.preenchimentoQuadroByNames,
    t.preenchimentoQuadroBy,
  ),
  'verificacao_validades' => resolveNames(
    t.verificacaoValidadesByNames,
    t.verificacaoValidadesBy,
  ),
  'lista_visivel' => t.listaVisivelByNames,
  'lista_automatica' => t.listaAutomaticaByNames,
  'validades_noite' => t.validadesNoiteByNames,
  'kiwi_fecho' => resolveNames(t.kiwiFechoByNames, t.kiwiFechoBy),
  _ => const [],
};

/// The automatic mark: [key] of [t] done by [who], its number (if any)
/// left to fill in, and the [AutoMark] at [now].
void autoMarkDaily(DailyTasks t, String key, List<String> who, DateTime now) {
  setDailyDone(t, key, who);
  t.autoMarks = {...t.autoMarks, key: AutoMark(at: now)};
  t.pendingCounts = {
    ...t.pendingCounts,
    if (countTaskKeys.contains(key)) key,
    if (key == 'verificacao_validades' || key == 'validades_noite')
      leftKey(key),
  }.toList();
}

/// A Listas 2.0 send by [who] ticks [key] (`lista_visivel` or
/// `lista_automatica`) of [t]: marked when it wasn't, theirs when the app
/// had marked it (the [AutoMark] goes), and its number (a Visível's itens)
/// fills the one pending. A Não feita stays. Returns whether [t] changed
/// and whether that was a correction (`DailyTasksService.save(edited:)`).
({bool changed, bool edited}) tickListTask(
  DailyTasks t,
  String key,
  List<String> who,
) {
  if (t.notDone.containsKey(key)) return (changed: false, edited: false);
  if (!dailyDone(t, key)) {
    setDailyDone(t, key, who);
    return (changed: true, edited: false);
  }
  var edited = false;
  if (t.autoMarks.containsKey(key) && who.isNotEmpty) {
    setDailyDone(t, key, who);
    t.autoMarks = {...t.autoMarks}..remove(key);
    edited = true;
  }
  if (t.pendingCounts.contains(key)) {
    t.pendingCounts = [...t.pendingCounts]..remove(key);
    edited = true;
  }
  return (changed: edited, edited: edited);
}

bool weeklyDone(WeeklyTasks t, String key) => switch (key) {
  'verificar_1a' => t.verificar1a,
  'verificar_4a' => t.verificar4a,
  'limpeza_maquina_voltas' => t.limpezaMaquinaVoltas,
  _ => false,
};

bool weeklySettled(WeeklyTasks t, String key) =>
    weeklyDone(t, key) || t.notDone.containsKey(key);

void setWeeklyDone(
  WeeklyTasks t,
  String key,
  List<String> who, {
  bool done = true,
}) {
  final names = done ? who : <String>[];
  switch (key) {
    case 'verificar_1a':
      t.verificar1a = done;
      t.verificar1aByNames = names;
    case 'verificar_4a':
      t.verificar4a = done;
      t.verificar4aByNames = names;
    case 'limpeza_maquina_voltas':
      t.limpezaMaquinaVoltas = done;
      t.limpezaMaquinaVoltasByNames = names;
  }
}

List<String> weeklyNames(WeeklyTasks t, String key) => switch (key) {
  'verificar_1a' => resolveNames(t.verificar1aByNames, t.verificar1aBy),
  'verificar_4a' => resolveNames(t.verificar4aByNames, t.verificar4aBy),
  'limpeza_maquina_voltas' => resolveNames(
    t.limpezaMaquinaVoltasByNames,
    t.limpezaMaquinaVoltasBy,
  ),
  _ => const [],
};

void autoMarkWeekly(WeeklyTasks t, String key, List<String> who, DateTime now) {
  setWeeklyDone(t, key, who);
  t.autoMarks = {...t.autoMarks, key: AutoMark(at: now)};
  if (countTaskKeys.contains(key)) {
    t.pendingCounts = {...t.pendingCounts, key}.toList();
  }
}
