import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/custom_task.dart';
import '../../models/opening_list.dart';
import '../../models/weekly_tasks.dart';
import '../../services/custom_task_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/person_picker.dart';

DateTime _periodKeyFor(CustomTaskFrequency frequency) {
  switch (frequency) {
    case CustomTaskFrequency.daily:
      return currentServiceDay();
    case CustomTaskFrequency.weekly:
      return currentServiceWeek();
    case CustomTaskFrequency.oneOff:
      return oneOffPeriodKey;
  }
}

class _TaskRow {
  _TaskRow({required this.task, required this.periodKey, this.entry});
  final CustomTask task;
  final DateTime periodKey;
  final CustomTaskEntry? entry;

  bool get done => entry?.done ?? false;
}

class CustomTasksTab extends StatefulWidget {
  const CustomTasksTab({super.key});

  @override
  State<CustomTasksTab> createState() => _CustomTasksTabState();
}

class _CustomTasksTabState extends State<CustomTasksTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<List<_TaskRow>> _future;

  @override
  void initState() {
    super.initState();
    CustomTaskService.instance.addListener(_reload);
    _future = _load();
  }

  @override
  void dispose() {
    CustomTaskService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<List<_TaskRow>> _load() async {
    final svc = CustomTaskService.instance;
    final tasks = await svc.tasks();
    final rows = <_TaskRow>[];
    for (final t in tasks) {
      final periodKey = _periodKeyFor(t.frequency);
      final entry = await svc.entryFor(t.syncUuid, periodKey);
      rows.add(_TaskRow(task: t, periodKey: periodKey, entry: entry));
    }
    return rows;
  }

  Future<void> _sendMsg(String msg) async {
    if (!mounted) return;
    await WhatsAppService.sendWithConfirm(context, msg);
  }

  Future<void> _complete(_TaskRow row, {int? count}) async {
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '${row.task.title}\n\nDepois de concluída, não poderá ser desmarcada neste período.',
      initialDay: DateTime(today.year, today.month, today.day),
    );
    if (result == null) return;
    final names = result.people.map((p) => p.fullName).toList();
    final who = joinNames(names);
    final currentPeriodKey = _periodKeyFor(row.task.frequency);

    late final DateTime targetPeriodKey;
    late final bool backdated;
    switch (row.task.frequency) {
      case CustomTaskFrequency.daily:
        targetPeriodKey = DateTime(
          result.day.year,
          result.day.month,
          result.day.day,
          5,
        );
        backdated = targetPeriodKey != currentPeriodKey;
      case CustomTaskFrequency.weekly:
        targetPeriodKey = currentServiceWeek(
          DateTime(result.day.year, result.day.month, result.day.day, 12),
        );
        backdated = targetPeriodKey != currentPeriodKey;
      case CustomTaskFrequency.oneOff:
        targetPeriodKey = oneOffPeriodKey;
        backdated = false;
    }

    await CustomTaskService.instance.complete(
      taskUuid: row.task.syncUuid,
      periodKey: targetPeriodKey,
      who: names,
      count: count,
      backdated: backdated,
    );
    final countSuffix = count == null ? '' : ' ($count)';
    final baseMsg =
        '✅ Tarefa concluída: ${row.task.title}$countSuffix (por $who)';
    if (!backdated) {
      _sendMsg(baseMsg);
      return;
    }
    final dayFmt = DateFormat("d 'de' MMMM", 'pt_PT').format(result.day);
    _sendMsg('$baseMsg — $dayFmt');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa marcada como concluída em $dayFmt.')),
    );
  }

  Future<void> _confirmDelete(CustomTask task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover tarefa'),
        content: Text(
          'Queres remover "${task.title}"? O histórico não é apagado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CustomTaskService.instance.deleteTask(task.syncUuid);
    }
  }

  Future<void> _openAddDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (_) => const _AddCustomTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova tarefa',
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: FutureBuilder<List<_TaskRow>>(
          future: _future,
          builder: (_, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final rows = snap.data!;
            if (rows.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sem tarefas personalizadas.\nUsa o + para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.muted),
                  ),
                ),
              );
            }
            final daily = rows
                .where((r) => r.task.frequency == CustomTaskFrequency.daily)
                .toList();
            final weekly = rows
                .where((r) => r.task.frequency == CustomTaskFrequency.weekly)
                .toList();
            final oneOff = rows
                .where((r) => r.task.frequency == CustomTaskFrequency.oneOff)
                .toList();
            // Bottom room so the + never covers the last task.
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              children: [
                ..._section('Diárias', daily),
                ..._section('Semanais', weekly),
                ..._section('Pontuais', oneOff),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _section(String title, List<_TaskRow> rows) {
    if (rows.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.colors.secondary,
          ),
        ),
      ),
      for (final row in rows) _tileFor(row),
      const SizedBox(height: 8),
    ];
  }

  Widget _tileFor(_TaskRow row) {
    final names = resolveNames(
      row.entry?.doneByNames ?? const [],
      row.entry?.doneBy,
    );
    final byStr = names.isEmpty ? '' : ' (por ${joinNames(names)})';
    if (row.task.inputType == CustomTaskInputType.count) {
      final count = row.entry?.count;
      final countStr = count == null ? '' : ' ($count)';
      return _CustomCountTile(
        key: ValueKey(row.task.syncUuid),
        row: row,
        onComplete: (count) => _complete(row, count: count),
        onDelete: () => _confirmDelete(row.task),
        onSendWhatsApp: row.done
            ? () => _sendMsg(
                '✅ Tarefa concluída: ${row.task.title}$countStr$byStr',
              )
            : null,
      );
    }
    return _CustomManualTile(
      key: ValueKey(row.task.syncUuid),
      row: row,
      onComplete: () => _complete(row),
      onDelete: () => _confirmDelete(row.task),
      onSendWhatsApp: row.done
          ? () => _sendMsg('✅ Tarefa concluída: ${row.task.title}$byStr')
          : null,
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

class _CustomManualTile extends StatelessWidget {
  const _CustomManualTile({
    super.key,
    required this.row,
    required this.onComplete,
    required this.onDelete,
    this.onSendWhatsApp,
  });

  final _TaskRow row;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback? onSendWhatsApp;

  @override
  Widget build(BuildContext context) {
    final done = row.done;
    final names = resolveNames(
      row.entry?.doneByNames ?? const [],
      row.entry?.doneBy,
    );
    return GestureDetector(
      onLongPress: onSendWhatsApp,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: done,
          onChanged: (v) {
            if (done) return;
            if (v == true) onComplete();
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: context.colors.primary,
          title: Text(
            row.task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: (done && row.entry!.backdated)
              ? const _BackdatedNote()
              : null,
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (done && names.isNotEmpty) ...[
                PersonInitialsRow(names: names),
                const SizedBox(width: 4),
              ],
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Remover tarefa',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomCountTile extends StatefulWidget {
  const _CustomCountTile({
    super.key,
    required this.row,
    required this.onComplete,
    required this.onDelete,
    this.onSendWhatsApp,
  });

  final _TaskRow row;
  final ValueChanged<int> onComplete;
  final VoidCallback onDelete;
  final VoidCallback? onSendWhatsApp;

  @override
  State<_CustomCountTile> createState() => _CustomCountTileState();
}

class _CustomCountTileState extends State<_CustomCountTile> {
  late final TextEditingController _countCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.row.entry?.count;
    _countCtrl = TextEditingController(
      text: (existing == null || existing == 0) ? '' : '$existing',
    );
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final done = row.done;
    final names = resolveNames(
      row.entry?.doneByNames ?? const [],
      row.entry?.doneBy,
    );
    return GestureDetector(
      onLongPress: widget.onSendWhatsApp,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: done,
          onChanged: (v) {
            if (done) return;
            if (v != true) return;
            final count = int.tryParse(_countCtrl.text) ?? 0;
            widget.onComplete(count);
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: context.colors.primary,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  row.task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (done && names.isNotEmpty) ...[
                const SizedBox(width: 8),
                PersonInitialsRow(names: names),
              ],
            ],
          ),
          subtitle: (done && row.entry!.backdated)
              ? const _BackdatedNote()
              : null,
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _countCtrl,
                  enabled: !done,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Remover tarefa',
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCustomTaskDialog extends StatefulWidget {
  const _AddCustomTaskDialog();

  @override
  State<_AddCustomTaskDialog> createState() => _AddCustomTaskDialogState();
}

class _AddCustomTaskDialogState extends State<_AddCustomTaskDialog> {
  final _titleCtrl = TextEditingController();
  CustomTaskFrequency _frequency = CustomTaskFrequency.daily;
  CustomTaskInputType _inputType = CustomTaskInputType.simple;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Indica um título para a tarefa.');
      return;
    }
    await CustomTaskService.instance.addTask(
      title: title,
      frequency: _frequency,
      inputType: _inputType,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova tarefa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Título',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Frequência',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<CustomTaskFrequency>(
              segments: const [
                ButtonSegment(
                  value: CustomTaskFrequency.daily,
                  label: Text('Diária'),
                ),
                ButtonSegment(
                  value: CustomTaskFrequency.weekly,
                  label: Text('Semanal'),
                ),
                ButtonSegment(
                  value: CustomTaskFrequency.oneOff,
                  label: Text('Pontual'),
                ),
              ],
              selected: {_frequency},
              onSelectionChanged: (sel) =>
                  setState(() => _frequency = sel.first),
            ),
            const SizedBox(height: 16),
            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<CustomTaskInputType>(
              segments: const [
                ButtonSegment(
                  value: CustomTaskInputType.simple,
                  label: Text('Simples'),
                ),
                ButtonSegment(
                  value: CustomTaskInputType.count,
                  label: Text('Com contagem'),
                ),
              ],
              selected: {_inputType},
              onSelectionChanged: (sel) =>
                  setState(() => _inputType = sel.first),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _create, child: const Text('Criar')),
      ],
    );
  }
}
