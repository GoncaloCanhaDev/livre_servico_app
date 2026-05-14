import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_log.dart';
import 'settings_service.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> _log({
    required String title,
    required String body,
    required String channel,
    required DateTime scheduledFor,
  }) async {
    try {
      final isar = ShiftService.instance.isar;
      final entry = NotificationLog()
        ..title = title
        ..body = body
        ..channel = channel
        ..scheduledFor = scheduledFor
        ..createdAt = DateTime.now();
      SyncMeta.stamp(entry);
      await isar.writeTxn(() => isar.notificationLogs.put(entry));
      notifyListeners();
    } catch (_) {
      // Logging must never break notification scheduling.
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Lisbon'));

    const androidSetup = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Using default Darwin initialization settings
    const darwinSetup = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const setup = InitializationSettings(android: androidSetup, iOS: darwinSetup);

    await _plugin.initialize(settings: setup);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  Future<void> testNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Alertas do Livre Serviço',
      channelDescription: 'Notificações para turnos, tarefas e outras atividades.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: 0,
      title: 'Notificações ativadas!',
      body: 'Irás agora receber lembretes.',
      notificationDetails: details,
    );
    await _log(
      title: 'Notificações ativadas!',
      body: 'Irás agora receber lembretes.',
      channel: 'teste',
      scheduledFor: DateTime.now(),
    );
  }

  Future<void> schedulePauseReminders({
    required bool isLunch,
    required DateTime pauseTime,
  }) async {
    if (!SettingsService.instance.notificationsEnabled ||
        !SettingsService.instance.isNotificationEnabled('page_turnos')) {
      return;
    }
    
    await cancelPauseReminders(); // Clear any existing

    final limitMinutes = isLunch ? 60 : 15;
    final warningTime = pauseTime.add(Duration(minutes: limitMinutes - 1));
    final limitTime = pauseTime.add(Duration(minutes: limitMinutes));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pausa_channel_id',
        'Lembretes de Pausa',
        channelDescription: 'Avisos sobre o tempo de pausa.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final pauseType = isLunch ? 'almoço' : 'pausa';

    // 1 Minute Warning
    if (warningTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id: 1001, // Warning ID
        title: 'O teu $pauseType está a terminar!',
        body: 'Falta 1 minuto para atingires o limite.',
        scheduledDate: tz.TZDateTime.from(warningTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      await _log(
        title: 'O teu $pauseType está a terminar!',
        body: 'Falta 1 minuto para atingires o limite.',
        channel: 'pausa',
        scheduledFor: warningTime,
      );
    }

    // Limit Reached
    if (limitTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id: 1002, // Limit ID
        title: 'Atenção!',
        body: 'O limite do teu $pauseType ($limitMinutes minutos) foi atingido.',
        scheduledDate: tz.TZDateTime.from(limitTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      await _log(
        title: 'Atenção!',
        body: 'O limite do teu $pauseType ($limitMinutes minutos) foi atingido.',
        channel: 'pausa',
        scheduledFor: limitTime,
      );
    }
  }

  Future<void> cancelPauseReminders() async {
    await _plugin.cancel(id: 1001);
    await _plugin.cancel(id: 1002);
  }

  Future<void> scheduleStraightWorkReminders(Duration alreadyWorked) async {
    if (!SettingsService.instance.notificationsEnabled ||
        !SettingsService.instance.isNotificationEnabled('page_turnos')) {
      return;
    }

    await cancelStraightWorkReminders();

    final remainingBefore5h = const Duration(hours: 5) - alreadyWorked;
    if (remainingBefore5h.isNegative) return;

    final limitTime = DateTime.now().add(remainingBefore5h);
    final warningTime = limitTime.subtract(const Duration(minutes: 5));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'trabalho_channel_id',
        'Lembretes de Trabalho',
        channelDescription: 'Avisos sobre limites de horas de trabalho.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    if (warningTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id: 2001,
        title: 'Pausa para Almoço',
        body: 'Faltam 5 minutos para atingires 5h de trabalho contínuo.',
        scheduledDate: tz.TZDateTime.from(warningTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      await _log(
        title: 'Pausa para Almoço',
        body: 'Faltam 5 minutos para atingires 5h de trabalho contínuo.',
        channel: 'trabalho',
        scheduledFor: warningTime,
      );
    }

    if (limitTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id: 2002,
        title: 'Atenção!',
        body: 'Atingiste o limite de 5h de trabalho contínuo sem almoço.',
        scheduledDate: tz.TZDateTime.from(limitTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      await _log(
        title: 'Atenção!',
        body: 'Atingiste o limite de 5h de trabalho contínuo sem almoço.',
        channel: 'trabalho',
        scheduledFor: limitTime,
      );
    }
  }

  Future<void> cancelStraightWorkReminders() async {
    await _plugin.cancel(id: 2001);
    await _plugin.cancel(id: 2002);
  }

  Future<void> scheduleTotalWorkReminders(DateTime clockInTime) async {
    if (!SettingsService.instance.notificationsEnabled ||
        !SettingsService.instance.isNotificationEnabled('page_turnos')) {
      return;
    }

    await cancelTotalWorkReminders();

    final limitTime = clockInTime.add(const Duration(hours: 9));
    final warningTime = limitTime.subtract(const Duration(minutes: 5));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'trabalho_total_channel_id',
        'Lembretes de Fim de Turno',
        channelDescription: 'Avisos sobre o limite de 8 horas de trabalho diário.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    if (warningTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id: 3001,
        title: 'Fim de Turno Próximo',
        body: 'Faltam 5 minutos para completares as tuas 9 horas de turno.',
        scheduledDate: tz.TZDateTime.from(warningTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      await _log(
        title: 'Fim de Turno Próximo',
        body: 'Faltam 5 minutos para completares as tuas 9 horas de turno.',
        channel: 'turno',
        scheduledFor: warningTime,
      );
    }

    if (limitTime.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        id: 3002,
        title: 'Fim de Turno!',
        body: 'O teu turno de 9 horas chegou ao fim.',
        scheduledDate: tz.TZDateTime.from(limitTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      await _log(
        title: 'Fim de Turno!',
        body: 'O teu turno de 9 horas chegou ao fim.',
        channel: 'turno',
        scheduledFor: limitTime,
      );
    }
  }

  Future<void> cancelTotalWorkReminders() async {
    await _plugin.cancel(id: 3001);
    await _plugin.cancel(id: 3002);
  }
}
