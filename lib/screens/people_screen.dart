import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/person.dart';
import '../services/person_service.dart';
import '../services/settings_service.dart';
import 'people_sections.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';
import 'widgets/person_picker.dart';

enum _ViewMode { list, teams }

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late Future<List<Person>> _future;
  _ViewMode _viewMode = _ViewMode.list;

  static const _viewModeLabel = {
    _ViewMode.list: 'Ver lista',
    _ViewMode.teams: 'Ver equipas',
  };

  static const _viewModeIcon = {
    _ViewMode.list: Icons.list,
    _ViewMode.teams: Icons.groups_outlined,
  };

  _ViewMode get _nextViewMode =>
      _viewMode == _ViewMode.list ? _ViewMode.teams : _ViewMode.list;

  PeopleSort _sort =
      PeopleSort.values.asNameMap()[SettingsService.instance.peopleSort] ??
      PeopleSort.name;
  final _searchCtrl = TextEditingController();

  static const _sortLabel = {
    PeopleSort.name: 'Nome',
    PeopleSort.role: 'Cargo',
    PeopleSort.number: 'Nº de colaborador',
    PeopleSort.seniority: 'Antiguidade',
  };

  void _setSort(PeopleSort sort) {
    setState(() => _sort = sort);
    SettingsService.instance.setPeopleSort(sort.name);
  }

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
        content: Text(
          'Queres remover "${p.fullName}"? Quem lhe reportava deixa de o ter como responsável; quem ficar sem responsáveis passa para o topo da hierarquia.',
        ),
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
          IconButton(
            tooltip: _viewModeLabel[_nextViewMode],
            icon: Icon(_viewModeIcon[_nextViewMode]),
            onPressed: () => setState(() => _viewMode = _nextViewMode),
          ),
          if (_viewMode == _ViewMode.list)
            PopupMenuButton<PeopleSort>(
              tooltip: 'Ordenar',
              icon: const Icon(Icons.sort),
              onSelected: _setSort,
              itemBuilder: (_) => [
                for (final sort in PeopleSort.values)
                  CheckedPopupMenuItem(
                    value: sort,
                    checked: sort == _sort,
                    child: Text(_sortLabel[sort]!),
                  ),
              ],
            ),
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
            if (_viewMode == _ViewMode.list) {
              final sections = buildPeopleSections(
                items,
                sort: _sort,
                query: _searchCtrl.text,
              );
              return Column(
                children: [
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
                            showCounts: _sort == PeopleSort.role,
                            showHireDate: _sort == PeopleSort.seniority,
                            onTap: _openDetail,
                            onLongPress: _showActions,
                          ),
                  ),
                ],
              );
            }
            return _TeamsList(
              byManager: PersonService.instance.groupByManager(items),
              onTap: _openDetail,
              onLongPress: _showActions,
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
          hintText: 'Procurar por nome, cargo ou nº',
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

/// The list view: [sections] from [buildPeopleSections], each under its
/// header (if it has one), with dividers between people.
class _PeopleList extends StatelessWidget {
  const _PeopleList({
    required this.sections,
    required this.showCounts,
    required this.showHireDate,
    required this.onTap,
    required this.onLongPress,
  });

  final List<PeopleSection> sections;
  final bool showCounts;
  final bool showHireDate;
  final void Function(Person) onTap;
  final void Function(Person) onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        for (final section in sections) ...[
          if (section.title != null)
            _SectionHeader(
              showCounts
                  ? '${section.title} (${section.people.length})'
                  : section.title!,
            ),
          for (final (i, p) in section.people.indexed) ...[
            if (i > 0) const Divider(height: 1),
            _PersonTile(
              person: p,
              showHireDate: showHireDate,
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
    this.showHireDate = false,
  });

  final Person person;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool showHireDate;

  @override
  Widget build(BuildContext context) {
    final p = person;
    final hasPhoto = p.photoPath != null && File(p.photoPath!).existsSync();
    return ListTile(
      leading: hasPhoto
          ? CircleAvatar(backgroundImage: FileImage(File(p.photoPath!)))
          : PersonInitialsBadge(name: p.fullName),
      title: Text(
        p.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          if (p.role != null && p.role!.isNotEmpty) p.role!,
          if (p.collaboratorNumber.isNotEmpty) 'Nº ${p.collaboratorNumber}',
          if (showHireDate && p.hireDate != null)
            'desde ${DateFormat('MM/yyyy').format(p.hireDate!)}',
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

class _TeamSection extends StatelessWidget {
  const _TeamSection({
    required this.title,
    required this.people,
    required this.onTap,
    required this.onLongPress,
  });

  final String title;
  final List<Person> people;
  final void Function(Person) onTap;
  final void Function(Person) onLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title),
        for (final p in people)
          _PersonTile(
            person: p,
            onTap: () => onTap(p),
            onLongPress: () => onLongPress(p),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

/// Renders [byManager] (see `PersonService.groupByManager`) as sections —
/// one per manager who has direct reports, plus "Topo da hierarquia" for
/// the `null` key. A person reporting to two managers appears in both
/// their sections.
class _TeamsList extends StatelessWidget {
  const _TeamsList({
    required this.byManager,
    required this.onTap,
    required this.onLongPress,
  });

  final Map<String?, List<Person>> byManager;
  final void Function(Person) onTap;
  final void Function(Person) onLongPress;

  @override
  Widget build(BuildContext context) {
    final allPeople = {
      for (final list in byManager.values)
        for (final p in list) p.syncUuid: p,
    };
    final sections =
        byManager.keys.whereType<String>().map((uuid) {
          final name = allPeople[uuid]?.fullName ?? '—';
          return MapEntry(name, byManager[uuid]!);
        }).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final roots = byManager[null] ?? const <Person>[];

    return ListView(
      children: [
        if (roots.isNotEmpty)
          _TeamSection(
            title: 'Topo da hierarquia',
            people: roots,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        for (final section in sections)
          _TeamSection(
            title: section.key,
            people: section.value,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
      ],
    );
  }
}
