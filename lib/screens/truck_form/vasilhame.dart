part of '../truck_form_screen.dart';

/// The "Enviar Vasilhame" sheet: [items] with − / + buttons that edit
/// [quantities] (by name) in place, calling [onChanged] after each change.
Future<void> _showVasilhameSheet(
  BuildContext context, {
  required List<VasilhameItem> items,
  required Map<String, int> quantities,
  required VoidCallback onChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder: (ctx, scrollController) => Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Enviar Vasilhame',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final p = items[i];
                      final qty = quantities[p.name] ?? 0;
                      return ListTile(
                        title: Text(p.name),
                        subtitle: p.code == null ? null : Text(p.code!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: qty > 0
                                  ? () {
                                      setModalState(() {
                                        quantities[p.name] = qty - 1;
                                        if (quantities[p.name] == 0) {
                                          quantities.remove(p.name);
                                        }
                                      });
                                      onChanged();
                                    }
                                  : null,
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                qty.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setModalState(() {
                                  quantities[p.name] = qty + 1;
                                });
                                onChanged();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Concluído'),
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

/// A vasilhame line being sent: its name and [quantity]; tapping it shows
/// the item's EAN as a barcode.
class _VasilhameCard extends StatelessWidget {
  const _VasilhameCard({required this.item, required this.quantity});

  final VasilhameItem item;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          '$quantity un',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: item.ean == null
            ? null
            : () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        BarcodeWidget(
                          barcode: item.ean!.length == 13
                              ? Barcode.ean13()
                              : item.ean!.length == 8
                              ? Barcode.ean8()
                              : Barcode.code128(),
                          data: item.ean!,
                          width: double.infinity,
                          height: 120,
                          drawText: true,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Fechar'),
                      ),
                    ],
                  ),
                );
              },
      ),
    );
  }
}
