import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';

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
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PedidoSessionScreen(pedidoId: p.id)),
    );
  }

  Future<void> _open(Pedido p) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => p.isFinalized
            ? PedidoHistoryScreen(pedidoId: p.id)
            : PedidoSessionScreen(pedidoId: p.id),
      ),
    );
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
                  child: Text(
                    'Sem pedidos registados.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }
            final overdueCount = items.where((p) => p.isOverdue).length;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length + (overdueCount > 0 ? 1 : 0),
              itemBuilder: (_, i) {
                if (overdueCount > 0) {
                  if (i == 0) return _OverdueBanner(count: overdueCount);
                  final p = items[i - 1];
                  return _PedidoCard(pedido: p, onTap: () => _open(p));
                }
                final p = items[i];
                return _PedidoCard(pedido: p, onTap: () => _open(p));
              },
            );
          },
        ),
      ),
    );
  }
}

class _OverdueBanner extends StatelessWidget {
  const _OverdueBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                count == 1
                    ? '1 pedido está atrasado.'
                    : '$count pedidos estão atrasados.',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
    final overdue = pedido.isOverdue;
    final dateFmt = DateFormat('d/M HH:mm');
    final statusColor = overdue
        ? Colors.orange.shade800
        : finalized
        ? AppColors.green
        : AppColors.greenDark;
    final statusIcon = overdue
        ? Icons.warning_amber_rounded
        : finalized
        ? Icons.check_circle
        : Icons.play_circle;
    final subtitleParts = <String>[
      '${finalized ? 'Concluído' : 'A decorrer'} • ${dateFmt.format(pedido.createdAt)}',
      if (pedido.supplier != null) pedido.supplier!,
      if (overdue) 'Atrasado',
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          finalized ? 'Pedido ${pedido.numero ?? '—'}' : 'Pedido (em curso)',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitleParts.join(' · '),
          style: TextStyle(
            fontSize: 12,
            color: overdue ? Colors.orange.shade800 : Colors.black54,
            fontWeight: overdue ? FontWeight.w600 : FontWeight.normal,
          ),
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

  @override
  void initState() {
    super.initState();
    _load();
    PedidoService.instance.addListener(_load);
  }

  @override
  void dispose() {
    PedidoService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final p = await PedidoService.instance.getById(widget.pedidoId);
    if (p == null || !mounted) return;
    setState(() => _pedido = p);
  }

  Future<void> _editDetails() async {
    final p = _pedido;
    if (p == null || p.isFinalized) return;
    final result = await showDialog<_PedidoDetailsResult>(
      context: context,
      builder: (_) => _PedidoDetailsDialog(
        initialSupplier: p.supplier,
        initialExpectedDate: p.expectedDate,
      ),
    );
    if (result == null || !mounted) return;
    await PedidoService.instance.updateDetails(
      p,
      supplier: result.supplier,
      expectedDate: result.expectedDate,
      clearExpectedDate: result.clearDate,
    );
  }

  Future<void> _finalize() async {
    final p = _pedido;
    if (p == null || p.isFinalized) return;
    final numero = await _askNumero();
    if (numero == null || !mounted) return;
    await PedidoService.instance.finalize(p, numero: numero);
    if (!mounted) return;
    final msg = StringBuffer()..writeln('📝 Pedido nº $numero');
    if (p.supplier != null) msg.writeln('Fornecedor: ${p.supplier}');
    if (p.expectedDate != null) {
      msg.writeln(
        'Previsto para: ${DateFormat("d 'de' MMMM", 'pt_PT').format(p.expectedDate!)}',
      );
    }
    await WhatsAppService.sendWithConfirm(context, msg.toString().trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PedidoHistoryScreen(pedidoId: p.id)),
    );
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
        content: const Text('Esta ação irá descartar este pedido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Manter'),
          ),
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
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _finalize,
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Finalizar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    p.isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline,
                    color: p.isOverdue
                        ? Colors.orange.shade800
                        : AppColors.green,
                  ),
                  title: Text(
                    p.supplier ?? 'Fornecedor (opcional)',
                    style: TextStyle(
                      color: p.supplier == null
                          ? Colors.black45
                          : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    p.expectedDate == null
                        ? 'Sem data prevista'
                        : '${p.isOverdue ? 'Atrasado desde' : 'Previsto para'} ${DateFormat("d 'de' MMMM", 'pt_PT').format(p.expectedDate!)}',
                    style: TextStyle(
                      color: p.isOverdue
                          ? Colors.orange.shade800
                          : Colors.black54,
                      fontWeight: p.isOverdue
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: _editDetails,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PedidoDetailsResult {
  const _PedidoDetailsResult({
    this.supplier,
    this.expectedDate,
    this.clearDate = false,
  });
  final String? supplier;
  final DateTime? expectedDate;
  final bool clearDate;
}

class _PedidoDetailsDialog extends StatefulWidget {
  const _PedidoDetailsDialog({this.initialSupplier, this.initialExpectedDate});
  final String? initialSupplier;
  final DateTime? initialExpectedDate;

  @override
  State<_PedidoDetailsDialog> createState() => _PedidoDetailsDialogState();
}

class _PedidoDetailsDialogState extends State<_PedidoDetailsDialog> {
  late final TextEditingController _supplierCtrl;
  DateTime? _expectedDate;

  @override
  void initState() {
    super.initState();
    _supplierCtrl = TextEditingController(text: widget.initialSupplier ?? '');
    _expectedDate = widget.initialExpectedDate;
  }

  @override
  void dispose() {
    _supplierCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'PT'),
    );
    if (date == null) return;
    setState(() => _expectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes do pedido'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _supplierCtrl,
            decoration: const InputDecoration(
              labelText: 'Fornecedor (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Data prevista de chegada (opcional)',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _expectedDate == null
                        ? 'Escolher data'
                        : DateFormat("d/M/y", 'pt_PT').format(_expectedDate!),
                  ),
                ),
              ),
              if (_expectedDate != null)
                IconButton(
                  tooltip: 'Limpar data',
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _expectedDate = null),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.green),
          onPressed: () => Navigator.pop(
            context,
            _PedidoDetailsResult(
              supplier: _supplierCtrl.text,
              expectedDate: _expectedDate,
              clearDate: _expectedDate == null,
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await PedidoService.instance.getById(widget.pedidoId);
    if (p == null || !mounted) return;
    setState(() => _pedido = p);
  }

  @override
  Widget build(BuildContext context) {
    final p = _pedido;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
                  _stat('Data', DateFormat('d/M/y HH:mm').format(p.createdAt)),
                  if (p.supplier != null) _stat('Fornecedor', p.supplier!),
                ],
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
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }
}
