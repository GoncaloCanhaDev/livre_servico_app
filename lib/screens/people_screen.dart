import 'dart:io';

import 'package:flutter/material.dart';

import '../models/person.dart';
import '../services/person_service.dart';
import '../theme.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';
import 'widgets/org_chart.dart';
import 'widgets/person_picker.dart';

enum _ViewMode { list, teams, chart }

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late Future<List<Person>> _future;
  _ViewMode _viewMode = _ViewMode.chart;

  static const _viewModeOrder = [
    _ViewMode.chart,
    _ViewMode.list,
    _ViewMode.teams,
  ];

  static const _viewModeLabel = {
    _ViewMode.list: 'Ver lista',
    _ViewMode.teams: 'Ver equipas',
    _ViewMode.chart: 'Ver organograma',
  };

  static const _viewModeIcon = {
    _ViewMode.list: Icons.list,
    _ViewMode.teams: Icons.groups_outlined,
    _ViewMode.chart: Icons.account_tree_outlined,
  };

  _ViewMode get _nextViewMode {
    final i = _viewModeOrder.indexOf(_viewMode);
    return _viewModeOrder[(i + 1) % _viewModeOrder.length];
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
          'Queres remover "${p.fullName}"? Quem lhe reportava passa para o topo da hierarquia.',
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
              return _PeopleList(
                people: items,
                onTap: _openDetail,
                onLongPress: _showActions,
              );
            }
            final byManager = PersonService.instance.groupByManager(items);
            if (_viewMode == _ViewMode.teams) {
              return _TeamsList(
                byManager: byManager,
                onTap: _openDetail,
                onLongPress: _showActions,
              );
            }
            final roots = buildForest(byManager);
            return OrgChart(
              roots: roots,
              onTap: _openDetail,
              onLongPress: _showActions,
            );
          },
        ),
      ),
    );
  }
}

class _PeopleList extends StatelessWidget {
  const _PeopleList({
    required this.people,
    required this.onTap,
    required this.onLongPress,
  });

  final List<Person> people;
  final void Function(Person) onTap;
  final void Function(Person) onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: people.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _PersonTile(
        person: people[i],
        onTap: () => onTap(people[i]),
        onLongPress: () => onLongPress(people[i]),
      ),
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
      title: Text(
        p.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          if (p.role != null && p.role!.isNotEmpty) p.role!,
          if (p.collaboratorNumber.isNotEmpty) 'Nº ${p.collaboratorNumber}',
        ].join(' · '),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, size: 14, color: AppColors.greenDark),
            const SizedBox(width: 4),
            Text(
              '${p.points}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.greenDark,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
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
/// their sections, same as they'd appear twice in the org chart.
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
