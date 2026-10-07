import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/inventory.dart';
import '../services/inventory_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'widgets/person_picker.dart';

// ============================================================================
// List screen
// ============================================================================

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<Inventory>> _future;

  @override
  void initState() {
    super.initState();
    _future = InventoryService.instance.history();
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

  Future<void> _newInventory() async {
    final result = await showDialog<_NewInventoryData>(
      context: context,
      builder: (_) => const _NewInventoryDialog(),
    );
    if (result == null || !mounted) return;
    final people = await pickPeople(context, title: 'Quem faz o inventário?');
    if (people == null || !mounted) return;
    final names = people.map((p) => p.fullName).toList();
    // Prompt for value, save a finalized inventory, WhatsApp it.
    final cents = await _askFinalValueOnScreen(context);
    if (cents == null || !mounted) return;
    final now = DateTime.now();
    final inv = Inventory()
      ..name = result.name
      ..code = result.code
      ..createdAt = now
      ..startedAt = now
      ..finishedAt = now
      ..valueCents = cents
      ..finalValueCents = cents
      ..createdByNames = names;
    await InventoryService.instance.save(inv);
    if (!mounted) return;
    final msg =
        '📦 Inventário: ${result.name} (cód. ${result.code})\n'
        'Valor: ${_fmtCents(cents)}\n'
        'Por: ${joinNames(names)}';
    await WhatsAppService.sendWithConfirm(context, msg);
  }

  Future<int?> _askFinalValueOnScreen(BuildContext ctx) {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Valor do inventário'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^-?[0-9]*[.,]?[0-9]{0,2}'),
            ),
          ],
          decoration: const InputDecoration(
            hintText: 'Ex.: -12,50',
            prefixText: '€ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () {
              final v = double.tryParse(ctrl.text.trim().replaceAll(',', '.'));
              if (v == null) return;
              Navigator.pop(ctx, (v * 100).round());
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  /// Sessions started before live inventories were removed can still be
  /// closed: ask for the final value, finalize and send.
  Future<void> _finishOpen(Inventory inv) async {
    if (inv.isLegacy || inv.isFinalized) return;
    final cents = await _askFinalValueOnScreen(context);
    if (cents == null || !mounted) return;
    await InventoryService.instance.finalize(inv, finalValueCents: cents);
    if (!mounted) return;
    final msg =
        '📦 Inventário: ${inv.name} (cód. ${inv.code ?? '—'})\n'
        'Valor: ${_fmtCents(cents)}\n'
        'Por: ${joinNames(inv.createdByNames)}';
    await WhatsAppService.sendWithConfirm(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventários')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        onPressed: _newInventory,
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Inventory>>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data!;
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sem inventários registados.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              itemBuilder: (_, i) => _InventoryCard(
                inv: items[i],
                onTap: () => _finishOpen(items[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.inv, required this.onTap});
  final Inventory inv;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final legacy = inv.isLegacy;
    final finalized = inv.isFinalized;
    final open = !legacy && !finalized;
    Color statusColor;
    String statusText;
    IconData statusIcon;
    if (legacy) {
      statusColor = Colors.black38;
      statusText = 'Legado';
      statusIcon = Icons.history;
    } else if (finalized) {
      statusColor = AppColors.green;
      statusText = 'Concluído';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = AppColors.greenDark;
      statusText = 'A decorrer';
      statusIcon = Icons.play_circle;
    }

    final subtitleParts = <String>[];
    if (inv.code != null && inv.code!.isNotEmpty) {
      subtitleParts.add('Código ${inv.code}');
    }
    if (finalized) {
      subtitleParts.add(_fmtCents(inv.valueCents));
    }
    final dateFmt = DateFormat('d/M HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          inv.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitleParts.isNotEmpty)
              Text(
                subtitleParts.join(' • '),
                style: const TextStyle(fontSize: 13),
              ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFmt.format(inv.createdAt),
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: open ? const Icon(Icons.chevron_right) : null,
        onTap: open ? onTap : null,
      ),
    );
  }
}

class _NewInventoryData {
  const _NewInventoryData({required this.name, required this.code});
  final String name;
  final String code;
}

class _NewInventoryDialog extends StatefulWidget {
  const _NewInventoryDialog();

  @override
  State<_NewInventoryDialog> createState() => _NewInventoryDialogState();
}

class _NewInventoryDialogState extends State<_NewInventoryDialog> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo inventário'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _code,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Código',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.green),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _NewInventoryData(
                name: _name.text.trim(),
                code: _code.text.trim(),
              ),
            );
          },
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

// ============================================================================
// Helpers
// ============================================================================

String _fmtCents(int cents) {
  final euros = cents / 100;
  return '${euros.toStringAsFixed(2).replaceAll('.', ',')} €';
}
