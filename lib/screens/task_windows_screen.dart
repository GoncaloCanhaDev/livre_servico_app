import 'package:flutter/material.dart';

import '../models/custom_task.dart';
import '../models/task_window.dart';
import '../services/custom_task_service.dart';
import '../services/task_window_service.dart';
import '../theme.dart';
import 'widgets/wide_layout.dart';

const _weekdays = {
  DateTime.tuesday: 'Terça-feira',
  DateTime.saturday: 'Sábado',
};

/// Definições → Horas das tarefas (level 3 and up): when each task is done
/// and whether the app marks it by itself once that time is over.
class TaskWindowsScreen extends StatefulWidget {
  const TaskWindowsScreen({super.key});

  @override
  State<TaskWindowsScreen> createState() => _TaskWindowsScreenState();
}

class _TaskWindowsScreenState extends State<TaskWindowsScreen> {
  List<CustomTask> _customs = [];

  @override
  void initState() {
    super.initState();
    TaskWindowService.instance.addListener(_changed);
    CustomTaskService.instance.addListener(_loadCustoms);
    _loadCustoms();
  }

  @override
  void dispose() {
    TaskWindowService.instance.removeListener(_changed);
    CustomTaskService.instance.removeListener(_loadCustoms);
    super.dispose();
  }

  void _changed() => setState(() {});

  Future<void> _loadCustoms() async {
    final tasks = await CustomTaskService.instance.tasks();
    if (!mounted) return;
    setState(() {
      _customs = [
        for (final t in tasks)
          if (t.frequency != CustomTaskFrequency.oneOff) t,
      ];
    });
  }

  Future<void> _edit(String key, String label) async {
    final w = TaskWindowService.instance.windowFor(key);
    final edited = await showDialog<TaskWindow>(
      context: context,
      builder: (_) => _WindowDialog(label: label, window: w),
    );
    if (edited == null) return;
    await TaskWindowService.instance.save(edited);
  }

  Widget _tile(String key, String label, {String? day, bool hours = true}) {
    final svc = TaskWindowService.instance;
    final w = svc.windowFor(key);
    final when = hours
        ? '${minutesText(w.opensAt)}–${minutesText(w.closesAt)}'
        : 'Toda a semana';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('window:$key'),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            ?day,
            when,
            if (!w.auto) 'marcar à mão',
            if (svc.isCustom(key)) 'alterada',
          ].join(' · '),
          style: TextStyle(color: context.muted),
        ),
        onTap: hours ? () => _edit(key, label) : null,
        trailing: Switch(
          value: w.auto,
          onChanged: (v) => svc.save(w..auto = v),
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: context.colors.secondary,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final daily = [
      for (final t in _customs)
        if (t.frequency == CustomTaskFrequency.daily) t,
    ];
    final weekly = [
      for (final t in _customs)
        if (t.frequency == CustomTaskFrequency.weekly) t,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Horas das tarefas')),
      body: SafeArea(
        child: ReadableWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Quando a hora de uma tarefa acaba e ninguém a marcou, a '
                'aplicação marca-a como feita por quem estava a trabalhar '
                'no Livre Serviço, segundo o horário. Os supervisores '
                'confirmam ou corrigem. Desligue para uma tarefa ser só '
                'marcada à mão.',
                style: TextStyle(color: context.muted),
              ),
              _header('Diárias'),
              for (final key in fixedDailyTaskKeys)
                _tile(key, fixedTaskLabels[key]!),
              for (final t in daily) _tile(t.syncUuid, t.title),
              _header('Semanais'),
              for (final key in fixedWeeklyTaskKeys)
                _tile(
                  key,
                  fixedTaskLabels[key]!,
                  day: _weekdays[taskDueWeekday[key]],
                ),
              for (final t in weekly) _tile(t.syncUuid, t.title, hours: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowDialog extends StatefulWidget {
  const _WindowDialog({required this.label, required this.window});

  final String label;
  final TaskWindow window;

  @override
  State<_WindowDialog> createState() => _WindowDialogState();
}

class _WindowDialogState extends State<_WindowDialog> {
  late final TaskWindow _w = widget.window.copy();

  Future<void> _pick({required bool opens}) async {
    final m = opens ? _w.opensAt : _w.closesAt;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
      helpText: opens ? 'Começa às' : 'Acaba às',
    );
    if (picked == null) return;
    final v = picked.hour * 60 + picked.minute;
    setState(() => opens ? _w.opensAt = v : _w.closesAt = v);
  }

  @override
  Widget build(BuildContext context) {
    final valid = windowValid(_w);
    return AlertDialog(
      title: Text(widget.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Começa às'),
            trailing: Text(
              minutesText(_w.opensAt),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () => _pick(opens: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Acaba às'),
            trailing: Text(
              minutesText(_w.closesAt),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () => _pick(opens: false),
          ),
          Text(
            valid
                ? 'O dia de trabalho vai das 05:00 às 05:00 do dia seguinte.'
                : 'Tem de acabar depois de começar (dia das 05:00 às 05:00).',
            style: TextStyle(
              fontSize: 12,
              color: valid ? context.muted : context.colors.error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final d = defaultTaskWindow(widget.window.taskKey);
            setState(
              () => _w
                ..opensAt = d.opensAt
                ..closesAt = d.closesAt,
            );
          },
          child: const Text('Repor'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: valid ? () => Navigator.pop(context, _w) : null,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
