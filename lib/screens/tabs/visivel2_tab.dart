import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/opening_list.dart';
import '../../models/visivel2_entry.dart';
import '../../services/visivel2_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';
import '../widgets/person_picker.dart';

/// Listas 2.0 → Visível, like 1.0's Visual without Quebra and Benefício:
/// the products picked by hand going round the store. Meant once a day,
/// after a round of Automáticas, but never locked.
class Visivel2Tab extends StatefulWidget {
  const Visivel2Tab({super.key});

  @override
  State<Visivel2Tab> createState() => _Visivel2TabState();
}

class _Visivel2TabState extends State<Visivel2Tab> {
  final _itens = TextEditingController();
  List<Visivel2Entry> _today = [];

  @override
  void initState() {
    super.initState();
    Visivel2Service.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    Visivel2Service.instance.removeListener(_load);
    _itens.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final today = await Visivel2Service.instance.forServiceDay(
      currentServiceDay(),
    );
    if (!mounted) return;
    setState(() => _today = today);
  }

  int get _value => int.tryParse(_itens.text) ?? 0;

  Future<void> _finalize() async {
    final itens = _value;
    if (itens == 0) return;
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem fez o Visível?',
      subtitle: 'Visível · Itens picados: $itens',
      initialDay: today,
    );
    if (result == null || !mounted) return;
    final names = result.people.map((p) => p.fullName).toList();
    final day = DateTime(result.day.year, result.day.month, result.day.day, 5);
    final isToday = day.isAtSameMomentAs(today);
    await Visivel2Service.instance.add(
      itens: itens,
      names: names,
      serviceDay: isToday ? null : day,
    );
    if (!mounted) return;

    final dayNote = isToday
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(day)})';
    await WhatsAppService.sendWithConfirm(
      context,
      '👁 Visível$dayNote\n'
      'Itens Picados: $itens\n'
      'Por: ${joinNames(names)}',
    );
    if (!mounted) return;
    setState(_itens.clear);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Visível guardado.')));
  }

  @override
  Widget build(BuildContext context) {
    final total = _today.fold(0, (s, e) => s + e.itens);
    final count = _today.length;
    final timeFmt = DateFormat('HH:mm');
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Visível',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Uma vez por dia, depois de uma volta de Automáticas: conte os '
              'produtos picados na loja.',
              style: TextStyle(fontSize: 12, color: context.muted),
            ),
          ),
          const SizedBox(height: 8),
          NumberRow(
            label: 'Itens Picados',
            controller: _itens,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Finalizar'),
            onPressed: _value == 0 ? null : _finalize,
          ),
          const SizedBox(height: 24),
          Card(
            color: AppColors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoje  ·  $count visíve${count == 1 ? 'l' : 'is'}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Itens Picados',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  for (final e in _today)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${timeFmt.format(e.createdAt)} · ${e.itens} · '
                        '${joinNames(e.byNames)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
