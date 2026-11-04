import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/auto2_entry.dart';
import '../../models/opening_list.dart';
import '../../services/auto2_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';
import '../widgets/person_picker.dart';

/// Listas 2.0 → Automáticas: each item gets its number and is ticked once
/// done, by whoever did it; the tick is saved for the service day and
/// offers a WhatsApp message.
class Automaticas2Tab extends StatefulWidget {
  const Automaticas2Tab({super.key});

  @override
  State<Automaticas2Tab> createState() => _Automaticas2TabState();
}

class _Automaticas2TabState extends State<Automaticas2Tab> {
  final _ctrls = {for (final i in Auto2Item.values) i: TextEditingController()};
  Map<Auto2Item, Auto2Entry> _entries = {};

  @override
  void initState() {
    super.initState();
    Auto2Service.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    Auto2Service.instance.removeListener(_load);
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await Auto2Service.instance.forDay(currentServiceDay());
    if (!mounted) return;
    setState(() {
      for (final i in Auto2Item.values) {
        final was = _entries[i]?.isDone ?? false;
        final e = entries[i];
        if (e != null && e.isDone) {
          _ctrls[i]!.text = '${e.value}';
        } else if (was) {
          _ctrls[i]!.clear();
        }
      }
      _entries = entries;
    });
  }

  bool _isDone(Auto2Item i) => _entries[i]?.isDone ?? false;

  int _valueOf(Auto2Item i) => int.tryParse(_ctrls[i]!.text) ?? 0;

  int get _total => Auto2Item.values.fold(0, (sum, i) => sum + _valueOf(i));

  int get _doneCount => Auto2Item.values.where(_isDone).length;

  Future<void> _complete(Auto2Item item) async {
    final value = _valueOf(item);
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
    final saved = await Auto2Service.instance.complete(
      serviceDay: day,
      item: item,
      value: value,
      names: names,
      backdated: !isToday,
    );
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.label} já estava feita nesse dia.')),
      );
      return;
    }
    // Ticked for an earlier day: today's field starts over.
    if (!isToday) setState(() => _ctrls[item]!.clear());

    final dayNote = isToday
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(day)})';
    await WhatsAppService.sendWithConfirm(
      context,
      '📦 Automáticas$dayNote · ${item.label}: $value\n'
      'Por: ${joinNames(names)}',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.label} feita.')));
  }

  Future<void> _undo(Auto2Item item) async {
    final entry = _entries[item];
    if (entry == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Desmarcar ${item.label}?'),
        content: const Text('O número e quem a fez deixam de ficar guardados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desmarcar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await Auto2Service.instance.undo(entry);
  }

  String? _subtitleOf(Auto2Item item) {
    final e = _entries[item];
    if (e == null || !e.isDone) return null;
    final at = DateFormat('HH:mm').format(e.doneAt!);
    return e.byNames.isEmpty
        ? 'Feita às $at'
        : 'Por ${joinNames(e.byNames)} · $at';
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
                  'Automáticas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$_doneCount/${Auto2Item.values.length} feitas',
                style: TextStyle(fontSize: 13, color: context.muted),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Marca cada item quando estiver feito.',
              style: TextStyle(fontSize: 12, color: context.muted),
            ),
          ),
          const SizedBox(height: 8),
          for (final i in Auto2Item.values)
            NumberRow(
              label: i.label,
              controller: _ctrls[i]!,
              enabled: !_isDone(i),
              subtitle: _subtitleOf(i),
              onChanged: () => setState(() {}),
              trailing: _isDone(i)
                  ? IconButton(
                      tooltip: 'Desmarcar ${i.label}',
                      icon: const Icon(Icons.check_circle),
                      color: context.colors.primary,
                      onPressed: () => _undo(i),
                    )
                  : IconButton(
                      tooltip: 'Marcar ${i.label} como feita',
                      icon: const Icon(Icons.radio_button_unchecked),
                      color: context.muted,
                      onPressed: () => _complete(i),
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
