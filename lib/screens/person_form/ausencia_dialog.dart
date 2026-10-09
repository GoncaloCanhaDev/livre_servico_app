part of '../person_form_screen.dart';

/// Picks an ausência's type and dates; pops the new [Ausencia], or null.
class _AusenciaDialog extends StatefulWidget {
  const _AusenciaDialog({this.existing});

  final Ausencia? existing;

  @override
  State<_AusenciaDialog> createState() => _AusenciaDialogState();
}

class _AusenciaDialogState extends State<_AusenciaDialog> {
  late AusenciaTipo _tipo = widget.existing?.tipo ?? AusenciaTipo.ferias;
  late DateTimeRange? _range = switch (widget.existing) {
    final a? => DateTimeRange(start: a.start, end: a.end),
    null => null,
  };

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
      locale: const Locale('pt', 'PT'),
      helpText: _tipo.label,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    return AlertDialog(
      title: Text(widget.existing == null ? 'Nova ausência' : 'Ausência'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<AusenciaTipo>(
            initialValue: _tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final t in AusenciaTipo.values)
                DropdownMenuItem(value: t, child: Text(t.label)),
            ],
            onChanged: (v) => setState(() => _tipo = v ?? _tipo),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              range == null
                  ? 'Escolher datas'
                  : ausenciaRangeText(
                      Ausencia()
                        ..start = range.start
                        ..end = range.end,
                    ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: range == null
              ? null
              : () => Navigator.pop(
                  context,
                  Ausencia()
                    ..tipo = _tipo
                    ..start = range.start
                    ..end = range.end,
                ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
