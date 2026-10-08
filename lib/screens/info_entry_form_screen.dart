import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/info_contacts.dart';
import '../models/info_entry.dart';
import '../services/info_service.dart';
import 'widgets/photo_viewer.dart';

/// Adds or edits an Informações entry (Título, Descrição) or, with
/// [contact], a Contactos Úteis contact (Nome, Grupo, Telefone, Email,
/// Nota); both can carry photos. Pops true once saved.
class InfoEntryFormScreen extends StatefulWidget {
  const InfoEntryFormScreen({
    super.key,
    this.existing,
    this.bucket,
    this.contact = false,
    this.groups = const [],
  });

  /// The entry being edited; null to add one to [bucket].
  final InfoEntry? existing;
  final String? bucket;
  final bool contact;

  /// Existing contact groups, offered while typing the group.
  final List<String> groups;

  @override
  State<InfoEntryFormScreen> createState() => _InfoEntryFormScreenState();
}

class _InfoEntryFormScreenState extends State<InfoEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _group;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  final _groupFocus = FocusNode();

  /// Photos shown in the form; [_added] were copied in during this edit and
  /// are deleted again unless the form is saved.
  late final List<String> _photos;
  final _added = <String>{};
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(
      text: e == null
          ? ''
          : widget.contact
          ? contactNoteOf(e)
          : e.description,
    );
    _group = TextEditingController(text: e == null ? '' : contactGroupOf(e));
    _phone = TextEditingController(
      text: e == null ? '' : contactPhoneOf(e) ?? '',
    );
    _email = TextEditingController(
      text: e == null ? '' : contactEmailOf(e) ?? '',
    );
    _photos = [...?e?.photoPaths];
  }

  @override
  void dispose() {
    if (!_saved) {
      for (final p in _added) {
        InfoService.instance.deletePhoto(p);
      }
    }
    _title.dispose();
    _description.dispose();
    _group.dispose();
    _phone.dispose();
    _email.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked == null) return;
    final path = await InfoService.instance.storePhoto(picked.path);
    if (!mounted) {
      InfoService.instance.deletePhoto(path);
      return;
    }
    setState(() {
      _photos.add(path);
      _added.add(path);
    });
  }

  void _removePhoto(String path) {
    setState(() => _photos.remove(path));
    if (_added.remove(path)) InfoService.instance.deletePhoto(path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final e =
        widget.existing ??
        (InfoEntry()
          ..bucket = widget.bucket ?? contactsBucket
          ..createdAt = DateTime.now());
    String? orNull(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    e
      ..title = _title.text.trim()
      ..description = _description.text.trim();
    if (widget.contact) {
      e
        ..bucket = contactsBucket
        ..group = _group.text.trim()
        ..phone = orNull(_phone)
        ..email = orNull(_email)
        ..contact = null;
    }
    // Photos taken out of an existing entry go once it is saved.
    for (final p in widget.existing?.photoPaths ?? const <String>[]) {
      if (!_photos.contains(p)) InfoService.instance.deletePhoto(p);
    }
    e.photoPaths = [..._photos];
    await InfoService.instance.save(e);
    _saved = true;
    if (mounted) Navigator.of(context).pop(true);
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null;

  Widget _groupField() {
    return RawAutocomplete<String>(
      textEditingController: _group,
      focusNode: _groupFocus,
      optionsBuilder: (value) {
        final q = value.text.trim().toLowerCase();
        return widget.groups.where(
          (g) => q.isEmpty || g.toLowerCase().contains(q),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Grupo',
              hintText: 'Ex.: Fornecedores, Técnicos de frio',
              border: OutlineInputBorder(),
            ),
            validator: _required,
            onFieldSubmitted: (_) => onSubmitted(),
          ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final g in options)
                  ListTile(title: Text(g), onTap: () => onSelected(g)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(switch ((contact, editing)) {
          (true, false) => 'Novo contacto',
          (true, true) => 'Editar contacto',
          (false, false) => 'Nova entrada',
          (false, true) => 'Editar entrada',
        }),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                autofocus: !editing,
                textCapitalization: contact
                    ? TextCapitalization.words
                    : TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: contact ? 'Nome' : 'Título',
                  border: const OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              if (contact) ...[
                _groupField(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: contact ? 'Nota (opcional)' : 'Descrição',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fotos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_photos.isNotEmpty) ...[
                PhotoStrip(paths: _photos, onRemove: _removePhoto),
                const SizedBox(height: 8),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Adicionar foto'),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
