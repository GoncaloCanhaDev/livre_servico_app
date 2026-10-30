import 'package:flutter/material.dart';

import '../services/account_service.dart';
import '../theme.dart';

/// Conta → Membros: who is in the store. The owner adds people by the email
/// of their account, changes their role and removes them.
class StoreMembersScreen extends StatefulWidget {
  const StoreMembersScreen({super.key});

  @override
  State<StoreMembersScreen> createState() => _StoreMembersScreenState();
}

class _StoreMembersScreenState extends State<StoreMembersScreen> {
  final _account = AccountService.instance;
  late Future<List<StoreMember>> _members = _account.members();

  bool get _isOwner => _account.store?.role == StoreRole.owner;

  void _reload() => setState(() => _members = _account.members());

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accountErrorText(e)),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Future<void> _add() async {
    final ctrl = TextEditingController();
    var role = StoreRole.editor;
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Adicionar pessoa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email da conta',
                  helperText: 'A pessoa tem de ter criado a conta.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _RolePicker(
                value: role,
                onChanged: (r) => setDialog(() => role = r),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (email == null || email.isEmpty) return;
    await _run(() => _account.setMember(email, role));
  }

  Future<void> _edit(StoreMember m) async {
    final choice = await showModalBottomSheet<Object>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                m.email,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            for (final r in StoreRole.values)
              ListTile(
                leading: Icon(
                  r == m.role
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(r.label),
                onTap: () => Navigator.pop(ctx, r),
              ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text(
                'Remover da loja',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (choice is StoreRole && choice != m.role) {
      await _run(() => _account.setMember(m.email, choice));
    } else if (choice == 'remove' && mounted) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remover da loja'),
          content: Text('${m.email} deixa de poder abrir os dados da loja.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remover'),
            ),
          ],
        ),
      );
      if (ok == true) await _run(() => _account.removeMember(m.userId));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Membros')),
    floatingActionButton: _isOwner
        ? FloatingActionButton.extended(
            onPressed: _add,
            icon: const Icon(Icons.person_add),
            label: const Text('Adicionar'),
          )
        : null,
    body: SafeArea(
      child: FutureBuilder<List<StoreMember>>(
        future: _members,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(accountErrorText(snap.error!)),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Tentar outra vez'),
                  ),
                ],
              ),
            );
          }
          final members = snap.data;
          if (members == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (_isOwner)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Edição: lê e altera os dados. Só leitura: só lê. Dono: '
                    'também gere quem pertence à loja.',
                    style: TextStyle(color: context.muted),
                  ),
                ),
              for (final m in members)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(m.email),
                  subtitle: Text(m.role.label),
                  // The owner manages the others, never themselves.
                  onTap: _isOwner && m.email != _account.email
                      ? () => _edit(m)
                      : null,
                ),
            ],
          );
        },
      ),
    ),
  );
}

class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.value, required this.onChanged});

  final StoreRole value;
  final ValueChanged<StoreRole> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<StoreRole>(
    segments: [
      for (final r in StoreRole.values)
        ButtonSegment(value: r, label: Text(r.label)),
    ],
    selected: {value},
    showSelectedIcon: false,
    onSelectionChanged: (s) => onChanged(s.single),
  );
}
