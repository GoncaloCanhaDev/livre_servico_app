import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/auto_mark_note.dart';
import '../widgets/auto_mark_review.dart';
import '../widgets/person_picker.dart';
import '../widgets/task_markers.dart';

import '../../models/auto_mark.dart';
import '../../models/daily_tasks.dart';
import '../../models/not_done.dart';
import '../../models/opening_list.dart';
import '../../models/validades.dart';
import '../../models/visivel2_entry.dart';
import '../../services/server_clock.dart';
import '../../services/account_service.dart';
import '../../services/auto2_service.dart';
import '../../services/daily_tasks_service.dart';
import '../../services/task_window_service.dart';
import '../../services/visivel2_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';

part 'daily_tasks/task_rows.dart';
part 'daily_tasks/validades_left_dialog.dart';

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

  /// Today's Listas 2.0 Visíveis (the Lista Visível is done with one) and
  /// how many Automáticas were sent (only counted, never ticked).
  List<Visivel2Entry> _visiveis = [];
  int _autoCount = 0;

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
    Visivel2Service.instance.addListener(_reload);
    Auto2Service.instance.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    DailyTasksService.instance.removeListener(_reload);
    Visivel2Service.instance.removeListener(_reload);
    Auto2Service.instance.removeListener(_reload);
    _clock.cancel();
    _alteracoesCtrl.dispose();
    _validadesCtrl.dispose();
    _validadesNoiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final tasks = await DailyTasksService.instance.currentOrCreate();
    final visiveis = await Visivel2Service.instance.forServiceDay(
      tasks.serviceDay,
    );
    final autos = await Auto2Service.instance.forServiceDay(tasks.serviceDay);

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _visiveis = visiveis;
      _autoCount = autos.length;
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
    Future<void> Function(DailyTasks target)? after,
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
      await after?.call(tasks);
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
    await after?.call(other);
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
    void Function(DailyTasks target)? apply,
    Future<void> Function(DailyTasks target)? after,
    String suffix = '',
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
      at: ServerClock.now(),
    );
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    if (targetDay == tasks.serviceDay) {
      setState(() {
        tasks.notDone = {...tasks.notDone, taskKey: notDone};
        apply?.call(tasks);
      });
      await _saveTasks();
      await after?.call(tasks);
      _sendMsg('${notDoneMessage(taskName, notDone)}$suffix');
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
    apply?.call(other);
    if (!other.backdatedTaskKeys.contains(taskKey)) {
      other.backdatedTaskKeys = [...other.backdatedTaskKeys, taskKey];
    }
    await DailyTasksService.instance.save(other);
    await after?.call(other);
    final dayFmt = DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay);
    _sendMsg('${notDoneMessage(taskName, notDone)}$suffix — $dayFmt');
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

  /// The notes under a task the app marked by itself, and under one whose
  /// number (or, for a Validades window, the artigos left) is still to be
  /// filled in.
  List<Widget> _autoNotes(
    DailyTasks tasks,
    String key,
    String label, {
    void Function(int n)? setCount,
    ValidadesTurno? turno,
  }) {
    final mark = tasks.autoMarks[key];
    final canReview = AccountService.instance.access.canConfirmTasks;
    return [
      if (mark != null)
        AutoMarkNote(
          mark,
          onReview: canReview
              ? () => reviewDailyMark(context, tasks, key, label)
              : null,
        ),
      if (setCount != null && tasks.pendingCounts.contains(key))
        PendingNumberNote(
          text: 'Número por preencher',
          onFill: () async {
            final n = await askNumber(context, label);
            if (n == null) return;
            setCount(n);
            tasks.pendingCounts = [...tasks.pendingCounts]..remove(key);
            await DailyTasksService.instance.save(tasks, edited: key);
          },
        ),
      if (turno != null && tasks.pendingCounts.contains(leftKey(key)))
        PendingNumberNote(
          text: 'Falta dizer quantos ficaram por fazer',
          onFill: () async {
            final n = await askValidadesLeft(context, turno);
            if (n == null) return;
            tasks.setValidadesLeft(turno, n);
            tasks.pendingCounts = [...tasks.pendingCounts]
              ..remove(leftKey(key));
            await DailyTasksService.instance.save(tasks, edited: key);
            await DailyTasksService.instance.carryValidades(tasks, turno, n);
          },
        ),
    ];
  }

  /// Adds [key] to `pendingCounts` when its number field was left empty.
  static void _pendingIfEmpty(
    DailyTasks t,
    String key,
    TextEditingController ctrl,
  ) {
    if (ctrl.text.trim().isEmpty && !t.pendingCounts.contains(key)) {
      t.pendingCounts = [...t.pendingCounts, key];
    }
  }

  /// One part of the Verificação de Validades: it can be marked from when
  /// its window opens (see [validadesStateAt]) until the service day ends,
  /// so a check done but not ticked in time can still be ticked later.
  /// Marking it (feita or não feita) asks how many artigos were left, which
  /// are added to the next window's count ([nextValidadesWindow]).
  Widget _validadesTask(DailyTasks tasks, ValidadesTurno turno) {
    final manha = turno == ValidadesTurno.manha;
    final done = manha ? tasks.verificacaoValidades : tasks.validadesNoite;
    final count = manha
        ? tasks.verificacaoValidadesCount
        : tasks.validadesNoiteCount;
    final taskKey = manha ? 'verificacao_validades' : 'validades_noite';
    final notDone = tasks.notDone[taskKey];
    final left = tasks.validadesLeft(turno);
    final carried = tasks.validadesCarried(turno);
    final window = TaskWindowService.instance.windowFor(turno.taskKey);
    final state = validadesStateAt(turno, DateTime.now(), window: window);
    String leftSuffix(int n) =>
        n > 0 ? ' · ficaram $n por fazer (${carriedToText(turno)})' : '';
    Future<void> carry(DailyTasks target) async {
      final n = target.validadesLeft(turno);
      final added = await DailyTasksService.instance.carryValidades(
        target,
        turno,
        n,
      );
      if (n > 0 && !added && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A validade seguinte já estava marcada: as que ficaram não '
              'foram somadas.',
            ),
          ),
        );
      }
    }

    final ctrl = manha ? _validadesCtrl : _validadesNoiteCtrl;
    return _CountTask(
      label: turno.label,
      notes: _autoNotes(
        tasks,
        taskKey,
        turno.label,
        setCount: (n) => manha
            ? tasks.verificacaoValidadesCount = n
            : tasks.validadesNoiteCount = n,
        turno: turno,
      ),
      checked: done,
      notDone: notDone,
      locked: state == ValidadesState.notYet,
      note: switch (state) {
        _ when done => null,
        ValidadesState.notYet => window.notYetNote,
        ValidadesState.open => window.openNote,
        ValidadesState.closed => window.lateNote,
      },
      noteWarn: !done && state == ValidadesState.closed,
      extraNotes: [
        if (carried > 0)
          (
            Icons.subdirectory_arrow_right,
            carriedFromText(turno, carried),
            false,
          ),
        if (left > 0)
          (
            Icons.redo,
            'Ficaram $left por fazer — ${carriedToText(turno)}',
            true,
          ),
      ],
      byNames: manha
          ? resolveNames(
              tasks.verificacaoValidadesByNames,
              tasks.verificacaoValidadesBy,
            )
          : tasks.validadesNoiteByNames,
      backdated: tasks.backdatedTaskKeys.contains(taskKey),
      countController: manha ? _validadesCtrl : _validadesNoiteCtrl,
      onLongPress: done
          ? () => _sendMsg(
              '✅ Tarefa concluída: ${turno.label} ($count)${leftSuffix(left)}',
            )
          : notDone != null
          ? () => _sendMsg(
              '${notDoneMessage(turno.label, notDone)}${leftSuffix(left)}',
            )
          : null,
      onDone: state == ValidadesState.notYet
          ? null
          : () async {
              final n = await askValidadesLeft(context, turno);
              if (n == null || !mounted) return;
              await _completeTask(
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
                  t.setValidadesLeft(turno, n);
                  _pendingIfEmpty(t, taskKey, ctrl);
                },
                after: carry,
                message: (who) =>
                    '✅ Tarefa concluída: ${turno.label} ($count) (por ${joinNames(who)})${leftSuffix(n)}',
              );
            },
      onNotDone: state == ValidadesState.notYet
          ? null
          : () async {
              final n = await askValidadesLeft(context, turno);
              if (n == null || !mounted) return;
              await _markNotDone(
                taskName: turno.label,
                taskKey: taskKey,
                apply: (t) => t.setValidadesLeft(turno, n),
                after: carry,
                suffix: leftSuffix(n),
              );
            },
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
      notes: _autoNotes(tasks, taskKey, label),
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
            notes: _autoNotes(
              tasks,
              'alteracoes_preco',
              'Alterações de Preço',
              setCount: (n) => tasks.alteracoesPrecoCount = n,
            ),
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
                  _pendingIfEmpty(t, 'alteracoes_preco', _alteracoesCtrl);
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
          _ListTask(
            label: 'Lista Visível',
            checked: _visiveis.isNotEmpty,
            note: _visiveis.isEmpty
                ? 'Faz-se em Listas 2.0 → Visível'
                : '${_visiveis.fold(0, (s, e) => s + e.itens)} itens picados · '
                      'por ${joinNames({for (final v in _visiveis) ...v.byNames}.toList())}',
            onLongPress: _visiveis.isEmpty
                ? null
                : () => _sendMsg('✅ Tarefa concluída: Lista Visível'),
          ),
          _CounterTask(
            label: 'Lista Automática',
            count: _autoCount,
            note: _autoCount == 1
                ? '1 automática enviada hoje'
                : '$_autoCount automáticas enviadas hoje',
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
