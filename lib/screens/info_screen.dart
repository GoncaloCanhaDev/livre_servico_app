import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/info_contacts.dart';
import '../models/info_entry.dart';
import '../services/info_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'info_entry_form_screen.dart';
import 'widgets/phone_linked_text.dart';
import 'widgets/photo_viewer.dart';

/// One of the store's single-value fields (Horário, Morada, Contactos).
class _StoreField {
  const _StoreField(this.label, this.bucket);
  final String label;
  final String bucket;
}

const _storeFields = [
  _StoreField('Horário', 'loja_horario'),
  _StoreField('Morada', 'loja_morada'),
  _StoreField('Contactos', 'loja_contactos'),
];

/// A list of entries added with "Adicionar" (Protocolos, Avarias…).
class _Bucket {
  const _Bucket(this.label, this.key);
  final String label;
  final String key;
}

/// Informações: pinned entries first (Afixadas), then the store's details,
/// Protocolos, Ações de Suporte and Contactos Úteis by group. Tapping an
/// entry offers Editar, Afixar, Partilhar and Apagar.
class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<InfoEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final entries = await InfoService.instance.all();
    if (mounted) setState(() => _entries = entries);
  }

  List<String> get _groups => {
    for (final e in _entries ?? const <InfoEntry>[])
      if (isContact(e)) contactGroupOf(e),
  }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  Future<void> _openForm({
    InfoEntry? existing,
    String? bucket,
    bool contact = false,
  }) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InfoEntryFormScreen(
          existing: existing,
          bucket: bucket,
          contact: contact,
          groups: _groups,
        ),
      ),
    );
    if (saved == true) _reload();
  }

  Future<void> _editStoreField(_StoreField field, InfoEntry? existing) async {
    final ctrl = TextEditingController(text: existing?.description ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(field.label),
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
    ctrl.dispose();
    if (saved == null) return;
    final entry =
        existing ??
        (InfoEntry()
          ..bucket = field.bucket
          ..title = field.label
          ..createdAt = DateTime.now());
    entry.description = saved;
    await InfoService.instance.save(entry);
    _reload();
  }

  Future<void> _togglePin(InfoEntry e) async {
    e.pinned = !e.pinned;
    await InfoService.instance.save(e);
    _reload();
  }

  Future<void> _share(InfoEntry e) async {
    final text = infoShareText(e);
    if (e.photoPaths.isEmpty) {
      await WhatsAppService.sendWithConfirm(context, text);
      return;
    }
    await Share.shareXFiles([
      for (final p in e.photoPaths) XFile(p),
    ], text: text);
  }

  Future<void> _delete(InfoEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar'),
        content: Text('Apagar "${e.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await InfoService.instance.delete(e);
    _reload();
  }

  Future<void> _renameGroup(String group) async {
    final ctrl = TextEditingController(text: group);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mudar o nome do grupo'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
    ctrl.dispose();
    if (name == null || name.isEmpty || name == group) return;
    await InfoService.instance.renameGroup(group, name);
    _reload();
  }

  /// Editar / Afixar / Partilhar / Apagar for [e]; a store field can't be
  /// deleted, only emptied.
  Future<void> _showActions(InfoEntry e) async {
    final storeField = _storeFields
        .where((f) => f.bucket == e.bucket)
        .firstOrNull;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                e.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: Icon(
                e.pinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              title: Text(e.pinned ? 'Desafixar' : 'Afixar'),
              onTap: () => Navigator.pop(ctx, 'pin'),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Partilhar'),
              onTap: () => Navigator.pop(ctx, 'share'),
            ),
            if (storeField == null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Apagar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'edit':
        if (storeField != null) {
          await _editStoreField(storeField, e);
        } else {
          await _openForm(existing: e, contact: isContact(e));
        }
      case 'pin':
        await _togglePin(e);
      case 'share':
        await _share(e);
      case 'delete':
        await _delete(e);
    }
  }

  Widget _tileFor(InfoEntry e) => isContact(e)
      ? _ContactTile(entry: e, onTap: () => _showActions(e))
      : _EntryTile(entry: e, onTap: () => _showActions(e));

  Widget _storeFieldTile(_StoreField field, InfoEntry? entry) {
    final body = (entry?.description ?? '').trim();
    if (entry == null || body.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          field.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: const Text('Por preencher.'),
        trailing: Icon(Icons.edit, size: 18, color: context.faint),
        onTap: () => _editStoreField(field, entry),
      );
    }
    return _EntryTile(entry: entry, onTap: () => _showActions(entry));
  }

  Widget _bucketBlock(_Bucket bucket, List<InfoEntry> entries) {
    final items = [
      for (final e in entries)
        if (e.bucket == bucket.key) e,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BlockHeader(
          label: bucket.label,
          actionLabel: 'Adicionar',
          onAction: () => _openForm(bucket: bucket.key),
        ),
        if (items.isEmpty)
          const _EmptyNote()
        else
          for (final e in items) _tileFor(e),
      ],
    );
  }

  List<Widget> _contactGroups(List<InfoEntry> entries) {
    final contacts = [
      for (final e in entries)
        if (isContact(e)) e,
    ];
    return [
      _BlockHeader(
        label: 'Contactos',
        actionLabel: 'Adicionar',
        onAction: () => _openForm(contact: true),
      ),
      if (contacts.isEmpty) const _EmptyNote(),
      for (final g in _groups) ...[
        InkWell(
          onTap: () => _renameGroup(g),
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    g,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.colors.secondary,
                    ),
                  ),
                ),
                Icon(Icons.edit, size: 16, color: context.faintest),
              ],
            ),
          ),
        ),
        for (final e
            in contacts.where((c) => contactGroupOf(c) == g).toList()..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            ))
          _tileFor(e),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    return Scaffold(
      appBar: AppBar(title: const Text('Informações')),
      body: SafeArea(
        child: entries == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (entries.where((e) => e.pinned).toList() case final pinned
                      when pinned.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.push_pin,
                                  color: context.colors.primary,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Afixadas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            for (final e in pinned) ...[
                              const Divider(height: 16),
                              _tileFor(e),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _Section(
                    title: 'Informações da Loja',
                    icon: Icons.store,
                    children: [
                      for (final f in _storeFields) ...[
                        const Divider(height: 1),
                        _storeFieldTile(
                          f,
                          entries
                              .where((e) => e.bucket == f.bucket)
                              .firstOrNull,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Protocolos',
                    icon: Icons.rule,
                    children: [
                      _bucketBlock(
                        const _Bucket('Protocolos', 'protocolos'),
                        entries,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Ações de Suporte',
                    icon: Icons.support_agent,
                    children: [
                      _bucketBlock(
                        const _Bucket('Avarias', 'suporte_avarias'),
                        entries,
                      ),
                      const Divider(height: 1),
                      _bucketBlock(
                        const _Bucket('Reclamações', 'suporte_reclamacoes'),
                        entries,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Contactos Úteis',
                    icon: Icons.contact_phone,
                    children: _contactGroups(entries),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: context.colors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _BlockHeader extends StatelessWidget {
  const _BlockHeader({
    required this.label,
    required this.actionLabel,
    required this.onAction,
  });

  final String label;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        'Sem entradas.',
        style: TextStyle(color: context.muted, fontSize: 13),
      ),
    );
  }
}

/// An entry's title, text (phone numbers tappable) and photos.
class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onTap});

  final InfoEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleRow(title: e.title, pinned: e.pinned),
            if (e.description.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              PhoneLinkedText(
                e.description,
                style: TextStyle(color: context.colors.onSurface, height: 1.35),
              ),
            ],
            if (e.photoPaths.isNotEmpty) ...[
              const SizedBox(height: 8),
              PhotoStrip(paths: e.photoPaths),
            ],
          ],
        ),
      ),
    );
  }
}

/// A contact: name, note, phone and email, with call, WhatsApp and email
/// buttons.
class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.entry, required this.onTap});

  final InfoEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final phone = contactPhoneOf(e);
    final email = contactEmailOf(e);
    final note = contactNoteOf(e);
    final wa = phone == null ? null : whatsAppNumber(phone);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleRow(title: e.title, pinned: e.pinned),
                      if (phone != null)
                        Text(
                          phone,
                          style: TextStyle(color: context.colors.onSurface),
                        ),
                      if (email != null)
                        Text(
                          email,
                          style: TextStyle(color: context.colors.onSurface),
                        ),
                    ],
                  ),
                ),
                if (phone != null)
                  IconButton(
                    tooltip: 'Ligar',
                    icon: Icon(Icons.phone, color: context.colors.primary),
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                  ),
                if (wa != null)
                  IconButton(
                    tooltip: 'WhatsApp',
                    icon: Icon(Icons.chat, color: context.colors.primary),
                    onPressed: () => launchUrl(
                      Uri.parse('https://wa.me/$wa'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                if (email != null)
                  IconButton(
                    tooltip: 'Email',
                    icon: Icon(Icons.email, color: context.colors.primary),
                    onPressed: () =>
                        launchUrl(Uri(scheme: 'mailto', path: email)),
                  ),
              ],
            ),
            if (note.isNotEmpty)
              PhoneLinkedText(
                note,
                style: TextStyle(color: context.muted, height: 1.35),
              ),
            if (e.photoPaths.isNotEmpty) ...[
              const SizedBox(height: 8),
              PhotoStrip(paths: e.photoPaths),
            ],
          ],
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, required this.pinned});

  final String title;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        if (pinned) Icon(Icons.push_pin, size: 14, color: context.faintest),
      ],
    );
  }
}
