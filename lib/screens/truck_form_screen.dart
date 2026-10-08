import 'package:barcode_widget/barcode_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/truck_reception.dart';
import '../models/vasilhame.dart';
import '../services/settings_service.dart';
import '../services/truck_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'widgets/person_picker.dart';

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
  final _issuesCtrl = TextEditingController();

  DateTime _arrival = DateTime.now();
  bool _showDetails = false;

  /// Picked on the first screen; the form shows once it is set.
  TruckType? _type;

  /// Departamentos the user has added to this reception, in order.
  final List<TruckDepartment> _selectedDepartments = [];

  /// Inputs for each selected departamento, by id, created on demand.
  final Map<String, _Inputs> _inputs = {};

  /// One line per kind of expositor, in the order they were added.
  final List<_ExpositorInputs> _expositores = [];

  /// Selected vasilhame quantities, keyed by item name.
  final Map<String, int> _vasilhameQuantities = {};
  final Map<String, VasilhameItem> _vasilhameItems = {};

  @override
  void dispose() {
    _plateCtrl.dispose();
    _supplierCtrl.dispose();
    _notesCtrl.dispose();
    _issuesCtrl.dispose();
    for (final i in _inputs.values) {
      i.dispose();
    }
    for (final e in _expositores) {
      e.dispose();
    }
    super.dispose();
  }

  int get _totalPallets => _inputs.values.fold(0, (s, i) => s + i.totalValue);
  int get _totalMistas => _inputs.values.fold(0, (s, i) => s + i.mistasValue);
  int get _totalExpositores =>
      _expositores.fold(0, (s, e) => s + e.amountValue);

  /// Departamentos available to pick (all minus already selected).
  List<TruckDepartment> get _availableDepartments =>
      truckDepartments.where((d) => !_selectedDepartments.contains(d)).toList();

  void _addDepartment() {
    final available = _availableDepartments;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os departamentos já foram adicionados.'),
        ),
      );
      return;
    }
    showModalBottomSheet<TruckDepartment>(
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
              child: Text(
                'Adicionar Departamento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...available.map(
                    (d) => ListTile(
                      leading: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.green,
                      ),
                      title: Text(d.label),
                      onTap: () => Navigator.pop(ctx, d),
                    ),
                  ),
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
        _selectedDepartments.add(picked);
        _inputs[picked.id] = _Inputs();
      });
    });
  }

  void _removeDepartment(TruckDepartment d) {
    setState(() {
      _selectedDepartments.remove(d);
      _inputs.remove(d.id)?.dispose();
    });
  }

  void _addExpositor() {
    setState(() => _expositores.add(_ExpositorInputs()));
  }

  void _removeExpositor(_ExpositorInputs e) {
    setState(() => _expositores.remove(e));
    e.dispose();
  }

  Future<void> _changeType() async {
    final picked = await showModalBottomSheet<TruckType>(
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
              child: Text(
                'Tipo de camião',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            for (final t in TruckType.values)
              ListTile(
                leading: Icon(_typeIcon(t), color: AppColors.green),
                title: Text(t.label),
                trailing: t == _type ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, t),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _type = picked);
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
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _showVasilhameModal() async {
    final products = SettingsService.instance.vasilhame;
    for (final p in products) {
      _vasilhameItems[p.name] = p;
    }

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A lista de vasilhame está vazia. Exporta a cópia de segurança, '
            'preenche a secção "vasilhame" e importa-a.',
          ),
        ),
      );
      return;
    }

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
                    child: Text(
                      'Enviar Vasilhame',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: products.length,
                      itemBuilder: (ctx, i) {
                        final p = products[i];
                        final qty = _vasilhameQuantities[p.name] ?? 0;
                        return ListTile(
                          title: Text(p.name),
                          subtitle: p.code == null ? null : Text(p.code!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: qty > 0
                                    ? () {
                                        setModalState(() {
                                          _vasilhameQuantities[p.name] =
                                              qty - 1;
                                          if (_vasilhameQuantities[p.name] ==
                                              0) {
                                            _vasilhameQuantities.remove(p.name);
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setModalState(() {
                                    _vasilhameQuantities[p.name] = qty + 1;
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
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + MediaQuery.of(context).padding.bottom,
                    ),
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
    if (!hasPallets && _totalExpositores == 0 && !hasVasilhame) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Indique pelo menos uma palete, expositor ou vasilhame.',
          ),
        ),
      );
      return;
    }
    final people = await pickPeople(context, title: 'Quem recebeu o camião?');
    if (people == null || !mounted) return;
    final names = people.map((p) => p.fullName).toList();
    final truck = TruckReception()
      ..arrivalTime = _arrival
      ..type = _type
      ..createdByNames = names
      ..licensePlate = _plateCtrl.text.trim().isEmpty
          ? null
          : _plateCtrl.text.trim().toUpperCase()
      ..supplier = _supplierCtrl.text.trim().isEmpty
          ? null
          : _supplierCtrl.text.trim()
      ..notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()
      ..issues = _issuesCtrl.text.trim().isEmpty
          ? null
          : _issuesCtrl.text.trim()
      ..pallets = _selectedDepartments
          .where((d) {
            final inp = _inputs[d.id];
            return inp != null && (inp.totalValue > 0 || inp.mistasValue > 0);
          })
          .map(
            (d) => PalletCount()
              ..department = d.id
              ..total = _inputs[d.id]!.totalValue
              ..mistas = _inputs[d.id]!.mistasValue,
          )
          .toList()
      ..expositores = [
        for (final e in _expositores)
          if (e.amountValue > 0)
            Expositor()
              ..amount = e.amountValue
              ..content = e.content.text.trim(),
      ]
      ..sentVasilhame = _vasilhameQuantities.entries
          .where((e) => e.value > 0)
          .map(
            (e) => SentVasilhameItem()
              ..productName = e.key
              ..amount = e.value,
          )
          .toList();

    await TruckService.instance.save(truck);
    if (!mounted) return;

    // Format WhatsApp message
    final dateFmt = DateFormat("d/MM/y, HH:mm", 'pt_PT');
    final lines = StringBuffer();
    lines.writeln('🚛 Receção de Camião');
    if (truck.type != null) lines.writeln('Tipo: ${truck.type!.label}');
    lines.writeln('Hora: ${dateFmt.format(_arrival)}');
    if (truck.licensePlate != null)
      lines.writeln('Matrícula: ${truck.licensePlate}');
    if (truck.supplier != null) lines.writeln('Fornecedor: ${truck.supplier}');
    for (final p in truck.pallets) {
      final mista = p.mistas > 0
          ? ' (${p.mistas} mista${p.mistas > 1 ? 's' : ''})'
          : '';
      lines.writeln('${p.label}: ${p.total}$mista');
    }
    lines.writeln(
      'Total: ${truck.totalPallets} paletes, ${truck.totalMistas} mistas',
    );
    lines.writeln('Por: ${joinNames(names)}');

    if (truck.expositores.isNotEmpty) {
      lines.writeln('\nExpositores:');
      for (final e in truck.expositores) {
        lines.writeln(
          e.content.isEmpty ? '- ${e.amount}' : '- ${e.amount} · ${e.content}',
        );
      }
    }

    if (truck.sentVasilhame.isNotEmpty) {
      lines.writeln('\n📦 Vasilhame Enviado:');
      for (final v in truck.sentVasilhame) {
        lines.writeln('- ${v.productName}: ${v.amount}');
      }
    }

    if (truck.issues != null) {
      lines.writeln('\n⚠️ Problemas: ${truck.issues}');
    }
    if (truck.notes != null) lines.writeln('\nNotas: ${truck.notes}');

    await WhatsAppService.sendWithConfirm(context, lines.toString().trim());
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat("d 'de' MMMM 'de' y, HH:mm", 'pt_PT');
    final type = _type;
    if (type == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receção de Camião')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 16),
                child: Text(
                  'Que camião chegou?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              for (final t in TruckType.values)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    leading: Icon(
                      _typeIcon(t),
                      color: AppColors.green,
                      size: 32,
                    ),
                    title: Text(
                      t.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => setState(() => _type = t),
                  ),
                ),
            ],
          ),
        ),
      );
    }
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
                  leading: Icon(_typeIcon(type), color: AppColors.green),
                  title: const Text('Tipo de camião'),
                  subtitle: Text(type.label),
                  trailing: const Icon(Icons.edit),
                  onTap: _changeType,
                ),
              ),

              // --- Hora de chegada (always visible) ---
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.access_time,
                    color: AppColors.green,
                  ),
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
                    const Text(
                      'Paletes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addDepartment,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),
              ),
              if (_selectedDepartments.isEmpty)
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
              ..._selectedDepartments.map(
                (d) => _DepartmentRow(
                  department: d,
                  inputs: _inputs[d.id]!,
                  onChanged: () => setState(() {}),
                  onRemove: () => _removeDepartment(d),
                ),
              ),
              const SizedBox(height: 16),

              // --- Expositores ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expositores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addExpositor,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),
              ),
              if (_expositores.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Sem expositores neste camião.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              for (final e in _expositores)
                _ExpositorRow(
                  key: ObjectKey(e),
                  inputs: e,
                  onChanged: () => setState(() {}),
                  onRemove: () => _removeExpositor(e),
                ),
              const SizedBox(height: 16),
              _TotalsCard(
                totalPallets: _totalPallets,
                totalMistas: _totalMistas,
                totalExpositores: _totalExpositores,
              ),
              const SizedBox(height: 16),

              // --- Vasilhame (new section) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vasilhame a Enviar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
              ..._vasilhameQuantities.entries.where((e) => e.value > 0).map((
                e,
              ) {
                final p = _vasilhameItems[e.key]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      '${e.value} un',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: p.ean == null
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    BarcodeWidget(
                                      barcode: p.ean!.length == 13
                                          ? Barcode.ean13()
                                          : p.ean!.length == 8
                                          ? Barcode.ean8()
                                          : Barcode.code128(),
                                      data: p.ean!,
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
                        _showDetails ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.green,
                      ),
                      title: const Text(
                        'Detalhes adicionais',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: !_showDetails
                          ? const Text(
                              'Matrícula, fornecedor, notas, problemas',
                            )
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _issuesCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Problemas na receção (opcional)',
                                hintText: 'Faltas, danos, produtos trocados…',
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

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.totalPallets,
    required this.totalMistas,
    required this.totalExpositores,
  });

  final int totalPallets;
  final int totalMistas;
  final int totalExpositores;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TotalCell(label: 'Paletes', value: totalPallets),
            Container(width: 1, height: 40, color: Colors.white24),
            _TotalCell(label: 'Mistas', value: totalMistas),
            Container(width: 1, height: 40, color: Colors.white24),
            _TotalCell(label: 'Expositores', value: totalExpositores),
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
        Text(
          '$value',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

IconData _typeIcon(TruckType t) => switch (t) {
  TruckType.pereciveis => Icons.eco_outlined,
  TruckType.naoPereciveis => Icons.inventory_2_outlined,
};
