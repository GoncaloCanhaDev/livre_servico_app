import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../models/truck_reception.dart';
import '../services/product_service.dart';
import '../services/truck_service.dart';
import '../services/whatsapp_service.dart';
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
  bool _showDetails = false;

  /// Categories the user has added to this reception, in order.
  final List<PalletCategory> _selectedCategories = [];

  /// Inputs for each selected category, created on demand.
  final Map<PalletCategory, _Inputs> _inputs = {};

  final Map<int, Product> _vasilhameProductsMap = {};
  final Map<int, int> _vasilhameQuantities = {};

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

  /// Categories available to pick (truck-eligible minus already selected).
  List<PalletCategory> get _availableCategories =>
      PalletCategory.truckCategories
          .where((c) => !_selectedCategories.contains(c))
          .toList();

  void _addCategory() {
    final available = _availableCategories;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os departamentos já foram adicionados.')),
      );
      return;
    }
    showModalBottomSheet<PalletCategory>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Adicionar Departamento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...available.map((c) => ListTile(
                        leading: const Icon(Icons.add_circle_outline,
                            color: AppColors.green),
                        title: Text(c.label),
                        onTap: () => Navigator.pop(ctx, c),
                      )),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((picked) {
      if (picked == null) return;
      setState(() {
        _selectedCategories.add(picked);
        _inputs[picked] = _Inputs();
      });
    });
  }

  void _removeCategory(PalletCategory c) {
    setState(() {
      _selectedCategories.remove(c);
      _inputs.remove(c)?.dispose();
    });
  }

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

  Future<void> _showVasilhameModal() async {
    final allProducts = await ProductService.instance.all();
    final products = allProducts.where((p) => p.department == PalletCategory.vasilhame).toList();

    for (final p in products) {
      _vasilhameProductsMap[p.id] = p;
    }

    if (products.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum artigo de vasilhame encontrado.')),
      );
      return;
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (ctx, scrollController) => Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Enviar Vasilhame',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: products.length,
                      itemBuilder: (ctx, i) {
                        final p = products[i];
                        final qty = _vasilhameQuantities[p.id] ?? 0;
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text(p.sapCode),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: qty > 0
                                    ? () {
                                        setModalState(() {
                                          _vasilhameQuantities[p.id] = qty - 1;
                                          if (_vasilhameQuantities[p.id] == 0) {
                                            _vasilhameQuantities.remove(p.id);
                                          }
                                        });
                                        setState(() {});
                                      }
                                    : null,
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  qty.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setModalState(() {
                                    _vasilhameQuantities[p.id] = qty + 1;
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Concluído'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final hasPallets = _totalPallets > 0;
    final hasVasilhame = _vasilhameQuantities.values.any((qty) => qty > 0);
    if (!hasPallets && !hasVasilhame) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indique pelo menos uma palete ou vasilhame.')),
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
      ..pallets = _selectedCategories
          .where((c) {
            final inp = _inputs[c];
            return inp != null && (inp.totalValue > 0 || inp.mistasValue > 0);
          })
          .map((c) => PalletCount()
            ..category = c
            ..total = _inputs[c]!.totalValue
            ..mistas = _inputs[c]!.mistasValue)
          .toList()
      ..sentVasilhame = _vasilhameQuantities.entries
          .where((e) => e.value > 0)
          .map((e) => SentVasilhameItem()
            ..productName = _vasilhameProductsMap[e.key]!.name
            ..amount = e.value)
          .toList();

    await TruckService.instance.save(truck);
    if (!mounted) return;

    // Format WhatsApp message
    final dateFmt = DateFormat("d/MM/y, HH:mm", 'pt_PT');
    final lines = StringBuffer();
    lines.writeln('🚛 Receção de Camião');
    lines.writeln('Hora: ${dateFmt.format(_arrival)}');
    if (truck.licensePlate != null) lines.writeln('Matrícula: ${truck.licensePlate}');
    if (truck.supplier != null) lines.writeln('Fornecedor: ${truck.supplier}');
    for (final p in truck.pallets) {
      final mista = p.mistas > 0 ? ' (${p.mistas} mista${p.mistas > 1 ? 's' : ''})' : '';
      lines.writeln('${p.category.label}: ${p.total}$mista');
    }
    lines.writeln('Total: ${truck.totalPallets} paletes, ${truck.totalMistas} mistas');
    
    if (truck.sentVasilhame.isNotEmpty) {
      lines.writeln('\n📦 Vasilhame Enviado:');
      for (final v in truck.sentVasilhame) {
        lines.writeln('- ${v.productName}: ${v.amount}');
      }
    }
    
    if (truck.notes != null) lines.writeln('\nNotas: ${truck.notes}');

    await WhatsAppService.sendWithConfirm(context, lines.toString().trim());
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
              // --- Hora de chegada (always visible) ---
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: AppColors.green),
                  title: const Text('Hora de chegada'),
                  subtitle: Text(dateFmt.format(_arrival)),
                  trailing: const Icon(Icons.edit),
                  onTap: _pickArrival,
                ),
              ),
              const SizedBox(height: 16),

              // --- Paletes (main section) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Paletes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    TextButton.icon(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),
              ),
              if (_selectedCategories.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Toque em "Adicionar" para selecionar departamentos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ..._selectedCategories.map((c) => _CategoryRow(
                    category: c,
                    inputs: _inputs[c]!,
                    onChanged: () => setState(() {}),
                    onRemove: () => _removeCategory(c),
                  )),
              const SizedBox(height: 16),
              _TotalsCard(
                  totalPallets: _totalPallets, totalMistas: _totalMistas),
              const SizedBox(height: 16),

              // --- Vasilhame (new section) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Vasilhame a Enviar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    TextButton.icon(
                      onPressed: _showVasilhameModal,
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('Selecionar'),
                    ),
                  ],
                ),
              ),
              if (_vasilhameQuantities.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Nenhum vasilhame selecionado para envio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ..._vasilhameQuantities.entries.where((e) => e.value > 0).map((e) {
                final p = _vasilhameProductsMap[e.key]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text('${e.value} un', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              BarcodeWidget(
                                barcode: Barcode.ean13(),
                                data: p.ean,
                                width: double.infinity,
                                height: 120,
                                drawText: true,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Fechar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),

              // --- Detalhes adicionais (collapsible) ---
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        _showDetails
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColors.green,
                      ),
                      title: const Text('Detalhes adicionais',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: !_showDetails
                          ? const Text('Matrícula, fornecedor, notas')
                          : null,
                      onTap: () => setState(() => _showDetails = !_showDetails),
                    ),
                    if (_showDetails)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _plateCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Matrícula',
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization:
                                  TextCapitalization.characters,
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
                  ],
                ),
              ),
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
    required this.onRemove,
  });

  final PalletCategory category;
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
                  child: Text(category.label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
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
