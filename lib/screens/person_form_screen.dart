import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/person.dart';
import '../models/planning.dart';
import '../models/teams.dart';
import '../services/person_service.dart';
import '../services/sync_meta.dart';
import '../theme.dart';

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
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _weeklyHoursCtrl;

  DateTime? _dob;
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
  File? _pendingPhoto;
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
    _phoneCtrl = TextEditingController(text: e?.phoneNumber ?? '');
    _weeklyHoursCtrl = TextEditingController(
      text: e?.weeklyHours?.toString() ?? '',
    );
    _dob = e?.dateOfBirth;
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
    _phoneCtrl.dispose();
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
    if (picked == null || !mounted) return;
    setState(() {
      _pendingPhoto = File(picked.path);
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
    person.phoneNumber = _phoneCtrl.text.trim().isEmpty
        ? null
        : _phoneCtrl.text.trim();
    person.dateOfBirth = _dob;
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

  /// Tick-chips for the tags the chosen team allows (a chefe can only have
  /// Permanência).
  Widget _tagsField() {
    final team = teamById(_team);
    final canTag = !_isChefe;
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Tags',
        helperText: 'Permanência: responsável quando não há chefia presente',
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (canTag && team?.hasSupervisors == true)
            FilterChip(
              label: const Text('Supervisor'),
              selected: _supervisor,
              onSelected: (v) => setState(() => _supervisor = v),
            ),
          if (canTag && team?.hasSegundaLinha == true)
            FilterChip(
              label: const Text('Segunda Linha'),
              selected: _segundaLinha,
              onSelected: (v) => setState(() => _segundaLinha = v),
            ),
          FilterChip(
            label: const Text('Permanência'),
            selected: _permanencia,
            onSelected: (v) => setState(() => _permanencia = v),
          ),
        ],
      ),
    );
  }

  /// Entrada and saída times, each optional.
  Widget _shiftField() {
    Widget button(bool start) {
      final value = start ? _shiftStart : _shiftEnd;
      return Expanded(
        child: OutlinedButton(
          onPressed: () => _pickTime(start: start),
          child: Text(
            value == null ? (start ? 'Entrada' : 'Saída') : timeText(value),
          ),
        ),
      );
    }

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Entrada e saída (opcional)',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          button(true),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('–'),
          ),
          button(false),
          if (_shiftStart != null || _shiftEnd != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => setState(() {
                _shiftStart = null;
                _shiftEnd = null;
              }),
            ),
        ],
      ),
    );
  }

  /// A chip per weekday; ticked days are the person's weekly folgas.
  Widget _folgasField() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Folgas',
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (var d = DateTime.monday; d <= DateTime.sunday; d++)
            FilterChip(
              label: Text(weekdayShort[d - 1]),
              showCheckmark: false,
              selected: _folgas.contains(d),
              onSelected: (v) => setState(() {
                if (v) {
                  _folgas.add(d);
                } else {
                  _folgas.remove(d);
                }
              }),
            ),
        ],
      ),
    );
  }

  /// The person's ausências (tap to edit, ✕ to remove) and an add button.
  Widget _ausenciasField() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Férias e ausências',
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in _ausencias)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(a.tipo.label),
              subtitle: Text(ausenciaRangeText(a)),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _ausencias.remove(a)),
              ),
              onTap: () => _editAusencia(a),
            ),
          TextButton.icon(
            onPressed: _editAusencia,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar ausência'),
          ),
        ],
      ),
    );
  }

  /// One editable field per note, then an empty field whose text becomes a
  /// new note on enter or +.
  Widget _notesField() {
    return Column(
      children: [
        for (final c in _noteCtrls)
          Padding(
            key: ObjectKey(c),
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: c,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _removeNote(c),
                ),
              ),
            ),
          ),
        TextField(
          controller: _newNoteCtrl,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addNote(),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Nova nota',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addNote,
            ),
          ),
        ),
      ],
    );
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
              const SizedBox(height: 8),
              const _FormHeading('Pessoa'),
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
                onTap: () =>
                    _pickDate('Data de nascimento', _dob, (d) => _dob = d),
                onClear: () => setState(() => _dob = null),
              ),
              const SizedBox(height: 12),
              InputDecorator(
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
              const _FormHeading('Equipa'),
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
                  _isChefe = false;
                  _supervisor = false;
                  _segundaLinha = false;
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
                if (team.chefeSlots.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool>(
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
                ],
              ],
              const SizedBox(height: 12),
              _tagsField(),
              const _FormHeading('Planeamento'),
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
              TextFormField(
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
                  return h == null || h < 1 || h > 80 ? 'Entre 1 e 80' : null;
                },
              ),
              const SizedBox(height: 12),
              _shiftField(),
              const SizedBox(height: 12),
              _folgasField(),
              const SizedBox(height: 12),
              _ausenciasField(),
              const _FormHeading('Datas'),
              _DateRow(
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
              const SizedBox(height: 12),
              _DateRow(
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
              const _FormHeading('Notas'),
              _notesField(),
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
        side: BorderSide(color: context.greyedFill),
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

/// A section title in the form.
class _FormHeading extends StatelessWidget {
  const _FormHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: context.colors.secondary,
        ),
      ),
    );
  }
}

/// Picks an ausência's type and dates; pops the new [Ausencia], or null.
class _AusenciaDialog extends StatefulWidget {
  const _AusenciaDialog({this.existing});

  final Ausencia? existing;

  @override
  State<_AusenciaDialog> createState() => _AusenciaDialogState();
}

class _AusenciaDialogState extends State<_AusenciaDialog> {
  late AusenciaTipo _tipo = widget.existing?.tipo ?? AusenciaTipo.ferias;
  late DateTimeRange? _range = switch (widget.existing) {
    final a? => DateTimeRange(start: a.start, end: a.end),
    null => null,
  };

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
      locale: const Locale('pt', 'PT'),
      helpText: _tipo.label,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    return AlertDialog(
      title: Text(widget.existing == null ? 'Nova ausência' : 'Ausência'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<AusenciaTipo>(
            initialValue: _tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final t in AusenciaTipo.values)
                DropdownMenuItem(value: t, child: Text(t.label)),
            ],
            onChanged: (v) => setState(() => _tipo = v ?? _tipo),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              range == null
                  ? 'Escolher datas'
                  : ausenciaRangeText(
                      Ausencia()
                        ..start = range.start
                        ..end = range.end,
                    ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: range == null
              ? null
              : () => Navigator.pop(
                  context,
                  Ausencia()
                    ..tipo = _tipo
                    ..start = range.start
                    ..end = range.end,
                ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
