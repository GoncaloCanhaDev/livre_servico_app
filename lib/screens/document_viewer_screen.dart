import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/app_document.dart';
import '../services/document_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';

/// One of the Documentos, open: its PDF (downloaded the first time, then
/// kept on the device), scrolled and zoomed with the fingers. The app bar's
/// button turns every page a quarter clockwise, for a scan saved sideways;
/// the turn is kept on this device for that file.
class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key, required this.doc});

  final AppDocument doc;

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late Future<Uint8List> _bytes = DocumentService.instance.open(widget.doc);

  void _retry() => setState(() {
    _bytes = DocumentService.instance.open(widget.doc);
  });

  /// The open document, once the viewer has it (all its pages loaded, so
  /// turning them sticks).
  PdfDocument? _document;
  late int _turns = SettingsService.instance.documentTurns(widget.doc.fileName);

  void _onViewerReady(PdfDocument document, PdfViewerController _) {
    if (identical(document, _document)) return;
    _document = document;
    _turn(PdfPageRotation.values[_turns]);
    setState(() {});
  }

  /// Turns every page by [delta] from where it is now.
  void _turn(PdfPageRotation delta) {
    final document = _document;
    if (document == null || delta == PdfPageRotation.none) return;
    document.pages = [for (final p in document.pages) p.rotatedBy(delta)];
  }

  void _rotate() {
    setState(() => _turns = (_turns + 1) & 3);
    _turn(PdfPageRotation.clockwise90);
    SettingsService.instance.setDocumentTurns(widget.doc.fileName, _turns);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc.title),
        actions: [
          IconButton(
            tooltip: 'Rodar',
            icon: const Icon(Icons.rotate_right),
            onPressed: _document == null ? null : _rotate,
          ),
        ],
      ),
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
              useProgressiveLoading: false,
              params: PdfViewerParams(
                backgroundColor: context.backdrop,
                onViewerReady: _onViewerReady,
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
