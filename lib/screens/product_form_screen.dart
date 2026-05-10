import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../models/truck_reception.dart';
import '../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.existing, this.prefilledEan});

  final Product? existing;
  final String? prefilledEan;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ean;
  late final TextEditingController _sap;
  late final TextEditingController _name;
  late final TextEditingController _notes;
  late PalletCategory _department;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _ean = TextEditingController(text: e?.ean ?? widget.prefilledEan ?? '');
    _sap = TextEditingController(text: e?.sapCode ?? '');
    _name = TextEditingController(text: e?.name ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _department = e?.department ?? PalletCategory.dph;
  }

  @override
  void dispose() {
    _ean.dispose();
    _sap.dispose();
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final svc = ProductService.instance;
    final ean = _ean.text.trim();

    final existingByEan = await svc.findByEan(ean);
    if (existingByEan != null && existingByEan.id != widget.existing?.id) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Já existe um produto com este EAN.')),
      );
      return;
    }

    final p = widget.existing ?? (Product()..createdAt = DateTime.now());
    p
      ..ean = ean
      ..sapCode = _sap.text.trim()
      ..name = _name.text.trim()
      ..department = _department
      ..notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();

    await svc.save(p);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Novo Produto' : 'Editar Produto'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _ean,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                decoration: const InputDecoration(
                  labelText: 'EAN-13',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Obrigatório';
                  if (s.length != 13) return 'Tem de ter 13 dígitos';
                  if (!isValidEan13(s)) return 'Checksum inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sap,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Código SAP',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PalletCategory>(
                initialValue: _department,
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  border: OutlineInputBorder(),
                ),
                items: PalletCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() {
                  if (v != null) _department = v;
                }),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
