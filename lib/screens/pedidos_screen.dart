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
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PedidoFormScreen()));
  }

  Future<void> _open(Pedido p) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => p.isFinalized
            ? PedidoHistoryScreen(pedidoId: p.id)
            : PedidoFormScreen(pedidoId: p.id),
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
        title: Text(switch ((finalized, pedido.numero)) {
          (true, final n) => 'Pedido ${n ?? '—'}',
          (false, null) => 'Pedido (em curso)',
          (false, final n?) => 'Pedido $n (em curso)',
        }, style: const TextStyle(fontWeight: FontWeight.w700)),
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
// Form screen (new and in-progress pedidos)
// ============================================================================

/// The pedido as a form: Número (required), Fornecedor and Data prevista.
/// Without [pedidoId] it is the Novo form and "Criar pedido" saves it; an
/// in-progress pedido saves each change as it is made and is closed with
/// Finalizar.
class PedidoFormScreen extends StatefulWidget {
  const PedidoFormScreen({super.key, this.pedidoId});
  final int? pedidoId;

  @override
  State<PedidoFormScreen> createState() => _PedidoFormScreenState();
}

class _PedidoFormScreenState extends State<PedidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  DateTime? _expectedDate;

  /// Null until the pedido exists (the Novo form before "Criar pedido").
  Pedido? _pedido;
  bool _loading = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.pedidoId case final id?) {
      _loading = true;
      _load(id);
    }
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  Future<void> _load(int id) async {
    final p = await PedidoService.instance.getById(id);
    if (p == null || !mounted) return;
    setState(() {
      _pedido = p;
      _numeroCtrl.text = p.numero ?? '';
      _supplierCtrl.text = p.supplier ?? '';
      _expectedDate = p.expectedDate;
      _loading = false;
    });
  }

  /// Saves the fields on an existing pedido; the Novo form waits for
  /// "Criar pedido".
  Future<void> _saveDetails() async {
    final p = _pedido;
    if (p == null) return;
    await PedidoService.instance.updateDetails(
      p,
      numero: _numeroCtrl.text,
      supplier: _supplierCtrl.text,
      expectedDate: _expectedDate,
    );
    if (mounted) setState(() {});
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'PT'),
      helpText: 'Data prevista de chegada',
    );
    if (date == null) return;
    setState(() => _expectedDate = date);
    await _saveDetails();
  }

  Future<void> _clearDate() async {
    setState(() => _expectedDate = null);
    await _saveDetails();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() => _busy = true);
    final p = await PedidoService.instance.create(
      numero: _numeroCtrl.text.trim(),
      supplier: _supplierCtrl.text,
      expectedDate: _expectedDate,
    );
    if (!mounted) return;
    setState(() {
      _pedido = p;
      _busy = false;
    });
  }

  Future<void> _finalize() async {
    final p = _pedido;
    if (p == null || p.isFinalized || _busy) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await _saveDetails();
    await PedidoService.instance.finalize(p);
    if (!mounted) return;
    final msg = StringBuffer()..writeln('📝 Pedido nº ${p.numero}');
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final p = _pedido;
    final numero = _numeroCtrl.text.trim();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          p == null
              ? 'Novo pedido'
              : numero.isEmpty
              ? 'Pedido (em curso)'
              : 'Pedido $numero (em curso)',
        ),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        actions: [
          if (p != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Cancelar pedido',
              onPressed: _cancel,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _numeroCtrl,
                autofocus: p == null,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Número do pedido',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                onChanged: (_) => _saveDetails(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _supplierCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Fornecedor (opcional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveDetails(),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data prevista de chegada (opcional)',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _expectedDate == null
                              ? 'Escolher data'
                              : DateFormat(
                                  "d 'de' MMMM 'de' y",
                                  'pt_PT',
                                ).format(_expectedDate!),
                        ),
                      ),
                    ),
                    if (_expectedDate != null)
                      IconButton(
                        tooltip: 'Limpar data',
                        icon: const Icon(Icons.clear),
                        onPressed: _clearDate,
                      ),
                  ],
                ),
              ),
              if (p != null && p.isOverdue)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Atrasado',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _busy ? null : (p == null ? _create : _finalize),
                icon: Icon(p == null ? Icons.add : Icons.check),
                label: Text(
                  p == null ? 'Criar pedido' : 'Finalizar',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
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
