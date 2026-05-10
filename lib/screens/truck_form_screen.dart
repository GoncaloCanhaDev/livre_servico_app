import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/truck_reception.dart';
import '../services/truck_service.dart';
import '../theme.dart';

class TruckFormScreen extends StatefulWidget {
  const TruckFormScreen({super.key});

  @override
  State<TruckFormScreen> createState() => _TruckFormScreenState();
}

class _TruckFormScreenState extends State<TruckFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _arrival = DateTime.now();

  late final Map<PalletCategory, _Inputs> _inputs = {
    for (final c in PalletCategory.values) c: _Inputs(),
  };

  @override
  void dispose() {
    _plateCtrl.dispose();
    _supplierCtrl.dispose();
    _notesCtrl.dispose();
    for (final i in _inputs.values) {
      i.dispose();
    }
    super.dispose();
  }

  int get _totalPallets =>
      _inputs.values.fold(0, (s, i) => s + i.totalValue);
  int get _totalMistas =>
      _inputs.values.fold(0, (s, i) => s + i.mistasValue);

  Future<void> _pickArrival() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _arrival,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('pt', 'PT'),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_arrival),
    );
    if (time == null) return;
    setState(() {
      _arrival = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_totalPallets == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indique pelo menos uma palete.')),
      );
      return;
    }
    final truck = TruckReception()
      ..arrivalTime = _arrival
      ..licensePlate = _plateCtrl.text.trim().isEmpty
          ? null
          : _plateCtrl.text.trim().toUpperCase()
      ..supplier = _supplierCtrl.text.trim().isEmpty
          ? null
          : _supplierCtrl.text.trim()
      ..notes = _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim()
      ..pallets = _inputs.entries
          .where((e) => e.value.totalValue > 0 || e.value.mistasValue > 0)
          .map((e) => PalletCount()
            ..category = e.key
            ..total = e.value.totalValue
            ..mistas = e.value.mistasValue)
          .toList();

    await TruckService.instance.save(truck);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat("d 'de' MMMM 'de' y, HH:mm", 'pt_PT');
    return Scaffold(
      appBar: AppBar(title: const Text('Receção de Camião')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: AppColors.green),
                  title: const Text('Hora de chegada'),
                  subtitle: Text(dateFmt.format(_arrival)),
                  trailing: const Icon(Icons.edit),
                  onTap: _pickArrival,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _plateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Matrícula',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _supplierCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Fornecedor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notas',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text('Paletes',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              ...PalletCategory.values.map((c) => _CategoryRow(
                    category: c,
                    inputs: _inputs[c]!,
                    onChanged: () => setState(() {}),
                  )),
              const SizedBox(height: 16),
              _TotalsCard(
                  totalPallets: _totalPallets, totalMistas: _totalMistas),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                onPressed: _save,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.inputs,
    required this.onChanged,
  });

  final PalletCategory category;
  final _Inputs inputs;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: inputs.total,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
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

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totalPallets, required this.totalMistas});

  final int totalPallets;
  final int totalMistas;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TotalCell(label: 'Total de paletes', value: totalPallets),
            Container(width: 1, height: 40, color: Colors.white24),
            _TotalCell(label: 'Total de mistas', value: totalMistas),
          ],
        ),
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  const _TotalCell({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
