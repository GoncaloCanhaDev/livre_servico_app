import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/auto_list.dart';
import '../../services/auto_list_service.dart';
import '../../theme.dart';

class AutomaticasTab extends StatefulWidget {
  const AutomaticasTab({super.key});

  @override
  State<AutomaticasTab> createState() => _AutomaticasTabState();
}

class _AutomaticasTabState extends State<AutomaticasTab> {
  final _congelados = TextEditingController();
  final _opls = TextEditingController();
  final _naoPereciveis = TextEditingController();

  @override
  void dispose() {
    _congelados.dispose();
    _opls.dispose();
    _naoPereciveis.dispose();
    super.dispose();
  }

  int get _total =>
      (int.tryParse(_congelados.text) ?? 0) +
      (int.tryParse(_opls.text) ?? 0) +
      (int.tryParse(_naoPereciveis.text) ?? 0);

  Future<void> _finalize() async {
    final c = int.tryParse(_congelados.text) ?? 0;
    final o = int.tryParse(_opls.text) ?? 0;
    final n = int.tryParse(_naoPereciveis.text) ?? 0;
    if (c == 0 && o == 0 && n == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indique pelo menos um valor.')),
      );
      return;
    }
    await AutoListService.instance
        .add(congelados: c, opls: o, naoPereciveis: n);
    if (!mounted) return;
    setState(() {
      _congelados.clear();
      _opls.clear();
      _naoPereciveis.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lista guardada.')),
    );
  }

  Future<void> _openHistory() async {
    final items = await AutoListService.instance.history();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => _HistorySheet(items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Nova lista automática',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Histórico',
                onPressed: _openHistory,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _NumberRow(
            label: 'Congelados',
            controller: _congelados,
            onChanged: () => setState(() {}),
          ),
          _NumberRow(
            label: 'OPLS',
            controller: _opls,
            onChanged: () => setState(() {}),
          ),
          _NumberRow(
            label: 'Não Perecíveis',
            controller: _naoPereciveis,
            onChanged: () => setState(() {}),
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
                    '$_total',
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
            onPressed: _finalize,
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
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
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
  final List<AutoList> items;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("d 'de' MMM, HH:mm", 'pt_PT');
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
                  leading: const Icon(Icons.bolt, color: AppColors.green),
                  title: Text(fmt.format(l.createdAt)),
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
