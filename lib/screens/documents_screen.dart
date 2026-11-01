import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_document.dart';
import '../services/account_service.dart';
import '../services/document_service.dart';
import '../theme.dart';
import 'document_viewer_screen.dart';
import 'widgets/wide_layout.dart';

/// The biggest PDF the admin may add (Supabase Storage's default limit).
const _maxBytes = 50 * 1024 * 1024;

/// Documentos: the PDFs the app's admin keeps for every store, by title.
/// Tapping one opens it in the app. Only the admin adds, renames and removes
/// them.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _service = DocumentService.instance;
  bool _loading = true;
  bool _offline = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_changed);
    _refresh();
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    try {
      await _service.refresh();
      _offline = false;
    } catch (_) {
      _offline = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Runs an admin change, with a message when it fails.
  Future<void> _run(Future<void> Function() change, String done) async {
    setState(() => _busy = true);
    try {
      await change();
      _message(done);
    } catch (e) {
      _message(accountErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askTitle(String heading, String initial) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(heading),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!isPdf(bytes)) {
      _message('O ficheiro escolhido não é um PDF.');
      return;
    }
    if (bytes.length > _maxBytes) {
      _message('O PDF é demasiado grande (máximo 50 MB).');
      return;
    }
    final name = picked.name.replaceAll(
      RegExp(r'\.pdf$', caseSensitive: false),
      '',
    );
    final title = await _askTitle('Novo documento', name);
    if (title == null || title.isEmpty) return;
    await _run(() => _service.add(title, bytes), 'Documento adicionado.');
  }

  Future<void> _rename(AppDocument doc) async {
    final title = await _askTitle('Renomear', doc.title);
    if (title == null || title.isEmpty || title == doc.title) return;
    await _run(() => _service.rename(doc, title), 'Documento renomeado.');
  }

  Future<void> _remove(AppDocument doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover'),
        content: Text(
          'Remover "${doc.title}"? Deixa de aparecer em todas as lojas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() => _service.remove(doc), 'Documento removido.');
  }

  void _open(AppDocument doc) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => DocumentViewerScreen(doc: doc)),
  );

  @override
  Widget build(BuildContext context) {
    final docs = _service.documents;
    final canManage = _service.canManage && _service.isAvailable;
    return Scaffold(
      appBar: AppBar(title: const Text('Documentos')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: _busy ? null : _add,
              icon: const Icon(Icons.upload_file),
              label: const Text('Adicionar PDF'),
            )
          : null,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ReadableWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (_busy) const LinearProgressIndicator(),
                if (_offline && _service.isAvailable)
                  _Note(
                    icon: Icons.cloud_off,
                    text:
                        'Sem ligação: a mostrar os documentos guardados neste '
                        'aparelho.',
                  ),
                if (docs.isEmpty && _loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (docs.isEmpty)
                  _Empty(available: _service.isAvailable)
                else
                  for (final d in docs)
                    _DocumentTile(
                      doc: d,
                      onOpen: () => _open(d),
                      onRename: canManage && !_busy ? () => _rename(d) : null,
                      onRemove: canManage && !_busy ? () => _remove(d) : null,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.doc,
    required this.onOpen,
    this.onRename,
    this.onRemove,
  });

  final AppDocument doc;
  final VoidCallback onOpen;
  final VoidCallback? onRename;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final size = documentSizeLabel(doc.size);
    final date = DateFormat('d/M/yyyy', 'pt_PT').format(doc.updatedAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.tint(Colors.red),
          child: Icon(Icons.picture_as_pdf, color: Colors.red.shade700),
        ),
        title: Text(doc.title),
        subtitle: Text(
          [if (size.isNotEmpty) size, 'Atualizado a $date'].join(' · '),
          style: TextStyle(color: context.muted),
        ),
        onTap: onOpen,
        trailing: onRename == null && onRemove == null
            ? const Icon(Icons.chevron_right)
            : PopupMenuButton<String>(
                tooltip: 'Opções',
                onSelected: (v) =>
                    v == 'rename' ? onRename?.call() : onRemove?.call(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Renomear')),
                  PopupMenuItem(value: 'remove', child: Text('Remover')),
                ],
              ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 56, color: context.faint),
          const SizedBox(height: 12),
          Text(
            available
                ? 'Ainda não há documentos.'
                : 'Os documentos aparecem aqui depois de entrar numa loja '
                      '(Definições → Conta e Sincronização).',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.muted),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: context.muted)),
          ),
        ],
      ),
    );
  }
}
