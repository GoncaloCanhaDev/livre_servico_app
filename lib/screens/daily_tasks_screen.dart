import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/daily_tasks.dart';
import '../models/opening_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/opening_list_service.dart';
import '../services/report_list_service.dart';
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
    final visualEntries =
        await VisualListService.instance.entriesForServiceDay(day);
    final allAuto = await AutoListService.instance.history();
    final dayStart = day;
    final dayEnd = day.add(const Duration(hours: 24));
    final autoToday = allAuto
        .where((a) =>
            !a.createdAt.isBefore(dayStart) && a.createdAt.isBefore(dayEnd))
        .toList();

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _aberturaDone = opening.isFinalized;
      _relatorioDone = report.isFinalized;
      _visualItens =
          visualEntries.fold(0, (s, e) => s + e.itensPicados);
      _autoCount = autoToday.length;
      if (_alteracoesCtrl.text != '${tasks.alteracoesPrecoCount}') {
        _alteracoesCtrl.text =
            tasks.alteracoesPrecoCount == 0 ? '' : '${tasks.alteracoesPrecoCount}';
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

  Future<bool> _confirmTask(String taskName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Tarefa'),
        content: Text('Tem a certeza que quer concluir a tarefa:\n"$taskName"?\n\nDepois de concluída, não poderá ser desmarcada hoje.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Concluir', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;
    if (tasks == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final day = tasks.serviceDay;
    final isSaturday = day.weekday == DateTime.saturday;
    final dayFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_PT');
    final visualDone = _visualItens >= 200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Diárias'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              dayFmt.format(day),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _ManualTask(
              label: 'Kiwi Abertura',
              checked: tasks.kiwiAbertura,
              onLongPress: tasks.kiwiAbertura ? () => _sendMsg('✅ Tarefa concluída: Kiwi Abertura') : null,
              onChanged: (v) async {
                if (v && !await _confirmTask('Kiwi Abertura')) return;
                setState(() => tasks.kiwiAbertura = v);
                await _saveTasks();
                if (v) _sendMsg('✅ Tarefa concluída: Kiwi Abertura');
              },
            ),
            _CountTask(
              label: 'Alterações de Preço',
              checked: tasks.alteracoesPreco,
              countController: _alteracoesCtrl,
              onLongPress: tasks.alteracoesPreco ? () => _sendMsg('✅ Tarefa concluída: Alterações de Preço (${tasks.alteracoesPrecoCount})') : null,
              onCheckedChanged: (v) async {
                if (v && !await _confirmTask('Alterações de Preço')) return;
                setState(() => tasks.alteracoesPreco = v);
                await _saveTasks();
                if (v) _sendMsg('✅ Tarefa concluída: Alterações de Preço (${tasks.alteracoesPrecoCount})');
              },
              onCountChanged: (n) {
                tasks.alteracoesPrecoCount = n;
                _saveTasks();
              },
            ),
            _ManualTask(
              label: 'Verificação de Temperaturas',
              checked: tasks.verificacaoTemperaturas,
              onLongPress: tasks.verificacaoTemperaturas ? () => _sendMsg('✅ Tarefa concluída: Verificação de Temperaturas') : null,
              onChanged: (v) async {
                if (v && !await _confirmTask('Verificação de Temperaturas')) return;
                setState(() => tasks.verificacaoTemperaturas = v);
                await _saveTasks();
                if (v) _sendMsg('✅ Tarefa concluída: Verificação de Temperaturas');
              },
            ),
            _AutoTask(
              label: 'Lista de Abertura',
              checked: _aberturaDone,
              note: _aberturaDone ? null : 'Finaliza no separador Abertura',
              onLongPress: _aberturaDone ? () => _sendMsg('✅ Tarefa concluída: Lista de Abertura') : null,
            ),
            _AutoTask(
              label: 'Relatório das Listas',
              checked: _relatorioDone,
              note: _relatorioDone
                  ? null
                  : 'Finaliza no separador Relatório',
              onLongPress: _relatorioDone ? () => _sendMsg('✅ Tarefa concluída: Relatório das Listas') : null,
            ),
            _ManualTask(
              label: 'Preenchimento do Quadro',
              checked: tasks.preenchimentoQuadro,
              onLongPress: tasks.preenchimentoQuadro ? () => _sendMsg('✅ Tarefa concluída: Preenchimento do Quadro') : null,
              onChanged: (v) async {
                if (v && !await _confirmTask('Preenchimento do Quadro')) return;
                setState(() => tasks.preenchimentoQuadro = v);
                await _saveTasks();
                if (v) _sendMsg('✅ Tarefa concluída: Preenchimento do Quadro');
              },
            ),
            _AutoTask(
              label: 'Lista Visual',
              checked: visualDone,
              note: '$_visualItens / 200 itens picados hoje',
              onLongPress: visualDone ? () => _sendMsg('✅ Tarefa concluída: Lista Visual') : null,
            ),
            _AutoTask(
              label: 'Lista Automática',
              checked: _autoCount > 0,
              note: _autoCount == 0
                  ? 'Sem listas automáticas hoje'
                  : '$_autoCount lista${_autoCount == 1 ? '' : 's'} hoje',
              onLongPress: _autoCount > 0 ? () => _sendMsg('✅ Tarefa concluída: Lista Automática') : null,
            ),
            _CountTask(
              label: 'Verificação de Validades',
              checked: tasks.verificacaoValidades,
              countController: _validadesCtrl,
              onLongPress: tasks.verificacaoValidades ? () => _sendMsg('✅ Tarefa concluída: Verificação de Validades (${tasks.verificacaoValidadesCount})') : null,
              onCheckedChanged: (v) async {
                if (v && !await _confirmTask('Verificação de Validades')) return;
                setState(() => tasks.verificacaoValidades = v);
                await _saveTasks();
                if (v) _sendMsg('✅ Tarefa concluída: Verificação de Validades (${tasks.verificacaoValidadesCount})');
              },
              onCountChanged: (n) {
                tasks.verificacaoValidadesCount = n;
                _saveTasks();
              },
            ),
            _ManualTask(
              label: 'Kiwi Fecho',
              checked: tasks.kiwiFecho,
              onLongPress: tasks.kiwiFecho ? () => _sendMsg('✅ Tarefa concluída: Kiwi Fecho') : null,
              onChanged: (v) async {
                if (v && !await _confirmTask('Kiwi Fecho')) return;
                setState(() => tasks.kiwiFecho = v);
                await _saveTasks();
                if (v) _sendMsg('✅ Tarefa concluída: Kiwi Fecho');
              },
            ),
            _ManualTask(
              label: 'Limpeza da Máquina Voltas',
              checked: tasks.limpezaMaquinaVoltas,
              enabled: isSaturday,
              note: isSaturday ? null : 'Apenas ao sábado',
              onLongPress: tasks.limpezaMaquinaVoltas ? () => _sendMsg('✅ Tarefa concluída: Limpeza da Máquina Voltas') : null,
              onChanged: (v) async {
                if (v && !await _confirmTask('Limpeza da Máquina Voltas')) return;
                setState(() => tasks.limpezaMaquinaVoltas = v);
                await _saveTasks();
                if (v) _sendMsg('✅ Tarefa concluída: Limpeza da Máquina Voltas');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualTask extends StatelessWidget {
  const _ManualTask({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.enabled = true,
    this.note,
    this.onLongPress,
  });

  final String label;
  final bool checked;
  final bool enabled;
  final String? note;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: checked,
          onChanged: enabled ? (v) {
            if (checked) return;
            onChanged(v ?? false);
          } : null,
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
          subtitle: note == null ? null : Text(note!),
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
  });

  final String label;
  final bool checked;
  final TextEditingController countController;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;

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
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
          secondary: SizedBox(
            width: 90,
            child: TextField(
              controller: countController,
              enabled: !checked,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
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
