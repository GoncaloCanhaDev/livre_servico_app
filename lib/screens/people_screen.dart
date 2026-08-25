import 'dart:io';

import 'package:flutter/material.dart';

import '../models/person.dart';
import '../services/person_service.dart';
import '../theme.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';
import 'widgets/org_chart.dart';
import 'widgets/person_picker.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late Future<List<Person>> _future;
  bool _listView = false;

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
            tooltip: _listView ? 'Ver organograma' : 'Ver lista',
            icon: Icon(_listView ? Icons.account_tree_outlined : Icons.list),
            onPressed: () => setState(() => _listView = !_listView),
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
            if (_listView) {
              return _PeopleList(
                people: items,
                onTap: _openDetail,
                onLongPress: _showActions,
              );
            }
            final byManager = PersonService.instance.groupByManager(items);
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
      itemBuilder: (_, i) {
        final p = people[i];
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
          onTap: () => onTap(p),
          onLongPress: () => onLongPress(p),
        );
      },
    );
  }
}
