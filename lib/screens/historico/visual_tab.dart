part of '../historico_screen.dart';

class _VisualTab extends StatefulWidget {
  const _VisualTab();
  @override
  State<_VisualTab> createState() => _VisualTabState();
}

class _VisualTabState extends State<_VisualTab>
    with AutomaticKeepAliveClientMixin, _ReloadWhenOpen {
  @override
  int get tabIndex => 5;

  @override
  bool get wantKeepAlive => true;
  late Future<List<VisualList>> _future;

  @override
  void initState() {
    super.initState();
    _future = VisualListService.instance.all(includeDeleted: true);
    VisualListService.instance.addListener(_changed);
  }

  @override
  void dispose() {
    VisualListService.instance.removeListener(_changed);
    super.dispose();
  }

  @override
  void _reload() {
    setState(() {
      _future = VisualListService.instance.all(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final dayFmt = DateFormat("EEE, d 'de' MMM y", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');
    return FutureBuilder<List<VisualList>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = _searched(query, snap.data!, visualSearchText);
        if (all.isEmpty) return _emptyOr(query, 'Sem listas visuais.');
        final byDay = <DateTime, List<VisualList>>{};
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
            final tI = entries.fold(0, (s, e) => s + e.itensPicados);
            final tQ = entries.fold(0, (s, e) => s + e.quebraCents);
            final tB = entries.fold(0, (s, e) => s + e.beneficioCents);
            final tTotal = tB - tQ;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                title: Text(
                  dayFmt.format(day),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12),
                    children: [
                      TextSpan(text: 'Itens: $tI · Total: '),
                      TextSpan(
                        text: '${formatCents(tTotal)} €',
                        style: TextStyle(
                          color: tTotal >= 0
                              ? context.colors.primary
                              : Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                children: entries.map((e) {
                  final eTotal = e.beneficioCents - e.quebraCents;
                  return _dimmedIfDeleted(
                    deleted: e.syncDeletedAt != null,
                    child: _HistoryDismissible(
                      itemKey: ValueKey(e.id),
                      deletePromptName: 'entrada visual',
                      onDelete: () async {
                        await VisualListService.instance.delete(e.id);
                      },
                      onSendWhatsApp: (ctx) async {
                        final msg =
                            '👁 Lista Visual (${timeFmt.format(e.createdAt)})\n'
                            'Itens Picados: ${e.itensPicados}\n'
                            'Quebra: -${formatCents(e.quebraCents)} €\n'
                            'Benefício: ${formatCents(e.beneficioCents)} €\n'
                            'Total: ${formatCents(eTotal)} €';
                        await WhatsAppService.sendWithConfirm(ctx, msg);
                      },
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.visibility,
                          color: context.colors.primary,
                        ),
                        title: Text(timeFmt.format(e.createdAt)),
                        trailing:
                            resolveNames(
                              e.createdByNames,
                              e.createdByInitials,
                            ).isEmpty
                            ? null
                            : _HistoryInitials(
                                names: resolveNames(
                                  e.createdByNames,
                                  e.createdByInitials,
                                ),
                              ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: const TextStyle(fontSize: 12),
                                children: [
                                  TextSpan(
                                    text: 'Itens: ${e.itensPicados} · Quebra: ',
                                  ),
                                  TextSpan(
                                    text: '-${formatCents(e.quebraCents)} €',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' · Benefício: '),
                                  TextSpan(
                                    text: '${formatCents(e.beneficioCents)} €',
                                    style: TextStyle(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' · Total: '),
                                  TextSpan(
                                    text: '${formatCents(eTotal)} €',
                                    style: TextStyle(
                                      color: eTotal >= 0
                                          ? context.colors.primary
                                          : Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (e.backdated) const _BackdatedRow(),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
