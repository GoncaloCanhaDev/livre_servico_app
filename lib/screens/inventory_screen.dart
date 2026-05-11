import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory.dart';
import '../models/visual_list.dart';
import '../services/inventory_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final valueText = _valueCtrl.text.trim().replaceAll(',', '.');
    final euros = double.tryParse(valueText);
    if (euros == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido.')),
      );
      return;
    }

    final cents = (euros * 100).round();

    final inv = Inventory()
      ..name = name
      ..valueCents = cents
      ..createdAt = DateTime.now();

    await InventoryService.instance.save(inv);
    if (!mounted) return;

    final msg = '📦 Inventário: $name\n'
        'Valor: ${formatCents(cents)} €';
    await WhatsAppService.sendWithConfirm(context, msg);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventário guardado.')),
    );

    _nameCtrl.clear();
    _valueCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventários')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Novo Inventário',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome do inventário',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Indique o nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _valueCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Valor (€)',
                          hintText: 'Ex: -12,50 ou 30,00',
                          border: OutlineInputBorder(),
                          prefixText: '€ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^-?[0-9]*[.,]?[0-9]{0,2}')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Indique o valor';
                          }
                          final parsed = double.tryParse(
                              v.trim().replaceAll(',', '.'));
                          if (parsed == null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Finalizar'),
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent entries
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text('Últimos inventários',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              _RecentList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentList extends StatefulWidget {
  @override
  State<_RecentList> createState() => _RecentListState();
}

class _RecentListState extends State<_RecentList> {
  late Future<List<Inventory>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
    InventoryService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    InventoryService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = InventoryService.instance.history();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Inventory>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Sem inventários registados.',
                    style: TextStyle(color: Colors.black45)),
              ),
            ),
          );
        }
        // Show last 10
        final display = items.take(10).toList();
        return Column(
          children: display.map((inv) {
            final color = inv.valueCents >= 0
                ? AppColors.green
                : Colors.redAccent;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(inv.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${formatCents(inv.valueCents)} €',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  _fmtDate(inv.createdAt),
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 12),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _fmtDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
