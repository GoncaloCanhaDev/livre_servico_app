import 'package:isar_community/isar.dart';

part 'notification_log.g.dart';

@collection
class NotificationLog {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  late String title;
  late String body;
  String? channel;

  @Index()
  late DateTime scheduledFor;

  late DateTime createdAt;
}
