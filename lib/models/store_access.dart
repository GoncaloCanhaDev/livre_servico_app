import 'person.dart';

/// The parts of a profile, by who may edit them (the same lists as
/// `person_edit_keys` in `supabase/migrations`).
enum PersonFieldGroup {
  /// Name, photo, phone, date of birth, género, notes: the person.
  self,

  /// Folgas and ausências: the chefe of their team, Gerência.
  schedule,

  /// Team, chefe, turno, Supervisor, Segunda Linha, Permanência: Gerência.
  role,

  /// Everything else (nº de colaborador, dates, hours, shift).
  other,
}

/// What the signed-in account may do in the store it syncs with, as the
/// server's `my_access` says (`supabase/migrations`): it comes from the
/// Person the account is linked to (chefe de secção, Gerência) and the
/// app's admin (there are no store owners). Signed out, [full]: one person on their own
/// phone sees and edits everything.
class StoreAccess {
  const StoreAccess({
    required this.admin,
    required this.gerencia,
    this.chefeTeam,
    this.personId,
  });

  factory StoreAccess.fromJson(Map<String, dynamic> j) => StoreAccess(
    admin: j['admin'] == true,
    gerencia: j['gerencia'] == true,
    chefeTeam: j['chefe_team'] as String?,
    personId: j['person_id'] as String?,
  );

  static const full = StoreAccess(admin: true, gerencia: true);

  /// The app's admin: everything, in every store (creating stores, wiping
  /// all data).
  final bool admin;

  /// The account's person is in Gerência.
  final bool gerencia;

  /// The `Team.id` the account's person is chefe de secção of, if any.
  final String? chefeTeam;

  /// The `syncUuid` of the account's person, if linked.
  final String? personId;

  /// Whether this account approves requests to join the store.
  bool get canApprove => admin || gerencia || chefeTeam != null;

  /// Whether this account shares the join code and adds, links and removes
  /// members.
  bool get canManageMembers => admin || gerencia;

  /// Whether this account may wipe all the store's data (it reaches every
  /// device).
  bool get canWipeAll => admin;

  bool get _all => admin;

  /// Whether [p] is this account's own person.
  bool isSelf(Person p) => personId != null && p.syncUuid == personId;

  bool _leads(Person p) => chefeTeam != null && p.team == chefeTeam;

  /// Whether this account reads [p]'s personal data (everything but the
  /// name, photo, género, date of birth and role); the server sends no more.
  bool canSeePersonal(Person p) => _all || gerencia || isSelf(p) || _leads(p);

  /// Whether this account edits [group] of [p]'s profile.
  bool canEdit(Person p, PersonFieldGroup group) =>
      _all ||
      switch (group) {
        PersonFieldGroup.self => isSelf(p),
        PersonFieldGroup.schedule => gerencia || _leads(p),
        PersonFieldGroup.role => gerencia,
        PersonFieldGroup.other => false,
      };

  /// Whether this account asks [p] to update their profile.
  bool canRequestUpdate(Person p) =>
      !isSelf(p) && (_all || gerencia || _leads(p));

  bool get canAddPeople => _all || gerencia;

  bool get canDeletePeople => _all;

  Map<String, dynamic> toJson() => {
    'admin': admin,
    'gerencia': gerencia,
    'chefe_team': chefeTeam,
    'person_id': personId,
  };

  @override
  bool operator ==(Object other) =>
      other is StoreAccess &&
      other.admin == admin &&
      other.gerencia == gerencia &&
      other.chefeTeam == chefeTeam &&
      other.personId == personId;

  @override
  int get hashCode => Object.hash(admin, gerencia, chefeTeam, personId);
}
