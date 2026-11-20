import 'package:intl/intl.dart';

/// One part of Definições → Diagnóstico (Sincronização, Tarefas marcadas
/// sozinhas, Este aparelho): a title and its lines.
class DiagSection {
  const DiagSection(this.title, this.lines);

  final String title;
  final List<DiagLine> lines;
}

/// A label and its value; [warn] when it shows something wrong.
class DiagLine {
  const DiagLine(this.label, this.value, {this.warn = false});

  final String label;
  final String value;
  final bool warn;
}

/// "14:02:31" today, "18/11 14:02:31" another day, "—" for none.
String diagTimeText(DateTime? t, {DateTime? now}) {
  if (t == null) return '—';
  final today = now ?? DateTime.now();
  final sameDay =
      t.year == today.year && t.month == today.month && t.day == today.day;
  final time = DateFormat.Hms('pt_PT').format(t);
  return sameDay ? time : '${DateFormat('dd/MM', 'pt_PT').format(t)} $time';
}

/// How far this phone's clock is from the server's: "Certo" under two
/// seconds, else e.g. "Adiantado 3 min 12 s" (the phone shows a later time
/// than the server) or "Atrasado 8 s".
String clockOffsetText(Duration serverMinusPhone) {
  final abs = serverMinusPhone.abs();
  if (abs < const Duration(seconds: 2)) return 'Certo';
  final parts = [
    if (abs.inHours > 0) '${abs.inHours} h',
    if (abs.inMinutes % 60 > 0) '${abs.inMinutes % 60} min',
    if (abs.inSeconds % 60 > 0) '${abs.inSeconds % 60} s',
  ];
  // The server ahead of the phone: the phone is behind (atrasado).
  final side = serverMinusPhone.isNegative ? 'Adiantado' : 'Atrasado';
  return '$side ${parts.join(' ')}';
}

/// Whether the clock is off enough to say so (a minute): marks are stamped
/// with the server's time, so it still works, but it's worth fixing.
bool clockOffsetWorrying(Duration serverMinusPhone) =>
    serverMinusPhone.abs() >= const Duration(minutes: 1);

/// Why this device doesn't mark tasks by itself right now, or null when it
/// does (see `AutoMarkService.canRun`).
String? autoMarkBlockedReason({
  required bool canAutoMark,
  required bool connected,
  required bool synced,
}) {
  if (!canAutoMark) {
    return 'Este aparelho não marca tarefas sozinho: só os da Gerência, '
        'os Chefes de Livre Serviço e o administrador, que veem o horário '
        'de todos.';
  }
  if (connected && !synced) {
    return 'À espera da primeira sincronização desta sessão.';
  }
  return null;
}

/// "1,4 s" or "320 ms".
String durationText(Duration d) => d.inMilliseconds < 1000
    ? '${d.inMilliseconds} ms'
    : '${NumberFormat('0.0', 'pt_PT').format(d.inMilliseconds / 1000)} s';

/// The whole report as plain text, to share with whoever helps.
String diagnosticText(
  List<DiagSection> sections, {
  required DateTime at,
  required String version,
}) {
  final out = StringBuffer()
    ..writeln('Diagnóstico — Livre Serviço Companion $version')
    ..writeln(DateFormat('dd/MM/y HH:mm:ss', 'pt_PT').format(at));
  for (final s in sections) {
    out
      ..writeln()
      ..writeln(s.title.toUpperCase());
    for (final l in s.lines) {
      out.writeln('${l.warn ? '! ' : ''}${l.label}: ${l.value}');
    }
  }
  return out.toString();
}
