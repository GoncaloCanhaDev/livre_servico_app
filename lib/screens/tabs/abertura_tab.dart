import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/opening_list.dart';
import '../../services/opening_list_service.dart';
import '../../services/whatsapp_service.dart';
import '../widgets/person_picker.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';

/// Today's opening list. Each section is sent on its own (who did it, plus a
/// WhatsApp message); the list finalizes itself once all three are sent.
class AberturaTab extends StatefulWidget {
  const AberturaTab({super.key});

  @override
  State<AberturaTab> createState() => _AberturaTabState();
}

class _AberturaTabState extends State<AberturaTab> {
  OpeningList? _list;
  final _ctrls = {
    for (final s in ListSection.values) s: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final list = await OpeningListService.instance.currentOrCreate();
    if (!mounted) return;
    setState(() {
      _list = list;
      for (final s in ListSection.values) {
        final v = list.valueOf(s);
        _ctrls[s]!.text = v == 0 ? '' : '$v';
      }
    });
  }

  Future<void> _persistField() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    for (final s in ListSection.values) {
      if (!list.isSectionDone(s)) {
        list.setValue(s, int.tryParse(_ctrls[s]!.text) ?? 0);
      }
    }
    setState(() {});
    await OpeningListService.instance.updateValues(
      list,
      congelados: list.congelados,
      opls: list.opls,
      naoPereciveis: list.naoPereciveis,
    );
  }

  Future<void> _sendSection(ListSection section) async {
    final list = _list;
    if (list == null || list.isSectionDone(section)) return;
    await _persistField();
    if (!mounted) return;
    final value = list.valueOf(section);
    final today = DateTime(
      list.serviceDay.year,
      list.serviceDay.month,
      list.serviceDay.day,
    );
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem fez ${section.label}?',
      subtitle: 'Lista de Abertura · ${section.label}: $value',
      initialDay: today,
    );
    if (result == null || !mounted) return;
    final names = result.people.map((p) => p.fullName).toList();
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );

    final OpeningList target;
    if (targetDay == list.serviceDay) {
      await OpeningListService.instance.finishSection(list, section, names);
      target = list;
    } else {
      final other = await OpeningListService.instance.finishSectionOnDay(
        serviceDay: targetDay,
        section: section,
        value: value,
        names: names,
      );
      if (!mounted) return;
      if (other == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${section.label} já estava registado nesse dia.'),
          ),
        );
        return;
      }
      target = other;
      _ctrls[section]!.clear();
      await _persistField();
    }
    if (!mounted) return;

    final dayNote = targetDay == list.serviceDay
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay)})';
    final msg = StringBuffer(
      '📋 Lista de Abertura$dayNote · ${section.label}: $value\n'
      'Por: ${joinNames(names)}',
    );
    // The section wasn't done there before, so a finalized list means this
    // send completed it.
    if (target.isFinalized) {
      msg.write('\n✅ Lista de Abertura completa · Total: ${target.total}');
    }
    await WhatsAppService.sendWithConfirm(context, msg.toString());
    if (mounted) _load();
  }

  Widget _sectionAction(OpeningList list, ListSection s) {
    if (list.isSectionDone(s)) {
      return SizedBox(
        width: 48,
        child: Icon(Icons.check_circle, color: context.colors.primary),
      );
    }
    return IconButton(
      tooltip: 'Enviar ${s.label}',
      icon: Icon(Icons.send, color: context.colors.primary),
      onPressed: () => _sendSection(s),
    );
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (locked)
            Card(
              color: context.tint(Colors.grey, 200),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: context.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Finalizada às ${DateFormat('HH:mm').format(list.finalizedAt!)}.\nA próxima abre às 5h.',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Envia cada secção quando estiver feita. A lista fica '
                'concluída quando as três estiverem enviadas.',
                style: TextStyle(fontSize: 12, color: context.muted),
              ),
            ),
          const SizedBox(height: 8),
          for (final s in ListSection.values)
            NumberRow(
              label: s.label,
              subtitle: switch (list.namesOf(s)) {
                [] => null,
                final names => 'Por ${joinNames(names)}',
              },
              controller: _ctrls[s]!,
              enabled: !list.isSectionDone(s),
              onChanged: _persistField,
              trailing: _sectionAction(list, s),
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
                    '${list.total}',
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
