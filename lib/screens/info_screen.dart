import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../models/info_entry.dart';
import '../services/shift_service.dart';
import '../services/sync_meta.dart';
import '../services/sync_service.dart';
import '../theme.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  Future<void> _reload() async {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informações')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SingleValueSection(
              title: 'Informações da Loja',
              icon: Icons.store,
              fields: const [
                _SingleField(label: 'Horário', bucket: 'loja_horario'),
                _SingleField(label: 'Morada', bucket: 'loja_morada'),
                _SingleField(label: 'Contactos', bucket: 'loja_contactos'),
              ],
              onChanged: _reload,
            ),
            const SizedBox(height: 12),
            _BucketSection(
              title: 'Protocolos',
              icon: Icons.rule,
              buckets: const [_Bucket(label: 'Protocolos', key: 'protocolos')],
              onChanged: _reload,
            ),
            const SizedBox(height: 12),
            _BucketSection(
              title: 'Ações de Suporte',
              icon: Icons.support_agent,
              buckets: const [
                _Bucket(label: 'Avarias', key: 'suporte_avarias'),
                _Bucket(label: 'Reclamações', key: 'suporte_reclamacoes'),
              ],
              onChanged: _reload,
            ),
            const SizedBox(height: 12),
            _BucketSection(
              title: 'Contactos Úteis',
              icon: Icons.contact_phone,
              buckets: const [
                _Bucket(
                    label: 'Responsável de Loja',
                    key: 'contactos_responsavel',
                    showContactField: true),
                _Bucket(
                    label: 'Suporte Técnico',
                    key: 'contactos_suporte',
                    showContactField: true),
              ],
              onChanged: _reload,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bucket {
  const _Bucket({
    required this.label,
    required this.key,
    this.showContactField = false,
  });
  final String label;
  final String key;
  final bool showContactField;
}

class _BucketSection extends StatelessWidget {
  const _BucketSection({
    required this.title,
    required this.icon,
    required this.buckets,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final List<_Bucket> buckets;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.green),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final b in buckets) ...[
            const Divider(height: 1),
            _BucketBody(bucket: b, onChanged: onChanged),
          ],
        ],
      ),
    );
  }
}

class _BucketBody extends StatefulWidget {
  const _BucketBody({required this.bucket, required this.onChanged});
  final _Bucket bucket;
  final VoidCallback onChanged;

  @override
  State<_BucketBody> createState() => _BucketBodyState();
}

class _BucketBodyState extends State<_BucketBody> {
  late Future<List<InfoEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<InfoEntry>> _load() async {
    final list = await ShiftService.instance.isar.infoEntrys
        .filter()
        .bucketEqualTo(widget.bucket.key)
        .findAll();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  void _refresh() {
    setState(() => _future = _load());
    widget.onChanged();
  }

  Future<void> _add() async {
    final result = await showDialog<_EntryDraft>(
      context: context,
      builder: (_) =>
          _EntryDialog(showContactField: widget.bucket.showContactField),
    );
    if (result == null) return;
    final isar = ShiftService.instance.isar;
    final entry = InfoEntry()
      ..bucket = widget.bucket.key
      ..title = result.title
      ..description = result.description
      ..contact = result.contact
      ..createdAt = DateTime.now();
    SyncMeta.stamp(entry);
    await isar.writeTxn(() => isar.infoEntrys.put(entry));
    SyncService.instance.requestSync();
    if (mounted) _refresh();
  }

  Future<void> _delete(InfoEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar entrada'),
        content: Text('Apagar "${entry.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final isar = ShiftService.instance.isar;
    SyncMeta.softDelete(entry);
    await isar.writeTxn(() => isar.infoEntrys.put(entry));
    SyncService.instance.requestSync();
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.bucket.label,
                  style:
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              TextButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          FutureBuilder<List<InfoEntry>>(
            future: _future,
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final items = snap.data!;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    'Sem entradas.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                );
              }
              return Column(
                children: [
                  for (final e in items)
                    Opacity(
                      opacity: e.syncDeletedAt != null ? 0.4 : 1.0,
                      child: IgnorePointer(
                        ignoring: e.syncDeletedAt != null,
                        child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        onLongPress: () => _delete(e),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            if (e.description.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                e.description,
                                style: const TextStyle(
                                    color: Colors.black87, height: 1.35),
                              ),
                            ],
                            if ((e.contact ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.phone,
                                      size: 14, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      e.contact!,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EntryDraft {
  const _EntryDraft(
      {required this.title, required this.description, this.contact});
  final String title;
  final String description;
  final String? contact;
}

class _EntryDialog extends StatefulWidget {
  const _EntryDialog({required this.showContactField});
  final bool showContactField;

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _contact = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova entrada'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            if (widget.showContactField) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _contact,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contacto (telefone/email)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final title = _title.text.trim();
            if (title.isEmpty) return;
            final contact = _contact.text.trim();
            Navigator.pop(
              context,
              _EntryDraft(
                title: title,
                description: _desc.text.trim(),
                contact: contact.isEmpty ? null : contact,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _SingleField {
  const _SingleField({required this.label, required this.bucket});
  final String label;
  final String bucket;
}

class _SingleValueSection extends StatelessWidget {
  const _SingleValueSection({
    required this.title,
    required this.icon,
    required this.fields,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final List<_SingleField> fields;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.green),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final f in fields) ...[
            const Divider(height: 1),
            _SingleFieldRow(field: f, onChanged: onChanged),
          ],
        ],
      ),
    );
  }
}

class _SingleFieldRow extends StatefulWidget {
  const _SingleFieldRow({required this.field, required this.onChanged});
  final _SingleField field;
  final VoidCallback onChanged;

  @override
  State<_SingleFieldRow> createState() => _SingleFieldRowState();
}

class _SingleFieldRowState extends State<_SingleFieldRow> {
  late Future<InfoEntry?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<InfoEntry?> _load() {
    return ShiftService.instance.isar.infoEntrys
        .filter()
        .syncDeletedAtIsNull()
        .bucketEqualTo(widget.field.bucket)
        .findFirst();
  }

  Future<void> _edit(InfoEntry? existing) async {
    final ctrl = TextEditingController(text: existing?.description ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.field.label),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
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
    if (saved == null) return;
    final isar = ShiftService.instance.isar;
    final entry = existing ?? InfoEntry()
      ..bucket = widget.field.bucket
      ..title = widget.field.label
      ..createdAt = existing?.createdAt ?? DateTime.now();
    entry.description = saved;
    SyncMeta.stamp(entry);
    await isar.writeTxn(() => isar.infoEntrys.put(entry));
    SyncService.instance.requestSync();
    if (!mounted) return;
    setState(() => _future = _load());
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InfoEntry?>(
      future: _future,
      builder: (ctx, snap) {
        final entry = snap.data;
        final body = (entry?.description ?? '').trim();
        return InkWell(
          onTap: () => _edit(entry),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.field.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        body.isEmpty ? 'Por preencher.' : body,
                        style: TextStyle(
                          color: body.isEmpty ? Colors.black54 : Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, size: 18, color: Colors.black45),
              ],
            ),
          ),
        );
      },
    );
  }
}
