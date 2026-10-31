import 'local_row.dart';
import 'person.dart';
import 'store_access.dart';

/// How long an aviso shows on Home, unseen.
const avisoHomeDays = 7;

/// How long an aviso stays in the Avisos screen.
const avisoKeepDays = 30;

/// The longest an aviso's text may be.
const avisoMaxLength = 500;

/// A short notice from someone at level 2 or up to people they reach, shown
/// in the app only (no phone notifications). Never edited once sent; the
/// sender may delete it. The server lets only the sender, the recipients
/// and the admin read it (`supabase/migrations`).
class Aviso with SyncFields {
  Aviso();

  factory Aviso.fromJson(Map<String, dynamic> j) {
    final a = Aviso()
      ..text = stringFromJson(j['text'])
      ..sentAt = dateFromJsonOr(j['sentAt'], DateTime(2000))
      ..fromPersonId = stringFromJson(j['fromPersonId'])
      ..fromName = stringFromJson(j['fromName'])
      ..toPersonIds = stringsFromJson(j['toPersonIds']);
    syncFieldsFromJson(a, j);
    return a;
  }

  String text = '';

  late DateTime sentAt;

  /// The sender's person (`Person.syncUuid`).
  String fromPersonId = '';

  /// The sender's name when sent, so it shows even if that person is gone.
  String fromName = '';

  /// The recipients' persons (`Person.syncUuid`), resolved when sent: a
  /// team chosen is the people in it at that moment.
  List<String> toPersonIds = [];

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'text': text,
    'sentAt': dateToJson(sentAt),
    'fromPersonId': fromPersonId,
    'fromName': fromName,
    'toPersonIds': toPersonIds,
  };
}

/// One recipient's "Visto" on an aviso: its own row (keyed online by
/// aviso and person), so two people's never conflict.
class AvisoVisto with SyncFields {
  AvisoVisto();

  factory AvisoVisto.fromJson(Map<String, dynamic> j) {
    final v = AvisoVisto()
      ..avisoId = stringFromJson(j['avisoId'])
      ..personId = stringFromJson(j['personId'])
      ..seenAt = dateFromJsonOr(j['seenAt'], DateTime(2000));
    syncFieldsFromJson(v, j);
    return v;
  }

  /// The aviso's `syncUuid`.
  String avisoId = '';

  /// The person who saw it (`Person.syncUuid`).
  String personId = '';

  late DateTime seenAt;

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'avisoId': avisoId,
    'personId': personId,
    'seenAt': dateToJson(seenAt),
  };
}

bool _within(Aviso a, DateTime now, int days) =>
    a.syncDeletedAt == null &&
    a.sentAt.isAfter(now.subtract(Duration(days: days)));

List<Aviso> _newestFirst(Iterable<Aviso> avisos) =>
    avisos.toList()..sort((a, b) => b.sentAt.compareTo(a.sentAt));

/// The avisos Home shows [personId] on [now]: sent to them under
/// [avisoHomeDays] ago, not deleted, not seen yet; newest first.
List<Aviso> avisosOnHome(
  List<Aviso> avisos,
  List<AvisoVisto> vistos,
  String personId,
  DateTime now,
) {
  final seen = {
    for (final v in vistos)
      if (v.personId == personId && v.syncDeletedAt == null) v.avisoId,
  };
  return _newestFirst(
    avisos.where(
      (a) =>
          _within(a, now, avisoHomeDays) &&
          a.toPersonIds.contains(personId) &&
          !seen.contains(a.syncUuid),
    ),
  );
}

/// The avisos sent to [personId] in the last [avisoKeepDays]; newest first.
List<Aviso> avisosReceived(List<Aviso> avisos, String personId, DateTime now) =>
    _newestFirst(
      avisos.where(
        (a) =>
            _within(a, now, avisoKeepDays) && a.toPersonIds.contains(personId),
      ),
    );

/// The avisos [personId] sent in the last [avisoKeepDays]; newest first.
List<Aviso> avisosSent(List<Aviso> avisos, String personId, DateTime now) =>
    _newestFirst(
      avisos.where(
        (a) => _within(a, now, avisoKeepDays) && a.fromPersonId == personId,
      ),
    );

/// The people an aviso from [access] goes to: those in [people] (not
/// deleted, already synced) the account reaches, in one of [teamIds] (null:
/// Sem equipa) or among [personIds], never the sender; in [people] order.
List<String> recipientsFor(
  StoreAccess access,
  List<Person> people, {
  Set<String?> teamIds = const {},
  Set<String> personIds = const {},
}) => [
  for (final p in people)
    if (p.syncDeletedAt == null &&
        p.syncUuid.isNotEmpty &&
        !access.isSelf(p) &&
        access.reaches(p) &&
        (teamIds.contains(p.team) || personIds.contains(p.syncUuid)))
      p.syncUuid,
];

/// When each of [a]'s recipients saw it, for those who did.
Map<String, DateTime> seenBy(Aviso a, List<AvisoVisto> vistos) => {
  for (final v in vistos)
    if (v.avisoId == a.syncUuid &&
        v.syncDeletedAt == null &&
        a.toPersonIds.contains(v.personId))
      v.personId: v.seenAt,
};

/// When [sent] was, from [now]: "hoje 09:05", "ontem 18:30" or "2/10 07:00".
String avisoWhen(DateTime sent, DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  final time = '${two(sent.hour)}:${two(sent.minute)}';
  final day = DateTime(sent.year, sent.month, sent.day);
  final today = DateTime(now.year, now.month, now.day);
  if (day.isAtSameMomentAs(today)) return 'hoje $time';
  if (day.isAtSameMomentAs(DateTime(now.year, now.month, now.day - 1))) {
    return 'ontem $time';
  }
  return '${sent.day}/${sent.month} $time';
}
