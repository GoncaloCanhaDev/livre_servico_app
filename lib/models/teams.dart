import 'person.dart';

/// A chefe position within a team. Stored on [Person.chefe] by name.
enum ChefeSlot {
  chefe('Chefe'),
  dia('Chefe de dia'),
  noite('Chefe de noite');

  const ChefeSlot(this.label);
  final String label;
}

/// One of the store's fixed teams. [id] is what [Person.team] stores, so
/// [name] can change without touching saved data.
class Team {
  const Team(this.id, this.name, this.chefeSlots);

  final String id;
  final String name;

  /// The team's chefe positions, in display order. Each is held by at most
  /// one (non-deleted) member.
  final List<ChefeSlot> chefeSlots;
}

/// Every team, in the order the Pessoas list shows them.
const teams = [
  Team('livre_servico', 'Livre Serviço', [ChefeSlot.dia, ChefeSlot.noite]),
  Team('gerencia', 'Gerência', [ChefeSlot.chefe]),
  Team('charcutaria', 'Charcutaria', [ChefeSlot.chefe]),
  Team('meal_solutions', 'Meal Solutions', [ChefeSlot.chefe]),
  Team('talho', 'Talho', [ChefeSlot.chefe]),
  Team('peixaria', 'Peixaria', [ChefeSlot.chefe]),
  Team('frente_de_loja', 'Frente de Loja', [ChefeSlot.chefe]),
  Team('bem_estar', 'BemEstar', [ChefeSlot.chefe]),
  Team('padaria', 'Padaria', [ChefeSlot.chefe]),
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
