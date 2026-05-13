import 'package:isar_community/isar.dart';

part 'notification_log.g.dart';

@collection
class NotificationLog {
  Id id = Isar.autoIncrement;

  late String title;
  late String body;
  String? channel;

  @Index()
  late DateTime scheduledFor;

  late DateTime createdAt;
}
