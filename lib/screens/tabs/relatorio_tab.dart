import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/report_list.dart';
import '../../services/report_list_service.dart';
import '../../theme.dart';

class RelatorioTab extends StatefulWidget {
  const RelatorioTab({super.key});

  @override
  State<RelatorioTab> createState() => _RelatorioTabState();
}

class _RelatorioTabState extends State<RelatorioTab> {
  ReportList? _list;
  final _diasSemVendas = TextEditingController();
  final _regularizacoes = TextEditingController();
  final _massiva = TextEditingController();
  final _repetidos = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _diasSemVendas.dispose();
    _regularizacoes.dispose();
    _massiva.dispose();
    _repetidos.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await ReportListService.instance.currentOrCreate();
    if (!mounted) return;
    setState(() {
      _list = list;
      _diasSemVendas.text =
          list.diasSemVendas == 0 ? '' : '${list.diasSemVendas}';
      _regularizacoes.text =
          list.regularizacoes == 0 ? '' : '${list.regularizacoes}';
      _massiva.text = list.massiva == 0 ? '' : '${list.massiva}';
      _repetidos.text = list.repetidos == 0 ? '' : '${list.repetidos}';
    });
  }

  Future<void> _persistField() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    await ReportListService.instance.updateValues(
      list,
      diasSemVendas: int.tryParse(_diasSemVendas.text) ?? 0,
      regularizacoes: int.tryParse(_regularizacoes.text) ?? 0,
      massiva: int.tryParse(_massiva.text) ?? 0,
      repetidos: int.tryParse(_repetidos.text) ?? 0,
    );
  }

  Future<void> _finalize() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Finalizar relatório?'),
        content: const Text(
            'O relatório ficará bloqueado. Será criado um novo às 5h.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Finalizar')),
        ],
      ),
    );
    if (ok != true) return;
    await _persistField();
    await ReportListService.instance.finalize(list);
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final list = _list;
    if (list == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final dayFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_PT');
    final locked = list.isFinalized;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            dayFmt.format(list.serviceDay),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (locked)
            Card(
              color: Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Finalizado às ${DateFormat('HH:mm').format(list.finalizedAt!)}.\nO próximo abre às 5h.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          _NumberRow(
            label: 'Dias s/ vendas',
            controller: _diasSemVendas,
            enabled: !locked,
            onChanged: _persistField,
          ),
          _NumberRow(
            label: 'Regularizações',
            controller: _regularizacoes,
            enabled: !locked,
            onChanged: _persistField,
          ),
          _NumberRow(
            label: 'Massiva',
            controller: _massiva,
            enabled: !locked,
            onChanged: _persistField,
          ),
          _NumberRow(
            label: 'Repetidos',
            controller: _repetidos,
            enabled: !locked,
            onChanged: _persistField,
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1)),
                  Text(
                    '${list.total}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Finalizar'),
            onPressed: locked ? null : _finalize,
          ),
        ],
      ),
    );
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              width: 110,
              child: TextField(
                controller: controller,
                enabled: enabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
