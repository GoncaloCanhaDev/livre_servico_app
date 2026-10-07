import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'widgets/person_picker.dart';

import '../models/daily_tasks.dart';
import '../models/opening_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/opening_list_service.dart';
import '../services/report_list_service.dart';
import '../services/settings_service.dart';
import '../services/visual_list_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  DailyTasks? _tasks;
  bool _aberturaDone = false;
  bool _relatorioDone = false;
  int _visualItens = 0;
  int _autoCount = 0;

  late final TextEditingController _alteracoesCtrl;
  late final TextEditingController _validadesCtrl;

  @override
  void initState() {
    super.initState();
    _alteracoesCtrl = TextEditingController();
    _validadesCtrl = TextEditingController();
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
    _alteracoesCtrl.dispose();
    _validadesCtrl.dispose();
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
    final allAuto = await AutoListService.instance.history();
    final dayStart = day;
    final dayEnd = day.add(const Duration(hours: 24));
    final autoToday = allAuto
        .where(
          (a) =>
              !a.createdAt.isBefore(dayStart) && a.createdAt.isBefore(dayEnd),
        )
        .toList();

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

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;
    if (tasks == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final day = tasks.serviceDay;
    final dayFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_PT');
    final visualGoal = SettingsService.instance.visualGoal;
    final visualDone = _visualItens >= visualGoal;

    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas Diárias')),
      body: SafeArea(
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
              byNames: resolveNames(tasks.kiwiAberturaByNames, tasks.kiwiAberturaBy),
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
              byNames: resolveNames(tasks.alteracoesPrecoByNames, tasks.alteracoesPrecoBy),
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
              byNames: resolveNames(tasks.verificacaoTemperaturasByNames, tasks.verificacaoTemperaturasBy),
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
              byNames: resolveNames(tasks.preenchimentoQuadroByNames, tasks.preenchimentoQuadroBy),
              backdated: tasks.backdatedTaskKeys.contains(
                'preenchimento_quadro',
              ),
              onLongPress: tasks.preenchimentoQuadro
                  ? () =>
                        _sendMsg('✅ Tarefa concluída: Preenchimento do Quadro')
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
            _CountTask(
              label: 'Verificação de Validades',
              checked: tasks.verificacaoValidades,
              byNames: resolveNames(tasks.verificacaoValidadesByNames, tasks.verificacaoValidadesBy),
              backdated: tasks.backdatedTaskKeys.contains(
                'verificacao_validades',
              ),
              countController: _validadesCtrl,
              onLongPress: tasks.verificacaoValidades
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificação de Validades (${tasks.verificacaoValidadesCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.verificacaoValidadesCount;
                await _completeTask(
                  taskName: 'Verificação de Validades',
                  taskKey: 'verificacao_validades',
                  apply: (t, who) {
                    t.verificacaoValidades = true;
                    t.verificacaoValidadesByNames = who;
                    t.verificacaoValidadesCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificação de Validades ($count) (por ${joinNames(who)})',
                );
              },
              onCountChanged: (n) {
                tasks.verificacaoValidadesCount = n;
                _saveTasks();
              },
            ),
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
          activeColor: AppColors.green,
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
          activeColor: AppColors.green,
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Row(
            children: [
              const Icon(Icons.lock_outline, size: 12, color: Colors.black38),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  note ?? 'Automática',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
  });

  final String label;
  final bool checked;
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
          subtitle: (checked && backdated) ? const _BackdatedNote() : null,
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
