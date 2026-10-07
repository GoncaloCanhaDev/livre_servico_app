import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/person.dart';
import '../models/teams.dart';
import '../services/person_service.dart';
import '../services/sync_meta.dart';

/// The "Função na equipa" choices; [supervisor] only for teams that have
/// supervisors.
enum _Funcao { membro, supervisor, chefe }

/// Full-screen add/edit form for a [Person]: identity fields plus team and
/// chefe role, and a profile picture. Used both from
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
  late final TextEditingController _phoneCtrl;

  DateTime? _dob;
  DateTime? _hireDate;

  /// Existing photo path (if editing and one was already set).
  String? _photoPath;
  File? _pendingPhoto;
  bool _removePhoto = false;

  String? _team; // Team.id, null = Sem equipa
  Turno? _turno; // only for teams split by turno
  _Funcao _funcao = _Funcao.membro;
  bool _permanencia = false;
  bool _partTime = false;

  /// The chefe slot the form would assign, or null for Membro (or a
  /// Livre Serviço chefe with no turno picked yet).
  ChefeSlot? get _chefeSlot {
    final team = teamById(_team);
    if (team == null || _funcao != _Funcao.chefe) return null;
    if (!team.hasTurnos) return team.chefeSlots.first;
    final turno = _turno;
    return turno == null ? null : chefeSlotForTurno(turno);
  }

  List<Person> _allPeople = const [];
  bool _loadingPeople = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.fullName ?? '');
    _numberCtrl = TextEditingController(text: e?.collaboratorNumber ?? '');
    _phoneCtrl = TextEditingController(text: e?.phoneNumber ?? '');
    _dob = e?.dateOfBirth;
    _hireDate = e?.hireDate;
    _photoPath = e?.photoPath;
    _team = teamById(e?.team)?.id;
    _funcao = e == null
        ? _Funcao.membro
        : chefeSlotOf(e) != null
        ? _Funcao.chefe
        : isSupervisor(e)
        ? _Funcao.supervisor
        : _Funcao.membro;
    _turno = e == null ? null : turnoOf(e);
    _permanencia = e?.permanencia ?? false;
    _partTime = e?.partTime ?? false;
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    final all = await PersonService.instance.all();
    if (!mounted) return;
    setState(() {
      _allPeople = all;
      _loadingPeople = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final person = widget.existing ?? (Person()..createdAt = DateTime.now());
    final slot = _chefeSlot;
    if (_team != null && slot != null) {
      final holder = chefeHolder(_allPeople, _team!, slot, except: person);
      if (holder != null) {
        final team = teamById(_team)!;
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(
              '${holder.fullName} é ${slot.label} de ${team.name}. '
              'Substituir?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Substituir'),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
    }
    setState(() => _saving = true);
    person.fullName = _nameCtrl.text.trim();
    person.collaboratorNumber = _numberCtrl.text.trim();
    person.phoneNumber = _phoneCtrl.text.trim().isEmpty
        ? null
        : _phoneCtrl.text.trim();
    person.dateOfBirth = _dob;
    person.hireDate = _hireDate;
    person.team = _team;
    person.turno = teamById(_team)?.hasTurnos == true ? _turno?.name : null;
    person.chefe = slot?.name;
    person.supervisor =
        _funcao == _Funcao.supervisor &&
        teamById(_team)?.hasSupervisors == true;
    person.permanencia = _permanencia;
    person.partTime = _partTime;
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
              DropdownButtonFormField<String?>(
                initialValue: _team,
                decoration: const InputDecoration(
                  labelText: 'Equipa',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final t in teams)
                    DropdownMenuItem(value: t.id, child: Text(t.name)),
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Sem equipa'),
                  ),
                ],
                onChanged: (v) => setState(() {
                  _team = v;
                  _funcao = _Funcao.membro;
                  _turno = teamById(v)?.hasTurnos == true ? Turno.dia : null;
                }),
              ),
              if (teamById(_team) case final team?) ...[
                if (team.hasTurnos) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Turno>(
                    key: ValueKey('turno-${team.id}'),
                    initialValue: _turno,
                    decoration: const InputDecoration(
                      labelText: 'Turno',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final t in Turno.values)
                        DropdownMenuItem(value: t, child: Text(t.label)),
                    ],
                    validator: (v) => v == null ? 'Obrigatório' : null,
                    onChanged: (v) => setState(() => _turno = v),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<_Funcao>(
                  key: ValueKey(team.id),
                  initialValue: _funcao,
                  decoration: const InputDecoration(
                    labelText: 'Função na equipa',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: _Funcao.membro,
                      child: Text('Membro'),
                    ),
                    if (team.hasSupervisors)
                      const DropdownMenuItem(
                        value: _Funcao.supervisor,
                        child: Text('Supervisor'),
                      ),
                    const DropdownMenuItem(
                      value: _Funcao.chefe,
                      child: Text('Chefe'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _funcao = v ?? _Funcao.membro),
                ),
              ],
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Horário',
                  border: OutlineInputBorder(),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: false, label: Text('Tempo inteiro')),
                      ButtonSegment(value: true, label: Text('Tempo parcial')),
                    ],
                    selected: {_partTime},
                    onSelectionChanged: (v) =>
                        setState(() => _partTime = v.first),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.black26),
                ),
                title: const Text('Permanência'),
                subtitle: const Text(
                  'Responsável quando não há chefia presente',
                ),
                value: _permanencia,
                onChanged: (v) => setState(() => _permanencia = v),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saving || _loadingPeople ? null : _save,
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
