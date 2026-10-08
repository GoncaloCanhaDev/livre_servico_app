import 'person.dart';

/// A chefe position within a team. Stored on [Person.chefe] by name.
enum ChefeSlot {
  chefe('Chefe'),
  dia('Chefe de dia'),
  noite('Chefe de noite');

  const ChefeSlot(this.label);
  final String label;
}

/// Livre Serviço's day and night halves. Stored on [Person.turno] by name.
enum Turno {
  dia('Dia'),
  noite('Noite');

  const Turno(this.label);
  final String label;
}

/// The Livre Serviço chefe slot that leads [turno].
ChefeSlot chefeSlotForTurno(Turno turno) =>
    turno == Turno.dia ? ChefeSlot.dia : ChefeSlot.noite;

/// One of the store's fixed teams. [id] is what [Person.team] stores, so
/// [name] can change without touching saved data.
class Team {
  const Team(
    this.id,
    this.name,
    this.chefeSlots, {
    this.hasTurnos = false,
    this.hasSupervisors = false,
    this.hasSegundaLinha = false,
    this.openByDefault = false,
  });

  final String id;
  final String name;

  /// Whether members are split into [Turno]s (only Livre Serviço).
  final bool hasTurnos;

  /// Whether members can be tagged Supervisor (only Frente de Loja).
  final bool hasSupervisors;

  /// Whether members can be tagged Segunda Linha.
  final bool hasSegundaLinha;

  /// Whether the team's Pessoas section(s) start expanded.
  final bool openByDefault;

  /// The team's chefe positions, in display order (empty for teams without
  /// a chefe). Each is held by at most one (non-deleted) member.
  final List<ChefeSlot> chefeSlots;
}

/// The Livre Serviço team's id; the horários are only for this team.
const livreServicoId = 'livre_servico';

/// Every team, in the order the Pessoas list shows them.
const teams = [
  Team(
    livreServicoId,
    'Livre Serviço',
    [ChefeSlot.dia, ChefeSlot.noite],
    hasTurnos: true,
    openByDefault: true,
  ),
  Team('gerencia', 'Gerência', [ChefeSlot.chefe]),
  Team('charcutaria', 'Charcutaria', [ChefeSlot.chefe], hasSegundaLinha: true),
  Team('meal_solutions', 'Meal Solutions', [
    ChefeSlot.chefe,
  ], hasSegundaLinha: true),
  Team('talho', 'Talho', [ChefeSlot.chefe], hasSegundaLinha: true),
  Team('peixaria', 'Peixaria', [ChefeSlot.chefe], hasSegundaLinha: true),
  Team('frente_de_loja', 'Frente de Loja', [], hasSupervisors: true),
  Team('bem_estar', 'Bem Estar', []),
  Team('padaria', 'Padaria', [ChefeSlot.chefe], hasSegundaLinha: true),
  Team('fruta', 'Fruta', [ChefeSlot.chefe], hasSegundaLinha: true),
];

/// The team with [id], or null for null/unknown ids (shown as "Sem equipa").
Team? teamById(String? id) {
  for (final t in teams) {
    if (t.id == id) return t;
  }
  return null;
}

/// [p]'s chefe slot, or null if they're a member, have no (known) team, or
/// [Person.chefe] isn't one of their team's slots.
ChefeSlot? chefeSlotOf(Person p) {
  final team = teamById(p.team);
  if (team == null) return null;
  for (final s in team.chefeSlots) {
    if (s.name == p.chefe) return s;
  }
  return null;
}

/// Whether [p] is tagged Supervisor: flagged, in a team that has
/// supervisors, and not a chefe.
bool isSupervisor(Person p) =>
    p.supervisor &&
    teamById(p.team)?.hasSupervisors == true &&
    chefeSlotOf(p) == null;

/// Whether [p] is tagged Segunda Linha: flagged, in a team that has it, and
/// not a chefe.
bool isSegundaLinha(Person p) =>
    p.segundaLinha &&
    teamById(p.team)?.hasSegundaLinha == true &&
    chefeSlotOf(p) == null;

/// [p]'s badge labels in display order: "Chefe" if they hold a chefe slot,
/// then the tags their team allows (Supervisor, Segunda Linha) and
/// Permanência.
List<String> roleTagsOf(Person p) => [
  if (chefeSlotOf(p) != null) 'Chefe',
  if (isSupervisor(p)) 'Supervisor',
  if (isSegundaLinha(p)) 'Segunda Linha',
  if (p.permanencia) 'Permanência',
];

/// [p]'s turno, or null if their team isn't split by turno or they have no
/// valid one. A chefe's turno is their slot's, whatever [Person.turno] says.
Turno? turnoOf(Person p) {
  if (teamById(p.team)?.hasTurnos != true) return null;
  switch (chefeSlotOf(p)) {
    case ChefeSlot.dia:
      return Turno.dia;
    case ChefeSlot.noite:
      return Turno.noite;
    case ChefeSlot.chefe || null:
      return Turno.values.asNameMap()[p.turno];
  }
}

/// Whether [a] and [b] are the same person: the same object, or the same
/// (non-empty) syncUuid, e.g. the form's copy and the one read from Isar.
bool _same(Person a, Person b) =>
    identical(a, b) || (a.syncUuid.isNotEmpty && a.syncUuid == b.syncUuid);

/// The non-deleted person in [all] other than [except] who holds [slot] in
/// team [teamId], if any.
Person? chefeHolder(
  List<Person> all,
  String teamId,
  ChefeSlot slot, {
  required Person except,
}) {
  for (final p in all) {
    if (p.syncDeletedAt != null || _same(p, except)) continue;
    if (p.team == teamId && chefeSlotOf(p) == slot) return p;
  }
  return null;
}

/// People in [all] who must lose their chefe slot when [saving] is saved:
/// anyone else (non-deleted) holding [saving]'s team and slot.
List<Person> chefeConflicts(Person saving, List<Person> all) {
  final slot = chefeSlotOf(saving);
  if (slot == null) return const [];
  return [
    for (final p in all)
      if (p.syncDeletedAt == null &&
          !_same(p, saving) &&
          p.team == saving.team &&
          chefeSlotOf(p) == slot)
        p,
  ];
}
