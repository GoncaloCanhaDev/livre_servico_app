import 'package:flutter/material.dart';

import '../../models/not_done.dart';
import '../../theme.dart';
import 'person_picker.dart';

/// Where a task stands: nothing ticked yet, Feita or Não feita.
enum TaskOutcome { open, done, notDone }

/// The two markers on a task card: ✓ Feita and ✗ Não feita. Only one can be
/// ticked and, once it is, both lock. A null callback leaves that marker
/// disabled (outside a Validades window, say).
class TaskMarkers extends StatelessWidget {
  const TaskMarkers({
    super.key,
    required this.outcome,
    required this.onDone,
    required this.onNotDone,
  });

  final TaskOutcome outcome;
  final VoidCallback? onDone;
  final VoidCallback? onNotDone;

  @override
  Widget build(BuildContext context) {
    final open = outcome == TaskOutcome.open;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Marker(
          icon: Icons.check,
          tooltip: 'Feita',
          color: context.colors.primary,
          selected: outcome == TaskOutcome.done,
          onTap: open ? onDone : null,
        ),
        const SizedBox(width: 6),
        _Marker(
          icon: Icons.close,
          tooltip: 'Não feita',
          color: context.colors.error,
          selected: outcome == TaskOutcome.notDone,
          onTap: open ? onNotDone : null,
        ),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final edge = selected || enabled ? color : context.faintest;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected ? color : Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: edge, width: 2)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 20,
              color: selected
                  ? Colors.white
                  : enabled
                  ? color
                  : context.faintest,
            ),
          ),
        ),
      ),
    );
  }
}

/// The subtitle of a task marked Não feita: the reason, in red.
class NotDoneNote extends StatelessWidget {
  const NotDoneNote(this.notDone, {super.key, this.backdated = false});

  final NotDone notDone;
  final bool backdated;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(Icons.block, size: 13, color: color),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Não feita: ${notDone.reason}',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (backdated)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Preenchido a posteriori',
              style: TextStyle(fontSize: 11, color: context.faint),
            ),
          ),
      ],
    );
  }
}

/// "❌ Tarefa não feita: Kiwi Fecho — sem tempo (por Ana Silva)".
String notDoneMessage(String label, NotDone n) {
  final by = n.byNames.isEmpty ? '' : ' (por ${joinNames(n.byNames)})';
  return '❌ Tarefa não feita: $label — ${n.reason}$by';
}

/// Who is marking [taskName] as Não feita, for which day, and why. Null
/// when cancelled at either step.
Future<(PeopleAndDay, String)?> pickNotDone(
  BuildContext context, {
  required String taskName,
  required DateTime initialDay,
  bool Function(DateTime)? selectableDayPredicate,
  String period = 'nesse dia',
}) async {
  final who = await pickPeopleAndDay(
    context,
    title: 'Quem marca como não feita?',
    subtitle:
        '$taskName\n\nDepois de marcada, não poderá ser desmarcada $period.',
    initialDay: initialDay,
    selectableDayPredicate: selectableDayPredicate,
    dayHelpText: 'Que dia ficou por fazer?',
  );
  if (who == null || !context.mounted) return null;
  final reason = await showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(taskName: taskName),
  );
  if (reason == null) return null;
  return (who, reason);
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.taskName});

  final String taskName;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final reason = _ctrl.text.trim();
    if (reason.isEmpty) return;
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final empty = _ctrl.text.trim().isEmpty;
    return AlertDialog(
      title: const Text('Porque não foi feita?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.taskName, style: TextStyle(color: context.muted)),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Motivo',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: empty ? null : _confirm,
          child: const Text('Marcar não feita'),
        ),
      ],
    );
  }
}
