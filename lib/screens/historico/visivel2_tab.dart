part of '../historico_screen.dart';

/// Listas 2.0 → Visível: every one saved, grouped by service day.
class _Visivel2Tab extends StatefulWidget {
  const _Visivel2Tab();
  @override
  State<_Visivel2Tab> createState() => _Visivel2TabState();
}

class _Visivel2TabState extends State<_Visivel2Tab>
    with AutomaticKeepAliveClientMixin, _ReloadWhenOpen {
  @override
  int get tabIndex => 7;

  @override
  bool get wantKeepAlive => true;
  late Future<List<Visivel2Entry>> _future;

  @override
  void initState() {
    super.initState();
    _future = Visivel2Service.instance.history(includeDeleted: true);
    Visivel2Service.instance.addListener(_changed);
  }

  @override
  void dispose() {
    Visivel2Service.instance.removeListener(_changed);
    super.dispose();
  }

  @override
  void _reload() {
    setState(() {
      _future = Visivel2Service.instance.history(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final dayFmt = DateFormat("EEE, d 'de' MMM y", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');
    return FutureBuilder<List<Visivel2Entry>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = _searched(query, snap.data!, visivel2SearchText);
        if (all.isEmpty) return _emptyOr(query, 'Sem visíveis.');
        final byDay = <DateTime, List<Visivel2Entry>>{};
        for (final e in all) {
          byDay.putIfAbsent(e.serviceDay, () => []).add(e);
        }
        final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: days.length,
          itemBuilder: (_, i) {
            final day = days[i];
            final entries = byDay[day]!;
            final total = entries
                .where((e) => e.syncDeletedAt == null)
                .fold(0, (s, e) => s + e.itens);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                title: Text(
                  dayFmt.format(day),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Itens picados: $total',
                  style: const TextStyle(fontSize: 12),
                ),
                children: [
                  for (final e in entries)
                    _dimmedIfDeleted(
                      deleted: e.syncDeletedAt != null,
                      child: _HistoryDismissible(
                        itemKey: ValueKey(e.id),
                        deletePromptName: 'visível',
                        onDelete: () async {
                          await Visivel2Service.instance.delete(e.id);
                        },
                        onSendWhatsApp: (ctx) async {
                          await WhatsAppService.sendWithConfirm(
                            ctx,
                            '👁 Visível (${dayFmt.format(day)})\n'
                            'Itens Picados: ${e.itens}\n'
                            'Por: ${joinNames(e.byNames)}',
                          );
                        },
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.visibility,
                            color: context.colors.primary,
                          ),
                          title: Text(
                            e.backdated
                                ? 'Registado mais tarde'
                                : timeFmt.format(e.createdAt),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _HistoryInitials(names: e.byNames),
                              const SizedBox(width: 8),
                              Text(
                                '${e.itens}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
