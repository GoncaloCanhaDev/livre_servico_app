import 'dart:io';

import 'package:flutter/material.dart';

import '../models/person.dart';
import '../models/teams.dart';
import '../services/person_service.dart';
import 'people_sections.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';
import 'widgets/person_picker.dart';
import 'widgets/role_badge.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late Future<List<Person>> _future;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
    PersonService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    PersonService.instance.removeListener(_reload);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = PersonService.instance.all();
    });
  }

  Future<void> _openForm({Person? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PersonFormScreen(existing: existing)),
    );
  }

  void _openDetail(Person p) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PersonDetailScreen(person: p)));
  }

  Future<void> _showActions(Person p) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () => Navigator.of(ctx).pop('edit'),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text('Remover'),
              onTap: () => Navigator.of(ctx).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'edit') {
      await _openForm(existing: p);
    } else if (action == 'delete') {
      await _confirmDelete(p);
    }
  }

  Future<void> _confirmDelete(Person p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover pessoa'),
        content: Text('Queres remover "${p.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await PersonService.instance.delete(p.id);
    }
  }

  Future<void> _confirmDeleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover todas as pessoas'),
        content: const Text(
          'Tens a certeza que queres remover TODAS as pessoas? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover Tudo'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await PersonService.instance.deleteAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openForm()),
          IconButton(
            tooltip: 'Remover todas as pessoas',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _confirmDeleteAll,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Person>>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data!;
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sem pessoas.\nUsa o + para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }
            final sections = buildPeopleSections(
              items,
              query: _searchCtrl.text,
            );
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      peopleCountText(items, query: _searchCtrl.text),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                _SearchField(
                  controller: _searchCtrl,
                  onChanged: () => setState(() {}),
                ),
                Expanded(
                  child: sections.isEmpty
                      ? const Center(
                          child: Text(
                            'Sem resultados.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : _PeopleList(
                          sections: sections,
                          onTap: _openDetail,
                          onLongPress: _showActions,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText: 'Procurar por nome, equipa ou nº',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onChanged();
                  },
                ),
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// The list view: [sections] from [buildPeopleSections], each under a
/// "Team (count)" header, with dividers between people.
class _PeopleList extends StatelessWidget {
  const _PeopleList({
    required this.sections,
    required this.onTap,
    required this.onLongPress,
  });

  final List<PeopleSection> sections;
  final void Function(Person) onTap;
  final void Function(Person) onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        for (final section in sections) ...[
          _SectionHeader('${section.title} (${section.people.length})'),
          for (final (i, p) in section.people.indexed) ...[
            if (i > 0) const Divider(height: 1),
            _PersonTile(
              person: p,
              onTap: () => onTap(p),
              onLongPress: () => onLongPress(p),
            ),
          ],
        ],
      ],
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.person,
    required this.onTap,
    required this.onLongPress,
  });

  final Person person;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final p = person;
    final hasPhoto = p.photoPath != null && File(p.photoPath!).existsSync();
    return ListTile(
      leading: hasPhoto
          ? CircleAvatar(backgroundImage: FileImage(File(p.photoPath!)))
          : PersonInitialsBadge(name: p.fullName),
      title: Wrap(
        spacing: 6,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
          for (final tag in roleTagsOf(p)) RoleBadge(tag),
        ],
      ),
      subtitle: Text(
        [
          if (p.partTime) 'Tempo parcial',
          if (p.collaboratorNumber.isNotEmpty) 'Nº ${p.collaboratorNumber}',
        ].join(' · '),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}
