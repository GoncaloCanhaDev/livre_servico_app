import 'package:flutter/material.dart';

import '../models/aviso.dart';
import '../models/person.dart';
import '../models/teams.dart';
import '../services/account_service.dart';
import '../services/aviso_service.dart';
import '../services/person_service.dart';
import 'claim_person_screen.dart';

/// Novo aviso: the text and who it goes to — whole teams the account
/// reaches and/or people picked one by one (see `recipientsFor`).
class AvisoFormScreen extends StatefulWidget {
  const AvisoFormScreen({super.key});

  @override
  State<AvisoFormScreen> createState() => _AvisoFormScreenState();
}

class _AvisoFormScreenState extends State<AvisoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();
  final _teamIds = <String?>{};
  final _personIds = <String>{};
  List<Person> _people = const [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPeople() async {
    final people = await PersonService.instance.all();
    people.sort((a, b) => a.fullName.compareTo(b.fullName));
    if (mounted) setState(() => _people = people);
  }

  /// Everyone this account may send to.
  List<Person> get _reachable {
    final ids = recipientsFor(
      AccountService.instance.access,
      _people,
      teamIds: {..._people.map((p) => p.team)},
    ).toSet();
    return [
      for (final p in _people)
        if (ids.contains(p.syncUuid)) p,
    ];
  }

  List<String> get _recipients => recipientsFor(
    AccountService.instance.access,
    _people,
    teamIds: _teamIds,
    personIds: _personIds,
  );

  Future<void> _pickPeople() async {
    final picked = {..._personIds};
    final reachable = _reachable;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Escolher pessoas'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final p in reachable)
                  CheckboxListTile(
                    value: picked.contains(p.syncUuid),
                    title: Text(p.fullName),
                    subtitle: Text(teamById(p.team)?.name ?? 'Sem equipa'),
                    onChanged: (v) => setDialog(
                      () => v == true
                          ? picked.add(p.syncUuid)
                          : picked.remove(p.syncUuid),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      setState(
        () => _personIds
          ..clear()
          ..addAll(picked),
      );
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final me = AccountService.instance.store?.personId;
    final to = _recipients;
    if (me == null || to.isEmpty) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    await AvisoService.instance.send(
      _textCtrl.text,
      to,
      fromPersonId: me,
      fromName: (await myPerson(me))?.fullName ?? '',
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          to.length == 1
              ? 'Aviso enviado a 1 pessoa'
              : 'Aviso enviado a ${to.length} pessoas',
        ),
      ),
    );
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final reachable = _reachable;
    final teamIds = [
      for (final t in [...teams.map((t) => t.id), null])
        if (reachable.any((p) => p.team == t)) t,
    ];
    final count = _recipients.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Novo aviso')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _textCtrl,
                maxLength: avisoMaxLength,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Aviso',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              const Text('Para', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final t in teamIds)
                    FilterChip(
                      label: Text(teamById(t)?.name ?? 'Sem equipa'),
                      selected: _teamIds.contains(t),
                      onSelected: (v) => setState(
                        () => v ? _teamIds.add(t) : _teamIds.remove(t),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.person_search),
                label: Text(
                  _personIds.isEmpty
                      ? 'Escolher pessoas'
                      : 'Escolher pessoas (${_personIds.length})',
                ),
                onPressed: reachable.isEmpty ? null : _pickPeople,
              ),
              const SizedBox(height: 12),
              Text(count == 1 ? '1 pessoa' : '$count pessoas'),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Enviar'),
                onPressed: count == 0 || _sending ? null : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
