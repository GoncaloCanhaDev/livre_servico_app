import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/inventory.dart';
import '../models/inventory_line.dart';
import '../services/inventory_line_service.dart';
import '../services/inventory_service.dart';
import '../services/product_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'product_form_screen.dart';
import 'scanner_screen.dart';

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
    if (result.action == _NewInventoryAction.start) {
      final inv = await InventoryService.instance.startSession(
        name: result.name,
        code: result.code,
      );
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InventorySessionScreen(inventoryId: inv.id),
      ));
      return;
    }
    // Send-only: prompt for value, save a finalized inventory, WhatsApp it.
    final cents = await _askFinalValueOnScreen(context);
    if (cents == null || !mounted) return;
    final now = DateTime.now();
    final inv = Inventory()
      ..name = result.name
      ..code = result.code
      ..createdAt = now
      ..startedAt = now
      ..finishedAt = now
      ..accumulatedSeconds = 0
      ..valueCents = cents
      ..finalValueCents = cents;
    await InventoryService.instance.save(inv);
    if (!mounted) return;
    final msg = '📦 Inventário: ${result.name} (cód. ${result.code})\n'
        'Valor: ${_fmtCents(cents)}';
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
              decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^-?[0-9]*[.,]?[0-9]{0,2}')),
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
              final v =
                  double.tryParse(ctrl.text.trim().replaceAll(',', '.'));
              if (v == null) return;
              Navigator.pop(ctx, (v * 100).round());
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _open(Inventory inv) async {
    if (inv.isLegacy) return;
    if (inv.isFinalized) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InventoryHistoryScreen(inventoryId: inv.id),
      ));
    } else {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InventorySessionScreen(inventoryId: inv.id),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventários')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        onPressed: _newInventory,
        icon: const Icon(Icons.play_arrow),
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
                  child: Text('Sem inventários registados.',
                      style: TextStyle(color: Colors.black54)),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              itemBuilder: (_, i) => _InventoryCard(
                inv: items[i],
                onTap: () => _open(items[i]),
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
    } else if (inv.isPaused) {
      statusColor = Colors.amber.shade700;
      statusText = 'Em pausa';
      statusIcon = Icons.pause_circle;
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
      if (inv.accumulatedSeconds > 0) {
        subtitleParts.add(_fmtDuration(inv.accumulatedSeconds));
      }
    }
    final dateFmt = DateFormat('d/M HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(inv.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitleParts.isNotEmpty)
              Text(subtitleParts.join(' • '),
                  style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(dateFmt.format(inv.createdAt),
                    style:
                        const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: legacy ? null : const Icon(Icons.chevron_right),
        onTap: legacy ? null : onTap,
      ),
    );
  }
}

enum _NewInventoryAction { start, sendOnly }

class _NewInventoryData {
  const _NewInventoryData({
    required this.name,
    required this.code,
    required this.action,
  });
  final String name;
  final String code;
  final _NewInventoryAction action;
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
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _code,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Código',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _NewInventoryData(
                name: _name.text.trim(),
                code: _code.text.trim(),
                action: _NewInventoryAction.sendOnly,
              ),
            );
          },
          child: const Text('Enviar direto'),
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
                action: _NewInventoryAction.start,
              ),
            );
          },
          child: const Text('Iniciar'),
        ),
      ],
    );
  }
}

// ============================================================================
// Session screen (running / paused)
// ============================================================================

class InventorySessionScreen extends StatefulWidget {
  const InventorySessionScreen({super.key, required this.inventoryId});
  final int inventoryId;

  @override
  State<InventorySessionScreen> createState() => _InventorySessionScreenState();
}

class _InventorySessionScreenState extends State<InventorySessionScreen> {
  Inventory? _inv;
  List<InventoryLine> _lines = [];
  Timer? _ticker;
  String? _flashMessage;

  @override
  void initState() {
    super.initState();
    _load();
    InventoryService.instance.addListener(_load);
    InventoryLineService.instance.addListener(_load);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && (_inv?.isRunning ?? false)) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    InventoryService.instance.removeListener(_load);
    InventoryLineService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final inv = await InventoryService.instance.getById(widget.inventoryId);
    if (inv == null || !mounted) return;
    final lines = await InventoryLineService.instance.linesFor(inv.syncUuid);
    if (!mounted) return;
    setState(() {
      _inv = inv;
      _lines = lines;
    });
  }

  int _elapsedSeconds() {
    final inv = _inv;
    if (inv == null) return 0;
    var sec = inv.accumulatedSeconds;
    if (inv.runningSince != null) {
      sec += DateTime.now().difference(inv.runningSince!).inSeconds;
    }
    return sec;
  }

  Future<void> _scan() async {
    final inv = _inv;
    if (inv == null || inv.isFinalized) return;
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (code == null || code.isEmpty || !mounted) return;
    final count = await _askCount(prefill: 1);
    if (count == null || count <= 0 || !mounted) return;
    final line = await InventoryLineService.instance.addScan(
      parentUuid: inv.syncUuid,
      ean: code.trim(),
      count: count,
    );
    if (!mounted) return;
    setState(() {
      _flashMessage = line.productName == null
          ? 'Produto desconhecido — guardado por EAN.'
          : '+$count × ${line.productName}';
    });
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _flashMessage = null);
    });
  }

  Future<int?> _askCount({int prefill = 1}) async {
    final ctrl = TextEditingController(text: '$prefill');
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quantidade'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () =>
                Navigator.pop(context, int.tryParse(ctrl.text.trim())),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel() async {
    final inv = _inv;
    if (inv == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar inventário?'),
        content: const Text(
            'Esta ação irá descartar este inventário e todas as linhas registadas. Não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Manter')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Cancelar inventário'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await InventoryService.instance.delete(inv.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _togglePause() async {
    final inv = _inv;
    if (inv == null || inv.isFinalized) return;
    if (inv.isRunning) {
      await InventoryService.instance.pause(inv);
    } else {
      await InventoryService.instance.resume(inv);
    }
  }

  Future<void> _finalize() async {
    final inv = _inv;
    if (inv == null || inv.isFinalized) return;
    final cents = await _askFinalValue();
    if (cents == null || !mounted) return;
    await InventoryService.instance.finalize(inv, finalValueCents: cents);
    if (!mounted) return;
    final msg = '📦 Inventário: ${inv.name} (cód. ${inv.code ?? '—'})\n'
        'Valor: ${_fmtCents(cents)}\n'
        'Duração: ${_fmtDuration(_elapsedSeconds())}\n'
        'Linhas: ${_lines.length}';
    await WhatsAppService.sendWithConfirm(context, msg);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => InventoryHistoryScreen(inventoryId: inv.id),
    ));
  }

  Future<int?> _askFinalValue() async {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Valor final do inventário'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^-?[0-9]*[.,]?[0-9]{0,2}')),
          ],
          decoration: const InputDecoration(
            hintText: 'Ex.: -12,50',
            prefixText: '€ ',
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
              final v = double.tryParse(
                  ctrl.text.trim().replaceAll(',', '.'));
              if (v == null) return;
              Navigator.pop(context, (v * 100).round());
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inv = _inv;
    if (inv == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final running = inv.isRunning;
    return Scaffold(
      appBar: AppBar(
        title: Text(inv.name),
        backgroundColor: running ? AppColors.green : Colors.amber.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Cancelar inventário',
            onPressed: _cancel,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: (running ? AppColors.green : Colors.amber.shade700)
                  .withValues(alpha: 0.08),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código ${inv.code ?? '—'}',
                            style:
                                const TextStyle(color: Colors.black54, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(_fmtDuration(_elapsedSeconds()),
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                fontFeatures: [FontFeature.tabularFigures()])),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(running ? Icons.pause : Icons.play_arrow),
                    label: Text(running ? 'Pausar' : 'Retomar'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: running ? _scan : null,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Ler código',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _finalize,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16)),
                    icon: const Icon(Icons.check),
                    label: const Text('Finalizar'),
                  ),
                ],
              ),
            ),
            if (_flashMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_flashMessage!,
                      style: const TextStyle(
                          color: AppColors.greenDark,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: _LinesList(
                lines: _lines,
                onProductFilled: _load,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// History screen (finalized read-only)
// ============================================================================

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({super.key, required this.inventoryId});
  final int inventoryId;

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  Inventory? _inv;
  List<InventoryLine> _lines = [];

  @override
  void initState() {
    super.initState();
    _load();
    InventoryLineService.instance.addListener(_load);
  }

  @override
  void dispose() {
    InventoryLineService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final inv = await InventoryService.instance.getById(widget.inventoryId);
    if (inv == null || !mounted) return;
    final lines = await InventoryLineService.instance.linesFor(inv.syncUuid);
    if (!mounted) return;
    setState(() {
      _inv = inv;
      _lines = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inv = _inv;
    if (inv == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final totalCount =
        _lines.fold<int>(0, (s, l) => s + l.count);
    return Scaffold(
      appBar: AppBar(title: Text(inv.name)),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.green.withValues(alpha: 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Código ${inv.code ?? '—'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _stat('Valor', _fmtCents(inv.valueCents)),
                      if (inv.accumulatedSeconds > 0)
                        _stat('Duração',
                            _fmtDuration(inv.accumulatedSeconds)),
                      _stat('Linhas', '${_lines.length}'),
                      if (totalCount > 0)
                        _stat('Unidades', '$totalCount'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _LinesList(
                lines: _lines,
                onProductFilled: _load,
                emptyMessage:
                    'Este inventário foi enviado diretamente, sem leituras.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

// ============================================================================
// Lines list (shared between Session + History)
// ============================================================================

class _LinesList extends StatelessWidget {
  const _LinesList({
    required this.lines,
    required this.onProductFilled,
    this.emptyMessage = 'Sem linhas. Lê um código para começar.',
  });
  final List<InventoryLine> lines;
  final VoidCallback onProductFilled;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: lines.length,
      itemBuilder: (_, i) {
        final l = lines[i];
        return _LineTile(line: l, onProductFilled: onProductFilled);
      },
    );
  }
}

class _LineTile extends StatefulWidget {
  const _LineTile({required this.line, required this.onProductFilled});
  final InventoryLine line;
  final VoidCallback onProductFilled;

  @override
  State<_LineTile> createState() => _LineTileState();
}

class _LineTileState extends State<_LineTile> {
  bool _expanded = false;

  Future<void> _addProduct() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            ProductFormScreen(prefilledEan: widget.line.ean),
      ),
    );
    if (saved != true || !mounted) return;
    final p = await ProductService.instance.findByEan(widget.line.ean);
    if (p != null) {
      await InventoryLineService.instance
          .setProductName(widget.line, p.name);
    }
    widget.onProductFilled();
  }

  Future<void> _editCount() async {
    final ctrl = TextEditingController(text: '${widget.line.count}');
    final v = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar quantidade'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () =>
                Navigator.pop(context, int.tryParse(ctrl.text.trim())),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (v == null) return;
    await InventoryLineService.instance.setCount(widget.line, v);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.line;
    final unknown = l.productName == null || l.productName!.isEmpty;
    final fmt = DateFormat('d/M HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: unknown
                        ? Colors.amber.shade100
                        : AppColors.green.withValues(alpha: 0.15),
                    foregroundColor: unknown
                        ? Colors.amber.shade900
                        : AppColors.greenDark,
                    child: Text('${l.count}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_expanded) ...[
                          SizedBox(
                            height: 44,
                            child: _BarcodeImage(
                              ean: l.ean,
                              drawText: false,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ] else
                          Text(l.ean,
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        Text(
                          unknown ? 'Produto desconhecido' : l.productName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: unknown
                                  ? Colors.amber.shade800
                                  : Colors.black87,
                              fontSize: 12,
                              fontStyle: unknown
                                  ? FontStyle.italic
                                  : FontStyle.normal),
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey),
                    ),
                    child: SizedBox(
                      height: 110,
                      child: _BarcodeImage(ean: l.ean, drawText: true),
                    ),
                  ),
                  Text('Última atualização: ${fmt.format(l.updatedAt)}',
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _editCount,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar qtd.'),
                      ),
                      if (unknown)
                        OutlinedButton.icon(
                          onPressed: _addProduct,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Adicionar produto'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.greenDark),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BarcodeImage extends StatelessWidget {
  const _BarcodeImage({required this.ean, required this.drawText});
  final String ean;
  final bool drawText;

  @override
  Widget build(BuildContext context) {
    final type = ean.length == 13
        ? Barcode.ean13()
        : ean.length == 8
            ? Barcode.ean8()
            : Barcode.code128();
    return BarcodeWidget(
      barcode: type,
      data: ean,
      drawText: drawText,
      color: AppColors.black,
      backgroundColor: Colors.white,
      style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600),
    );
  }
}

// ============================================================================
// Helpers
// ============================================================================

String _fmtDuration(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(h)}:${two(m)}:${two(s)}';
}

String _fmtCents(int cents) {
  final euros = cents / 100;
  return '${euros.toStringAsFixed(2).replaceAll('.', ',')} €';
}

