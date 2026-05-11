import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/daily_tasks.dart';
import 'auto_list_service.dart';
import 'daily_tasks_service.dart';
import 'opening_list_service.dart';
import 'report_list_service.dart';
import 'settings_service.dart';
import 'shift_service.dart';
import 'visual_list_service.dart';

class TaskNotificationService {
  TaskNotificationService._();
  static final instance = TaskNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'tarefas_channel_id',
      'Lembretes de Tarefas',
      channelDescription: 'Avisos para tarefas diárias e listas.',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Called when the user clocks in or when any task state changes
  Future<void> rescheduleAll() async {
    // Only schedule if notifications enabled and user is NOT idle
    if (!SettingsService.instance.notificationsEnabled ||
        ShiftService.instance.status == WorkStatus.idle) {
      await cancelAll();
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Fetch today's tasks
    final tasks = await DailyTasksService.instance.history();
    DailyTasks? todayTasks;
    try {
      todayTasks = tasks.firstWhere((t) => t.serviceDay.isAtSameMomentAs(today));
    } catch (_) {}

    // Check custom tasks
    final openingLists = await OpeningListService.instance.entriesForServiceDay(today);
    final reportLists = await ReportListService.instance.entriesForServiceDay(today);
    final autoLists = await AutoListService.instance.entriesForServiceDay(today);
    final visualLists = await VisualListService.instance.entriesForServiceDay(today);

    // Schedule each task if not done and time hasn't passed
    await _scheduleIf(
      key: 'page_tarefas',
      id: 4001,
      hour: 7,
      minute: 0,
      title: 'Kiwi Abertura',
      body: 'Não te esqueças de fazer o Kiwi Abertura!',
      isDone: todayTasks?.kiwiAbertura ?? false,
    );
    await _scheduleIf(
      key: 'page_tarefas',
      id: 4002,
      hour: 7,
      minute: 30,
      title: 'Alterações de Preço',
      body: 'Já verificaste as Alterações de Preço?',
      isDone: todayTasks?.alteracoesPreco ?? false,
    );
    await _scheduleIf(
      key: 'page_tarefas',
      id: 4003,
      hour: 9,
      minute: 0,
      title: 'Verificação de Temperaturas',
      body: 'Está na hora de verificar as Temperaturas.',
      isDone: todayTasks?.verificacaoTemperaturas ?? false,
    );
    await _scheduleIf(
      key: 'page_listas',
      id: 4004,
      hour: 11,
      minute: 0,
      title: 'Lista de Abertura',
      body: 'Não te esqueças da Lista de Abertura.',
      isDone: openingLists.isNotEmpty && openingLists.first.isFinalized,
    );
    await _scheduleIf(
      key: 'page_listas',
      id: 4005,
      hour: 12,
      minute: 0,
      title: 'Relatório das Listas',
      body: 'Está na hora de enviar o Relatório das Listas.',
      isDone: reportLists.isNotEmpty && reportLists.first.isFinalized,
    );
    await _scheduleIf(
      key: 'page_tarefas',
      id: 4006,
      hour: 14,
      minute: 0,
      title: 'Preenchimento do Quadro',
      body: 'Preenche o quadro de gestão diária.',
      isDone: todayTasks?.preenchimentoQuadro ?? false,
    );
    await _scheduleIf(
      key: 'page_listas',
      id: 4007,
      hour: 14,
      minute: 0,
      title: 'Lista Visual',
      body: 'Ainda não fizeste a Lista Visual de hoje!',
      isDone: visualLists.isNotEmpty,
    );

    // Auto lists (14h, 17h, 20h)
    await _scheduleIf(
      key: 'page_listas',
      id: 4008,
      hour: 14,
      minute: 0,
      title: '1ª Lista Automática',
      body: 'Está na hora da Lista Automática das 14h.',
      isDone: autoLists.isNotEmpty,
    );
    await _scheduleIf(
      key: 'page_listas',
      id: 4009,
      hour: 17,
      minute: 0,
      title: '2ª Lista Automática',
      body: 'Está na hora da Lista Automática das 17h.',
      isDone: autoLists.length >= 2,
    );
    await _scheduleIf(
      key: 'page_tarefas',
      id: 4010,
      hour: 19,
      minute: 0,
      title: 'Verificação de Validades',
      body: 'Inicia a Verificação de Validades.',
      isDone: todayTasks?.verificacaoValidades ?? false,
    );
    await _scheduleIf(
      key: 'page_listas',
      id: 4011,
      hour: 20,
      minute: 0,
      title: '3ª Lista Automática',
      body: 'Está na hora da Lista Automática das 20h.',
      isDone: autoLists.length >= 3,
    );
    await _scheduleIf(
      key: 'page_tarefas',
      id: 4012,
      hour: 22,
      minute: 0,
      title: 'Kiwi Fecho',
      body: 'Não te esqueças de fazer o Kiwi Fecho!',
      isDone: todayTasks?.kiwiFecho ?? false,
    );
    await _scheduleIf(
      key: 'page_tarefas',
      id: 4013,
      hour: 22,
      minute: 0,
      title: 'Limpeza da Máquina',
      body: 'Está na hora da Limpeza da Máquina de Voltas.',
      isDone: todayTasks?.limpezaMaquinaVoltas ?? false,
    );
  }

  Future<void> _scheduleIf({
    required String key,
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required bool isDone,
  }) async {
    await _plugin.cancel(id: id);
    if (isDone || !SettingsService.instance.isNotificationEnabled(key)) return;

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduled.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> checkVisualGoal() async {
    if (!SettingsService.instance.notificationsEnabled ||
        !SettingsService.instance.isNotificationEnabled('page_listas') ||
        ShiftService.instance.status == WorkStatus.idle) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visualLists = await VisualListService.instance.entriesForServiceDay(today);

    if (visualLists.isEmpty) return;

    int totalPicados = 0;
    for (final v in visualLists) {
      totalPicados += v.itensPicados;
    }

    final goal = SettingsService.instance.visualGoal;
    if (totalPicados < goal) {
      final missing = goal - totalPicados;
      await _plugin.show(
        id: 4099,
        title: 'Lista Visual Guardada',
        body: 'Ainda faltam $missing itens para atingires o teu objetivo diário ($goal).',
        notificationDetails: _details,
      );
    } else {
      await _plugin.show(
        id: 4099,
        title: 'Objetivo Atingido! 🎉',
        body: 'Parabéns! Já atingiste o teu objetivo diário de itens picados ($goal).',
        notificationDetails: _details,
      );
    }
  }

  Future<void> cancelAll() async {
    for (int i = 4001; i <= 4013; i++) {
      await _plugin.cancel(id: i);
    }
  }
}
