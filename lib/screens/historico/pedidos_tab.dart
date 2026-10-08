part of '../historico_screen.dart';

class _PedidosTab extends StatefulWidget {
  const _PedidosTab();
  @override
  State<_PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<_PedidosTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Pedido>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _reload();
    PedidoService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    PedidoService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = PedidoService.instance.history(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateFmt = DateFormat("d 'de' MMMM, HH:mm", 'pt_PT');
    return FutureBuilder<List<Pedido>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const Center(child: Text('Sem pedidos registados.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final p = items[i];
            final title = p.isFinalized
                ? 'Pedido ${p.numero ?? '—'}'
                : 'Pedido (em curso)';
            final subtitleParts = <String>[
              dateFmt.format(p.createdAt),
              if (p.supplier != null) p.supplier!,
              if (p.isOverdue) 'Atrasado',
            ];
            return _dimmedIfDeleted(
              deleted: p.syncDeletedAt != null,
              child: _HistoryDismissible(
                itemKey: ValueKey(p.id),
                deletePromptName: 'pedido',
                onDelete: () async {
                  await PedidoService.instance.delete(p.id);
                },
                onSendWhatsApp: (ctx) async {
                  final msg = StringBuffer()
                    ..writeln('📝 Pedido nº ${p.numero ?? '—'}');
                  if (p.supplier != null) {
                    msg.writeln('Fornecedor: ${p.supplier}');
                  }
                  await WhatsAppService.sendWithConfirm(
                    ctx,
                    msg.toString().trim(),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(
                      p.isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.receipt_long,
                      color: p.isOverdue
                          ? Colors.orange.shade800
                          : p.isFinalized
                          ? AppColors.green
                          : AppColors.greenDark,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      subtitleParts.join(' · '),
                      style: TextStyle(
                        color: p.isOverdue ? Colors.orange.shade800 : null,
                        fontWeight: p.isOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                    trailing: _trailingWithInitials(
                      p.createdByInitials,
                      Text(
                        p.isFinalized ? 'Concluído' : 'A decorrer',
                        style: TextStyle(
                          color: p.isFinalized
                              ? AppColors.green
                              : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
