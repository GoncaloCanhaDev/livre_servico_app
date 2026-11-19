import 'task_window.dart';

/// The two parts of the daily Verificação de Validades. Both windows sit
/// inside one service day (05:00 to 05:00, see `currentServiceDay`): Manhã
/// opens with the day, Noite closes with it.
enum ValidadesTurno {
  manha('Validades · Manhã'),
  noite('Validades · Noite');

  const ValidadesTurno(this.label);
  final String label;

  /// The key of its task (`notDone`, `TaskWindow.taskKey`).
  String get taskKey => switch (this) {
    ValidadesTurno.manha => 'verificacao_validades',
    ValidadesTurno.noite => 'validades_noite',
  };

  /// Its hours until a Chefe changes them: Manhã 05–14, Noite 19–05.
  TaskWindow get defaultWindow => defaultTaskWindow(taskKey);
}

enum ValidadesState { notYet, open, closed }

/// Whether [turno]'s window for the service day [now] falls in has not
/// opened yet, is open, or has closed: its [window] when a Chefe set one
/// (Definições → Horas das tarefas), otherwise the turno's own hours.
ValidadesState validadesStateAt(
  ValidadesTurno turno,
  DateTime now, {
  TaskWindow? window,
}) {
  final w = window ?? turno.defaultWindow;
  final m = serviceMinutes(now.hour * 60 + now.minute);
  if (m < serviceMinutes(w.opensAt)) return ValidadesState.notYet;
  if (m < serviceMinutes(w.closesAt, close: true)) return ValidadesState.open;
  return ValidadesState.closed;
}

/// "14h", "7h30".
String _hourText(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h${m.toString().padLeft(2, '0')}';
}

/// The notes under a Validades task, from its [window].
extension ValidadesWindowNotes on TaskWindow {
  String get openNote => 'Aberta até às ${_hourText(closesAt)}';
  String get notYetNote => 'Abre às ${_hourText(opensAt)}';

  /// Past the window it can still be marked until the service day ends.
  String get lateNote =>
      'Era até às ${_hourText(closesAt)} — ainda se pode marcar';
}

/// Where the artigos left in [turno] of [serviceDay] go: the Manhã's to the
/// same day's Noite, the Noite's to the next service day's Manhã.
(DateTime, ValidadesTurno) nextValidadesWindow(
  DateTime serviceDay,
  ValidadesTurno turno,
) => switch (turno) {
  ValidadesTurno.manha => (serviceDay, ValidadesTurno.noite),
  ValidadesTurno.noite => (
    DateTime(serviceDay.year, serviceDay.month, serviceDay.day + 1, 5),
    ValidadesTurno.manha,
  ),
};

/// Says where [left] artigos go, for the leftover question and the notes.
String carriedToText(ValidadesTurno turno) => switch (turno) {
  ValidadesTurno.manha => 'passam para a Noite',
  ValidadesTurno.noite => 'passam para a Manhã seguinte',
};

/// Under a window's count: where its carried artigos came from.
String carriedFromText(ValidadesTurno turno, int n) => switch (turno) {
  ValidadesTurno.manha => 'Inclui $n da Noite anterior',
  ValidadesTurno.noite => 'Inclui $n da Manhã',
};
