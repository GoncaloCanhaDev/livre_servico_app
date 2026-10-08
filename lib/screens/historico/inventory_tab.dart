part of '../historico_screen.dart';

class _InventoryTab extends StatefulWidget {
  const _InventoryTab();
  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Inventory>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _reload();
    InventoryService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    InventoryService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = InventoryService.instance.history(includeDeleted: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _HistoricoQuery.of(context);
    final dateFmt = DateFormat("d 'de' MMMM, HH:mm", 'pt_PT');
    return FutureBuilder<List<Inventory>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = _searched(query, snap.data!, inventorySearchText);
        if (items.isEmpty) {
          return _emptyOr(query, 'Sem inventários registados.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final inv = items[i];
            final color = inv.valueCents >= 0
                ? context.colors.primary
                : Colors.redAccent;
            return _dimmedIfDeleted(
              deleted: inv.syncDeletedAt != null,
              child: _HistoryDismissible(
                itemKey: ValueKey(inv.id),
                deletePromptName: 'inventário',
                onDelete: () async {
                  await InventoryService.instance.delete(inv.id);
                },
                onSendWhatsApp: (ctx) async {
                  final msg =
                      '📦 Inventário: ${inv.name}\n'
                      'Data: ${dateFmt.format(inv.createdAt)}\n'
                      'Valor: ${formatCents(inv.valueCents)} €';
                  await WhatsAppService.sendWithConfirm(ctx, msg);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(Icons.assignment, color: color),
                    title: Text(
                      inv.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(dateFmt.format(inv.createdAt)),
                    trailing: _trailingWithInitials(
                      inv.createdByInitials,
                      Text(
                        '${formatCents(inv.valueCents)} €',
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
