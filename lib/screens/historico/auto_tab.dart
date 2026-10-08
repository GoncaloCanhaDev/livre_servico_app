part of '../historico_screen.dart';

class _AutoTab extends StatefulWidget {
  const _AutoTab();
  @override
  State<_AutoTab> createState() => _AutoTabState();
}

class _AutoTabState extends State<_AutoTab>
    with AutomaticKeepAliveClientMixin, _ReloadWhenOpen {
  @override
  int get tabIndex => 3;

  @override
  bool get wantKeepAlive => true;
  late Future<List<AutoList>> _future;

  @override
  void initState() {
    super.initState();
    _future = AutoListService.instance.history(includeDeleted: true);
    AutoListService.instance.addListener(_changed);
  }

  @override
  void dispose() {
    AutoListService.instance.removeListener(_changed);
    super.dispose();
  }

  @override
  void _reload() {
    setState(() {
      _future = AutoListService.instance.history(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final fmt = DateFormat("d 'de' MMM, HH:mm", 'pt_PT');
    return FutureBuilder<List<AutoList>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = _searched(query, snap.data!, autoSearchText);
        if (items.isEmpty) return _emptyOr(query, 'Sem listas automáticas.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final l = items[i];
            return _dimmedIfDeleted(
              deleted: l.syncDeletedAt != null,
              child: _HistoryDismissible(
                itemKey: ValueKey(l.id),
                deletePromptName: 'lista automática',
                onDelete: () async {
                  await AutoListService.instance.delete(l.id);
                },
                onSendWhatsApp: (ctx) async {
                  final msg =
                      '📦 Lista Automática (${fmt.format(l.createdAt)})\n'
                      'Congelados: ${l.congelados}\n'
                      'OPLS: ${l.opls}\n'
                      'Não Perecíveis: ${l.naoPereciveis}\n'
                      'Total: ${l.total}';
                  await WhatsAppService.sendWithConfirm(ctx, msg);
                },
                child: ListTile(
                  leading: Icon(Icons.bolt, color: context.colors.primary),
                  title: Text(fmt.format(l.createdAt)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cong: ${l.congelados} · OPLS: ${l.opls} · NP: ${l.naoPereciveis}',
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
