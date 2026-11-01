import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/account_service.dart';
import '../theme.dart';
import 'widgets/wide_layout.dart';

/// "Mudanças de loja", for the app's admin: who asked to move to another
/// store and where to (their note); choosing the store moves them, with
/// their person.
class StoreTransfersScreen extends StatefulWidget {
  const StoreTransfersScreen({super.key});

  @override
  State<StoreTransfersScreen> createState() => _StoreTransfersScreenState();
}

class _StoreTransfersScreenState extends State<StoreTransfersScreen> {
  final _account = AccountService.instance;
  late Future<List<TransferRequest>> _requests = _account.transferRequests();

  void _reload() => setState(() => _requests = _account.transferRequests());

  void _showError(Object e) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(accountErrorText(e)),
      duration: const Duration(seconds: 6),
    ),
  );

  /// Picks the store [r] goes to, confirms, and moves them.
  Future<void> _move(TransferRequest r) async {
    final List<StoreInfo> stores;
    try {
      stores = await _account.myStores();
    } catch (e) {
      if (mounted) _showError(e);
      return;
    }
    if (!mounted) return;
    final who = r.personName ?? r.email;
    final to = await showModalBottomSheet<StoreInfo>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                'Mudar $who para',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            for (final s in stores)
              if (s.id != r.fromStore)
                ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(s.name),
                  onTap: () => Navigator.pop(ctx, s),
                ),
          ],
        ),
      ),
    );
    if (to == null || !mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mudar de loja'),
        content: Text(
          '$who passa de ${r.fromStoreName} para ${to.name}, com o seu '
          'perfil. O histórico fica em ${r.fromStoreName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mudar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _account.transferMember(r.userId, r.fromStore, to.id);
    } catch (e) {
      if (mounted) _showError(e);
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mudanças de loja')),
    body: ReadableWidth(
      child: SafeArea(
        child: FutureBuilder<List<TransferRequest>>(
          future: _requests,
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
            final list = snap.data;
            if (list == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (list.isEmpty) {
              return Center(
                child: Text(
                  'Ninguém pediu para mudar de loja.',
                  style: TextStyle(color: context.muted),
                ),
              );
            }
            final when = DateFormat('d/M', 'pt_PT');
            return ListView(
              children: [
                for (final r in list)
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: Text(r.personName ?? r.email),
                    subtitle: Text(
                      [
                        '${r.fromStoreName} · ${when.format(r.createdAt)}',
                        if (r.note.isNotEmpty) r.note,
                      ].join('\n'),
                    ),
                    isThreeLine: r.note.isNotEmpty,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _move(r),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
