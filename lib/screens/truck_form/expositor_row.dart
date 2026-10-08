part of '../truck_form_screen.dart';

class _ExpositorInputs {
  final TextEditingController amount = TextEditingController();
  final TextEditingController content = TextEditingController();

  int get amountValue => int.tryParse(amount.text) ?? 0;

  void dispose() {
    amount.dispose();
    content.dispose();
  }
}

class _ExpositorRow extends StatelessWidget {
  const _ExpositorRow({
    super.key,
    required this.inputs,
    required this.onChanged,
    required this.onRemove,
  });

  final _ExpositorInputs inputs;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: TextFormField(
                controller: inputs.amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => onChanged(),
                validator: (_) =>
                    inputs.amountValue == 0 && inputs.content.text.trim() != ''
                    ? 'Indique'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: inputs.content,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo / marca',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 20, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
