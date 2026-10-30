import 'local_row.dart';

class InfoEntry with SyncFields {
  InfoEntry();

  factory InfoEntry.fromJson(Map<String, dynamic> j) {
    final e = InfoEntry()
      ..createdByInitials = stringOrNull(j['createdByInitials'])
      ..bucket = stringFromJson(j['bucket'])
      ..title = stringFromJson(j['title'])
      ..description = stringFromJson(j['description'])
      ..contact = stringOrNull(j['contact'])
      ..createdAt = dateFromJsonOr(j['createdAt'], DateTime(2000))
      ..group = stringOrNull(j['group'])
      ..phone = stringOrNull(j['phone'])
      ..email = stringOrNull(j['email'])
      ..pinned = boolFromJson(j['pinned'])
      ..photoPaths = stringsFromJson(j['photoPaths']);
    syncFieldsFromJson(e, j);
    return e;
  }

  String? createdByInitials;

  late String bucket;

  /// The entry's title; a contact's name.
  late String title;

  /// The entry's text; a contact's note.
  late String description;

  /// Legacy free-text contact of the old Contactos Úteis entries — read it
  /// through `contactPhoneOf` / `contactEmailOf` / `contactNoteOf`.
  String? contact;
  late DateTime createdAt;

  /// Contactos Úteis group, phone and email (bucket `contactos`).
  String? group;
  String? phone;
  String? email;

  /// Shown in the Afixadas card at the top of Informações.
  bool pinned = false;

  /// Photos copied into the app's documents folder (not in backups).
  List<String> photoPaths = [];

  @override
  Map<String, dynamic> toJson() => {
    ...syncFieldsToJson(this),
    'createdByInitials': createdByInitials,
    'bucket': bucket,
    'title': title,
    'description': description,
    'contact': contact,
    'createdAt': dateToJson(createdAt),
    'group': group,
    'phone': phone,
    'email': email,
    'pinned': pinned,
    'photoPaths': photoPaths,
  };
}
