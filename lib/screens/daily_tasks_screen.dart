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

  @override
  void initState() {
    super.initState();
    _alteracoesCtrl = TextEditingController();
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
    });
  }

  Future<void> _saveTasks() async {
    final t = _tasks;
    if (t == null) return;
    await DailyTasksService.instance.save(t);
  }

  Future<void> _openHistory() async {
    final items = await DailyTasksService.instance.history();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HistorySheet(items: items),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: _openHistory,
          ),
        ],
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
              onChanged: (v) {
                setState(() => tasks.kiwiAbertura = v);
                _saveTasks();
              },
            ),
            _AlteracoesPrecoTask(
              checked: tasks.alteracoesPreco,
              countController: _alteracoesCtrl,
              onCheckedChanged: (v) {
                setState(() => tasks.alteracoesPreco = v);
                _saveTasks();
              },
              onCountChanged: (n) {
                tasks.alteracoesPrecoCount = n;
                _saveTasks();
              },
            ),
            _AutoTask(
              label: 'Lista de Abertura',
              checked: _aberturaDone,
              note: _aberturaDone ? null : 'Finaliza no separador Abertura',
            ),
            _AutoTask(
              label: 'Relatório das Listas',
              checked: _relatorioDone,
              note: _relatorioDone
                  ? null
                  : 'Finaliza no separador Relatório',
            ),
            _ManualTask(
              label: 'Preenchimento do Quadro',
              checked: tasks.preenchimentoQuadro,
              onChanged: (v) {
                setState(() => tasks.preenchimentoQuadro = v);
                _saveTasks();
              },
            ),
            _AutoTask(
              label: 'Lista Visual',
              checked: visualDone,
              note: '$_visualItens / 200 itens picados hoje',
            ),
            _AutoTask(
              label: 'Lista Automática',
              checked: _autoCount > 0,
              note: _autoCount == 0
                  ? 'Sem listas automáticas hoje'
                  : '$_autoCount lista${_autoCount == 1 ? '' : 's'} hoje',
            ),
            _ManualTask(
              label: 'Kiwi Fecho',
              checked: tasks.kiwiFecho,
              onChanged: (v) {
                setState(() => tasks.kiwiFecho = v);
                _saveTasks();
              },
            ),
            _ManualTask(
              label: 'Limpeza da Máquina Voltas',
              checked: tasks.limpezaMaquinaVoltas,
              enabled: isSaturday,
              note: isSaturday ? null : 'Apenas ao sábado',
              onChanged: (v) {
                setState(() => tasks.limpezaMaquinaVoltas = v);
                _saveTasks();
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
  });

  final String label;
  final bool checked;
  final bool enabled;
  final String? note;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        value: checked,
        onChanged: enabled ? (v) => onChanged(v ?? false) : null,
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
    );
  }
}

class _AutoTask extends StatelessWidget {
  const _AutoTask({
    required this.label,
    required this.checked,
    this.note,
  });

  final String label;
  final bool checked;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: checked ? AppColors.green : Colors.black38,
        ),
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
    );
  }
}

class _AlteracoesPrecoTask extends StatelessWidget {
  const _AlteracoesPrecoTask({
    required this.checked,
    required this.countController,
    required this.onCheckedChanged,
    required this.onCountChanged,
  });

  final bool checked;
  final TextEditingController countController;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<int> onCountChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (v) => onCheckedChanged(v ?? false),
              activeColor: AppColors.green,
            ),
            Expanded(
              child: Text(
                'Alterações de Preço',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            SizedBox(
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
          ],
        ),
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({required this.items});
  final List<DailyTasks> items;

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat("EEEE, d 'de' MMM y", 'pt_PT');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Sem histórico.'),
            ),
          );
        }
        return ListView.separated(
          controller: scrollCtrl,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final t = items[i];
            final manual = [
              if (t.kiwiAbertura) 'Kiwi Abertura',
              if (t.alteracoesPreco)
                'Alterações de Preço (${t.alteracoesPrecoCount})',
              if (t.preenchimentoQuadro) 'Preench. Quadro',
              if (t.kiwiFecho) 'Kiwi Fecho',
              if (t.limpezaMaquinaVoltas) 'Limpeza Máquina',
            ];
            return ListTile(
              title: Text(dayFmt.format(t.serviceDay),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                manual.isEmpty ? 'Sem tarefas manuais marcadas' : manual.join(' · '),
              ),
            );
          },
        );
      },
    );
  }
}
