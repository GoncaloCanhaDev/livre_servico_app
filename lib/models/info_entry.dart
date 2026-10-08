import 'package:isar_community/isar.dart';

part 'info_entry.g.dart';

@collection
class InfoEntry {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  String? createdByInitials;

  @Index()
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
}
