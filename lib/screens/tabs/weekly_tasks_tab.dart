import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/person_picker.dart';

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

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${rangeFmt.format(monday)} — ${rangeFmt.format(sunday)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _WeeklyCountTask(
            label: 'Verificar 1ª',
            checked: tasks.verificar1a,
            byNames: resolveNames(tasks.verificar1aByNames, tasks.verificar1aBy),
            backdated: tasks.backdatedTaskKeys.contains('verificar_1a'),
            countController: _verificar1aCtrl,
            goalNote: 'Itens no Mural — mínimo 10, recomendado 20',
            late: tuesdayPassed && !tasks.verificar1a,
            onLongPress: tasks.verificar1a
                ? () => _sendMsg(
                    '✅ Tarefa concluída: Verificar 1ª (${tasks.verificar1aCount})',
                  )
                : null,
            onCheckedChanged: (v) async {
              if (!v) return;
              final count = tasks.verificar1aCount;
              await _completeTask(
                taskName: 'Verificar 1ª',
                taskKey: 'verificar_1a',
                apply: (t, who) {
                  t.verificar1a = true;
                  t.verificar1aByNames = who;
                  t.verificar1aCount = count;
                },
                message: (who) =>
                    '✅ Tarefa concluída: Verificar 1ª ($count) (por ${joinNames(who)})',
              );
            },
            onCountChanged: (n) {
              tasks.verificar1aCount = n;
              _saveTasks();
            },
          ),
          _WeeklyCountTask(
            label: 'Verificar 4ª',
            checked: tasks.verificar4a,
            byNames: resolveNames(tasks.verificar4aByNames, tasks.verificar4aBy),
            backdated: tasks.backdatedTaskKeys.contains('verificar_4a'),
            countController: _verificar4aCtrl,
            goalNote: 'Itens por colocar preço',
            late: tuesdayPassed && !tasks.verificar4a,
            onLongPress: tasks.verificar4a
                ? () => _sendMsg(
                    '✅ Tarefa concluída: Verificar 4ª (${tasks.verificar4aCount})',
                  )
                : null,
            onCheckedChanged: (v) async {
              if (!v) return;
              final count = tasks.verificar4aCount;
              await _completeTask(
                taskName: 'Verificar 4ª',
                taskKey: 'verificar_4a',
                apply: (t, who) {
                  t.verificar4a = true;
                  t.verificar4aByNames = who;
                  t.verificar4aCount = count;
                },
                message: (who) =>
                    '✅ Tarefa concluída: Verificar 4ª ($count) (por ${joinNames(who)})',
              );
            },
            onCountChanged: (n) {
              tasks.verificar4aCount = n;
              _saveTasks();
            },
          ),
          _WeeklyManualTask(
            label: 'Limpeza da Máquina Voltas',
            checked: tasks.limpezaMaquinaVoltas,
            byNames: resolveNames(tasks.limpezaMaquinaVoltasByNames, tasks.limpezaMaquinaVoltasBy),
            backdated: tasks.backdatedTaskKeys.contains(
              'limpeza_maquina_voltas',
            ),
            enabled: isSaturday,
            note: isSaturday ? null : 'Apenas ao sábado',
            onLongPress: tasks.limpezaMaquinaVoltas
                ? () =>
                      _sendMsg('✅ Tarefa concluída: Limpeza da Máquina Voltas')
                : null,
            onChanged: (v) async {
              if (!v) return;
              final lastSaturday = _lastSaturdayOnOrBefore(currentServiceDay());
              await _completeTask(
                taskName: 'Limpeza da Máquina Voltas',
                taskKey: 'limpeza_maquina_voltas',
                initialDay: lastSaturday,
                selectableDayPredicate: (d) => d.weekday == DateTime.saturday,
                apply: (t, who) {
                  t.limpezaMaquinaVoltas = true;
                  t.limpezaMaquinaVoltasByNames = who;
                },
                message: (who) =>
                    '✅ Tarefa concluída: Limpeza da Máquina Voltas (por ${joinNames(who)})',
              );
            },
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
        children: const [
          Icon(Icons.history_toggle_off, size: 14, color: Colors.black45),
          SizedBox(width: 4),
          Text(
            'Preenchido a posteriori',
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _WeeklyManualTask extends StatelessWidget {
  const _WeeklyManualTask({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.enabled = true,
    this.note,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;
  final bool enabled;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: checked,
          onChanged: (v) {
            if (checked) return;
            onChanged(v ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.green,
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: enabled ? null : Colors.black38,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: (checked && backdated)
              ? const _BackdatedNote()
              : (note == null ? null : Text(note!)),
          secondary: (checked && byNames.isNotEmpty)
              ? PersonInitialsRow(names: byNames, size: 30)
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
    required this.onCheckedChanged,
    required this.onCountChanged,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.goalNote,
    this.late = false,
  });

  final String label;
  final bool checked;
  final TextEditingController countController;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;
  final String? goalNote;
  final bool late;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        color: late ? Colors.red.shade50 : null,
        shape: late
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade700, width: 1.5),
              )
            : null,
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: checked,
          onChanged: (v) {
            if (checked) return;
            onCheckedChanged(v ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.green,
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
              if (checked && byNames.isNotEmpty) ...[
                const SizedBox(width: 8),
                PersonInitialsRow(names: byNames, size: 30),
              ],
            ],
          ),
          subtitle: (checked && backdated)
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      )),
          secondary: SizedBox(
            width: 90,
            child: TextField(
              controller: countController,
              enabled: !checked,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
