import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/account_service.dart';
import '../services/person_service.dart';
import '../theme.dart';
import 'claim_person_screen.dart';

/// Conta → Membros: who is in the store, and which person each account is.
/// Chefes, Gerência and the owner approve or refuse requests to join. The
/// owner shares the store's code (anyone with it can ask to join), adds
/// people by the email of their account, unlinks them from a person and
/// removes them.
class StoreMembersScreen extends StatefulWidget {
  const StoreMembersScreen({super.key});

  @override
  State<StoreMembersScreen> createState() => _StoreMembersScreenState();
}

class _StoreMembersScreenState extends State<StoreMembersScreen> {
  final _account = AccountService.instance;
  late Future<List<StoreMember>> _members = _account.members();
  late Future<List<JoinRequest>> _requests = _loadRequests();

  Future<List<JoinRequest>> _loadRequests() =>
      _account.access.canApprove ? _account.joinRequests() : Future.value([]);

  /// Person names by `syncUuid`, for the members linked to one.
  Map<String, String> _names = const {};

  bool get _isOwner => _account.access.owner || _account.access.admin;

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final people = await PersonService.instance.all();
    if (!mounted) return;
    setState(() => _names = {for (final p in people) p.syncUuid: p.fullName});
  }

  String _subtitle(StoreMember m) {
    final person = switch (m.personId) {
      null => 'sem pessoa',
      final id => _names[id] ?? 'pessoa ainda não sincronizada',
    };
    return '${m.role.label} · $person';
  }

  void _reload() => setState(() {
    _members = _account.members();
    _requests = _loadRequests();
  });

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
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar pessoa'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email da conta',
            helperText: 'A pessoa tem de ter criado a conta.',
            border: OutlineInputBorder(),
          ),
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
    );
    if (email == null || email.isEmpty) return;
    await _run(() => _account.setMember(email, StoreRole.editor));
  }

  /// Picks, from the people without an account, who [m] is.
  Future<void> _link(StoreMember m) async {
    final List<UnlinkedPerson> people;
    try {
      people = await _account.unlinkedPeople();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(accountErrorText(e))));
      return;
    }
    if (!mounted) return;
    final choice = await Navigator.push<({String? personId, String? name})>(
      context,
      MaterialPageRoute(
        builder: (_) => ClaimPersonScreen(
          storeName: _account.store!.name,
          people: people,
          canAddNew: false,
        ),
      ),
    );
    final id = choice?.personId;
    if (id == null) return;
    await _run(() => _account.linkMember(m.userId, id));
    _loadNames();
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
            if (m.personId == null)
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Ligar a uma pessoa'),
                subtitle: const Text('Quem é na lista de pessoas da loja.'),
                onTap: () => Navigator.pop(ctx, 'link'),
              ),
            if (m.personId != null)
              ListTile(
                leading: const Icon(Icons.link_off),
                title: const Text('Desligar da pessoa'),
                subtitle: Text(
                  '${_names[m.personId] ?? 'A pessoa'} volta a poder ser '
                  'escolhida.',
                ),
                onTap: () => Navigator.pop(ctx, 'unlink'),
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
    if (choice == 'link' && mounted) {
      await _link(m);
    } else if (choice == 'unlink') {
      await _run(() => _account.unlinkMember(m.userId));
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
              if (_isOwner) const _JoinCodeCard(),
              _Requests(
                requests: _requests,
                onApprove: (r) => _run(() => _account.approveJoin(r.userId)),
                onRefuse: (r) => _run(() => _account.refuseJoin(r.userId)),
              ),
              for (final m in members)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(m.email),
                  subtitle: Text(_subtitle(m)),
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

/// "Pedidos para entrar": the requests waiting for approval, if any.
class _Requests extends StatelessWidget {
  const _Requests({
    required this.requests,
    required this.onApprove,
    required this.onRefuse,
  });

  final Future<List<JoinRequest>> requests;
  final ValueChanged<JoinRequest> onApprove;
  final ValueChanged<JoinRequest> onRefuse;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<JoinRequest>>(
    future: requests,
    builder: (context, snap) {
      if (snap.hasError) {
        return ListTile(
          leading: const Icon(Icons.error_outline),
          title: Text(accountErrorText(snap.error!)),
        );
      }
      final list = snap.data ?? const [];
      if (list.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Pedidos para entrar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          for (final r in list)
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: Text(r.email),
              subtitle: Text(
                r.requestedName != null
                    ? 'Novo: ${r.requestedName}'
                    : 'É: ${r.personName ?? 'pessoa apagada'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Recusar',
                    icon: const Icon(Icons.close),
                    onPressed: () => onRefuse(r),
                  ),
                  IconButton(
                    tooltip: 'Aprovar',
                    icon: const Icon(Icons.check),
                    onPressed: () => onApprove(r),
                  ),
                ],
              ),
            ),
          const Divider(),
        ],
      );
    },
  );
}

/// The store's join code, for the owner to share: with it, someone signed
/// in picks who they are in the list of people and asks to join.
class _JoinCodeCard extends StatefulWidget {
  const _JoinCodeCard();

  @override
  State<_JoinCodeCard> createState() => _JoinCodeCardState();
}

class _JoinCodeCardState extends State<_JoinCodeCard> {
  late Future<String> _code = AccountService.instance.joinCode();

  /// "K7QM2XPA" as "K7QM-2XPA", easier to read out.
  String _shown(String code) =>
      code.length == 8 ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo código'),
        content: const Text(
          'O código atual deixa de funcionar. Quem já entrou na loja '
          'continua nela.',
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
    if (ok == true) {
      setState(() => _code = AccountService.instance.resetJoinCode());
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<String>(
        future: _code,
        builder: (context, snap) {
          final code = snap.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Código da loja',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Quem tiver o código pede para entrar e diz quem é na lista '
                'de pessoas; um chefe, a gerência ou o dono aprova. '
                'Partilhe-o só com a equipa.',
                style: TextStyle(color: context.muted),
              ),
              const SizedBox(height: 12),
              if (snap.hasError)
                Text(accountErrorText(snap.error!))
              else if (code == null)
                const LinearProgressIndicator()
              else
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _shown(code),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copiar',
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _shown(code)));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código copiado.')),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Novo código',
                      icon: const Icon(Icons.refresh),
                      onPressed: _reset,
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    ),
  );
}
