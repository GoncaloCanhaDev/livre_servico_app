import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/auto_mark.dart';
import '../../services/account_service.dart';
import '../../services/person_service.dart';
import '../../theme.dart';
import 'person_picker.dart';

/// Under a task the app marked by itself: "Automática · por confirmar" in
/// orange, or "Automática · confirmada por X"; with [onReview] (level 2 and
/// up), a "Rever" button.
class AutoMarkNote extends StatelessWidget {
  const AutoMarkNote(this.mark, {super.key, this.onReview});

  final AutoMark mark;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final confirmed = mark.confirmed;
    final color = confirmed ? context.muted : context.warningText;
    // Wraps: under a count task there is little width beside the field.
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.auto_mode, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          confirmed
              ? 'Automática · confirmada por ${joinNames(mark.confirmedByNames)}'
              : 'Automática · por confirmar',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: confirmed ? null : FontWeight.w600,
          ),
        ),
        if (onReview != null && !confirmed)
          TextButton(
            onPressed: onReview,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Rever'),
          ),
      ],
    );
  }
}

/// A number to fill in after the task was marked ("Número por preencher"),
/// with a button opening [onFill].
class PendingNumberNote extends StatelessWidget {
  const PendingNumberNote({
    super.key,
    required this.text,
    required this.onFill,
  });

  final String text;
  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.pin_outlined, size: 14, color: context.warningText),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: context.warningText,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onFill,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text('Preencher'),
        ),
      ],
    );
  }
}

enum AutoMarkAction { confirm, change, notDone }

/// What to do with an automatic mark of [taskName] by [names].
Future<AutoMarkAction?> reviewAutoMark(
  BuildContext context, {
  required String taskName,
  required List<String> names,
}) => showModalBottomSheet<AutoMarkAction>(
  context: context,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Text(
            '$taskName\nMarcada sozinha: ${joinNames(names)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.verified_outlined),
          title: const Text('Confirmar'),
          subtitle: const Text('Foi feita por estas pessoas.'),
          onTap: () => Navigator.pop(context, AutoMarkAction.confirm),
        ),
        ListTile(
          leading: const Icon(Icons.people_outline),
          title: const Text('Alterar quem fez'),
          onTap: () => Navigator.pop(context, AutoMarkAction.change),
        ),
        ListTile(
          leading: Icon(Icons.close, color: context.colors.error),
          title: const Text('Não foi feita'),
          onTap: () => Navigator.pop(context, AutoMarkAction.notDone),
        ),
      ],
    ),
  ),
);

/// Who confirms: the person this account is linked to, or (signed out, or
/// not linked) whoever is picked; null when cancelled.
Future<List<String>?> confirmerNames(BuildContext context) async {
  if (AccountService.instance.access.personId case final id?) {
    if (await PersonService.instance.bySyncUuid(id) case final p?) {
      return [p.fullName];
    }
  }
  if (!context.mounted) return null;
  final people = await pickPeople(context, title: 'Quem confirma?');
  return people?.map((p) => p.fullName).toList();
}

/// Asks for a number left to fill in; null when cancelled.
Future<int?> askNumber(BuildContext context, String title) =>
    showDialog<int>(context: context, builder: (_) => _NumberDialog(title));

class _NumberDialog extends StatefulWidget {
  const _NumberDialog(this.title);

  final String title;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_ctrl.text);
    if (n != null) Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('pendingNumber'),
        controller: _ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: 'Número',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
