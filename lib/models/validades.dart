/// The two parts of the daily Verificação de Validades. Both windows sit
/// inside one service day (05:00 to 05:00, see `currentServiceDay`): Manhã
/// opens with the day, Noite closes with it.
enum ValidadesTurno {
  manha('Validades · Manhã', 5, 14),
  noite('Validades · Noite', 19, 5);

  const ValidadesTurno(this.label, this.opensAt, this.closesAt);
  final String label;

  /// Hours of the day the window opens and closes.
  final int opensAt;
  final int closesAt;

  String get openNote => 'Aberta até às ${closesAt}h';
  String get notYetNote => 'Abre às ${opensAt}h';
}

enum ValidadesState { notYet, open, closed }

/// Whether [turno]'s window for the service day [now] falls in has not
/// opened yet, is open, or has closed.
ValidadesState validadesStateAt(ValidadesTurno turno, DateTime now) {
  // Hours since the service day started at 05:00.
  int sinceDayStart(int hour) => (hour - 5) % 24;
  final h = sinceDayStart(now.hour);
  final opens = sinceDayStart(turno.opensAt);
  // A window closing at 05:00 closes when the day ends.
  final closes = turno.closesAt == 5 ? 24 : sinceDayStart(turno.closesAt);
  if (h < opens) return ValidadesState.notYet;
  if (h < closes) return ValidadesState.open;
  return ValidadesState.closed;
}
