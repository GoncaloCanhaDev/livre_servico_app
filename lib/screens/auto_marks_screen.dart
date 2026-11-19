import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/account_service.dart';
import '../services/auto_mark_service.dart';
import '../services/custom_task_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/weekly_tasks_service.dart';
import '../theme.dart';
import 'widgets/auto_mark_review.dart';
import 'widgets/person_picker.dart';
import 'widgets/wide_layout.dart';

/// The tasks the app marked by itself in the last week that nobody
/// confirmed yet, each with "Rever" (Confirmar, Alterar quem fez, Não foi
/// feita). Opened from Home's card, for level 2 and up.
class AutoMarksScreen extends StatefulWidget {
  const AutoMarksScreen({super.key});

  @override
  State<AutoMarksScreen> createState() => _AutoMarksScreenState();
}

class _AutoMarksScreenState extends State<AutoMarksScreen> {
  List<UnconfirmedMark>? _marks;

  @override
  void initState() {
    super.initState();
    for (final l in _sources) {
      l.addListener(_load);
    }
    _load();
  }

  @override
  void dispose() {
    for (final l in _sources) {
      l.removeListener(_load);
    }
    super.dispose();
  }

  static final List<ChangeNotifier> _sources = [
    AutoMarkService.instance,
    DailyTasksService.instance,
    WeeklyTasksService.instance,
    CustomTaskService.instance,
  ];

  Future<void> _load() async {
    final marks = await AutoMarkService.instance.unconfirmedMarks();
    if (mounted) setState(() => _marks = marks);
  }

  Future<void> _review(UnconfirmedMark m) async {
    if (m.daily case final t?) {
      await reviewDailyMark(context, t, m.key, m.label);
    } else if (m.weekly case final t?) {
      await reviewWeeklyMark(context, t, m.key, m.label, m.day);
    } else if (m.entry case final e?) {
      await reviewCustomMark(context, e, m.label, m.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marks = _marks;
    final dayFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_PT');
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas por confirmar')),
      body: SafeArea(
        child: marks == null
            ? const Center(child: CircularProgressIndicator())
            : marks.isEmpty
            ? Center(
                child: Text(
                  'Nada por confirmar.',
                  style: TextStyle(color: context.muted),
                ),
              )
            : ReadableWidth(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Marcadas sozinhas pela aplicação, por quem estava a '
                      'trabalhar no horário. Confirme ou corrija.',
                      style: TextStyle(color: context.muted),
                    ),
                    const SizedBox(height: 12),
                    for (final m in marks)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            m.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${dayFmt.format(m.day)}\n${joinNames(m.names)}',
                          ),
                          isThreeLine: true,
                          trailing: TextButton(
                            onPressed: () => _review(m),
                            child: const Text('Rever'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// On Home for level 2 and up: how many automatic marks wait to be
/// confirmed, opening [AutoMarksScreen].
class AutoMarksCard extends StatefulWidget {
  const AutoMarksCard({super.key});

  @override
  State<AutoMarksCard> createState() => _AutoMarksCardState();
}

class _AutoMarksCardState extends State<AutoMarksCard> {
  int _count = 0;

  static final List<ChangeNotifier> _sources = [
    AutoMarkService.instance,
    DailyTasksService.instance,
    WeeklyTasksService.instance,
    CustomTaskService.instance,
    AccountService.instance,
  ];

  @override
  void initState() {
    super.initState();
    for (final l in _sources) {
      l.addListener(_load);
    }
    _load();
  }

  @override
  void dispose() {
    for (final l in _sources) {
      l.removeListener(_load);
    }
    super.dispose();
  }

  Future<void> _load() async {
    final count = await AutoMarkService.instance.unconfirmed();
    if (mounted && count != _count) setState(() => _count = count);
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0 || !AccountService.instance.access.canConfirmTasks) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.auto_mode, color: context.warningText),
        title: Text(
          _count == 1
              ? '1 tarefa automática por confirmar'
              : '$_count tarefas automáticas por confirmar',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Marcadas pelo horário. Confirme ou corrija.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AutoMarksScreen()),
        ),
      ),
    );
  }
}
