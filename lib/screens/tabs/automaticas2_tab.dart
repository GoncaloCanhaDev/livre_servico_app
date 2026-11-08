import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/auto2_entry.dart';
import '../../models/opening_list.dart';
import '../../services/auto2_service.dart';
import '../../services/settings_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';
import '../widgets/person_picker.dart';

/// Listas 2.0 → Automáticas, like 1.0's: each item is sent on its own once
/// done (who did it, then WhatsApp), saved to Histórico, and its field
/// clears for the next one. The item is picked from chips, so its count is
/// typed without scrolling; every count not yet sent is kept as a draft
/// ([SettingsService.draft]) until it is.
class Automaticas2Tab extends StatefulWidget {
  const Automaticas2Tab({super.key});

  @override
  State<Automaticas2Tab> createState() => _Automaticas2TabState();
}

class _Automaticas2TabState extends State<Automaticas2Tab> {
  final _ctrls = {
    for (final i in Auto2Item.values)
      i: TextEditingController(text: SettingsService.instance.draft(_key(i))),
  };
  late Auto2Item _selected = Auto2Item.values.firstWhere(
    (i) => _ctrls[i]!.text.isNotEmpty,
    orElse: () => Auto2Item.values.first,
  );

  static String _key(Auto2Item i) => 'auto2:${i.name}';

  void _changed(Auto2Item i) {
    SettingsService.instance.setDraft(_key(i), _ctrls[i]!.text);
    setState(() {});
  }

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
    await SettingsService.instance.setDraft(_key(item), '');
    if (!mounted) return;
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
              'Escolhe a secção, conta e envia quando estiver feita. '
              'O número fica guardado até ser enviado.',
              style: TextStyle(fontSize: 12, color: context.muted),
            ),
          ),
          const SizedBox(height: 8),
          NumberRow(
            key: ValueKey(_selected),
            label: _selected.label,
            controller: _ctrls[_selected]!,
            onChanged: () => _changed(_selected),
            trailing: IconButton.filled(
              tooltip: 'Enviar ${_selected.label}',
              icon: const Icon(Icons.send),
              onPressed: _valueOf(_selected) == 0
                  ? null
                  : () => _send(_selected),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final i in Auto2Item.values)
                ChoiceChip(
                  label: Text(
                    _valueOf(i) == 0 ? i.label : '${i.label} · ${_valueOf(i)}',
                  ),
                  selected: i == _selected,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (_) => setState(() => _selected = i),
                ),
            ],
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
