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

class _ProductsListScreenState extends State<ProductsListScreen>
    with TickerProviderStateMixin {
  late final TabController _tabCtrl;

  /// Tab 0 = all, then one per PalletCategory.values
  static const _tabs = [null, ...PalletCategory.values];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
  }

  Future<void> _newManual() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ProductFormScreen(),
    ));
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
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.green,
          tabs: _tabs.map((cat) {
            return Tab(text: cat?.label ?? 'Todos');
          }).toList(),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabCtrl,
          children: _tabs.map((cat) {
            return _ProductTab(department: cat);
          }).toList(),
        ),
      ),
    );
  }
}

/// A single tab showing products filtered by [department] (null = all).
class _ProductTab extends StatefulWidget {
  const _ProductTab({this.department});
  final PalletCategory? department;

  @override
  State<_ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<_ProductTab>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  late Future<List<Product>> _future;

  @override
  bool get wantKeepAlive => true;

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
      _future = _loadFiltered();
    });
  }

  Future<List<Product>> _loadFiltered() async {
    final all = await ProductService.instance.all(query: _searchCtrl.text);
    if (widget.department == null) return all;
    return all.where((p) => p.department == widget.department).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.department == null
                          ? 'Sem produtos.\nUse o scanner ou + para adicionar.'
                          : 'Sem produtos neste departamento.',
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
                        'EAN ${p.ean}  ·  SAP ${p.sapCode}${widget.department == null ? '\n${p.department.label}' : ''}'),
                    isThreeLine: widget.department == null,
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
    );
  }
}
