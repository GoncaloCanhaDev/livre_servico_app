import 'package:flutter/material.dart';

/// Where an error report or a suggestion stands, set by the app's admin
/// (`feedback.status` online, by [dbName]) and shown to everyone.
enum FeedbackStatus {
  novo('novo', 'Novo'),
  visto('visto', 'Visto'),
  emCurso('em_curso', 'Em curso'),
  resolvido('resolvido', 'Resolvido'),
  recusado('recusado', 'Não será feito');

  const FeedbackStatus(this.dbName, this.label);
  final String dbName;
  final String label;

  /// Still to deal with (the admin's "Por tratar").
  bool get isOpen => this != resolvido && this != recusado;

  /// The badge's colour (white text on it).
  Color get color => switch (this) {
    novo => Colors.blueGrey.shade600,
    visto => Colors.blue.shade700,
    emCurso => Colors.orange.shade800,
    resolvido => Colors.green.shade700,
    recusado => Colors.red.shade700,
  };

  /// Novo for anything unknown (a state added by a newer app).
  static FeedbackStatus fromName(Object? name) =>
      values.firstWhere((s) => s.dbName == name, orElse: () => novo);
}
