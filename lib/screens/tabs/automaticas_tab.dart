import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/opening_list.dart';
import '../../models/task_timer.dart';
import '../../services/auto_list_service.dart';
import '../../services/task_notification_service.dart';
import '../../services/task_timer_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';
import '../widgets/person_picker.dart';
import '../widgets/task_timer_control.dart';

class AutomaticasTab extends StatefulWidget {
  const AutomaticasTab({super.key});

  @override
  State<AutomaticasTab> createState() => _AutomaticasTabState();
}

class _AutomaticasTabState extends State<AutomaticasTab> {
  final _congelados = TextEditingController();
  final _opls = TextEditingController();
  final _naoPereciveis = TextEditingController();
  String _draftUuid = const Uuid().v4();

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
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem fez esta lista?',
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
    await TaskTimerService.instance.finishOrCreateFinished(
      parentKind: TimerKind.auto,
      parentUuid: _draftUuid,
      taskKey: 'main',
    );
    if (targetDay == today) {
      await AutoListService.instance.add(
        syncUuid: _draftUuid,
        congelados: c,
        opls: o,
        naoPereciveis: n,
        by: names,
      );
      await TaskNotificationService.instance.rescheduleAll();
    } else {
      await AutoListService.instance.addForDay(
        serviceDay: targetDay,
        congelados: c,
        opls: o,
        naoPereciveis: n,
        by: names,
      );
    }
    if (!mounted) return;

    final total = c + o + n;
    final dayNote = targetDay == today
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay)})';
    final msg =
        '📦 Lista Automática$dayNote\n'
        'Congelados: $c\n'
        'OPLS: $o\n'
        'Não Perecíveis: $n\n'
        'Total: $total\n'
        'Por: ${joinNames(names)}';
    await WhatsAppService.sendWithConfirm(context, msg);
    if (!mounted) return;

    setState(() {
      _congelados.clear();
      _opls.clear();
      _naoPereciveis.clear();
      _draftUuid = const Uuid().v4();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Lista guardada.')));
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
                  'Nova lista automática',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              TaskTimerControl(
                key: ValueKey(_draftUuid),
                parentKind: TimerKind.auto,
                parentUuid: _draftUuid,
                taskKey: 'main',
              ),
            ],
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
