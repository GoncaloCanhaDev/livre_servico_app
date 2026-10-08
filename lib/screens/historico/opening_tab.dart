part of '../historico_screen.dart';

class _OpeningTab extends StatefulWidget {
  const _OpeningTab();
  @override
  State<_OpeningTab> createState() => _OpeningTabState();
}

class _OpeningTabState extends State<_OpeningTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<List<OpeningList>> _future;

  @override
  void initState() {
    super.initState();
    _future = OpeningListService.instance.history(includeDeleted: true);
    OpeningListService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    OpeningListService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = OpeningListService.instance.history(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final dayFmt = DateFormat("d 'de' MMM y", 'pt_PT');
    return FutureBuilder<List<OpeningList>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = _searched(query, snap.data!, openingSearchText);
        if (items.isEmpty) return _emptyOr(query, 'Sem listas de abertura.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final l = items[i];
            return _dimmedIfDeleted(
              deleted: l.syncDeletedAt != null,
              child: _HistoryDismissible(
                itemKey: ValueKey(l.id),
                deletePromptName: 'lista de abertura',
                onDelete: () async {
                  await OpeningListService.instance.delete(l.id);
                },
                onSendWhatsApp: (ctx) async {
                  final msg =
                      '📋 Lista de Abertura (${dayFmt.format(l.serviceDay)})\n'
                      'Congelados: ${l.congelados}\n'
                      'OPLS: ${l.opls}\n'
                      'Não Perecíveis: ${l.naoPereciveis}\n'
                      'Total: ${l.total}';
                  await WhatsAppService.sendWithConfirm(ctx, msg);
                },
                child: ListTile(
                  leading: Icon(
                    l.isFinalized ? Icons.check_circle : Icons.edit,
                    color: l.isFinalized ? AppColors.green : Colors.black45,
                  ),
                  title: Text(dayFmt.format(l.serviceDay)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cong: ${l.congelados} · OPLS: ${l.opls} · NP: ${l.naoPereciveis}',
                      ),
                      for (final s in ListSection.values)
                        if (l.namesOf(s) case final names when names.isNotEmpty)
                          Text(
                            '${s.label}: ${joinNames(names)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
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
