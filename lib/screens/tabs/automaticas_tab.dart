import 'package:flutter/material.dart';

import '../../services/auto_list_service.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Nova lista automática',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          NumberRow(
            label: 'Congelados',
            controller: _congelados,
            onChanged: () => setState(() {}),
          ),
          NumberRow(
            label: 'OPLS',
            controller: _opls,
            onChanged: () => setState(() {}),
          ),
          NumberRow(
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
