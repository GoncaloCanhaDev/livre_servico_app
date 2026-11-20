part of '../account_service.dart';

/// A member's role in a store, as `store_role` in `supabase/migrations`
/// (by name: viewer < editor < owner). Nobody is an owner any more (the
/// app's admin shows as one in `my_stores`).
enum StoreRole {
  // Viewers ("Só leitura") became members when join requests came in.
  viewer('Membro'),
  editor('Membro'),
  owner('Administrador');

  const StoreRole(this.label);
  final String label;

  static StoreRole fromName(Object? name) => StoreRole.values.firstWhere(
    (r) => r.name == name,
    orElse: () => StoreRole.viewer,
  );
}

/// A store this account belongs to; [personId] is the `syncUuid` of the
/// Person this account is in it (its profile), null when not linked yet.
/// [pending] while the request to join waits for approval: nothing syncs.
typedef StoreInfo = ({
  String id,
  String name,
  StoreRole role,
  String? personId,
  bool pending,
  StoreAccess access,
});

/// Whether this device syncs with [s]: not while the request to join waits.
bool syncsWith(StoreInfo s) => !s.pending;

/// [s] as the `account_store` pref keeps it.
String storeInfoToJson(StoreInfo s) => jsonEncode({
  'id': s.id,
  'name': s.name,
  'role': s.role.name,
  'personId': s.personId,
  'pending': s.pending,
  'access': s.access.toJson(),
});

/// The store [raw] (from [storeInfoToJson]) describes; null when unreadable.
StoreInfo? storeInfoFromJson(String? raw) {
  if (raw == null) return null;
  try {
    if (jsonDecode(raw) case final Map<String, dynamic> j) {
      if (j case {
        'id': final String id,
        'name': final String name,
        'role': final String role,
      }) {
        final r = StoreRole.fromName(role);
        return (
          id: id,
          name: name,
          role: r,
          // Missing in what versions before profiles saved.
          personId: j['personId'] as String?,
          // Missing in what versions before join requests saved.
          pending: j['pending'] == true,
          access: switch (j['access']) {
            final Map<String, dynamic> a => StoreAccess.fromJson(a),
            // An older version's owner was a store owner, not the admin:
            // nothing until `my_access` answers.
            _ => const StoreAccess(admin: false),
          },
        );
      }
    }
  } on FormatException {
    // Unreadable: as if no store was chosen.
  }
  return null;
}

/// What a store's role alone says, until `my_access` answers: `my_stores`
/// gives the app's admin the owner role.
StoreAccess _accessOfRole(StoreRole r) =>
    StoreAccess(admin: r == StoreRole.owner);

/// A request to move an account (and its person [personName]) out of the
/// store [fromStore], with the [note] saying where to.
typedef TransferRequest = ({
  String userId,
  String email,
  String fromStore,
  String fromStoreName,
  String? personName,
  String note,
  DateTime createdAt,
});

/// What someone sends from "Erros e sugestões" (`feedback` online, by
/// [name]).
enum FeedbackKind {
  erro('Erro'),
  sugestao('Sugestão');

  const FeedbackKind(this.label);
  final String label;

  static FeedbackKind fromName(Object? name) => FeedbackKind.values.firstWhere(
    (k) => k.name == name,
    orElse: () => FeedbackKind.erro,
  );
}

/// An error report or a suggestion, as the admin sees it: who sent it
/// ([email], their person [personName] in [storeName]), from which version
/// and platform, its [status], when it was closed ([doneAt]) and whether
/// everyone reads it ([isPublic]; not those sent before 0.88.0).
typedef FeedbackItem = ({
  String id,
  FeedbackKind kind,
  String message,
  String email,
  String? storeName,
  String? personName,
  String appVersion,
  String platform,
  DateTime createdAt,
  DateTime? doneAt,
  FeedbackStatus status,
  bool isPublic,
});

/// An error report or a suggestion as everyone reads it: no sender, only
/// whether it was this account's ([mine]).
typedef PublicFeedback = ({
  String id,
  FeedbackKind kind,
  String message,
  FeedbackStatus status,
  DateTime createdAt,
  bool mine,
});

/// A request to join the current store, waiting for approval: as the
/// person [personId] ([personName]), or [requestedName] for someone new.
typedef JoinRequest = ({
  String userId,
  String email,
  String? personId,
  String? personName,
  String? requestedName,
  DateTime createdAt,
});
typedef StoreMember = ({
  String userId,
  String email,
  StoreRole role,
  String? personId,
});

/// What waits for the app's admin, in every store: requests to join, to
/// move store, and error reports or suggestions not yet dealt with.
typedef AdminSummary = ({int joinRequests, int transfers, int feedback});

/// A request to join any store, as the admin's Administração lists it.
typedef AdminJoinRequest = ({
  String storeId,
  String storeName,
  JoinRequest request,
});

/// A store, with its approved [members], [pending] requests and [people].
typedef AdminStore = ({
  String id,
  String name,
  DateTime createdAt,
  int members,
  int pending,
  int people,
});

/// An account, with the store it is in ([storeId] null: none), whether it
/// waits for approval there and the person it is linked to.
typedef AdminAccount = ({
  String userId,
  String email,
  DateTime createdAt,
  DateTime? lastSignInAt,
  bool isAdmin,
  String? storeId,
  String? storeName,
  bool pending,
  String? personName,
});

/// One of a store's people, with the [email] of the account linked to it.
typedef AdminPerson = ({
  String id,
  String name,
  String number,
  String? team,
  String? role,
  String? email,
});

/// One of a store's people with no account linked yet: only what the
/// "Quem é você?" list shows, so no other personal details leave the store.
typedef UnlinkedPerson = ({String id, String name, String number});

/// What joining a store with its code shows first.
typedef JoinPreview = ({
  String storeId,
  String storeName,
  List<UnlinkedPerson> people,
});
