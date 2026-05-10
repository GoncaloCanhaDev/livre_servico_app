import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/truck_reception.dart';
import '../services/product_service.dart';
import '../theme.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ProductService.instance.findById(widget.productId);
    if (mounted) setState(() => _product = p);
  }

  Future<void> _edit() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(existing: _product),
      ),
    );
    if (ok == true) _load();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Apagar produto?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Apagar')),
        ],
      ),
    );
    if (ok == true && _product != null) {
      await ProductService.instance.delete(_product!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produto'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: p == null ? null : _edit),
          IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: p == null ? null : _delete),
        ],
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          BarcodeWidget(
                            barcode: Barcode.ean13(),
                            data: p.ean,
                            width: double.infinity,
                            height: 120,
                            drawText: true,
                            color: AppColors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(p.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(p.department.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Field(label: 'EAN-13', value: p.ean),
                  _Field(label: 'Código SAP', value: p.sapCode),
                  if (p.notes != null && p.notes!.isNotEmpty)
                    _Field(label: 'Notas', value: p.notes!),
                ],
              ),
            ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                  letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
