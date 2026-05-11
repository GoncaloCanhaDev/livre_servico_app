import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/opening_list.dart';
import '../../models/visual_list.dart';
import '../../services/visual_list_service.dart';
import '../../theme.dart';

class VisualTab extends StatefulWidget {
  const VisualTab({super.key});

  @override
  State<VisualTab> createState() => _VisualTabState();
}

class _VisualTabState extends State<VisualTab> {
  final _itens = TextEditingController();
  final _quebra = TextEditingController();
  final _beneficio = TextEditingController();

  List<VisualList> _todayEntries = [];

  @override
  void initState() {
    super.initState();
    VisualListService.instance.addListener(_loadToday);
    _loadToday();
  }

  @override
  void dispose() {
    VisualListService.instance.removeListener(_loadToday);
    _itens.dispose();
    _quebra.dispose();
    _beneficio.dispose();
    super.dispose();
  }

  Future<void> _loadToday() async {
    final list = await VisualListService.instance
        .entriesForServiceDay(currentServiceDay());
    if (!mounted) return;
    setState(() => _todayEntries = list);
  }

  int get _todayItens =>
      _todayEntries.fold(0, (s, e) => s + e.itensPicados);
  int get _todayQuebra =>
      _todayEntries.fold(0, (s, e) => s + e.quebraCents);
  int get _todayBeneficio =>
      _todayEntries.fold(0, (s, e) => s + e.beneficioCents);

  Future<void> _finalize() async {
    final i = int.tryParse(_itens.text) ?? 0;
    final q = parseEurosToCents(_quebra.text);
    final b = parseEurosToCents(_beneficio.text);
    if (i == 0 && q == 0 && b == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indique pelo menos um valor.')),
      );
      return;
    }
    await VisualListService.instance.add(
      itensPicados: i,
      quebraCents: q,
      beneficioCents: b,
    );
    if (!mounted) return;
    setState(() {
      _itens.clear();
      _quebra.clear();
      _beneficio.clear();
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
            'Nova lista visual',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _IntRow(
            label: 'Itens Picados',
            controller: _itens,
            onChanged: () => setState(() {}),
          ),
          _MoneyRow(
            label: 'Quebra (€)',
            controller: _quebra,
            onChanged: () => setState(() {}),
          ),
          _MoneyRow(
            label: 'Benefício (€)',
            controller: _beneficio,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Finalizar'),
            onPressed: _finalize,
          ),
          const SizedBox(height: 24),
          _DayTotalsCard(
            itens: _todayItens,
            quebraCents: _todayQuebra,
            beneficioCents: _todayBeneficio,
            entriesCount: _todayEntries.length,
          ),
        ],
      ),
    );
  }
}

class _DayTotalsCard extends StatelessWidget {
  const _DayTotalsCard({
    required this.itens,
    required this.quebraCents,
    required this.beneficioCents,
    required this.entriesCount,
  });

  final int itens;
  final int quebraCents;
  final int beneficioCents;
  final int entriesCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Totais de hoje  ·  $entriesCount entrada${entriesCount == 1 ? '' : 's'}',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            _totalLine('Itens Picados', '$itens'),
            const SizedBox(height: 6),
            _totalLine('Quebra', '-${formatCents(quebraCents)} €',
                valueColor: Colors.redAccent),
            const SizedBox(height: 6),
            _totalLine('Benefício', '${formatCents(beneficioCents)} €',
                valueColor: AppColors.green),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.white24, height: 1),
            ),
            _totalLine('Total', '${formatCents(beneficioCents - quebraCents)} €',
                valueColor: (beneficioCents - quebraCents) >= 0
                    ? AppColors.green
                    : Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _totalLine(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _IntRow extends StatelessWidget {
  const _IntRow({
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
              width: 130,
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

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
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
              width: 130,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '0,00',
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
