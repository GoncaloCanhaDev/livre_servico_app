import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/opening_list.dart';
import '../../services/opening_list_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';

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
    list.congelados = int.tryParse(_congelados.text) ?? 0;
    list.opls = int.tryParse(_opls.text) ?? 0;
    list.naoPereciveis = int.tryParse(_naoPereciveis.text) ?? 0;
    setState(() {});
    await OpeningListService.instance.updateValues(
      list,
      congelados: list.congelados,
      opls: list.opls,
      naoPereciveis: list.naoPereciveis,
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

    if (mounted) {
      final msg = '📋 Lista de Abertura\n'
          'Congelados: ${list.congelados}\n'
          'OPLS: ${list.opls}\n'
          'Não Perecíveis: ${list.naoPereciveis}\n'
          'Total: ${list.total}';
      await WhatsAppService.sendWithConfirm(context, msg);
    }
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
                        'Finalizada às ${DateFormat('HH:mm').format(list.finalizedAt!)}.\nA próxima abre às 5h.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          NumberRow(
            label: 'Congelados',
            controller: _congelados,
            enabled: !locked,
            onChanged: _persistField,
          ),
          NumberRow(
            label: 'OPLS',
            controller: _opls,
            enabled: !locked,
            onChanged: _persistField,
          ),
          NumberRow(
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
