import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/pedido.dart';
import '../models/pedido_line.dart';
import '../services/pedido_line_service.dart';
import '../services/pedido_service.dart';
import '../services/product_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'product_form_screen.dart';
import 'scanner_screen.dart';

// ============================================================================
// List screen
// ============================================================================

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late Future<List<Pedido>> _future;

  @override
  void initState() {
    super.initState();
    _future = PedidoService.instance.history();
    PedidoService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    PedidoService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = PedidoService.instance.history();
    });
  }

  Future<void> _newPedido() async {
    final p = await PedidoService.instance.startSession();
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PedidoSessionScreen(pedidoId: p.id),
    ));
  }

  Future<void> _open(Pedido p) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => p.isFinalized
          ? PedidoHistoryScreen(pedidoId: p.id)
          : PedidoSessionScreen(pedidoId: p.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        onPressed: _newPedido,
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Pedido>>(
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
                  child: Text('Sem pedidos registados.',
                      style: TextStyle(color: Colors.black54)),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              itemBuilder: (_, i) => _PedidoCard(
                pedido: items[i],
                onTap: () => _open(items[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({required this.pedido, required this.onTap});
  final Pedido pedido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final finalized = pedido.isFinalized;
    final dateFmt = DateFormat('d/M HH:mm');
    final statusColor =
        finalized ? AppColors.green : AppColors.greenDark;
    final statusIcon =
        finalized ? Icons.check_circle : Icons.play_circle;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          finalized
              ? 'Pedido ${pedido.numero ?? '—'}'
              : 'Pedido (em curso)',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${finalized ? 'Concluído' : 'A decorrer'} • ${dateFmt.format(pedido.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================================
// Session screen
// ============================================================================

class PedidoSessionScreen extends StatefulWidget {
  const PedidoSessionScreen({super.key, required this.pedidoId});
  final int pedidoId;

  @override
  State<PedidoSessionScreen> createState() => _PedidoSessionScreenState();
}

class _PedidoSessionScreenState extends State<PedidoSessionScreen> {
  Pedido? _pedido;
  List<PedidoLine> _lines = [];
  String? _flash;

  @override
  void initState() {
    super.initState();
    _load();
    PedidoService.instance.addListener(_load);
    PedidoLineService.instance.addListener(_load);
  }

  @override
  void dispose() {
    PedidoService.instance.removeListener(_load);
    PedidoLineService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final p = await PedidoService.instance.getById(widget.pedidoId);
    if (p == null || !mounted) return;
    final lines = await PedidoLineService.instance.linesFor(p.syncUuid);
    if (!mounted) return;
    setState(() {
      _pedido = p;
      _lines = lines;
    });
  }

  Future<void> _scan() async {
    final p = _pedido;
    if (p == null || p.isFinalized) return;
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (code == null || code.isEmpty || !mounted) return;
    final caixas = await _askCaixas();
    if (caixas == null || caixas <= 0 || !mounted) return;
    final line = await PedidoLineService.instance.addScan(
      parentUuid: p.syncUuid,
      ean: code.trim(),
      caixas: caixas,
    );
    if (!mounted) return;
    setState(() {
      _flash = line.productName == null
          ? 'Produto desconhecido — guardado por EAN.'
          : '+$caixas cx × ${line.productName}';
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _flash = null);
    });
  }

  Future<int?> _askCaixas() async {
    final ctrl = TextEditingController(text: '1');
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Caixas'),
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

  Future<void> _finalize() async {
    final p = _pedido;
    if (p == null || p.isFinalized) return;
    final numero = await _askNumero();
    if (numero == null || !mounted) return;
    await PedidoService.instance.finalize(p, numero: numero);
    if (!mounted) return;
    final msg = StringBuffer()
      ..writeln('📝 Pedido nº $numero')
      ..writeln('${_lines.length} produto(s)');
    for (final l in _lines) {
      msg.writeln(
          '• ${l.productName ?? l.ean} (${l.ean}) — ${l.caixas} cx');
    }
    await WhatsAppService.sendWithConfirm(context, msg.toString().trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => PedidoHistoryScreen(pedidoId: p.id),
    ));
  }

  Future<String?> _askNumero() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Número do pedido'),
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
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(context, v);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel() async {
    final p = _pedido;
    if (p == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar pedido?'),
        content: const Text(
            'Esta ação irá descartar este pedido e todas as linhas registadas.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Manter')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Cancelar pedido'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await PedidoService.instance.delete(p.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = _pedido;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido (em curso)'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Cancelar pedido',
            onPressed: _cancel,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: _scan,
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
            if (_flash != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_flash!,
                      style: const TextStyle(
                          color: AppColors.greenDark,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: _PedidoLinesList(
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

class PedidoHistoryScreen extends StatefulWidget {
  const PedidoHistoryScreen({super.key, required this.pedidoId});
  final int pedidoId;

  @override
  State<PedidoHistoryScreen> createState() => _PedidoHistoryScreenState();
}

class _PedidoHistoryScreenState extends State<PedidoHistoryScreen> {
  Pedido? _pedido;
  List<PedidoLine> _lines = [];

  @override
  void initState() {
    super.initState();
    _load();
    PedidoLineService.instance.addListener(_load);
  }

  @override
  void dispose() {
    PedidoLineService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final p = await PedidoService.instance.getById(widget.pedidoId);
    if (p == null || !mounted) return;
    final lines = await PedidoLineService.instance.linesFor(p.syncUuid);
    if (!mounted) return;
    setState(() {
      _pedido = p;
      _lines = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _pedido;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final totalCaixas = _lines.fold<int>(0, (s, l) => s + l.caixas);
    return Scaffold(
      appBar: AppBar(title: Text('Pedido ${p.numero ?? '—'}')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.green.withValues(alpha: 0.08),
              child: Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _stat('Nº', p.numero ?? '—'),
                  _stat('Linhas', '${_lines.length}'),
                  _stat('Caixas', '$totalCaixas'),
                  _stat('Data',
                      DateFormat('d/M/y HH:mm').format(p.createdAt)),
                ],
              ),
            ),
            Expanded(
              child: _PedidoLinesList(
                lines: _lines,
                onProductFilled: _load,
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
// Lines list (shared)
// ============================================================================

class _PedidoLinesList extends StatelessWidget {
  const _PedidoLinesList(
      {required this.lines, required this.onProductFilled});
  final List<PedidoLine> lines;
  final VoidCallback onProductFilled;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Sem linhas. Lê um código para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: lines.length,
      itemBuilder: (_, i) => _PedidoLineTile(
        line: lines[i],
        onProductFilled: onProductFilled,
      ),
    );
  }
}

class _PedidoLineTile extends StatefulWidget {
  const _PedidoLineTile(
      {required this.line, required this.onProductFilled});
  final PedidoLine line;
  final VoidCallback onProductFilled;

  @override
  State<_PedidoLineTile> createState() => _PedidoLineTileState();
}

class _PedidoLineTileState extends State<_PedidoLineTile> {
  bool _expanded = false;

  Future<void> _addProduct() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(prefilledEan: widget.line.ean),
      ),
    );
    if (saved != true || !mounted) return;
    final p = await ProductService.instance.findByEan(widget.line.ean);
    if (p != null) {
      await PedidoLineService.instance
          .setProductName(widget.line, p.name);
    }
    widget.onProductFilled();
  }

  Future<void> _editCaixas() async {
    final ctrl = TextEditingController(text: '${widget.line.caixas}');
    final v = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar caixas'),
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
    await PedidoLineService.instance.setCaixas(widget.line, v);
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
                children: [
                  CircleAvatar(
                    backgroundColor: unknown
                        ? Colors.amber.shade100
                        : AppColors.green.withValues(alpha: 0.15),
                    foregroundColor: unknown
                        ? Colors.amber.shade900
                        : AppColors.greenDark,
                    child: Text('${l.caixas}',
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
                            child: BarcodeWidget(
                              barcode: l.ean.length == 13
                                  ? Barcode.ean13()
                                  : l.ean.length == 8
                                      ? Barcode.ean8()
                                      : Barcode.code128(),
                              data: l.ean,
                              drawText: false,
                              color: AppColors.black,
                              backgroundColor: Colors.white,
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
                              fontStyle:
                                  unknown ? FontStyle.italic : FontStyle.normal),
                        ),
                      ],
                    ),
                  ),
                  Text('${l.caixas} cx',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
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
                      child: BarcodeWidget(
                        barcode: l.ean.length == 13
                            ? Barcode.ean13()
                            : l.ean.length == 8
                                ? Barcode.ean8()
                                : Barcode.code128(),
                        data: l.ean,
                        drawText: true,
                        color: AppColors.black,
                        backgroundColor: Colors.white,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
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
                        onPressed: _editCaixas,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar caixas'),
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
