import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

  Future<void> _openHistory() async {
    final all = await VisualListService.instance.all();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HistorySheet(all: all),
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
                  'Nova lista visual',
                  style: TextStyle(
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
            _totalLine('Quebra', '${formatCents(quebraCents)} €'),
            const SizedBox(height: 6),
            _totalLine('Benefício', '${formatCents(beneficioCents)} €'),
          ],
        ),
      ),
    );
  }

  Widget _totalLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
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

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({required this.all});
  final List<VisualList> all;

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat("EEEE, d 'de' MMM y", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');

    final byDay = <DateTime, List<VisualList>>{};
    for (final e in all) {
      byDay.putIfAbsent(e.serviceDay, () => []).add(e);
    }
    final days = byDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        if (days.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Sem histórico.'),
            ),
          );
        }
        return ListView.builder(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(12),
          itemCount: days.length,
          itemBuilder: (_, i) {
            final day = days[i];
            final entries = byDay[day]!;
            final totalItens =
                entries.fold(0, (s, e) => s + e.itensPicados);
            final totalQ =
                entries.fold(0, (s, e) => s + e.quebraCents);
            final totalB =
                entries.fold(0, (s, e) => s + e.beneficioCents);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                title: Text(dayFmt.format(day),
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Itens: $totalItens · Quebra: ${formatCents(totalQ)} € · Benefício: ${formatCents(totalB)} €',
                ),
                children: entries.map((e) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.visibility,
                        color: AppColors.green),
                    title: Text(timeFmt.format(e.createdAt)),
                    subtitle: Text(
                      'Itens: ${e.itensPicados} · Quebra: ${formatCents(e.quebraCents)} € · Benefício: ${formatCents(e.beneficioCents)} €',
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
