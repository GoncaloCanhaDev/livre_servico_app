part of '../historico_screen.dart';

/// Listas 2.0 → Automáticas: every item sent, newest first.
class _Auto2Tab extends StatefulWidget {
  const _Auto2Tab();
  @override
  State<_Auto2Tab> createState() => _Auto2TabState();
}

class _Auto2TabState extends State<_Auto2Tab>
    with AutomaticKeepAliveClientMixin, _ReloadWhenOpen {
  @override
  int get tabIndex => 4;

  @override
  bool get wantKeepAlive => true;
  late Future<List<Auto2Entry>> _future;

  @override
  void initState() {
    super.initState();
    _future = Auto2Service.instance.history(includeDeleted: true);
    Auto2Service.instance.addListener(_changed);
  }

  @override
  void dispose() {
    Auto2Service.instance.removeListener(_changed);
    super.dispose();
  }

  @override
  void _reload() {
    setState(() {
      _future = Auto2Service.instance.history(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final fmt = DateFormat("d 'de' MMM, HH:mm", 'pt_PT');
    final dayFmt = DateFormat("d 'de' MMM", 'pt_PT');
    return FutureBuilder<List<Auto2Entry>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = _searched(query, snap.data!, auto2SearchText);
        if (items.isEmpty) return _emptyOr(query, 'Sem automáticas.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final a = items[i];
            final when = a.backdated
                ? dayFmt.format(a.createdAt)
                : fmt.format(a.createdAt);
            return _dimmedIfDeleted(
              deleted: a.syncDeletedAt != null,
              child: _HistoryDismissible(
                itemKey: ValueKey(a.id),
                deletePromptName: 'automática',
                onDelete: () async {
                  await Auto2Service.instance.delete(a.id);
                },
                onSendWhatsApp: (ctx) async {
                  await WhatsAppService.sendWithConfirm(
                    ctx,
                    '📦 Automáticas ($when) · ${a.label}: ${a.value}\n'
                    'Por: ${joinNames(a.byNames)}',
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.bolt, color: context.colors.primary),
                  title: Text(a.label),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(when),
                      if (a.backdated) const _BackdatedRow(),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HistoryInitials(names: a.byNames),
                      const SizedBox(width: 8),
                      Text(
                        '${a.value}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
