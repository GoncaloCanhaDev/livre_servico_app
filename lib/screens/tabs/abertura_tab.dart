import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/opening_list.dart';
import '../../services/opening_list_service.dart';
import '../../theme.dart';

class AberturaTab extends StatefulWidget {
  const AberturaTab({super.key});

  @override
  State<AberturaTab> createState() => _AberturaTabState();
}

class _AberturaTabState extends State<AberturaTab> {
  OpeningList? _list;
  late final TextEditingController _congelados;
  late final TextEditingController _opls;
  late final TextEditingController _naoPereciveis;

  @override
  void initState() {
    super.initState();
    _congelados = TextEditingController();
    _opls = TextEditingController();
    _naoPereciveis = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _congelados.dispose();
    _opls.dispose();
    _naoPereciveis.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await OpeningListService.instance.currentOrCreate();
    if (!mounted) return;
    setState(() {
      _list = list;
      _congelados.text = list.congelados == 0 ? '' : '${list.congelados}';
      _opls.text = list.opls == 0 ? '' : '${list.opls}';
      _naoPereciveis.text =
          list.naoPereciveis == 0 ? '' : '${list.naoPereciveis}';
    });
  }

  Future<void> _persistField() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    await OpeningListService.instance.updateValues(
      list,
      congelados: int.tryParse(_congelados.text) ?? 0,
      opls: int.tryParse(_opls.text) ?? 0,
      naoPereciveis: int.tryParse(_naoPereciveis.text) ?? 0,
    );
  }

  Future<void> _finalize() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Finalizar lista?'),
        content: const Text(
            'A lista ficará bloqueada. Será criada uma nova às 5h.'),
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
    await OpeningListService.instance.finalize(list);
    if (mounted) _load();
  }

  Future<void> _openHistory() async {
    final items = await OpeningListService.instance.history();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => _HistorySheet(items: items),
    );
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
          Row(
            children: [
              Expanded(
                child: Text(
                  dayFmt.format(list.serviceDay),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Histórico',
                onPressed: _openHistory,
              ),
            ],
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
                        'Finalizada às ${DateFormat('HH:mm').format(list.finalizedAt!)}.\nA próxima abre às 5h.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          _NumberRow(
            label: 'Congelados',
            controller: _congelados,
            enabled: !locked,
            onChanged: _persistField,
          ),
          _NumberRow(
            label: 'OPLS',
            controller: _opls,
            enabled: !locked,
            onChanged: _persistField,
          ),
          _NumberRow(
            label: 'Não Perecíveis',
            controller: _naoPereciveis,
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

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({required this.items});
  final List<OpeningList> items;

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat("d 'de' MMM y", 'pt_PT');
    return SafeArea(
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Sem histórico.', textAlign: TextAlign.center),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final l = items[i];
                return ListTile(
                  leading: Icon(
                    l.isFinalized ? Icons.check_circle : Icons.edit,
                    color: l.isFinalized ? AppColors.green : Colors.black45,
                  ),
                  title: Text(dayFmt.format(l.serviceDay)),
                  subtitle: Text(
                      'Cong: ${l.congelados} · OPLS: ${l.opls} · NP: ${l.naoPereciveis}'),
                  trailing: Text('${l.total}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                );
              },
            ),
    );
  }
}
