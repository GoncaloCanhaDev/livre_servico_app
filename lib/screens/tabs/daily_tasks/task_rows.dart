part of '../daily_tasks_tab.dart';

// The rows of the Diárias: a task marked by hand, one ticked by another
// screen (the Lista Visível), one only counted (the Lista Automática) and
// one with a number to fill in.

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

/// [subtitle] with [notes] under it.
Widget? _withNotes(Widget? subtitle, List<Widget> notes) => notes.isEmpty
    ? subtitle
    : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [?subtitle, ...notes],
      );

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
    this.notes = const [],
  });

  final String label;
  final bool checked;
  final NotDone? notDone;
  final VoidCallback onDone;
  final VoidCallback onNotDone;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;

  /// More lines under the subtitle (an automatic mark).
  final List<Widget> notes;

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
          subtitle: _withNotes(
            notDone != null && !checked
                ? NotDoneNote(notDone, backdated: backdated)
                : (checked && backdated)
                ? const _BackdatedNote()
                : null,
            notes,
          ),
          trailing: names.isNotEmpty
              ? PersonInitialsRow(names: names, size: 30)
              : null,
        ),
      ),
    );
  }
}

/// A task ticked by another screen: no markers, only whether it is done.
class _ListTask extends StatelessWidget {
  const _ListTask({
    required this.label,
    required this.checked,
    required this.note,
    this.onLongPress,
  });

  final String label;
  final bool checked;
  final String note;
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
                  note,
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

/// A task that is only counted, never ticked: the Lista Automática.
class _CounterTask extends StatelessWidget {
  const _CounterTask({
    required this.label,
    required this.count,
    required this.note,
  });

  final String label;
  final int count;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: count == 0 ? null : context.colors.primary,
            border: count == 0 ? Border.all(color: context.faint) : null,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: count == 0
                  ? context.colors.onSurface
                  : context.colors.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          note,
          style: TextStyle(fontSize: 12, color: context.muted),
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
    this.extraNotes = const [],
    this.notes = const [],
  });

  /// More lines under the subtitle (an automatic mark, a number to fill).
  final List<Widget> notes;

  /// More lines under the subtitle: icon, text, and whether in orange.
  final List<(IconData, String, bool)> extraNotes;

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

  Widget? _withExtraNotes(BuildContext context, Widget? subtitle) {
    subtitle = _withNotes(subtitle, notes);
    if (extraNotes.isEmpty) return subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ?subtitle,
        for (final (icon, text, warn) in extraNotes)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: warn ? context.warningText : context.faintest,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      color: warn ? context.warningText : context.muted,
                      fontWeight: warn ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

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
          subtitle: _withExtraNotes(
            context,
            notDone != null && !checked
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
          ),
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
