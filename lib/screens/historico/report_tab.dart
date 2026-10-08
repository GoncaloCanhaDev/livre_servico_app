part of '../historico_screen.dart';

class _ReportTab extends StatefulWidget {
  const _ReportTab();
  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab>
    with AutomaticKeepAliveClientMixin, _ReloadWhenOpen {
  @override
  int get tabIndex => 4;

  @override
  bool get wantKeepAlive => true;
  late Future<List<ReportList>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReportListService.instance.history(includeDeleted: true);
    ReportListService.instance.addListener(_changed);
  }

  @override
  void dispose() {
    ReportListService.instance.removeListener(_changed);
    super.dispose();
  }

  @override
  void _reload() {
    setState(() {
      _future = ReportListService.instance.history(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final dayFmt = DateFormat("d 'de' MMM y", 'pt_PT');
    return FutureBuilder<List<ReportList>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = _searched(query, snap.data!, reportSearchText);
        if (items.isEmpty) return _emptyOr(query, 'Sem relatórios.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final l = items[i];
            return _dimmedIfDeleted(
              deleted: l.syncDeletedAt != null,
              child: _HistoryDismissible(
                itemKey: ValueKey(l.id),
                deletePromptName: 'relatório',
                onDelete: () async {
                  await ReportListService.instance.delete(l.id);
                },
                onSendWhatsApp: (ctx) async {
                  final msg =
                      '📊 Relatório (${dayFmt.format(l.serviceDay)})\n'
                      'Dias s/ vendas: ${l.diasSemVendas}\n'
                      'Regularizações: ${l.regularizacoes}\n'
                      'Massiva: ${l.massiva}\n'
                      'Repetidos: ${l.repetidos}\n'
                      'Total: ${l.total}';
                  await WhatsAppService.sendWithConfirm(ctx, msg);
                },
                child: ListTile(
                  leading: Icon(
                    l.isFinalized ? Icons.check_circle : Icons.edit,
                    color: l.isFinalized
                        ? context.colors.primary
                        : context.faint,
                  ),
                  title: Text(dayFmt.format(l.serviceDay)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'DSV: ${l.diasSemVendas} · Reg: ${l.regularizacoes} · Mas: ${l.massiva} · Rep: ${l.repetidos}',
                      ),
                      if (l.backdated) const _BackdatedRow(),
                    ],
                  ),
                  trailing: _trailingWithInitials(
                    l.createdByInitials,
                    Text(
                      '${l.total}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
