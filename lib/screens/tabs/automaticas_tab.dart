import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/opening_list.dart';
import '../../services/auto_list_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';
import '../widgets/person_picker.dart';

/// A new automatic list, sent one section at a time: each send saves an
/// automatic list holding just that section and clears its field.
class AutomaticasTab extends StatefulWidget {
  const AutomaticasTab({super.key});

  @override
  State<AutomaticasTab> createState() => _AutomaticasTabState();
}

class _AutomaticasTabState extends State<AutomaticasTab> {
  final _ctrls = {
    for (final s in ListSection.values) s: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _valueOf(ListSection s) => int.tryParse(_ctrls[s]!.text) ?? 0;

  int get _total => ListSection.values.fold(0, (sum, s) => sum + _valueOf(s));

  Future<void> _sendSection(ListSection section) async {
    final value = _valueOf(section);
    if (value == 0) return;
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem fez ${section.label}?',
      subtitle: 'Lista Automática · ${section.label}: $value',
      initialDay: DateTime(today.year, today.month, today.day),
    );
    if (result == null || !mounted) return;
    final names = result.people.map((p) => p.fullName).toList();
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    int only(ListSection s) => s == section ? value : 0;
    if (targetDay == today) {
      await AutoListService.instance.add(
        congelados: only(ListSection.congelados),
        opls: only(ListSection.opls),
        naoPereciveis: only(ListSection.naoPereciveis),
        by: names,
      );
    } else {
      await AutoListService.instance.addForDay(
        serviceDay: targetDay,
        congelados: only(ListSection.congelados),
        opls: only(ListSection.opls),
        naoPereciveis: only(ListSection.naoPereciveis),
        by: names,
      );
    }
    if (!mounted) return;

    final dayNote = targetDay == today
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay)})';
    await WhatsAppService.sendWithConfirm(
      context,
      '📦 Lista Automática$dayNote · ${section.label}: $value\n'
      'Por: ${joinNames(names)}',
    );
    if (!mounted) return;
    setState(() => _ctrls[section]!.clear());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${section.label} guardado.')));
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
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Envia cada secção quando estiver feita.',
              style: TextStyle(fontSize: 12, color: context.muted),
            ),
          ),
          const SizedBox(height: 8),
          for (final s in ListSection.values)
            NumberRow(
              label: s.label,
              controller: _ctrls[s]!,
              onChanged: () => setState(() {}),
              trailing: IconButton(
                tooltip: 'Enviar ${s.label}',
                icon: const Icon(Icons.send),
                color: context.colors.primary,
                onPressed: _valueOf(s) == 0 ? null : () => _sendSection(s),
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
