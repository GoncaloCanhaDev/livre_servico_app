import 'person.dart';
import 'teams.dart';

/// The parts of a profile, by who may edit them (the same lists as
/// `person_edit_keys` in `supabase/migrations`).
enum PersonFieldGroup {
  /// Name, photo, birthday (day and month), género, notes: the person.
  self,

  /// Folgas and ausências: level 3 and up, for the people they reach.
  schedule,

  /// Team, role, turno, Permanência: level 3 and up, for the people they
  /// are above (and themselves, to a lower role).
  role,

  /// Everything else (nº de colaborador, dates, hours, shift).
  other,
}

/// What the signed-in account may do in the store it syncs with, as the
/// server's `my_access` says (`supabase/migrations`): it comes from the
/// [Role] of the Person the account is linked to ([level], [team]) and the
/// app's admin (there are no store owners). Signed out, [full]: one person
/// on their own phone sees and edits everything.
///
/// Two rules decide the rest. An account *reaches* a person when its
/// authority covers their team: level 5 every team, level 4 every team but
/// Gerência, levels 2 and 3 their own team (level 3 also people with no
/// team), level 1 nobody. It is *above* a person it reaches with a lower
/// level (level 5: also another level 5, to hand the role over).
class StoreAccess {
  const StoreAccess({
    required this.admin,
    this.level = 1,
    this.team,
    this.personId,
  });

  /// Reads `my_access`, or a cached copy from before 0.68.0 (`gerencia`,
  /// `chefe_team` instead of `level` and `team`).
  factory StoreAccess.fromJson(Map<String, dynamic> j) {
    final chefeTeam = j['chefe_team'] as String?;
    final (oldLevel, oldTeam) = j['gerencia'] == true
        ? (4, gerenciaId)
        : chefeTeam != null
        ? (3, chefeTeam)
        : (1, null);
    return StoreAccess(
      admin: j['admin'] == true,
      level: (j['level'] as num?)?.toInt() ?? oldLevel,
      team: j['team'] as String? ?? oldTeam,
      personId: j['person_id'] as String?,
    );
  }

  static const full = StoreAccess(admin: true, level: 5);

  /// The app's admin: everything, in every store (creating stores, wiping
  /// all data).
  final bool admin;

  /// The account's person's level (`levelOf`): 1 when unlinked.
  final int level;

  /// The `Team.id` of the account's person, if linked and in a team.
  final String? team;

  /// The `syncUuid` of the account's person, if linked.
  final String? personId;

  /// Whether this account approves requests to join the store.
  bool get canApprove => admin || level >= 3;

  /// Whether this account shares the join code and adds, links and removes
  /// members.
  bool get canManageMembers => admin || level >= 4;

  /// Whether this account may wipe all the store's data (it reaches every
  /// device).
  bool get canWipeAll => admin;

  /// Whether this account removes every person at once.
  bool get canDeleteAll => admin;

  /// Whether [p] is this account's own person.
  bool isSelf(Person p) => personId != null && p.syncUuid == personId;

  /// Whether this account's authority covers [p]'s team.
  bool reaches(Person p) => admin || _reachesTeam(p.team);

  bool _reachesTeam(String? t) => switch (level) {
    _ when admin => true,
    >= 5 => true,
    4 => t != gerenciaId,
    3 => t == team || teamById(t) == null,
    2 => t == team,
    _ => false,
  };

  /// Whether this account reaches [p] with a higher level (level 5: any).
  bool isAbove(Person p) =>
      admin || (reaches(p) && (levelOf(p) < level || level >= 5));

  /// Whether this account reads [p]'s personal data (everything but the
  /// name, photo, género, birthday, team and role); the server sends no
  /// more.
  bool canSeePersonal(Person p) =>
      admin || isSelf(p) || (level >= 3 && reaches(p));

  /// Whether this account edits [group] of [p]'s profile.
  bool canEdit(Person p, PersonFieldGroup group) =>
      admin ||
      switch (group) {
        PersonFieldGroup.self => isSelf(p),
        PersonFieldGroup.schedule => level >= 3 && reaches(p),
        PersonFieldGroup.role => level >= 3 && (isAbove(p) || isSelf(p)),
        PersonFieldGroup.other => false,
      };

  /// Whether this account asks [p] to update their profile.
  bool canRequestUpdate(Person p) =>
      !isSelf(p) && (admin || (level >= 3 && reaches(p)));

  bool get canAddPeople => admin || level >= 3;

  /// Whether this account removes [p] (never themselves).
  bool canDeletePerson(Person p) =>
      admin || (level >= 3 && isAbove(p) && !isSelf(p));

  /// The roles this account gives someone in team [teamId]: those the team
  /// allows, below this account's level (level 5 and the admin: all).
  List<Role> assignableRoles(String? teamId) => [
    for (final r in rolesIn(teamId))
      if (admin || level >= 5 || r.level < level) r,
  ];

  /// The teams this account puts people in, in [teams] order, then null
  /// (Sem equipa) when it reaches that; empty below level 3.
  List<String?> get assignableTeams => [
    if (admin || level >= 3)
      for (final t in [...teams.map((t) => t.id), null])
        if (_reachesTeam(t)) t,
  ];

  Map<String, dynamic> toJson() => {
    'admin': admin,
    'level': level,
    'team': team,
    'person_id': personId,
  };

  @override
  bool operator ==(Object other) =>
      other is StoreAccess &&
      other.admin == admin &&
      other.level == level &&
      other.team == team &&
      other.personId == personId;

  @override
  int get hashCode => Object.hash(admin, level, team, personId);
}
