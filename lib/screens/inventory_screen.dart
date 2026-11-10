import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/inventory.dart';
import '../services/account_service.dart';
import '../services/inventory_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'claim_person_screen.dart' show myPerson;
import 'widgets/person_picker.dart';
import 'widgets/wide_layout.dart';

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
  late Future<List<Inventory>> _toDo;

  @override
  void initState() {
    super.initState();
    _future = InventoryService.instance.history();
    _toDo = InventoryService.instance.toDo();
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
      _toDo = InventoryService.instance.toDo();
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
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
            ),
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

  bool get _canPlan => AccountService.instance.access.canPlanInventories;

  Future<void> _plan() async {
    final result = await showDialog<_NewInventoryData>(
      context: context,
      builder: (_) => const _NewInventoryDialog(planning: true),
    );
    if (result == null || !mounted) return;
    final me = AccountService.instance.store?.personId;
    final by = me == null ? null : (await myPerson(me))?.fullName;
    await InventoryService.instance.plan(
      name: result.name,
      code: result.code,
      dueDate: result.dueDate,
      plannedBy: by,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${result.name}: por fazer.')));
  }

  /// Marks the planned [inv] done: who did it, its value, then WhatsApp.
  Future<void> _markDone(Inventory inv) async {
    final people = await pickPeople(
      context,
      title: 'Quem fez o inventário?',
      subtitle: inv.name,
    );
    if (people == null || !mounted) return;
    final names = people.map((p) => p.fullName).toList();
    final cents = await _askFinalValueOnScreen(context);
    if (cents == null || !mounted) return;
    await InventoryService.instance.markDone(
      inv,
      names: names,
      finalValueCents: cents,
    );
    if (!mounted) return;
    final msg =
        '📦 Inventário: ${inv.name} (cód. ${inv.code ?? '—'})\n'
        'Valor: ${_fmtCents(cents)}\n'
        'Por: ${joinNames(names)}';
    await WhatsAppService.sendWithConfirm(context, msg);
  }

  Future<void> _removeToDo(Inventory inv) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover inventário por fazer?'),
        content: Text(inv.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok == true) await InventoryService.instance.delete(inv.id);
  }

  Widget _toDoBody() => FutureBuilder<List<Inventory>>(
    future: _toDo,
    builder: (context, snap) {
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final items = snap.data!;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (_canPlan)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: _plan,
                icon: const Icon(Icons.playlist_add),
                label: const Text('Planear inventário'),
              ),
            ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Nenhum inventário por fazer.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.muted),
              ),
            ),
          for (final inv in items)
            _ToDoCard(
              inv: inv,
              onTap: () => _markDone(inv),
              onRemove: _canPlan ? () => _removeToDo(inv) : null,
            ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return ResponsiveTabs(
      title: const Text('Inventários'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
        onPressed: _newInventory,
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
      tabs: [('Por fazer', _toDoBody()), ('Feitos', _doneBody())],
    );
  }

  Widget _doneBody() {
    return SafeArea(
      child: FutureBuilder<List<Inventory>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Sem inventários registados.',
                  style: TextStyle(color: context.muted),
                ),
              ),
            );
          }
          // Its own width: beside "Por fazer" on a computer.
          return LayoutBuilder(
            builder: (context, box) {
              final columns = (box.maxWidth / 360).floor().clamp(1, 3);
              if (columns > 1) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  child: GridRows(
                    columns: columns,
                    children: [
                      for (final inv in items)
                        _InventoryCard(inv: inv, onTap: () => _finishOpen(inv)),
                    ],
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
          );
        },
      ),
    );
  }
}

/// A planned inventory in "Por fazer": tap to mark it done.
class _ToDoCard extends StatelessWidget {
  const _ToDoCard({required this.inv, required this.onTap, this.onRemove});
  final Inventory inv;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final due = inv.dueDate;
    final now = DateTime.now();
    final late =
        due != null && due.isBefore(DateTime(now.year, now.month, now.day));
    final parts = [
      if (inv.code case final code? when code.isNotEmpty) 'Código $code',
      if (due != null) 'Até ${DateFormat('d/M').format(due)}' else 'Sem data',
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.pending_actions,
          color: late ? context.colors.error : context.colors.secondary,
        ),
        title: Text(
          inv.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parts.join(' • '), style: const TextStyle(fontSize: 13)),
            if (late)
              Text(
                'Atrasado',
                style: TextStyle(
                  color: context.colors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (inv.plannedBy case final by? when by.isNotEmpty)
              Text(
                'Planeado por $by',
                style: TextStyle(color: context.faint, fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onRemove != null)
              IconButton(
                tooltip: 'Remover',
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemove,
              ),
            FilledButton(onPressed: onTap, child: const Text('Feito')),
          ],
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
      statusColor = context.faintest;
      statusText = 'Legado';
      statusIcon = Icons.history;
    } else if (finalized) {
      statusColor = context.colors.primary;
      statusText = 'Concluído';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = context.colors.secondary;
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
            // Wraps: a long status and a two-digit day don't fit a narrow
            // phone's card on one line.
            Wrap(
              spacing: 8,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dateFmt.format(inv.createdAt),
                  style: TextStyle(color: context.faint, fontSize: 12),
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
  const _NewInventoryData({
    required this.name,
    required this.code,
    this.dueDate,
  });
  final String name;
  final String code;
  final DateTime? dueDate;
}

class _NewInventoryDialog extends StatefulWidget {
  const _NewInventoryDialog({this.planning = false});

  /// Planning one to do: also asks for an optional date.
  final bool planning;

  @override
  State<_NewInventoryDialog> createState() => _NewInventoryDialogState();
}

class _NewInventoryDialogState extends State<_NewInventoryDialog> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _due;

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (picked != null) setState(() => _due = picked);
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.planning ? 'Planear inventário' : 'Novo inventário'),
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
            if (widget.planning) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDue,
                icon: const Icon(Icons.event),
                label: Text(
                  _due == null
                      ? 'Data (opcional)'
                      : 'Até ${DateFormat('d/M/y').format(_due!)}',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.primary,
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _NewInventoryData(
                name: _name.text.trim(),
                code: _code.text.trim(),
                dueDate: _due,
              ),
            );
          },
          child: Text(widget.planning ? 'Planear' : 'Continuar'),
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
