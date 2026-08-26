import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/report_list.dart';
import '../../models/task_timer.dart';
import '../../services/report_list_service.dart';
import '../../services/task_notification_service.dart';
import '../../services/task_timer_service.dart';
import '../../services/whatsapp_service.dart';
import '../widgets/person_picker.dart';
import '../widgets/task_timer_control.dart';
import '../../theme.dart';
import '../widgets/number_row.dart';

class RelatorioTab extends StatefulWidget {
  const RelatorioTab({super.key});

  @override
  State<RelatorioTab> createState() => _RelatorioTabState();
}

class _RelatorioTabState extends State<RelatorioTab> {
  ReportList? _list;
  final _diasSemVendas = TextEditingController();
  final _regularizacoes = TextEditingController();
  final _massiva = TextEditingController();
  final _repetidos = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _diasSemVendas.dispose();
    _regularizacoes.dispose();
    _massiva.dispose();
    _repetidos.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await ReportListService.instance.currentOrCreate();
    if (!mounted) return;
    setState(() {
      _list = list;
      _diasSemVendas.text = list.diasSemVendas == 0
          ? ''
          : '${list.diasSemVendas}';
      _regularizacoes.text = list.regularizacoes == 0
          ? ''
          : '${list.regularizacoes}';
      _massiva.text = list.massiva == 0 ? '' : '${list.massiva}';
      _repetidos.text = list.repetidos == 0 ? '' : '${list.repetidos}';
    });
  }

  Future<void> _persistField() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    list.diasSemVendas = int.tryParse(_diasSemVendas.text) ?? 0;
    list.regularizacoes = int.tryParse(_regularizacoes.text) ?? 0;
    list.massiva = int.tryParse(_massiva.text) ?? 0;
    list.repetidos = int.tryParse(_repetidos.text) ?? 0;
    setState(() {});
    await ReportListService.instance.updateValues(
      list,
      diasSemVendas: list.diasSemVendas,
      regularizacoes: list.regularizacoes,
      massiva: list.massiva,
      repetidos: list.repetidos,
    );
  }

  Future<void> _finalize() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    final today = DateTime(
      list.serviceDay.year,
      list.serviceDay.month,
      list.serviceDay.day,
    );
    final result = await pickPeopleAndDay(
      context,
      title: 'Finalizar por quem?',
      subtitle: 'O relatório ficará bloqueado. Será criado um novo às 5h.',
      initialDay: today,
    );
    if (result == null) return;
    final names = result.people.map((p) => p.fullName).toList();
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    final dsv = list.diasSemVendas;
    final reg = list.regularizacoes;
    final mas = list.massiva;
    final rep = list.repetidos;

    await TaskTimerService.instance.finishOrCreateFinished(
      parentKind: TimerKind.report,
      parentUuid: list.syncUuid,
      taskKey: 'main',
    );

    if (targetDay == list.serviceDay) {
      list.createdByNames = names;
      await _persistField();
      await ReportListService.instance.finalize(list);
      await TaskNotificationService.instance.rescheduleAll();
    } else {
      await ReportListService.instance.backfillFinalized(
        serviceDay: targetDay,
        diasSemVendas: dsv,
        regularizacoes: reg,
        massiva: mas,
        repetidos: rep,
      );
      await ReportListService.instance.updateValues(
        list,
        diasSemVendas: 0,
        regularizacoes: 0,
        massiva: 0,
        repetidos: 0,
      );
      _diasSemVendas.clear();
      _regularizacoes.clear();
      _massiva.clear();
      _repetidos.clear();
    }

    if (mounted) {
      final dayNote = targetDay == list.serviceDay
          ? ''
          : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay)})';
      final msg =
          '📊 Relatório$dayNote\n'
          'Dias s/ vendas: $dsv\n'
          'Regularizações: $reg\n'
          'Massiva: $mas\n'
          'Repetidos: $rep\n'
          'Total: ${dsv + reg + mas + rep}\n'
          'Por: ${joinNames(names)}';
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
          Row(
            children: [
              Expanded(
                child: Text(
                  dayFmt.format(list.serviceDay),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TaskTimerControl(
                parentKind: TimerKind.report,
                parentUuid: list.syncUuid,
                taskKey: 'main',
                enabled: !locked,
              ),
            ],
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
                        'Finalizado às ${DateFormat('HH:mm').format(list.finalizedAt!)}.\nO próximo abre às 5h.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          NumberRow(
            label: 'Dias s/ vendas',
            controller: _diasSemVendas,
            enabled: !locked,
            onChanged: _persistField,
          ),
          NumberRow(
            label: 'Regularizações',
            controller: _regularizacoes,
            enabled: !locked,
            onChanged: _persistField,
          ),
          NumberRow(
            label: 'Massiva',
            controller: _massiva,
            enabled: !locked,
            onChanged: _persistField,
          ),
          NumberRow(
            label: 'Repetidos',
            controller: _repetidos,
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
