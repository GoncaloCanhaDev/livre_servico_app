import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

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
  }
}
