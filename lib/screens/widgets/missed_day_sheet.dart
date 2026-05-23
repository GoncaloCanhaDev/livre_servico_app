import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/daily_tasks.dart';
import '../../models/justification.dart';
import '../../services/auto_list_service.dart';
import '../../services/daily_tasks_service.dart';
import '../../services/justification_service.dart';
import '../../services/opening_list_service.dart';
import '../../services/report_list_service.dart';
import '../../services/visual_list_service.dart';
import '../../theme.dart';

Future<bool?> showMissedDaySheet({
  required BuildContext context,
  required DateTime day,
  required String kind,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _MissedDaySheet(day: day, kind: kind),
  );
}

class _MissedDaySheet extends StatefulWidget {
  const _MissedDaySheet({required this.day, required this.kind});
  final DateTime day;
  final String kind;

  @override
  State<_MissedDaySheet> createState() => _MissedDaySheetState();
}

class _MissedDaySheetState extends State<_MissedDaySheet> {
  bool _saving = false;
  Justification? _existingJust;
  String? _justInitialReason;

  @override
  void initState() {
    super.initState();
    _loadJust();
  }

  Future<void> _loadJust() async {
    final j = await JustificationService.instance.find(widget.day, widget.kind);
    if (!mounted) return;
    setState(() {
      _existingJust = j;
      _justInitialReason = j?.reason;
    });
  }

  String get _kindLabel => switch (widget.kind) {
        JustificationKind.opening => 'Lista de abertura',
        JustificationKind.report => 'Relatório',
        JustificationKind.auto => 'Lista automática',
        JustificationKind.visual => 'Visual',
        JustificationKind.tasks => 'Tarefas diárias',
        _ => widget.kind,
      };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("EEEE, d 'de' MMMM y", 'pt_PT');
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_kindLabel,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              Text(fmt.format(widget.day),
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              if (_existingJust != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Já justificado',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(_existingJust!.reason,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: _existingJust == null,
                title: const Text('Marcar como feito',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                children: [_buildMarkDoneForm()],
              ),
              const Divider(),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                    _existingJust == null ? 'Justificar' : 'Editar justificação',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                children: [
                  _JustifyForm(
                    initial: _justInitialReason ?? '',
                    onSubmit: _saveJustification,
                    onDelete: _existingJust == null ? null : _deleteJustification,
                    saving: _saving,
                  ),
                ],
              ),
              if (_saving)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkDoneForm() {
    switch (widget.kind) {
      case JustificationKind.opening:
        return _ThreeNumberForm(
          labels: const ['Congelados', 'OPLs', 'Não perecíveis'],
          onSubmit: (values) async {
            await OpeningListService.instance.backfillFinalized(
              serviceDay: widget.day,
              congelados: values[0],
              opls: values[1],
              naoPereciveis: values[2],
            );
          },
          finish: _afterMarkDone,
        );
      case JustificationKind.report:
        return _NumberForm(
          labels: const [
            'Dias sem vendas',
            'Regularizações',
            'Massiva',
            'Repetidos',
          ],
          onSubmit: (values) async {
            await ReportListService.instance.backfillFinalized(
              serviceDay: widget.day,
              diasSemVendas: values[0],
              regularizacoes: values[1],
              massiva: values[2],
              repetidos: values[3],
            );
          },
          finish: _afterMarkDone,
        );
      case JustificationKind.auto:
        return _ThreeNumberForm(
          labels: const ['Congelados', 'OPLs', 'Não perecíveis'],
          onSubmit: (values) async {
            await AutoListService.instance.addForDay(
              serviceDay: widget.day,
              congelados: values[0],
              opls: values[1],
              naoPereciveis: values[2],
            );
          },
          finish: _afterMarkDone,
        );
      case JustificationKind.visual:
        return _NumberForm(
          labels: const ['Itens picados', 'Quebra (€)', 'Benefício (€)'],
          isEuro: const [false, true, true],
          onSubmit: (values) async {
            await VisualListService.instance.addForDay(
              serviceDay: widget.day,
              itensPicados: values[0],
              quebraCents: values[1],
              beneficioCents: values[2],
            );
          },
          finish: _afterMarkDone,
        );
      case JustificationKind.tasks:
        return _TasksForm(day: widget.day, finish: _afterMarkDone);
    }
    return const SizedBox.shrink();
  }

  Future<void> _saveJustification(String reason) async {
    if (reason.trim().isEmpty) return;
    setState(() => _saving = true);
    await JustificationService.instance.upsert(
      serviceDay: widget.day,
      kind: widget.kind,
      reason: reason.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteJustification() async {
    setState(() => _saving = true);
    await JustificationService.instance.remove(widget.day, widget.kind);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _afterMarkDone() {
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}

class _NumberForm extends StatefulWidget {
  const _NumberForm({
    required this.labels,
    required this.onSubmit,
    required this.finish,
    this.isEuro = const [],
  });
  final List<String> labels;
  final List<bool> isEuro;
  final Future<void> Function(List<int>) onSubmit;
  final VoidCallback finish;

  @override
  State<_NumberForm> createState() => _NumberFormState();
}

class _NumberFormState extends State<_NumberForm> {
  late final List<TextEditingController> _ctrls;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(widget.labels.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final values = <int>[];
      for (var i = 0; i < _ctrls.length; i++) {
        final isEuro = i < widget.isEuro.length && widget.isEuro[i];
        final raw = _ctrls[i].text.replaceAll(',', '.').trim();
        if (raw.isEmpty) {
          values.add(0);
          continue;
        }
        if (isEuro) {
          values.add(((double.tryParse(raw) ?? 0) * 100).round());
        } else {
          values.add(int.tryParse(raw) ?? 0);
        }
      }
      await widget.onSubmit(values);
      widget.finish();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _ctrls[i],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
                ],
                decoration: InputDecoration(
                  labelText: widget.labels[i],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          FilledButton(
            onPressed: _saving ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            child: Text(_saving ? 'A guardar…' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}

class _ThreeNumberForm extends _NumberForm {
  const _ThreeNumberForm({
    required super.labels,
    required super.onSubmit,
    required super.finish,
  });
}

class _TasksForm extends StatefulWidget {
  const _TasksForm({required this.day, required this.finish});
  final DateTime day;
  final VoidCallback finish;

  @override
  State<_TasksForm> createState() => _TasksFormState();
}

class _TasksFormState extends State<_TasksForm> {
  DailyTasks? _tasks;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await DailyTasksService.instance.forDay(widget.day);
    if (!mounted) return;
    setState(() {
      _tasks = t;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_tasks == null) return;
    setState(() => _saving = true);
    await DailyTasksService.instance.save(_tasks!);
    widget.finish();
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final t = _tasks!;
    final isSaturday = widget.day.weekday == DateTime.saturday;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _check('Kiwi abertura', t.kiwiAbertura,
              (v) => setState(() => t.kiwiAbertura = v)),
          _check('Alterações de preço', t.alteracoesPreco,
              (v) => setState(() => t.alteracoesPreco = v)),
          _check('Verificação temperaturas', t.verificacaoTemperaturas,
              (v) => setState(() => t.verificacaoTemperaturas = v)),
          _check('Preenchimento quadro', t.preenchimentoQuadro,
              (v) => setState(() => t.preenchimentoQuadro = v)),
          _check('Verificação validades', t.verificacaoValidades,
              (v) => setState(() => t.verificacaoValidades = v)),
          _check('Kiwi fecho', t.kiwiFecho,
              (v) => setState(() => t.kiwiFecho = v)),
          if (isSaturday)
            _check('Limpeza máquina voltas', t.limpezaMaquinaVoltas,
                (v) => setState(() => t.limpezaMaquinaVoltas = v)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            child: Text(_saving ? 'A guardar…' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}

class _JustifyForm extends StatefulWidget {
  const _JustifyForm({
    required this.initial,
    required this.onSubmit,
    required this.saving,
    this.onDelete,
  });
  final String initial;
  final bool saving;
  final Future<void> Function(String) onSubmit;
  final Future<void> Function()? onDelete;

  @override
  State<_JustifyForm> createState() => _JustifyFormState();
}

class _JustifyFormState extends State<_JustifyForm> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _ctrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Razão pela qual não foi feito…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: widget.saving
                      ? null
                      : () => widget.onSubmit(_ctrl.text),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.green),
                  child: const Text('Guardar justificação'),
                ),
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: widget.saving ? null : widget.onDelete,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: const Text('Remover'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
