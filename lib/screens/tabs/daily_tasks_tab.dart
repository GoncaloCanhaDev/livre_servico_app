import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/person_picker.dart';
import '../widgets/task_markers.dart';

import '../../models/daily_tasks.dart';
import '../../models/not_done.dart';
import '../../models/opening_list.dart';
import '../../models/validades.dart';
import '../../services/daily_tasks_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';

class DailyTasksTab extends StatefulWidget {
  const DailyTasksTab({super.key});

  @override
  State<DailyTasksTab> createState() => _DailyTasksTabState();
}

class _DailyTasksTabState extends State<DailyTasksTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DailyTasks? _tasks;

  late final TextEditingController _alteracoesCtrl;
  late final TextEditingController _validadesCtrl;
  late final TextEditingController _validadesNoiteCtrl;

  /// Re-checks the Validades windows (and the service day) every minute.
  late final Timer _clock;

  @override
  void initState() {
    super.initState();
    _alteracoesCtrl = TextEditingController();
    _validadesCtrl = TextEditingController();
    _validadesNoiteCtrl = TextEditingController();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (currentServiceDay() != _tasks?.serviceDay) {
        _reload();
      } else {
        setState(() {});
      }
    });
    DailyTasksService.instance.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    DailyTasksService.instance.removeListener(_reload);
    _clock.cancel();
    _alteracoesCtrl.dispose();
    _validadesCtrl.dispose();
    _validadesNoiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final tasks = await DailyTasksService.instance.currentOrCreate();

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      if (_alteracoesCtrl.text != '${tasks.alteracoesPrecoCount}') {
        _alteracoesCtrl.text = tasks.alteracoesPrecoCount == 0
            ? ''
            : '${tasks.alteracoesPrecoCount}';
      }
      if (_validadesCtrl.text != '${tasks.verificacaoValidadesCount}') {
        _validadesCtrl.text = tasks.verificacaoValidadesCount == 0
            ? ''
            : '${tasks.verificacaoValidadesCount}';
      }
      if (_validadesNoiteCtrl.text != '${tasks.validadesNoiteCount}') {
        _validadesNoiteCtrl.text = tasks.validadesNoiteCount == 0
            ? ''
            : '${tasks.validadesNoiteCount}';
      }
    });
  }

  Future<void> _saveTasks() async {
    final t = _tasks;
    if (t == null) return;
    await DailyTasksService.instance.save(t);
  }

  Future<void> _sendMsg(String msg) async {
    if (!mounted) return;
    await WhatsAppService.sendWithConfirm(context, msg);
  }

  Future<void> _completeTask({
    required String taskName,
    required String taskKey,
    required void Function(DailyTasks target, List<String> who) apply,
    required String Function(List<String> who) message,
  }) async {
    final tasks = _tasks;
    if (tasks == null) return;
    final today = DateTime(
      tasks.serviceDay.year,
      tasks.serviceDay.month,
      tasks.serviceDay.day,
    );
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '$taskName\n\nDepois de concluída, não poderá ser desmarcada nesse dia.',
      initialDay: today,
    );
    if (result == null) return;
    final who = result.people.map((p) => p.fullName).toList();
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    if (targetDay == tasks.serviceDay) {
      setState(() => apply(tasks, who));
      await _saveTasks();
      _sendMsg(message(who));
      return;
    }
    final other = await DailyTasksService.instance.forDay(targetDay);
    if (other.notDone.containsKey(taskKey)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nesse dia a tarefa foi marcada como não feita.'),
        ),
      );
      return;
    }
    apply(other, who);
    if (!other.backdatedTaskKeys.contains(taskKey)) {
      other.backdatedTaskKeys = [...other.backdatedTaskKeys, taskKey];
    }
    await DailyTasksService.instance.save(other);
    final dayFmt = DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay);
    _sendMsg('${message(who)} — $dayFmt');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa marcada como concluída em $dayFmt.')),
    );
  }

  /// Marks [taskKey] as Não feita: who, which day and why. Like
  /// [_completeTask], another day's row when the day picked isn't today's.
  Future<void> _markNotDone({
    required String taskName,
    required String taskKey,
  }) async {
    final tasks = _tasks;
    if (tasks == null) return;
    final picked = await pickNotDone(
      context,
      taskName: taskName,
      initialDay: DateTime(
        tasks.serviceDay.year,
        tasks.serviceDay.month,
        tasks.serviceDay.day,
      ),
    );
    if (picked == null) return;
    final (result, reason) = picked;
    final notDone = NotDone(
      byNames: result.people.map((p) => p.fullName).toList(),
      reason: reason,
      at: DateTime.now(),
    );
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    if (targetDay == tasks.serviceDay) {
      setState(() => tasks.notDone = {...tasks.notDone, taskKey: notDone});
      await _saveTasks();
      _sendMsg(notDoneMessage(taskName, notDone));
      return;
    }
    final other = await DailyTasksService.instance.forDay(targetDay);
    if (_isDone(other, taskKey)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nesse dia a tarefa já foi feita.')),
      );
      return;
    }
    other.notDone = {...other.notDone, taskKey: notDone};
    if (!other.backdatedTaskKeys.contains(taskKey)) {
      other.backdatedTaskKeys = [...other.backdatedTaskKeys, taskKey];
    }
    await DailyTasksService.instance.save(other);
    final dayFmt = DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay);
    _sendMsg('${notDoneMessage(taskName, notDone)} — $dayFmt');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa marcada como não feita em $dayFmt.')),
    );
  }

  static bool _isDone(DailyTasks t, String taskKey) => switch (taskKey) {
    'kiwi_abertura' => t.kiwiAbertura,
    'alteracoes_preco' => t.alteracoesPreco,
    'verificacao_temperaturas' => t.verificacaoTemperaturas,
    'preenchimento_quadro' => t.preenchimentoQuadro,
    'verificacao_validades' => t.verificacaoValidades,
    'validades_noite' => t.validadesNoite,
    'kiwi_fecho' => t.kiwiFecho,
    _ => false,
  };

  /// One part of the Verificação de Validades: it can only be marked Feita
  /// while its window is open (see [validadesStateAt]), and Não feita from
  /// when it opens.
  Widget _validadesTask(DailyTasks tasks, ValidadesTurno turno) {
    final manha = turno == ValidadesTurno.manha;
    final done = manha ? tasks.verificacaoValidades : tasks.validadesNoite;
    final count = manha
        ? tasks.verificacaoValidadesCount
        : tasks.validadesNoiteCount;
    final taskKey = manha ? 'verificacao_validades' : 'validades_noite';
    final notDone = tasks.notDone[taskKey];
    final state = validadesStateAt(turno, DateTime.now());
    return _CountTask(
      label: turno.label,
      checked: done,
      notDone: notDone,
      locked: state != ValidadesState.open,
      note: switch (state) {
        _ when done => null,
        ValidadesState.notYet => turno.notYetNote,
        ValidadesState.open => turno.openNote,
        ValidadesState.closed => 'Não feita — falta o motivo',
      },
      noteWarn: !done && state == ValidadesState.closed,
      byNames: manha
          ? resolveNames(
              tasks.verificacaoValidadesByNames,
              tasks.verificacaoValidadesBy,
            )
          : tasks.validadesNoiteByNames,
      backdated: tasks.backdatedTaskKeys.contains(taskKey),
      countController: manha ? _validadesCtrl : _validadesNoiteCtrl,
      onLongPress: done
          ? () => _sendMsg('✅ Tarefa concluída: ${turno.label} ($count)')
          : notDone != null
          ? () => _sendMsg(notDoneMessage(turno.label, notDone))
          : null,
      onDone: state != ValidadesState.open
          ? null
          : () => _completeTask(
              taskName: turno.label,
              taskKey: taskKey,
              apply: (t, who) {
                if (manha) {
                  t.verificacaoValidades = true;
                  t.verificacaoValidadesByNames = who;
                  t.verificacaoValidadesCount = count;
                } else {
                  t.validadesNoite = true;
                  t.validadesNoiteByNames = who;
                  t.validadesNoiteCount = count;
                }
              },
              message: (who) =>
                  '✅ Tarefa concluída: ${turno.label} ($count) (por ${joinNames(who)})',
            ),
      onNotDone: state == ValidadesState.notYet
          ? null
          : () => _markNotDone(taskName: turno.label, taskKey: taskKey),
      onCountChanged: (n) {
        if (manha) {
          tasks.verificacaoValidadesCount = n;
        } else {
          tasks.validadesNoiteCount = n;
        }
        _saveTasks();
      },
    );
  }

  /// A task ticked by hand, with no count.
  Widget _manual(
    DailyTasks tasks, {
    required String label,
    required String taskKey,
    required bool checked,
    required List<String> byNames,
    required void Function(DailyTasks t, List<String> who) apply,
  }) {
    final notDone = tasks.notDone[taskKey];
    return _ManualTask(
      label: label,
      checked: checked,
      notDone: notDone,
      byNames: byNames,
      backdated: tasks.backdatedTaskKeys.contains(taskKey),
      onLongPress: checked
          ? () => _sendMsg('✅ Tarefa concluída: $label')
          : notDone != null
          ? () => _sendMsg(notDoneMessage(label, notDone))
          : null,
      onDone: () => _completeTask(
        taskName: label,
        taskKey: taskKey,
        apply: apply,
        message: (who) => '✅ Tarefa concluída: $label (por ${joinNames(who)})',
      ),
      onNotDone: () => _markNotDone(taskName: label, taskKey: taskKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tasks = _tasks;
    if (tasks == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final day = tasks.serviceDay;
    final dayFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_PT');
    final precoNotDone = tasks.notDone['alteracoes_preco'];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            dayFmt.format(day),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _manual(
            tasks,
            label: 'Kiwi Abertura',
            taskKey: 'kiwi_abertura',
            checked: tasks.kiwiAbertura,
            byNames: resolveNames(
              tasks.kiwiAberturaByNames,
              tasks.kiwiAberturaBy,
            ),
            apply: (t, who) {
              t.kiwiAbertura = true;
              t.kiwiAberturaByNames = who;
            },
          ),
          _CountTask(
            label: 'Alterações de Preço',
            checked: tasks.alteracoesPreco,
            notDone: precoNotDone,
            byNames: resolveNames(
              tasks.alteracoesPrecoByNames,
              tasks.alteracoesPrecoBy,
            ),
            backdated: tasks.backdatedTaskKeys.contains('alteracoes_preco'),
            countController: _alteracoesCtrl,
            onLongPress: tasks.alteracoesPreco
                ? () => _sendMsg(
                    '✅ Tarefa concluída: Alterações de Preço (${tasks.alteracoesPrecoCount})',
                  )
                : precoNotDone != null
                ? () => _sendMsg(
                    notDoneMessage('Alterações de Preço', precoNotDone),
                  )
                : null,
            onDone: () {
              final count = tasks.alteracoesPrecoCount;
              _completeTask(
                taskName: 'Alterações de Preço',
                taskKey: 'alteracoes_preco',
                apply: (t, who) {
                  t.alteracoesPreco = true;
                  t.alteracoesPrecoByNames = who;
                  t.alteracoesPrecoCount = count;
                },
                message: (who) =>
                    '✅ Tarefa concluída: Alterações de Preço ($count) (por ${joinNames(who)})',
              );
            },
            onNotDone: () => _markNotDone(
              taskName: 'Alterações de Preço',
              taskKey: 'alteracoes_preco',
            ),
            onCountChanged: (n) {
              tasks.alteracoesPrecoCount = n;
              _saveTasks();
            },
          ),
          _manual(
            tasks,
            label: 'Verificação de Temperaturas',
            taskKey: 'verificacao_temperaturas',
            checked: tasks.verificacaoTemperaturas,
            byNames: resolveNames(
              tasks.verificacaoTemperaturasByNames,
              tasks.verificacaoTemperaturasBy,
            ),
            apply: (t, who) {
              t.verificacaoTemperaturas = true;
              t.verificacaoTemperaturasByNames = who;
            },
          ),
          _manual(
            tasks,
            label: 'Preenchimento do Quadro',
            taskKey: 'preenchimento_quadro',
            checked: tasks.preenchimentoQuadro,
            byNames: resolveNames(
              tasks.preenchimentoQuadroByNames,
              tasks.preenchimentoQuadroBy,
            ),
            apply: (t, who) {
              t.preenchimentoQuadro = true;
              t.preenchimentoQuadroByNames = who;
            },
          ),
          _validadesTask(tasks, ValidadesTurno.manha),
          _validadesTask(tasks, ValidadesTurno.noite),
          _manual(
            tasks,
            label: 'Kiwi Fecho',
            taskKey: 'kiwi_fecho',
            checked: tasks.kiwiFecho,
            byNames: resolveNames(tasks.kiwiFechoByNames, tasks.kiwiFechoBy),
            apply: (t, who) {
              t.kiwiFecho = true;
              t.kiwiFechoByNames = who;
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

class _ManualTask extends StatelessWidget {
  const _ManualTask({
    required this.label,
    required this.checked,
    required this.onDone,
    required this.onNotDone,
    this.notDone,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
  });

  final String label;
  final bool checked;
  final NotDone? notDone;
  final VoidCallback onDone;
  final VoidCallback onNotDone;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;

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
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: notDone != null && !checked
              ? NotDoneNote(notDone, backdated: backdated)
              : (checked && backdated)
              ? const _BackdatedNote()
              : null,
          trailing: names.isNotEmpty
              ? PersonInitialsRow(names: names, size: 30)
              : null,
        ),
      ),
    );
  }
}

class _CountTask extends StatelessWidget {
  const _CountTask({
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
    this.locked = false,
    this.note,
    this.noteWarn = false,
  });

  final String label;
  final bool checked;
  final NotDone? notDone;

  /// Outside its window: the count can't change.
  final bool locked;

  /// Shown under the label ("Abre às 19h"), in orange when [noteWarn].
  final String? note;
  final bool noteWarn;
  final TextEditingController countController;

  /// Null leaves that marker disabled.
  final VoidCallback? onDone;
  final VoidCallback? onNotDone;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;

  @override
  Widget build(BuildContext context) {
    final notDone = this.notDone;
    final closed = checked || notDone != null;
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
              : switch (note) {
                  null => null,
                  final note => Row(
                    children: [
                      Icon(
                        locked ? Icons.lock_outline : Icons.schedule,
                        size: 12,
                        color: noteWarn
                            ? Colors.orange.shade800
                            : context.faintest,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          note,
                          style: TextStyle(
                            fontSize: 12,
                            color: noteWarn
                                ? Colors.orange.shade800
                                : context.muted,
                            fontWeight: noteWarn ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                },
          trailing: SizedBox(
            width: 72,
            child: TextField(
              controller: countController,
              enabled: !closed && !locked,
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
