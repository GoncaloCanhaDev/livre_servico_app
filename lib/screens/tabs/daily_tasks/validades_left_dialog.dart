part of '../daily_tasks_tab.dart';

/// Asks how many artigos of [turno] were left to check; null when
/// cancelled, 0 when none.
Future<int?> askValidadesLeft(BuildContext context, ValidadesTurno turno) =>
    showDialog<int>(
      context: context,
      builder: (_) => _ValidadesLeftDialog(turno),
    );

class _ValidadesLeftDialog extends StatefulWidget {
  const _ValidadesLeftDialog(this.turno);

  final ValidadesTurno turno;

  @override
  State<_ValidadesLeftDialog> createState() => _ValidadesLeftDialogState();
}

class _ValidadesLeftDialogState extends State<_ValidadesLeftDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, int.tryParse(_ctrl.text) ?? 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.turno.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantos artigos ficaram por fazer? '
            'Estes ${carriedToText(widget.turno)}.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('validadesLeft'),
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: '0',
              labelText: 'Ficaram por fazer',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continuar')),
      ],
    );
  }
}
