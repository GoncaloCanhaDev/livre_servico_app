part of '../truck_form_screen.dart';

class _Inputs {
  final TextEditingController total = TextEditingController();
  final TextEditingController mistas = TextEditingController();

  int get totalValue => int.tryParse(total.text) ?? 0;
  int get mistasValue => int.tryParse(mistas.text) ?? 0;

  void dispose() {
    total.dispose();
    mistas.dispose();
  }
}

class _DepartmentRow extends StatelessWidget {
  const _DepartmentRow({
    required this.department,
    required this.inputs,
    required this.onChanged,
    required this.onRemove,
  });

  final TruckDepartment department;
  final _Inputs inputs;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    department.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 20, color: Colors.black45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: inputs.total,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => onChanged(),
                    validator: (v) {
                      final t = int.tryParse(v ?? '') ?? 0;
                      final m = inputs.mistasValue;
                      if (m > t) return 'Mistas > total';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: inputs.mistas,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Mistas',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Quantidade and Conteúdo / marca for one line of expositores.
