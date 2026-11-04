import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/auto2_entry.dart';
import '../../models/opening_list.dart';
import '../../services/auto2_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';
import '../widgets/person_picker.dart';

/// Listas 2.0 → Automáticas, like 1.0's: each item is sent on its own once
/// done (who did it, then WhatsApp), saved to Histórico, and its field
/// clears for the next one.
class Automaticas2Tab extends StatefulWidget {
  const Automaticas2Tab({super.key});

  @override
  State<Automaticas2Tab> createState() => _Automaticas2TabState();
}

class _Automaticas2TabState extends State<Automaticas2Tab> {
  final _ctrls = {for (final i in Auto2Item.values) i: TextEditingController()};

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _valueOf(Auto2Item i) => int.tryParse(_ctrls[i]!.text) ?? 0;

  int get _total => Auto2Item.values.fold(0, (sum, i) => sum + _valueOf(i));

  Future<void> _send(Auto2Item item) async {
    final value = _valueOf(item);
    if (value == 0) return;
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem fez ${item.label}?',
      subtitle: 'Automáticas · ${item.label}: $value',
      initialDay: today,
    );
    if (result == null || !mounted) return;
    final names = result.people.map((p) => p.fullName).toList();
    final day = DateTime(result.day.year, result.day.month, result.day.day, 5);
    final isToday = day.isAtSameMomentAs(today);
    await Auto2Service.instance.send(
      item: item,
      value: value,
      names: names,
      serviceDay: isToday ? null : day,
    );
    if (!mounted) return;

    final dayNote = isToday
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(day)})';
    await WhatsAppService.sendWithConfirm(
      context,
      '📦 Automáticas$dayNote · ${item.label}: $value\n'
      'Por: ${joinNames(names)}',
    );
    if (!mounted) return;
    setState(() => _ctrls[item]!.clear());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.label} guardado.')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Automáticas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Envia cada item quando estiver feito.',
              style: TextStyle(fontSize: 12, color: context.muted),
            ),
          ),
          const SizedBox(height: 8),
          for (final i in Auto2Item.values)
            NumberRow(
              label: i.label,
              controller: _ctrls[i]!,
              onChanged: () => setState(() {}),
              trailing: IconButton(
                tooltip: 'Enviar ${i.label}',
                icon: const Icon(Icons.check_circle),
                color: context.colors.primary,
                onPressed: _valueOf(i) == 0 ? null : () => _send(i),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '$_total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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
