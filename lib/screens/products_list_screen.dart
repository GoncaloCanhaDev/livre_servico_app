import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/truck_reception.dart';
import '../services/product_service.dart';
import '../theme.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';
import 'scanner_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final _searchCtrl = TextEditingController();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
    ProductService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    ProductService.instance.removeListener(_reload);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = ProductService.instance.all(query: _searchCtrl.text);
    });
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (code == null || !mounted) return;
    final existing = await ProductService.instance.findByEan(code);
    if (!mounted) return;
    if (existing != null) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: existing.id),
      ));
    } else {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductFormScreen(prefilledEan: code),
      ));
    }
    _reload();
  }

  Future<void> _newManual() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ProductFormScreen(),
    ));
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code_scanner), onPressed: _scan),
          IconButton(icon: const Icon(Icons.add), onPressed: _newManual),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Pesquisar por nome, EAN ou SAP',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _reload();
                          },
                        ),
                ),
                onChanged: (_) => _reload(),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Sem produtos.\nUse o scanner ou + para adicionar.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = items[i];
                      return ListTile(
                        title: Text(p.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            'EAN ${p.ean}  ·  SAP ${p.sapCode}\n${p.department.label}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.green),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(productId: p.id),
                          ));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
