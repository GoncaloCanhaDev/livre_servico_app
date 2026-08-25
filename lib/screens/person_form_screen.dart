import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/person.dart';
import '../services/person_service.dart';
import '../services/sync_meta.dart';
import 'widgets/person_picker.dart';

/// Full-screen add/edit form for a [Person]: identity fields plus the
/// hierarchy fields (role, manager) and a profile picture. Used both from
/// the people list ("+") and from [PersonDetailScreen]'s edit action.
class PersonFormScreen extends StatefulWidget {
  const PersonFormScreen({super.key, this.existing});

  final Person? existing;

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _phoneCtrl;

  DateTime? _dob;
  DateTime? _hireDate;

  /// Existing photo path (if editing and one was already set).
  String? _photoPath;
  File? _pendingPhoto;
  bool _removePhoto = false;

  List<Person> _allPeople = const [];
  Person? _manager;
  bool _loadingPeople = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.fullName ?? '');
    _numberCtrl = TextEditingController(text: e?.collaboratorNumber ?? '');
    _roleCtrl = TextEditingController(text: e?.role ?? '');
    _phoneCtrl = TextEditingController(text: e?.phoneNumber ?? '');
    _dob = e?.dateOfBirth;
    _hireDate = e?.hireDate;
    _photoPath = e?.photoPath;
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    final all = await PersonService.instance.allRaw();
    final managerUuid = widget.existing?.managerUuid;
    Person? manager;
    if (managerUuid != null) {
      for (final p in all) {
        if (p.syncUuid == managerUuid) {
          manager = p;
          break;
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _allPeople = all;
      _manager = manager;
      _loadingPeople = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _roleCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final choice = await showModalBottomSheet<Object>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tirar fotografia'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            if (_hasPhotoPreview)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text('Remover fotografia'),
                onTap: () => Navigator.of(ctx).pop('remove'),
              ),
          ],
        ),
      ),
    );
    if (choice == 'remove') {
      if (mounted) {
        setState(() {
          _pendingPhoto = null;
          _removePhoto = true;
        });
      }
      return;
    }
    if (choice is! ImageSource) return;
    final picked = await ImagePicker().pickImage(
      source: choice,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _pendingPhoto = File(picked.path);
      _removePhoto = false;
    });
  }

  bool get _hasPhotoPreview =>
      _pendingPhoto != null || (!_removePhoto && _photoPath != null);

  Future<void> _pickDate({required bool isDob}) async {
    final now = DateTime.now();
    final initial = (isDob ? _dob : _hireDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: now,
      locale: const Locale('pt', 'PT'),
      helpText: isDob ? 'Data de nascimento' : 'Data de início',
    );
    if (picked == null) return;
    setState(() {
      if (isDob) {
        _dob = picked;
      } else {
        _hireDate = picked;
      }
    });
  }

  Future<void> _pickManager() async {
    final selfUuid = widget.existing?.syncUuid;
    final excluded = selfUuid == null
        ? <String>{}
        : PersonService.instance.subtreeUuids(_allPeople, selfUuid);
    final candidates = _allPeople
        .where((p) => !excluded.contains(p.syncUuid))
        .toList();
    final result = await showDialog<_ManagerChoice>(
      context: context,
      builder: (_) => _ManagerPickerDialog(candidates: candidates),
    );
    if (result == null) return;
    setState(() => _manager = result.person);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final person = widget.existing ?? (Person()..createdAt = DateTime.now());
    person.fullName = _nameCtrl.text.trim();
    person.collaboratorNumber = _numberCtrl.text.trim();
    person.role = _roleCtrl.text.trim().isEmpty ? null : _roleCtrl.text.trim();
    person.phoneNumber = _phoneCtrl.text.trim().isEmpty
        ? null
        : _phoneCtrl.text.trim();
    person.dateOfBirth = _dob;
    person.hireDate = _hireDate;
    person.managerUuid = _manager?.syncUuid;
    SyncMeta.stamp(person);

    var photoPath = _photoPath;
    if (_pendingPhoto != null) {
      final dir = await getApplicationDocumentsDirectory();
      final peopleDir = Directory('${dir.path}/people_photos');
      if (!peopleDir.existsSync()) peopleDir.createSync(recursive: true);
      final ext = _pendingPhoto!.path.split('.').last;
      final dest = '${peopleDir.path}/${person.syncUuid}.$ext';
      await _pendingPhoto!.copy(dest);
      if (photoPath != null && photoPath != dest) {
        try {
          File(photoPath).deleteSync();
        } catch (_) {}
      }
      photoPath = dest;
    } else if (_removePhoto && photoPath != null) {
      try {
        File(photoPath).deleteSync();
      } catch (_) {}
      photoPath = null;
    }
    person.photoPath = photoPath;

    await PersonService.instance.save(person);
    if (mounted) Navigator.of(context).pop(person);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final dateFmt = DateFormat("d 'de' MMMM y", 'pt_PT');
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar pessoa' : 'Nova pessoa')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _pendingPhoto != null
                            ? FileImage(_pendingPhoto!)
                            : (_hasPhotoPreview
                                  ? FileImage(File(_photoPath!))
                                  : null),
                        child: _hasPhotoPreview
                            ? null
                            : const Icon(Icons.person, size: 48),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roleCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numberCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nº colaborador (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _DateRow(
                label: 'Data de nascimento',
                value: _dob,
                formatted: _dob == null ? null : dateFmt.format(_dob!),
                onTap: () => _pickDate(isDob: true),
                onClear: () => setState(() => _dob = null),
              ),
              const SizedBox(height: 12),
              _DateRow(
                label: 'Data de início na empresa',
                value: _hireDate,
                formatted: _hireDate == null
                    ? null
                    : dateFmt.format(_hireDate!),
                onTap: () => _pickDate(isDob: false),
                onClear: () => setState(() => _hireDate = null),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.black26),
                ),
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text('Reporta a'),
                subtitle: Text(
                  _manager?.fullName ?? 'Ninguém (topo da hierarquia)',
                ),
                trailing: _loadingPeople
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _loadingPeople ? null : _pickManager,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(isEdit ? 'Guardar' : 'Adicionar'),
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.formatted,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final String? formatted;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Colors.black26),
      ),
      leading: const Icon(Icons.event_outlined),
      title: Text(label),
      subtitle: Text(formatted ?? 'Não definida'),
      trailing: value == null
          ? const Icon(Icons.chevron_right)
          : IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClear,
            ),
      onTap: onTap,
    );
  }
}

class _ManagerChoice {
  const _ManagerChoice(this.person);
  final Person? person;
}

class _ManagerPickerDialog extends StatelessWidget {
  const _ManagerPickerDialog({required this.candidates});
  final List<Person> candidates;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reporta a'),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.vertical_align_top),
              title: const Text('Ninguém (topo da hierarquia)'),
              onTap: () =>
                  Navigator.of(context).pop(const _ManagerChoice(null)),
            ),
            const Divider(height: 1),
            Flexible(
              child: candidates.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Sem outras pessoas disponíveis.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: candidates.length,
                      itemBuilder: (_, i) {
                        final p = candidates[i];
                        return ListTile(
                          leading: PersonInitialsBadge(name: p.fullName),
                          title: Text(p.fullName),
                          subtitle: p.role == null ? null : Text(p.role!),
                          onTap: () =>
                              Navigator.of(context).pop(_ManagerChoice(p)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
