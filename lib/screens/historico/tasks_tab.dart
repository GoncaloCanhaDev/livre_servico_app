part of '../historico_screen.dart';

class _TasksTab extends StatefulWidget {
  const _TasksTab();
  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<_TasksRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    DailyTasksService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    DailyTasksService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<List<_TasksRow>> _load() async {
    final all = await DailyTasksService.instance.history(includeDeleted: true);
    final lists = await _ListsByDay.load();
    final rows = <_TasksRow>[];
    for (final t in all) {
      final day = t.serviceDay;
      final openingEntries = lists.openings(day);
      final aberturaDone = openingEntries.any((o) => o.isFinalized);
      final aberturaBackdated = openingEntries.any(
        (o) => o.isFinalized && o.backdated,
      );
      final reportEntries = lists.reports(day);
      final relatorioDone = reportEntries.any((r) => r.isFinalized);
      final relatorioBackdated = reportEntries.any(
        (r) => r.isFinalized && r.backdated,
      );
      final visualEntries = lists.visuals(day);
      final visualItens = visualEntries.fold<int>(
        0,
        (s, e) => s + e.itensPicados,
      );
      final visualDone = visualItens >= SettingsService.instance.visualGoal;
      final visualBackdated = visualEntries.any((e) => e.backdated);
      final autoEntries = lists.autos(day);
      final autoDone = autoEntries.isNotEmpty;
      final autoBackdated = autoEntries.any((e) => e.backdated);
      rows.add(
        _TasksRow(
          tasks: t,
          aberturaDone: aberturaDone,
          aberturaBackdated: aberturaBackdated,
          relatorioDone: relatorioDone,
          relatorioBackdated: relatorioBackdated,
          visualDone: visualDone,
          visualItens: visualItens,
          visualBackdated: visualBackdated,
          autoDone: autoDone,
          autoCount: autoEntries.length,
          autoBackdated: autoBackdated,
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final dayFmt = DateFormat("EEEE, d 'de' MMM y", 'pt_PT');
    return FutureBuilder<List<_TasksRow>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = _searched(
          query,
          snap.data!,
          (r) => dailyTasksSearchText(r.tasks),
        );
        if (items.isEmpty) return _emptyOr(query, 'Sem registos de tarefas.');
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (_, i) {
            final r = items[i];
            final t = r.tasks;

            final allTasks = <_TaskEntry>[
              _TaskEntry(
                'Kiwi Abertura',
                t.kiwiAbertura,
                byNames: resolveNames(t.kiwiAberturaByNames, t.kiwiAberturaBy),
                backdated: t.backdatedTaskKeys.contains('kiwi_abertura'),
              ),
              _TaskEntry(
                'Alterações de Preço (${t.alteracoesPrecoCount})',
                t.alteracoesPreco,
                byNames: resolveNames(
                  t.alteracoesPrecoByNames,
                  t.alteracoesPrecoBy,
                ),
                backdated: t.backdatedTaskKeys.contains('alteracoes_preco'),
              ),
              _TaskEntry(
                'Verificação de Temperaturas',
                t.verificacaoTemperaturas,
                byNames: resolveNames(
                  t.verificacaoTemperaturasByNames,
                  t.verificacaoTemperaturasBy,
                ),
                backdated: t.backdatedTaskKeys.contains(
                  'verificacao_temperaturas',
                ),
              ),
              _TaskEntry(
                'Lista de Abertura',
                r.aberturaDone,
                backdated: r.aberturaBackdated,
              ),
              _TaskEntry(
                'Relatório das Listas',
                r.relatorioDone,
                backdated: r.relatorioBackdated,
              ),
              _TaskEntry(
                'Preenchimento do Quadro',
                t.preenchimentoQuadro,
                byNames: resolveNames(
                  t.preenchimentoQuadroByNames,
                  t.preenchimentoQuadroBy,
                ),
                backdated: t.backdatedTaskKeys.contains('preenchimento_quadro'),
              ),
              _TaskEntry(
                'Lista Visual (${r.visualItens}/${SettingsService.instance.visualGoal})',
                r.visualDone,
                backdated: r.visualBackdated,
              ),
              _TaskEntry(
                'Lista Automática (${r.autoCount})',
                r.autoDone,
                backdated: r.autoBackdated,
              ),
              _TaskEntry(
                '${ValidadesTurno.manha.label} (${t.verificacaoValidadesCount})',
                t.verificacaoValidades,
                byNames: resolveNames(
                  t.verificacaoValidadesByNames,
                  t.verificacaoValidadesBy,
                ),
                backdated: t.backdatedTaskKeys.contains(
                  'verificacao_validades',
                ),
              ),
              _TaskEntry(
                '${ValidadesTurno.noite.label} (${t.validadesNoiteCount})',
                t.validadesNoite,
                byNames: t.validadesNoiteByNames,
                backdated: t.backdatedTaskKeys.contains('validades_noite'),
              ),
              _TaskEntry(
                'Kiwi Fecho',
                t.kiwiFecho,
                byNames: resolveNames(t.kiwiFechoByNames, t.kiwiFechoBy),
                backdated: t.backdatedTaskKeys.contains('kiwi_fecho'),
              ),
            ];
            final totalTasks = allTasks.length;
            final doneCount = allTasks.where((e) => e.done).length;

            return _dimmedIfDeleted(
              deleted: t.syncDeletedAt != null,
              child: _HistoryDismissible(
                itemKey: ValueKey(t.id),
                deletePromptName: 'registo de tarefas',
                onDelete: () async {
                  await DailyTasksService.instance.delete(t.id);
                },
                onSendWhatsApp: (ctx) async {
                  String s(bool done, String label) =>
                      '${done ? '✅' : '❌'} $label';
                  final lines = allTasks
                      .map((e) => s(e.done, e.label))
                      .join('\n');
                  final msg =
                      '📋 Tarefas (${dayFmt.format(t.serviceDay)})\n'
                      '$lines\n'
                      'Total: $doneCount/$totalTasks';
                  await WhatsAppService.sendWithConfirm(ctx, msg);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      dayFmt.format(t.serviceDay),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('$doneCount/$totalTasks tarefas concluídas'),
                    trailing: Icon(
                      doneCount == totalTasks
                          ? Icons.check_circle
                          : Icons.pending,
                      color: doneCount == totalTasks
                          ? context.colors.primary
                          : context.faint,
                    ),
                    children: allTasks
                        .map(
                          (e) => _taskTile(
                            context,
                            e.label,
                            e.done,
                            byNames: e.byNames,
                            backdated: e.backdated,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TaskEntry {
  const _TaskEntry(
    this.label,
    this.done, {
    this.byNames = const [],
    this.backdated = false,
  });
  final String label;
  final bool done;
  final List<String> byNames;
  final bool backdated;
}

class _TasksRow {
  _TasksRow({
    required this.tasks,
    required this.aberturaDone,
    required this.aberturaBackdated,
    required this.relatorioDone,
    required this.relatorioBackdated,
    required this.visualDone,
    required this.visualItens,
    required this.visualBackdated,
    required this.autoDone,
    required this.autoCount,
    required this.autoBackdated,
  });
  final DailyTasks tasks;
  final bool aberturaDone;
  final bool aberturaBackdated;
  final bool relatorioDone;
  final bool relatorioBackdated;
  final bool visualDone;
  final int visualItens;
  final bool visualBackdated;
  final bool autoDone;
  final int autoCount;
  final bool autoBackdated;
}

Widget _taskTile(
  BuildContext context,
  String label,
  bool done, {
  List<String> byNames = const [],
  bool backdated = false,
}) {
  return ListTile(
    dense: true,
    leading: Icon(
      done ? Icons.check_circle : Icons.cancel,
      size: 20,
      color: done ? context.colors.primary : context.greyedFill,
    ),
    title: Text(
      label,
      style: TextStyle(
        decoration: done ? TextDecoration.lineThrough : null,
        color: done ? null : context.faint,
      ),
    ),
    subtitle: (done && backdated)
        ? Text(
            'Preenchido a posteriori',
            style: TextStyle(fontSize: 11, color: context.faint),
          )
        : null,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (done && backdated) ...[
          Icon(Icons.history_toggle_off, size: 16, color: context.faint),
          const SizedBox(width: 4),
        ],
        if (done && byNames.isNotEmpty) ...[
          const SizedBox(width: 4),
          _HistoryInitials(names: byNames),
        ],
      ],
    ),
  );
}
