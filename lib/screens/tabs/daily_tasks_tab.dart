import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/person_picker.dart';

import '../../models/daily_tasks.dart';
import '../../models/opening_list.dart';
import '../../models/validades.dart';
import '../../services/auto_list_service.dart';
import '../../services/daily_tasks_service.dart';
import '../../services/opening_list_service.dart';
import '../../services/report_list_service.dart';
import '../../services/settings_service.dart';
import '../../services/visual_list_service.dart';
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
  bool _aberturaDone = false;
  bool _relatorioDone = false;
  int _visualItens = 0;
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
    OpeningListService.instance.addListener(_reload);
    ReportListService.instance.addListener(_reload);
    VisualListService.instance.addListener(_reload);
    AutoListService.instance.addListener(_reload);
    DailyTasksService.instance.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    OpeningListService.instance.removeListener(_reload);
    ReportListService.instance.removeListener(_reload);
    VisualListService.instance.removeListener(_reload);
    AutoListService.instance.removeListener(_reload);
    DailyTasksService.instance.removeListener(_reload);
    _clock.cancel();
    _alteracoesCtrl.dispose();
    _validadesCtrl.dispose();
    _validadesNoiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final day = currentServiceDay();
    final tasks = await DailyTasksService.instance.currentOrCreate();

    final opening = await OpeningListService.instance.currentOrCreate();
    final report = await ReportListService.instance.currentOrCreate();
    final visualEntries = await VisualListService.instance.entriesForServiceDay(
      day,
    );
    final autoToday = await AutoListService.instance.entriesForServiceDay(day);

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _aberturaDone = opening.isFinalized;
      _relatorioDone = report.isFinalized;
      _visualItens = visualEntries.fold(0, (s, e) => s + e.itensPicados);
      _autoCount = autoToday.length;
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

  /// One part of the Verificação de Validades: it can only be ticked while
  /// its window is open (see [validadesStateAt]).
  Widget _validadesTask(DailyTasks tasks, ValidadesTurno turno) {
    final manha = turno == ValidadesTurno.manha;
    final done = manha ? tasks.verificacaoValidades : tasks.validadesNoite;
    final count = manha
        ? tasks.verificacaoValidadesCount
        : tasks.validadesNoiteCount;
    final taskKey = manha ? 'verificacao_validades' : 'validades_noite';
    final state = validadesStateAt(turno, DateTime.now());
    return _CountTask(
      label: turno.label,
      checked: done,
      locked: state != ValidadesState.open,
      note: switch (state) {
        _ when done => null,
        ValidadesState.notYet => turno.notYetNote,
        ValidadesState.open => turno.openNote,
        ValidadesState.closed => 'Não feita',
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
          : null,
      onCheckedChanged: (v) async {
        if (!v) return;
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
          },
          message: (who) =>
              '✅ Tarefa concluída: ${turno.label} ($count) (por ${joinNames(who)})',
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tasks = _tasks;
    if (tasks == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final day = tasks.serviceDay;
    final dayFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_PT');
    final visualGoal = SettingsService.instance.visualGoal;
    final visualDone = _visualItens >= visualGoal;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            dayFmt.format(day),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _ManualTask(
            label: 'Kiwi Abertura',
            checked: tasks.kiwiAbertura,
            byNames: resolveNames(
              tasks.kiwiAberturaByNames,
              tasks.kiwiAberturaBy,
            ),
            backdated: tasks.backdatedTaskKeys.contains('kiwi_abertura'),
            onLongPress: tasks.kiwiAbertura
                ? () => _sendMsg('✅ Tarefa concluída: Kiwi Abertura')
                : null,
            onChanged: (v) async {
              if (!v) return;
              await _completeTask(
                taskName: 'Kiwi Abertura',
                taskKey: 'kiwi_abertura',
                apply: (t, who) {
                  t.kiwiAbertura = true;
                  t.kiwiAberturaByNames = who;
                },
                message: (who) =>
                    '✅ Tarefa concluída: Kiwi Abertura (por ${joinNames(who)})',
              );
            },
          ),
          _CountTask(
            label: 'Alterações de Preço',
            checked: tasks.alteracoesPreco,
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
                : null,
            onCheckedChanged: (v) async {
              if (!v) return;
              final count = tasks.alteracoesPrecoCount;
              await _completeTask(
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
            onCountChanged: (n) {
              tasks.alteracoesPrecoCount = n;
              _saveTasks();
            },
          ),
          _ManualTask(
            label: 'Verificação de Temperaturas',
            checked: tasks.verificacaoTemperaturas,
            byNames: resolveNames(
              tasks.verificacaoTemperaturasByNames,
              tasks.verificacaoTemperaturasBy,
            ),
            backdated: tasks.backdatedTaskKeys.contains(
              'verificacao_temperaturas',
            ),
            onLongPress: tasks.verificacaoTemperaturas
                ? () => _sendMsg(
                    '✅ Tarefa concluída: Verificação de Temperaturas',
                  )
                : null,
            onChanged: (v) async {
              if (!v) return;
              await _completeTask(
                taskName: 'Verificação de Temperaturas',
                taskKey: 'verificacao_temperaturas',
                apply: (t, who) {
                  t.verificacaoTemperaturas = true;
                  t.verificacaoTemperaturasByNames = who;
                },
                message: (who) =>
                    '✅ Tarefa concluída: Verificação de Temperaturas (por ${joinNames(who)})',
              );
            },
          ),
          _AutoTask(
            label: 'Lista de Abertura',
            checked: _aberturaDone,
            note: _aberturaDone ? null : 'Finaliza no separador Abertura',
            onLongPress: _aberturaDone
                ? () => _sendMsg('✅ Tarefa concluída: Lista de Abertura')
                : null,
          ),
          _AutoTask(
            label: 'Relatório das Listas',
            checked: _relatorioDone,
            note: _relatorioDone ? null : 'Finaliza no separador Relatório',
            onLongPress: _relatorioDone
                ? () => _sendMsg('✅ Tarefa concluída: Relatório das Listas')
                : null,
          ),
          _ManualTask(
            label: 'Preenchimento do Quadro',
            checked: tasks.preenchimentoQuadro,
            byNames: resolveNames(
              tasks.preenchimentoQuadroByNames,
              tasks.preenchimentoQuadroBy,
            ),
            backdated: tasks.backdatedTaskKeys.contains('preenchimento_quadro'),
            onLongPress: tasks.preenchimentoQuadro
                ? () => _sendMsg('✅ Tarefa concluída: Preenchimento do Quadro')
                : null,
            onChanged: (v) async {
              if (!v) return;
              await _completeTask(
                taskName: 'Preenchimento do Quadro',
                taskKey: 'preenchimento_quadro',
                apply: (t, who) {
                  t.preenchimentoQuadro = true;
                  t.preenchimentoQuadroByNames = who;
                },
                message: (who) =>
                    '✅ Tarefa concluída: Preenchimento do Quadro (por ${joinNames(who)})',
              );
            },
          ),
          _AutoTask(
            label: 'Lista Visual',
            checked: visualDone,
            note: '$_visualItens / $visualGoal itens picados hoje',
            onLongPress: visualDone
                ? () => _sendMsg('✅ Tarefa concluída: Lista Visual')
                : null,
          ),
          _AutoTask(
            label: 'Lista Automática',
            checked: _autoCount > 0,
            note: _autoCount == 0
                ? 'Sem listas automáticas hoje'
                : '$_autoCount lista${_autoCount == 1 ? '' : 's'} hoje',
            onLongPress: _autoCount > 0
                ? () => _sendMsg('✅ Tarefa concluída: Lista Automática')
                : null,
          ),
          _validadesTask(tasks, ValidadesTurno.manha),
          _validadesTask(tasks, ValidadesTurno.noite),
          _ManualTask(
            label: 'Kiwi Fecho',
            checked: tasks.kiwiFecho,
            byNames: resolveNames(tasks.kiwiFechoByNames, tasks.kiwiFechoBy),
            backdated: tasks.backdatedTaskKeys.contains('kiwi_fecho'),
            onLongPress: tasks.kiwiFecho
                ? () => _sendMsg('✅ Tarefa concluída: Kiwi Fecho')
                : null,
            onChanged: (v) async {
              if (!v) return;
              await _completeTask(
                taskName: 'Kiwi Fecho',
                taskKey: 'kiwi_fecho',
                apply: (t, who) {
                  t.kiwiFecho = true;
                  t.kiwiFechoByNames = who;
                },
                message: (who) =>
                    '✅ Tarefa concluída: Kiwi Fecho (por ${joinNames(who)})',
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

class _ManualTask extends StatelessWidget {
  const _ManualTask({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;

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
          activeColor: context.colors.primary,
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: (checked && backdated) ? const _BackdatedNote() : null,
          secondary: (checked && byNames.isNotEmpty)
              ? PersonInitialsRow(names: byNames, size: 30)
              : null,
        ),
      ),
    );
  }
}

class _AutoTask extends StatelessWidget {
  const _AutoTask({
    required this.label,
    required this.checked,
    this.note,
    this.onLongPress,
  });

  final String label;
  final bool checked;
  final String? note;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: checked,
          onChanged: null,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: context.colors.primary,
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.lock_outline, size: 12, color: context.faintest),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  note ?? 'Automática',
                  style: TextStyle(fontSize: 12, color: context.muted),
                ),
              ),
            ],
          ),
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
    required this.onCheckedChanged,
    required this.onCountChanged,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.locked = false,
    this.note,
    this.noteWarn = false,
  });

  final String label;
  final bool checked;

  /// Outside its window: can't be ticked and the count can't change.
  final bool locked;

  /// Shown under the label ("Abre às 19h"), in orange when [noteWarn].
  final String? note;
  final bool noteWarn;
  final TextEditingController countController;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: checked,
          onChanged: locked && !checked
              ? null
              : (v) {
                  if (checked) return;
                  onCheckedChanged(v ?? false);
                },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: context.colors.primary,
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
          secondary: SizedBox(
            width: 90,
            child: TextField(
              controller: countController,
              enabled: !checked && !locked,
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
