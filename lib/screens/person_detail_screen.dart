import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/daily_tasks.dart';
import '../models/person.dart';
import '../models/visual_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/inventory_service.dart';
import '../services/opening_list_service.dart';
import '../services/person_service.dart';
import '../services/report_list_service.dart';
import '../services/truck_service.dart';
import '../services/visual_list_service.dart';
import '../theme.dart';
import 'person_form_screen.dart';
import 'widgets/person_picker.dart';

class PersonDetailScreen extends StatefulWidget {
  const PersonDetailScreen({super.key, required this.person});

  final Person person;

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Person _person;
  late Future<Map<DateTime, List<_ActivityItem>>> _future;

  @override
  void initState() {
    super.initState();
    _person = widget.person;
    _future = _load();
    OpeningListService.instance.addListener(_reload);
    AutoListService.instance.addListener(_reload);
    ReportListService.instance.addListener(_reload);
    VisualListService.instance.addListener(_reload);
    DailyTasksService.instance.addListener(_reload);
    InventoryService.instance.addListener(_reload);
    TruckService.instance.addListener(_reload);
    PersonService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    OpeningListService.instance.removeListener(_reload);
    AutoListService.instance.removeListener(_reload);
    ReportListService.instance.removeListener(_reload);
    VisualListService.instance.removeListener(_reload);
    DailyTasksService.instance.removeListener(_reload);
    InventoryService.instance.removeListener(_reload);
    TruckService.instance.removeListener(_reload);
    PersonService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _load());
  }

  DateTime _toServiceDay(DateTime dt) {
    if (dt.hour < 5) {
      final y = dt.subtract(const Duration(days: 1));
      return DateTime(y.year, y.month, y.day, 5);
    }
    return DateTime(dt.year, dt.month, dt.day, 5);
  }

  Future<Map<DateTime, List<_ActivityItem>>> _load() async {
    final name = _person.fullName;
    final items = <_ActivityItem>[];

    final openings = await OpeningListService.instance.history();
    for (final o in openings) {
      if (!o.isFinalized) continue;
      if (!resolveNames(o.createdByNames, o.createdByInitials).contains(name)) {
        continue;
      }
      items.add(
        _ActivityItem(
          time: o.finalizedAt ?? o.serviceDay,
          icon: Icons.check_circle,
          iconColor: AppColors.green,
          title: 'Lista de Abertura',
          subtitle:
              'Cong: ${o.congelados} · OPLS: ${o.opls} · NP: ${o.naoPereciveis} · Total: ${o.total}',
        ),
      );
    }

    final autos = await AutoListService.instance.history();
    for (final a in autos) {
      if (!resolveNames(a.createdByNames, a.createdByInitials).contains(name)) {
        continue;
      }
      items.add(
        _ActivityItem(
          time: a.createdAt,
          icon: Icons.bolt,
          iconColor: AppColors.green,
          title: 'Lista Automática',
          subtitle:
              'Cong: ${a.congelados} · OPLS: ${a.opls} · NP: ${a.naoPereciveis} · Total: ${a.total}',
        ),
      );
    }

    final reports = await ReportListService.instance.history();
    for (final r in reports) {
      if (!r.isFinalized) continue;
      if (!resolveNames(r.createdByNames, r.createdByInitials).contains(name)) {
        continue;
      }
      items.add(
        _ActivityItem(
          time: r.finalizedAt ?? r.serviceDay,
          icon: Icons.check_circle,
          iconColor: AppColors.green,
          title: 'Relatório',
          subtitle:
              'DSV: ${r.diasSemVendas} · Reg: ${r.regularizacoes} · Mas: ${r.massiva} · Rep: ${r.repetidos} · Total: ${r.total}',
        ),
      );
    }

    final visuals = await VisualListService.instance.all();
    for (final v in visuals) {
      if (!resolveNames(v.createdByNames, v.createdByInitials).contains(name)) {
        continue;
      }
      final total = v.beneficioCents - v.quebraCents;
      items.add(
        _ActivityItem(
          time: v.createdAt,
          icon: Icons.visibility,
          iconColor: AppColors.green,
          title: 'Lista Visual',
          subtitle: '${v.itensPicados} itens · Total ${formatCents(total)} €',
        ),
      );
    }

    final invs = await InventoryService.instance.history();
    for (final inv in invs) {
      if (!resolveNames(
        inv.createdByNames,
        inv.createdByInitials,
      ).contains(name)) {
        continue;
      }
      items.add(
        _ActivityItem(
          time: inv.createdAt,
          icon: Icons.assignment,
          iconColor: inv.valueCents >= 0 ? AppColors.green : Colors.redAccent,
          title: 'Inventário: ${inv.name}',
          subtitle: '${formatCents(inv.valueCents)} €',
        ),
      );
    }

    final trucks = await TruckService.instance.all();
    for (final t in trucks) {
      if (!resolveNames(t.createdByNames, t.createdByInitials).contains(name)) {
        continue;
      }
      final parts = <String>[
        if (t.licensePlate != null) t.licensePlate!,
        if (t.supplier != null) t.supplier!,
      ];
      items.add(
        _ActivityItem(
          time: t.arrivalTime,
          icon: Icons.local_shipping,
          iconColor: AppColors.green,
          title: 'Camião',
          subtitle:
              '${parts.isNotEmpty ? '${parts.join(' · ')} · ' : ''}${t.totalPallets} paletes',
        ),
      );
    }

    final tasks = await DailyTasksService.instance.history();
    for (final t in tasks) {
      final done = _tasksDoneByPerson(t, name);
      for (final entry in done) {
        items.add(
          _ActivityItem(
            time: t.lastUpdatedAt ?? t.serviceDay,
            icon: Icons.task_alt,
            iconColor: AppColors.green,
            title: 'Tarefa: ${entry.label}',
            subtitle: DateFormat(
              "EEE, d 'de' MMM y",
              'pt_PT',
            ).format(t.serviceDay),
          ),
        );
      }
    }

    for (var i = 0; i < _person.pointHistory.length; i++) {
      final ev = _person.pointHistory[i];
      final sign = ev.delta > 0 ? '+' : '';
      items.add(
        _ActivityItem(
          time: ev.at,
          icon: Icons.stars,
          iconColor: ev.delta >= 0 ? AppColors.greenDark : Colors.redAccent,
          title: '$sign${ev.delta} ponto${ev.delta.abs() == 1 ? '' : 's'}',
          subtitle: ev.reason ?? 'Sem motivo indicado',
          pointIndex: i,
        ),
      );
    }

    final grouped = <DateTime, List<_ActivityItem>>{};
    for (final item in items) {
      final day = _toServiceDay(item.time);
      (grouped[day] ??= []).add(item);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <DateTime, List<_ActivityItem>>{};
    for (final key in sortedKeys) {
      grouped[key]!.sort((a, b) => b.time.compareTo(a.time));
      result[key] = grouped[key]!;
    }
    return result;
  }

  List<({String label})> _tasksDoneByPerson(DailyTasks t, String name) {
    final out = <({String label})>[];
    if (t.kiwiAbertura &&
        resolveNames(t.kiwiAberturaByNames, t.kiwiAberturaBy).contains(name)) {
      out.add((label: 'Kiwi Abertura'));
    }
    if (t.alteracoesPreco &&
        resolveNames(
          t.alteracoesPrecoByNames,
          t.alteracoesPrecoBy,
        ).contains(name)) {
      out.add((label: 'Alterações de Preço'));
    }
    if (t.verificacaoTemperaturas &&
        resolveNames(
          t.verificacaoTemperaturasByNames,
          t.verificacaoTemperaturasBy,
        ).contains(name)) {
      out.add((label: 'Verificação de Temperaturas'));
    }
    if (t.preenchimentoQuadro &&
        resolveNames(
          t.preenchimentoQuadroByNames,
          t.preenchimentoQuadroBy,
        ).contains(name)) {
      out.add((label: 'Preenchimento do Quadro'));
    }
    if (t.verificacaoValidades &&
        resolveNames(
          t.verificacaoValidadesByNames,
          t.verificacaoValidadesBy,
        ).contains(name)) {
      out.add((label: 'Verificação de Validades'));
    }
    if (t.kiwiFecho &&
        resolveNames(t.kiwiFechoByNames, t.kiwiFechoBy).contains(name)) {
      out.add((label: 'Kiwi Fecho'));
    }
    return out;
  }

  Future<void> _adjustPoints(int delta, String reason) async {
    final updated = await PersonService.instance.adjustPoints(
      _person.id,
      delta,
      reason: reason,
    );
    if (updated != null && mounted) {
      setState(() => _person = updated);
    }
  }

  Future<void> _openAdjustDialog() async {
    final result = await showDialog<_PointsAdjustResult>(
      context: context,
      builder: (_) => const _PointsAdjustDialog(),
    );
    if (result != null && result.delta != 0) {
      await _adjustPoints(result.delta, result.reason);
    }
  }

  Future<void> _openEditPointEntry(int index) async {
    final event = _person.pointHistory[index];
    final result = await showDialog<_PointsAdjustResult>(
      context: context,
      builder: (_) => _PointsAdjustDialog(
        title: 'Editar registo de pontos',
        initialAmount: event.delta.abs(),
        initialAdd: event.delta >= 0,
        initialReason: event.reason,
      ),
    );
    if (result == null || result.delta == 0) return;
    final updated = await PersonService.instance.editPointEvent(
      _person.id,
      index,
      delta: result.delta,
      reason: result.reason,
    );
    if (updated != null && mounted) {
      setState(() => _person = updated);
    }
  }

  Future<void> _removePointEntry(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover registo'),
        content: const Text(
          'Tens a certeza que queres remover este registo de pontos? '
          'A pontuação total é recalculada. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final updated = await PersonService.instance.removePointEvent(
      _person.id,
      index,
    );
    if (updated != null && mounted) {
      setState(() => _person = updated);
    }
  }

  Future<void> _openPointEntryActions(int index) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remover'),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (action == 'edit') {
      await _openEditPointEntry(index);
    } else if (action == 'remove') {
      await _removePointEntry(index);
    }
  }

  Future<void> _confirmResetPoints() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar pontos'),
        content: Text(
          'Tens a certeza que queres apagar todos os pontos de "${_person.fullName}"? '
          'O histórico de pontos também é removido. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final updated = await PersonService.instance.resetPoints(_person.id);
    if (updated != null && mounted) {
      setState(() => _person = updated);
    }
  }

  Future<void> _openEditForm() async {
    final result = await Navigator.of(context).push<Person>(
      MaterialPageRoute(builder: (_) => PersonFormScreen(existing: _person)),
    );
    if (result != null && mounted) {
      setState(() => _person = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat("EEEE, d 'de' MMMM y", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text(_person.fullName),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _openEditForm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _person.photoPath != null &&
                          File(_person.photoPath!).existsSync()
                      ? CircleAvatar(
                          radius: 24,
                          backgroundImage: FileImage(File(_person.photoPath!)),
                        )
                      : PersonInitialsBadge(name: _person.fullName, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _person.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_person.role != null ||
                            _person.collaboratorNumber.isNotEmpty)
                          Text(
                            [
                              if (_person.role != null) _person.role!,
                              if (_person.collaboratorNumber.isNotEmpty)
                                'Nº colaborador: ${_person.collaboratorNumber}',
                            ].join(' · '),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        if (_person.phoneNumber != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: InkWell(
                              onTap: () => launchUrl(
                                Uri(scheme: 'tel', path: _person.phoneNumber),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: AppColors.greenDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _person.phoneNumber!,
                                    style: const TextStyle(
                                      color: AppColors.greenDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_person.dateOfBirth != null ||
                            _person.hireDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              [
                                if (_person.dateOfBirth != null)
                                  'Nasc.: ${DateFormat("d/MM/y").format(_person.dateOfBirth!)}',
                                if (_person.hireDate != null)
                                  'Início: ${DateFormat("d/MM/y").format(_person.hireDate!)}',
                              ].join('  ·  '),
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.greenDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pontos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '${_person.points}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.greenDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ajustar',
                      onPressed: _openAdjustDialog,
                      icon: const Icon(Icons.tune),
                    ),
                    IconButton(
                      tooltip: 'Apagar pontos',
                      onPressed: _confirmResetPoints,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<Map<DateTime, List<_ActivityItem>>>(
                future: _future,
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final grouped = snap.data!;
                  if (grouped.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Sem atividade registada.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }
                  final days = grouped.keys.toList();
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: days.length,
                    itemBuilder: (_, i) {
                      final day = days[i];
                      final items = grouped[day]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (i > 0) const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              dayFmt.format(day),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.greenDark,
                              ),
                            ),
                          ),
                          ...items.map(
                            (item) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  item.icon,
                                  color: item.iconColor,
                                  size: 24,
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  item.subtitle,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  timeFmt.format(item.time),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                                onTap: item.pointIndex != null
                                    ? () => _openPointEntryActions(
                                        item.pointIndex!,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  _ActivityItem({
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.pointIndex,
  });
  final DateTime time;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  /// Index into `Person.pointHistory`, set only for point-event items —
  /// used to look the entry up again for edit/remove. Null for every other
  /// activity type, which stays non-interactive.
  final int? pointIndex;
}

class _PointsAdjustResult {
  const _PointsAdjustResult({required this.delta, required this.reason});
  final int delta;
  final String reason;
}

class _PointsAdjustDialog extends StatefulWidget {
  const _PointsAdjustDialog({
    this.title = 'Ajustar pontos',
    this.initialAmount,
    this.initialAdd = true,
    this.initialReason,
  });

  final String title;
  final int? initialAmount;
  final bool initialAdd;
  final String? initialReason;

  @override
  State<_PointsAdjustDialog> createState() => _PointsAdjustDialogState();
}

class _PointsAdjustDialogState extends State<_PointsAdjustDialog> {
  late final TextEditingController _ctrl = TextEditingController(
    text: '${widget.initialAmount ?? 5}',
  );
  late final TextEditingController _reasonCtrl = TextEditingController(
    text: widget.initialReason ?? '',
  );
  late bool _add = widget.initialAdd;
  String? _reasonError;

  @override
  void dispose() {
    _ctrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_ctrl.text.trim());
    if (n == null || n <= 0) {
      Navigator.of(context).pop();
      return;
    }
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      setState(() => _reasonError = 'Indica um motivo');
      return;
    }
    Navigator.of(
      context,
    ).pop(_PointsAdjustResult(delta: _add ? n : -n, reason: reason));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Adicionar'),
                icon: Icon(Icons.add),
              ),
              ButtonSegment(
                value: false,
                label: Text('Remover'),
                icon: Icon(Icons.remove),
              ),
            ],
            selected: {_add},
            onSelectionChanged: (s) => setState(() => _add = s.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            decoration: InputDecoration(
              labelText: 'Motivo',
              border: const OutlineInputBorder(),
              errorText: _reasonError,
            ),
            onChanged: (_) {
              if (_reasonError != null) setState(() => _reasonError = null);
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Aplicar')),
      ],
    );
  }
}
