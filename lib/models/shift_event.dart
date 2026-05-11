import 'package:isar_community/isar.dart';

part 'shift_event.g.dart';

enum ShiftEventType {
  clockIn,
  pause,
  lunch,
  resume,
  clockOut,
}

@collection
class ShiftEvent {
  Id id = Isar.autoIncrement;

  late DateTime timestamp;

  @enumerated
  late ShiftEventType type;

  // Groups events into a single shift. New shift starts at clockIn.
  @Index()
  late int shiftId;

  String? note;

  ShiftEvent();

  ShiftEvent.create({
    required this.timestamp,
    required this.type,
    required this.shiftId,
    this.note,
  });
}
