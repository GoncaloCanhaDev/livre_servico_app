import 'local_row.dart';

/// When a task is done in the service day (05:00 to 05:00) and whether the
/// app marks it by itself once that time is over (`AutoMarkService`). One
/// row per task, keyed online by [taskKey]; with no row,
/// [defaultTaskWindow]. Chefes edit them in Definições → Horas das tarefas.
class TaskWindow with SyncFields {
  TaskWindow({
    this.taskKey = '',
    this.opensAt = _dayStart,
    this.closesAt = _dayStart,
    this.auto = true,
  });

  factory TaskWindow.fromJson(Map<String, dynamic> j) {
    final w = TaskWindow(
      taskKey: stringFromJson(j['taskKey']),
      opensAt: intFromJson(j['opensAt'], fallback: _dayStart),
      closesAt: intFromJson(j['closesAt'], fallback: _dayStart),
      auto: boolFromJson(j['auto'], fallback: true),
    );
    syncFieldsFromJson(w, j);
    return w;
  }

  /// A fixed task's key (the keys of `notDone`) or a `CustomTask.syncUuid`.
  String taskKey;

  /// Minutes after midnight. A time before 05:00 is on the next date; a
  /// close at 05:00 is the end of the service day.
  int opensAt;
  int closesAt;

  /// Whether the app marks the task by itself after [closesAt].
  bool auto;

  TaskWindow copy() =>
      TaskWindow(
          taskKey: taskKey,
          opensAt: opensAt,
          closesAt: closesAt,
          auto: auto,
        )
        ..id = id
        ..syncUuid = syncUuid
        ..syncUpdatedAt = syncUpdatedAt
        ..syncDeletedAt = syncDeletedAt
        ..synced = synced;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'taskKey': taskKey,
    'opensAt': opensAt,
    'closesAt': closesAt,
    'auto': auto,
  };
}

const _dayStart = 5 * 60;

/// The Diárias, in the Tarefas order.
const fixedDailyTaskKeys = [
  'kiwi_abertura',
  'alteracoes_preco',
  'verificacao_temperaturas',
  'preenchimento_quadro',
  'lista_visivel',
  'lista_automatica',
  'verificacao_validades',
  'validades_noite',
  'kiwi_fecho',
];

const fixedWeeklyTaskKeys = [
  'verificar_1a',
  'verificar_4a',
  'limpeza_maquina_voltas',
];

/// The weekday each Semanal is done on.
const taskDueWeekday = {
  'verificar_1a': DateTime.tuesday,
  'verificar_4a': DateTime.tuesday,
  'limpeza_maquina_voltas': DateTime.saturday,
};

/// The fixed tasks' names, for the windows screen and the Home card.
const fixedTaskLabels = {
  'kiwi_abertura': 'Kiwi Abertura',
  'alteracoes_preco': 'Alterações de Preço',
  'verificacao_temperaturas': 'Verificação de Temperaturas',
  'preenchimento_quadro': 'Preenchimento do Quadro',
  'lista_visivel': 'Lista Visível',
  'lista_automatica': 'Lista Automática',
  'verificacao_validades': 'Validades · Manhã',
  'validades_noite': 'Validades · Noite',
  'kiwi_fecho': 'Kiwi Fecho',
  'verificar_1a': 'Verificar 1ª Sheet',
  'verificar_4a': 'Verificar 4ª Sheet',
  'limpeza_maquina_voltas': 'Limpeza da Máquina Voltas',
};

/// The tasks with a number to fill in (it can be left for later; the Lista
/// Visível's is a Visível's itens picados).
const countTaskKeys = {
  'alteracoes_preco',
  'lista_visivel',
  'verificacao_validades',
  'validades_noite',
  'verificar_1a',
  'verificar_4a',
};

/// The window a task has until a Chefe changes it; any task not listed
/// (the Semanais, custom tasks) takes the whole service day.
TaskWindow defaultTaskWindow(String key) {
  final (opens, closes) = switch (key) {
    'kiwi_abertura' => (5 * 60, 9 * 60),
    'alteracoes_preco' => (5 * 60, 7 * 60 + 30),
    'verificacao_temperaturas' => (5 * 60, 12 * 60),
    'preenchimento_quadro' => (5 * 60, 14 * 60),
    'lista_visivel' => (5 * 60, 14 * 60),
    'verificacao_validades' => (5 * 60, 14 * 60),
    'validades_noite' => (19 * 60, 5 * 60),
    'kiwi_fecho' => (19 * 60, 22 * 60),
    _ => (_dayStart, _dayStart),
  };
  return TaskWindow(taskKey: key, opensAt: opens, closesAt: closes);
}

/// Tasks added after the app started marking by itself: windows opening
/// before this moment are never marked for them (nor counted unmarked in
/// Estatísticas), so the days before the update aren't filled in.
final taskAutoMarkSince = {
  'lista_visivel': DateTime(2026, 11, 22, 5),
  'lista_automatica': DateTime(2026, 11, 22, 5),
};

/// Minutes since the service day started at 05:00 (0 to 1439); a close at
/// 05:00 is 1440, the day's end.
int serviceMinutes(int minutes, {bool close = false}) {
  final m = (minutes - _dayStart) % (24 * 60);
  return close && m == 0 ? 24 * 60 : m;
}

/// Whether [w] opens before it closes within the service day.
bool windowValid(TaskWindow w) =>
    serviceMinutes(w.opensAt) < serviceMinutes(w.closesAt, close: true);

/// When [w] runs on [serviceDay] (its 05:00).
({DateTime start, DateTime end}) windowSpan(TaskWindow w, DateTime serviceDay) {
  // Built from the date (not by adding a Duration), so a DST change that
  // day doesn't move it.
  DateTime at(int minutes) =>
      DateTime(serviceDay.year, serviceDay.month, serviceDay.day, 5, minutes);
  return (
    start: at(serviceMinutes(w.opensAt)),
    end: at(serviceMinutes(w.closesAt, close: true)),
  );
}

/// "07:30".
String minutesText(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutes % 60).toString().padLeft(2, '0')}';
