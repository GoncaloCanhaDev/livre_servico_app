import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/person.dart';
import '../models/store_access.dart';
import '../models/planning.dart';
import '../models/teams.dart';
import '../services/account_service.dart';
import '../services/person_service.dart';
import '../services/photo_store.dart';
import '../services/sync_meta.dart';
import '../theme.dart';
import 'widgets/edit_lock.dart';

part 'person_form/ausencia_dialog.dart';
part 'person_form/fields.dart';

/// Full-screen add/edit form for a [Person]: identity fields, team and
/// roles, planning (horário, folgas, ausências), dates, notes and a profile
/// picture. Used both from
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
  late final TextEditingController _weeklyHoursCtrl;

  int? _birthDay;
  int? _birthMonth;
  Genero? _genero;
  DateTime? _hireDate;
  DateTime? _storeStart;

  int? _shiftStart; // minutes after midnight
  int? _shiftEnd;
  late final Set<int> _folgas; // DateTime.weekday values
  late final List<Ausencia> _ausencias;

  /// One field per existing note, plus [_newNoteCtrl] for the next one.
  late final List<TextEditingController> _noteCtrls;
  final _newNoteCtrl = TextEditingController();

  /// Existing photo path (if editing and one was already set).
  String? _photoPath;
  Uint8List? _pendingPhoto;
  bool _removePhoto = false;

  String? _team; // Team.id, null = Sem equipa
  Turno? _turno; // only for teams split by turno
  bool _isChefe = false;
  bool _supervisor = false;
  bool _segundaLinha = false;
  bool _permanencia = false;
  bool _partTime = false;

  /// The chefe slot the form would assign, or null for Membro (or a
  /// Livre Serviço chefe with no turno picked yet).
  ChefeSlot? get _chefeSlot {
    final team = teamById(_team);
    if (team == null || !_isChefe) return null;
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
    _weeklyHoursCtrl = TextEditingController(
      text: e?.weeklyHours?.toString() ?? '',
    );
    _birthDay = e?.birthDay;
    _birthMonth = e?.birthMonth;
    _genero = e?.genero;
    _hireDate = e?.hireDate;
    _storeStart = e?.storeStartDate;
    _shiftStart = e?.shiftStart;
    _shiftEnd = e?.shiftEnd;
    _folgas = {...?e?.folgas};
    _ausencias = [
      for (final a in e?.ausencias ?? const <Ausencia>[])
        Ausencia()
          ..tipo = a.tipo
          ..start = a.start
          ..end = a.end,
    ];
    _noteCtrls = [
      for (final n in e?.notes ?? const <String>[])
        TextEditingController(text: n),
    ];
    _photoPath = e?.photoPath;
    _team = teamById(e?.team)?.id;
    _isChefe = e != null && chefeSlotOf(e) != null;
    _supervisor = e != null && isSupervisor(e);
    _segundaLinha = e != null && isSegundaLinha(e);
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
    _weeklyHoursCtrl.dispose();
    for (final c in _noteCtrls) {
      c.dispose();
    }
    _newNoteCtrl.dispose();
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
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _pendingPhoto = bytes;
      _removePhoto = false;
    });
  }

  bool get _hasPhotoPreview =>
      _pendingPhoto != null || (!_removePhoto && _photoPath != null);

  Future<void> _pickDate(
    String helpText,
    DateTime? current,
    ValueChanged<DateTime> onPicked,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
      locale: const Locale('pt', 'PT'),
      helpText: helpText,
    );
    if (picked == null) return;
    setState(() => onPicked(picked));
  }

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _shiftStart : _shiftEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay(hour: start ? 7 : 15, minute: 0)
          : TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: start ? 'Entrada' : 'Saída',
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      if (start) {
        _shiftStart = minutes;
      } else {
        _shiftEnd = minutes;
      }
    });
  }

  /// Adds an ausência, or edits [existing] in place.
  Future<void> _editAusencia([Ausencia? existing]) async {
    final result = await showDialog<Ausencia>(
      context: context,
      builder: (_) => _AusenciaDialog(existing: existing),
    );
    if (result == null) return;
    setState(() {
      if (existing == null) {
        _ausencias.add(result);
      } else {
        existing
          ..tipo = result.tipo
          ..start = result.start
          ..end = result.end;
      }
      _ausencias.sort((a, b) => a.start.compareTo(b.start));
    });
  }

  /// Turns the text in the new-note field into a note of its own.
  void _addNote() {
    final text = _newNoteCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _noteCtrls.add(TextEditingController(text: text));
      _newNoteCtrl.clear();
    });
  }

  void _removeNote(TextEditingController c) {
    setState(() => _noteCtrls.remove(c));
    WidgetsBinding.instance.addPostFrameCallback((_) => c.dispose());
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
    // Both or neither: half a birthday says nothing.
    final hasBirthday = _birthDay != null && _birthMonth != null;
    person.birthDay = hasBirthday ? _birthDay : null;
    person.birthMonth = hasBirthday ? _birthMonth : null;
    person.genero = _genero;
    person.hireDate = _hireDate;
    person.storeStartDate = _storeStart;
    person.weeklyHours = int.tryParse(_weeklyHoursCtrl.text.trim());
    person.shiftStart = _shiftStart;
    person.shiftEnd = _shiftEnd;
    person.folgas = _folgas.toList()..sort();
    person.ausencias = _ausencias;
    person.notes = [
      for (final c in [..._noteCtrls, _newNoteCtrl])
        if (c.text.trim().isNotEmpty) c.text.trim(),
    ];
    person.team = _team;
    person.turno = teamById(_team)?.hasTurnos == true ? _turno?.name : null;
    person.chefe = slot?.name;
    final team = teamById(_team);
    person.supervisor =
        _supervisor && slot == null && team?.hasSupervisors == true;
    person.segundaLinha =
        _segundaLinha && slot == null && team?.hasSegundaLinha == true;
    person.permanencia = _permanencia;
    person.partTime = _partTime;
    SyncMeta.stamp(person);

    var photoPath = _photoPath;
    if (_pendingPhoto case final bytes?) {
      if (photoPath != null) await PhotoStore.instance.remove(photoPath);
      photoPath = await PhotoStore.instance.add(bytes);
    } else if (_removePhoto && photoPath != null) {
      await PhotoStore.instance.remove(photoPath);
      photoPath = null;
    }
    person.photoPath = photoPath;

    await PersonService.instance.save(person);
    if (mounted) Navigator.of(context).pop(person);
  }

  /// Whether this account changes [group] of the person: everything for a
  /// new one (only those who may add people get here).
  bool _can(PersonFieldGroup group) => switch (widget.existing) {
    null => true,
    final p => AccountService.instance.access.canEdit(p, group),
  };

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final dateFmt = DateFormat("d 'de' MMMM y", 'pt_PT');
    final self = _can(PersonFieldGroup.self);
    final schedule = _can(PersonFieldGroup.schedule);
    final role = _can(PersonFieldGroup.role);
    final other = _can(PersonFieldGroup.other);
    // The server sends no more of others' people; this hides empty fields.
    final personal = switch (widget.existing) {
      null => true,
      final p => AccountService.instance.access.canSeePersonal(p),
    };
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar pessoa' : 'Nova pessoa')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              EditLock(
                enabled: self,
                child: _PhotoButton(
                  photo: switch (_pendingPhoto) {
                    final bytes? => MemoryImage(bytes),
                    null when _hasPhotoPreview => PhotoImage(_photoPath!),
                    null => null,
                  },
                  onTap: _pickPhoto,
                ),
              ),
              const SizedBox(height: 8),
              const _FormHeading('Pessoa'),
              EditLock(
                enabled: self,
                child: TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
              ),
              if (personal) ...[
                const SizedBox(height: 12),
                EditLock(
                  enabled: other,
                  child: TextFormField(
                    controller: _numberCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nº colaborador (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              EditLock(
                enabled: self,
                child: _BirthdayField(
                  day: _birthDay,
                  month: _birthMonth,
                  onDay: (d) => setState(() => _birthDay = d),
                  onMonth: (m) => setState(() => _birthMonth = m),
                ),
              ),
              const SizedBox(height: 12),
              EditLock(
                enabled: self,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Género (opcional)',
                    helperText: 'Para escrever "Novo" ou "Nova"',
                    border: OutlineInputBorder(),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<Genero>(
                      showSelectedIcon: false,
                      emptySelectionAllowed: true,
                      segments: [
                        for (final g in Genero.values)
                          ButtonSegment(value: g, label: Text(g.label)),
                      ],
                      selected: {?_genero},
                      onSelectionChanged: (v) =>
                          setState(() => _genero = v.firstOrNull),
                    ),
                  ),
                ),
              ),
              const _FormHeading('Equipa'),
              EditLock(
                enabled: role,
                child: DropdownButtonFormField<String?>(
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
                    _isChefe = false;
                    _supervisor = false;
                    _segundaLinha = false;
                    _turno = teamById(v)?.hasTurnos == true ? Turno.dia : null;
                  }),
                ),
              ),
              if (teamById(_team) case final team?) ...[
                if (team.hasTurnos) ...[
                  const SizedBox(height: 12),
                  EditLock(
                    enabled: role,
                    child: DropdownButtonFormField<Turno>(
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
                  ),
                ],
                if (team.chefeSlots.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  EditLock(
                    enabled: role,
                    child: DropdownButtonFormField<bool>(
                      key: ValueKey(team.id),
                      initialValue: _isChefe,
                      decoration: const InputDecoration(
                        labelText: 'Função na equipa',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: false, child: Text('Membro')),
                        DropdownMenuItem(value: true, child: Text('Chefe')),
                      ],
                      onChanged: (v) => setState(() {
                        _isChefe = v ?? false;
                        if (_isChefe) {
                          _supervisor = false;
                          _segundaLinha = false;
                        }
                      }),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 12),
              EditLock(
                enabled: role,
                child: _TagsField(
                  team: teamById(_team),
                  isChefe: _isChefe,
                  supervisor: _supervisor,
                  segundaLinha: _segundaLinha,
                  permanencia: _permanencia,
                  onSupervisor: (v) => setState(() => _supervisor = v),
                  onSegundaLinha: (v) => setState(() => _segundaLinha = v),
                  onPermanencia: (v) => setState(() => _permanencia = v),
                ),
              ),
              if (personal) ...[
                const _FormHeading('Planeamento'),
                EditLock(
                  enabled: other,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Horário',
                      border: OutlineInputBorder(),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Tempo inteiro'),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Tempo parcial'),
                          ),
                        ],
                        selected: {_partTime},
                        onSelectionChanged: (v) =>
                            setState(() => _partTime = v.first),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                EditLock(
                  enabled: other,
                  child: TextFormField(
                    controller: _weeklyHoursCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Horas por semana (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final text = v?.trim() ?? '';
                      if (text.isEmpty) return null;
                      final h = int.tryParse(text);
                      return h == null || h < 1 || h > 80
                          ? 'Entre 1 e 80'
                          : null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                EditLock(
                  enabled: other,
                  child: _ShiftField(
                    start: _shiftStart,
                    end: _shiftEnd,
                    onPick: (start) => _pickTime(start: start),
                    onClear: () => setState(() {
                      _shiftStart = null;
                      _shiftEnd = null;
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                EditLock(
                  enabled: schedule,
                  child: _FolgasField(
                    folgas: _folgas,
                    onToggle: (d, off) => setState(() {
                      if (off) {
                        _folgas.add(d);
                      } else {
                        _folgas.remove(d);
                      }
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                EditLock(
                  enabled: schedule,
                  child: _AusenciasField(
                    ausencias: _ausencias,
                    onEdit: _editAusencia,
                    onRemove: (a) => setState(() => _ausencias.remove(a)),
                  ),
                ),
                const _FormHeading('Datas'),
                EditLock(
                  enabled: other,
                  child: _DateRow(
                    label: 'Início na loja',
                    value: _storeStart,
                    formatted: _storeStart == null
                        ? null
                        : dateFmt.format(_storeStart!),
                    onTap: () => _pickDate(
                      'Início na loja',
                      _storeStart,
                      (d) => _storeStart = d,
                    ),
                    onClear: () => setState(() => _storeStart = null),
                  ),
                ),
                const SizedBox(height: 12),
                EditLock(
                  enabled: other,
                  child: _DateRow(
                    label: 'Início no Pingo Doce',
                    value: _hireDate,
                    formatted: _hireDate == null
                        ? null
                        : dateFmt.format(_hireDate!),
                    onTap: () => _pickDate(
                      'Início no Pingo Doce',
                      _hireDate,
                      (d) => _hireDate = d,
                    ),
                    onClear: () => setState(() => _hireDate = null),
                  ),
                ),
                const _FormHeading('Notas'),
                EditLock(
                  enabled: self,
                  child: _NotesField(
                    notes: _noteCtrls,
                    newNote: _newNoteCtrl,
                    onAdd: _addNote,
                    onRemove: _removeNote,
                  ),
                ),
              ],
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
