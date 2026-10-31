import 'person.dart';

/// A person's role, from Operador (level 1) to Gerente de Loja (level 5).
/// Stored on [Person.role] by name — never by index. Each level can do
/// everything the levels below it can (see `StoreAccess`).
enum Role {
  operador('Operador', 1),
  segundaLinha('Segunda Linha', 2),
  supervisor('Supervisor', 2),
  chefeSeccao('Chefe de Secção', 3),
  gestorArea('Gestor de Área', 4),
  secretaria('Secretária de Loja', 4),
  gerente('Gerente de Loja', 5);

  const Role(this.label, this.level);
  final String label;
  final int level;
}

/// Whether at most one (non-deleted) person holds [r]: one Chefe de Secção
/// per team (per turno in Livre Serviço), one Gerente de Loja per store.
bool isSingleHolder(Role r) => r == Role.chefeSeccao || r == Role.gerente;

/// Before 0.68.0, a chefe position within a team, stored on [Person.chefe]
/// by name. Only read to derive the [Role] of rows saved before then.
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

  /// Before 0.68.0, whether members could be tagged Supervisor (only Frente
  /// de Loja): read for rows without a [Person.role].
  final bool hasSupervisors;

  /// Before 0.68.0, whether members could be tagged Segunda Linha: read for
  /// rows without a [Person.role].
  final bool hasSegundaLinha;

  /// Whether the team's Pessoas section(s) start expanded.
  final bool openByDefault;

  /// Before 0.68.0, the team's chefe positions (empty for teams without a
  /// chefe): read for rows without a [Person.role].
  final List<ChefeSlot> chefeSlots;
}

/// The Livre Serviço team's id; the horários are only for this team.
const livreServicoId = 'livre_servico';

/// The Gerência team's id: the only team with levels 4 and 5.
const gerenciaId = 'gerencia';

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

/// [p]'s chefe slot before 0.68.0, or null if they were a member, have no
/// (known) team, or [Person.chefe] isn't one of their team's slots.
ChefeSlot? _legacyChefeSlot(Person p) {
  final team = teamById(p.team);
  if (team == null) return null;
  for (final s in team.chefeSlots) {
    if (s.name == p.chefe) return s;
  }
  return null;
}

/// The roles a person in team [teamId] may have, lowest first: levels 1–3
/// in every team, all of them in Gerência, only Operador with no (known)
/// team.
List<Role> rolesIn(String? teamId) {
  if (teamById(teamId) == null) return const [Role.operador];
  if (teamId == gerenciaId) return Role.values;
  return [
    for (final r in Role.values)
      if (r.level <= 3) r,
  ];
}

/// [p]'s role: [Person.role] when their team allows it, Operador when it
/// doesn't. Rows saved before 0.68.0 (no role) take it from the old fields:
/// Gerência's chefe is Gerente de Loja and the rest of Gerência Gestor de
/// Área, another team's chefe Chefe de Secção, then Supervisor and Segunda
/// Linha where the team had them. `person_role` in `supabase/migrations`
/// does the same.
Role roleOf(Person p) {
  final allowed = rolesIn(p.team);
  if (p.role case final name?) {
    final r = Role.values.asNameMap()[name];
    return r != null && allowed.contains(r) ? r : Role.operador;
  }
  final team = teamById(p.team);
  if (team == null) return Role.operador;
  if (team.id == gerenciaId) {
    return _legacyChefeSlot(p) != null ? Role.gerente : Role.gestorArea;
  }
  if (_legacyChefeSlot(p) != null) return Role.chefeSeccao;
  if (p.supervisor && team.hasSupervisors) return Role.supervisor;
  if (p.segundaLinha && team.hasSegundaLinha) return Role.segundaLinha;
  return Role.operador;
}

/// [p]'s authority level, 1 (Operador) to 5 (Gerente de Loja).
int levelOf(Person p) => roleOf(p).level;

/// [p]'s role, team and turno, as Conta shows them: "Chefe de Secção ·
/// Talho", "Operador · Livre Serviço · Noite", "Operador · Sem equipa".
String roleLineOf(Person p) => [
  roleOf(p).label,
  teamById(p.team)?.name ?? 'Sem equipa',
  ?turnoOf(p)?.label,
].join(' · ');

/// [p]'s badge labels in display order: their role from level 2 up, then
/// Permanência.
List<String> roleTagsOf(Person p) => [
  if (roleOf(p) case final r when r.level >= 2) r.label,
  if (p.permanencia) 'Permanência',
];

/// [p]'s turno, or null if their team isn't split by turno or they have no
/// valid one. A chefe from before 0.68.0 (no [Person.role]) is on their
/// slot's turno, whatever [Person.turno] says.
Turno? turnoOf(Person p) {
  if (teamById(p.team)?.hasTurnos != true) return null;
  if (p.role == null) {
    switch (_legacyChefeSlot(p)) {
      case ChefeSlot.dia:
        return Turno.dia;
      case ChefeSlot.noite:
        return Turno.noite;
      case ChefeSlot.chefe || null:
    }
  }
  return Turno.values.asNameMap()[p.turno];
}

/// Whether [a] and [b] are the same person: the same object, or the same
/// (non-empty) syncUuid, e.g. the form's copy and the one read from the database.
bool _same(Person a, Person b) =>
    identical(a, b) || (a.syncUuid.isNotEmpty && a.syncUuid == b.syncUuid);

/// People in [all] who must lose their role when [saving] is saved: anyone
/// else (non-deleted) holding the same single-holder role — Gerente de Loja
/// anywhere, Chefe de Secção in the same team (and turno, in Livre
/// Serviço).
List<Person> roleConflicts(Person saving, List<Person> all) {
  final role = roleOf(saving);
  if (!isSingleHolder(role)) return const [];
  final byTurno = teamById(saving.team)?.hasTurnos == true;
  return [
    for (final p in all)
      if (p.syncDeletedAt == null &&
          !_same(p, saving) &&
          roleOf(p) == role &&
          (role == Role.gerente ||
              (p.team == saving.team &&
                  (!byTurno || turnoOf(p) == turnoOf(saving)))))
        p,
  ];
}

/// Whoever else holds [saving]'s single-holder role, if anyone (see
/// [roleConflicts]).
Person? roleHolder(List<Person> all, Person saving) =>
    roleConflicts(saving, all).firstOrNull;
