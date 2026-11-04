import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/app_document.dart';
import '../services/document_service.dart';
import '../theme.dart';

/// One of the Documentos, open: its PDF (downloaded the first time, then
/// kept on the device), scrolled and zoomed with the fingers.
class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key, required this.doc});

  final AppDocument doc;

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late Future<Uint8List> _bytes = DocumentService.instance.open(widget.doc);

  void _retry() =>
      setState(() => _bytes = DocumentService.instance.open(widget.doc));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.doc.title)),
      body: SafeArea(
        top: false,
        child: FutureBuilder<Uint8List>(
          future: _bytes,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 48, color: context.faint),
                      const SizedBox(height: 12),
                      Text(
                        'Não foi possível abrir o documento. Verifique a '
                        'ligação à internet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.muted),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _retry,
                        child: const Text('Tentar de novo'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final bytes = snap.data;
            if (bytes == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return PdfViewer.data(
              bytes,
              sourceName: widget.doc.fileName,
              params: PdfViewerParams(
                backgroundColor: context.backdrop,
                loadingBannerBuilder: (context, _, _) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ),
    );
  }
}
