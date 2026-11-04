import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/person_picker.dart';
import '../widgets/task_markers.dart';

import '../../models/not_done.dart';
import '../../models/opening_list.dart';
import '../../models/weekly_tasks.dart';
import '../../services/weekly_tasks_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';

class WeeklyTasksTab extends StatefulWidget {
  const WeeklyTasksTab({super.key});

  @override
  State<WeeklyTasksTab> createState() => _WeeklyTasksTabState();
}

class _WeeklyTasksTabState extends State<WeeklyTasksTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  WeeklyTasks? _tasks;

  late final TextEditingController _verificar1aCtrl;
  late final TextEditingController _verificar4aCtrl;

  @override
  void initState() {
    super.initState();
    _verificar1aCtrl = TextEditingController();
    _verificar4aCtrl = TextEditingController();
    WeeklyTasksService.instance.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    WeeklyTasksService.instance.removeListener(_reload);
    _verificar1aCtrl.dispose();
    _verificar4aCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final tasks = await WeeklyTasksService.instance.currentOrCreate();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      if (_verificar1aCtrl.text != '${tasks.verificar1aCount}') {
        _verificar1aCtrl.text = tasks.verificar1aCount == 0
            ? ''
            : '${tasks.verificar1aCount}';
      }
      if (_verificar4aCtrl.text != '${tasks.verificar4aCount}') {
        _verificar4aCtrl.text = tasks.verificar4aCount == 0
            ? ''
            : '${tasks.verificar4aCount}';
      }
    });
  }

  Future<void> _saveTasks() async {
    final t = _tasks;
    if (t == null) return;
    await WeeklyTasksService.instance.save(t);
  }

  Future<void> _sendMsg(String msg) async {
    if (!mounted) return;
    await WhatsAppService.sendWithConfirm(context, msg);
  }

  DateTime _lastSaturdayOnOrBefore(DateTime day) {
    var d = day;
    while (d.weekday != DateTime.saturday) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  Future<void> _completeTask({
    required String taskName,
    required String taskKey,
    required void Function(WeeklyTasks target, List<String> who) apply,
    required String Function(List<String> who) message,
    DateTime? initialDay,
    bool Function(DateTime)? selectableDayPredicate,
  }) async {
    final tasks = _tasks;
    if (tasks == null) return;
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '$taskName\n\nDepois de concluída, não poderá ser desmarcada nessa semana.',
      initialDay: initialDay ?? DateTime(today.year, today.month, today.day),
      selectableDayPredicate: selectableDayPredicate,
    );
    if (result == null) return;
    final who = result.people.map((p) => p.fullName).toList();
    final targetWeek = currentServiceWeek(
      DateTime(result.day.year, result.day.month, result.day.day, 12),
    );
    if (targetWeek == tasks.serviceWeek) {
      setState(() => apply(tasks, who));
      await _saveTasks();
      _sendMsg(message(who));
      return;
    }
    final other = await WeeklyTasksService.instance.forWeek(targetWeek);
    if (other.notDone.containsKey(taskKey)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nessa semana a tarefa foi marcada como não feita.'),
        ),
      );
      return;
    }
    apply(other, who);
    if (!other.backdatedTaskKeys.contains(taskKey)) {
      other.backdatedTaskKeys = [...other.backdatedTaskKeys, taskKey];
    }
    await WeeklyTasksService.instance.save(other);
    final dayFmt = DateFormat("d 'de' MMMM", 'pt_PT').format(result.day);
    _sendMsg('${message(who)} — $dayFmt');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa marcada como concluída em $dayFmt.')),
    );
  }

  /// Marks [taskKey] as Não feita: who, which day of which week and why.
  Future<void> _markNotDone({
    required String taskName,
    required String taskKey,
    DateTime? initialDay,
    bool Function(DateTime)? selectableDayPredicate,
  }) async {
    final tasks = _tasks;
    if (tasks == null) return;
    final today = currentServiceDay();
    final picked = await pickNotDone(
      context,
      taskName: taskName,
      initialDay: initialDay ?? DateTime(today.year, today.month, today.day),
      selectableDayPredicate: selectableDayPredicate,
      period: 'nessa semana',
    );
    if (picked == null) return;
    final (result, reason) = picked;
    final notDone = NotDone(
      byNames: result.people.map((p) => p.fullName).toList(),
      reason: reason,
      at: DateTime.now(),
    );
    final targetWeek = currentServiceWeek(
      DateTime(result.day.year, result.day.month, result.day.day, 12),
    );
    if (targetWeek == tasks.serviceWeek) {
      setState(() => tasks.notDone = {...tasks.notDone, taskKey: notDone});
      await _saveTasks();
      _sendMsg(notDoneMessage(taskName, notDone));
      return;
    }
    final other = await WeeklyTasksService.instance.forWeek(targetWeek);
    final alreadyDone = switch (taskKey) {
      'verificar_1a' => other.verificar1a,
      'verificar_4a' => other.verificar4a,
      'limpeza_maquina_voltas' => other.limpezaMaquinaVoltas,
      _ => false,
    };
    if (alreadyDone) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessa semana a tarefa já foi feita.')),
      );
      return;
    }
    other.notDone = {...other.notDone, taskKey: notDone};
    if (!other.backdatedTaskKeys.contains(taskKey)) {
      other.backdatedTaskKeys = [...other.backdatedTaskKeys, taskKey];
    }
    await WeeklyTasksService.instance.save(other);
    final dayFmt = DateFormat("d 'de' MMMM", 'pt_PT').format(result.day);
    _sendMsg('${notDoneMessage(taskName, notDone)} — $dayFmt');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa marcada como não feita em $dayFmt.')),
    );
  }

  /// One of the Verificar tasks, due on Tuesday.
  Widget _verificar(
    WeeklyTasks tasks, {
    required String label,
    required String taskKey,
    required bool checked,
    required List<String> byNames,
    required int Function() count,
    required TextEditingController controller,
    required String goalNote,
    required bool tuesdayPassed,
    required void Function(WeeklyTasks t, List<String> who, int count) apply,
    required ValueChanged<int> setCount,
  }) {
    final notDone = tasks.notDone[taskKey];
    return _WeeklyCountTask(
      label: label,
      checked: checked,
      notDone: notDone,
      byNames: byNames,
      backdated: tasks.backdatedTaskKeys.contains(taskKey),
      countController: controller,
      goalNote: goalNote,
      late: tuesdayPassed && !checked && notDone == null,
      onLongPress: checked
          ? () => _sendMsg('✅ Tarefa concluída: $label (${count()})')
          : notDone != null
          ? () => _sendMsg(notDoneMessage(label, notDone))
          : null,
      onDone: () {
        final n = count();
        _completeTask(
          taskName: label,
          taskKey: taskKey,
          apply: (t, who) => apply(t, who, n),
          message: (who) =>
              '✅ Tarefa concluída: $label ($n) (por ${joinNames(who)})',
        );
      },
      onNotDone: () => _markNotDone(taskName: label, taskKey: taskKey),
      onCountChanged: (n) {
        setCount(n);
        _saveTasks();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tasks = _tasks;
    if (tasks == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final monday = tasks.serviceWeek;
    final sunday = monday.add(const Duration(days: 6));
    final rangeFmt = DateFormat("d 'de' MMMM", 'pt_PT');
    // The Verificar tasks are due on Tuesday.
    final tuesdayPassed = currentServiceDay().isAfter(
      monday.add(const Duration(days: 1)),
    );
    final isSaturday = currentServiceDay().weekday == DateTime.saturday;
    final limpezaNotDone = tasks.notDone['limpeza_maquina_voltas'];
    const limpeza = 'Limpeza da Máquina Voltas';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${rangeFmt.format(monday)} — ${rangeFmt.format(sunday)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _verificar(
            tasks,
            label: 'Verificar 1ª Sheet',
            taskKey: 'verificar_1a',
            checked: tasks.verificar1a,
            byNames: resolveNames(
              tasks.verificar1aByNames,
              tasks.verificar1aBy,
            ),
            count: () => tasks.verificar1aCount,
            controller: _verificar1aCtrl,
            goalNote: 'Itens no Mural — mínimo 10, recomendado 20',
            tuesdayPassed: tuesdayPassed,
            apply: (t, who, count) {
              t.verificar1a = true;
              t.verificar1aByNames = who;
              t.verificar1aCount = count;
            },
            setCount: (n) => tasks.verificar1aCount = n,
          ),
          _verificar(
            tasks,
            label: 'Verificar 4ª Sheet',
            taskKey: 'verificar_4a',
            checked: tasks.verificar4a,
            byNames: resolveNames(
              tasks.verificar4aByNames,
              tasks.verificar4aBy,
            ),
            count: () => tasks.verificar4aCount,
            controller: _verificar4aCtrl,
            goalNote: 'Itens por colocar preço',
            tuesdayPassed: tuesdayPassed,
            apply: (t, who, count) {
              t.verificar4a = true;
              t.verificar4aByNames = who;
              t.verificar4aCount = count;
            },
            setCount: (n) => tasks.verificar4aCount = n,
          ),
          _WeeklyManualTask(
            label: limpeza,
            checked: tasks.limpezaMaquinaVoltas,
            notDone: limpezaNotDone,
            byNames: resolveNames(
              tasks.limpezaMaquinaVoltasByNames,
              tasks.limpezaMaquinaVoltasBy,
            ),
            backdated: tasks.backdatedTaskKeys.contains(
              'limpeza_maquina_voltas',
            ),
            enabled: isSaturday,
            note: isSaturday ? null : 'Apenas ao sábado',
            onLongPress: tasks.limpezaMaquinaVoltas
                ? () => _sendMsg('✅ Tarefa concluída: $limpeza')
                : limpezaNotDone != null
                ? () => _sendMsg(notDoneMessage(limpeza, limpezaNotDone))
                : null,
            onDone: () => _completeTask(
              taskName: limpeza,
              taskKey: 'limpeza_maquina_voltas',
              initialDay: _lastSaturdayOnOrBefore(currentServiceDay()),
              selectableDayPredicate: (d) => d.weekday == DateTime.saturday,
              apply: (t, who) {
                t.limpezaMaquinaVoltas = true;
                t.limpezaMaquinaVoltasByNames = who;
              },
              message: (who) =>
                  '✅ Tarefa concluída: $limpeza (por ${joinNames(who)})',
            ),
            onNotDone: () => _markNotDone(
              taskName: limpeza,
              taskKey: 'limpeza_maquina_voltas',
              initialDay: _lastSaturdayOnOrBefore(currentServiceDay()),
              selectableDayPredicate: (d) => d.weekday == DateTime.saturday,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdatedNote extends StatelessWidget {
  const _BackdatedNote();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Preenchido a posteriori',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off, size: 14, color: context.faint),
          SizedBox(width: 4),
          Text(
            'Preenchido a posteriori',
            style: TextStyle(fontSize: 11, color: context.faint),
          ),
        ],
      ),
    );
  }
}

TaskOutcome _outcome(bool checked, NotDone? notDone) => checked
    ? TaskOutcome.done
    : notDone != null
    ? TaskOutcome.notDone
    : TaskOutcome.open;

class _WeeklyManualTask extends StatelessWidget {
  const _WeeklyManualTask({
    required this.label,
    required this.checked,
    required this.onDone,
    required this.onNotDone,
    this.notDone,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.enabled = true,
    this.note,
  });

  final String label;
  final bool checked;
  final NotDone? notDone;
  final VoidCallback onDone;
  final VoidCallback onNotDone;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;
  final bool enabled;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final notDone = this.notDone;
    final names = checked ? byNames : notDone?.byNames ?? const <String>[];
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: TaskMarkers(
            outcome: _outcome(checked, notDone),
            onDone: onDone,
            onNotDone: onNotDone,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: enabled || checked || notDone != null
                  ? null
                  : context.faintest,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: notDone != null && !checked
              ? NotDoneNote(notDone, backdated: backdated)
              : (checked && backdated)
              ? const _BackdatedNote()
              : (note == null || checked ? null : Text(note!)),
          trailing: names.isNotEmpty
              ? PersonInitialsRow(names: names, size: 30)
              : null,
        ),
      ),
    );
  }
}

class _WeeklyCountTask extends StatelessWidget {
  const _WeeklyCountTask({
    required this.label,
    required this.checked,
    required this.countController,
    required this.onDone,
    required this.onNotDone,
    required this.onCountChanged,
    this.notDone,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.goalNote,
    this.late = false,
  });

  final String label;
  final bool checked;
  final NotDone? notDone;
  final TextEditingController countController;
  final VoidCallback onDone;
  final VoidCallback onNotDone;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;
  final String? goalNote;
  final bool late;

  @override
  Widget build(BuildContext context) {
    final notDone = this.notDone;
    final names = checked ? byNames : notDone?.byNames ?? const <String>[];
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        color: late ? context.tint(Colors.red) : null,
        shape: late
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade700, width: 1.5),
              )
            : null,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: TaskMarkers(
            outcome: _outcome(checked, notDone),
            onDone: onDone,
            onNotDone: onNotDone,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: checked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (names.isNotEmpty) ...[
                const SizedBox(width: 8),
                PersonInitialsRow(names: names, size: 30),
              ],
            ],
          ),
          subtitle: notDone != null && !checked
              ? NotDoneNote(notDone, backdated: backdated)
              : (checked && backdated)
              ? const _BackdatedNote()
              : late
              ? Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Atrasada — devia ter sido concluída à 3ª feira',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              : (goalNote == null
                    ? null
                    : Text(
                        goalNote!,
                        style: TextStyle(fontSize: 12, color: context.muted),
                      )),
          trailing: SizedBox(
            width: 72,
            child: TextField(
              controller: countController,
              enabled: !checked && notDone == null,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (s) => onCountChanged(int.tryParse(s) ?? 0),
            ),
          ),
        ),
      ),
    );
  }
}
