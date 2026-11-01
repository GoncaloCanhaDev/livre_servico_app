import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/teams.dart';
import '../services/account_service.dart';
import '../theme.dart';
import 'feedback_screen.dart';
import 'store_transfers_screen.dart';
import 'widgets/wide_layout.dart';

/// "Administração", for the app's admin: what waits in every store (requests
/// to join, approved or refused right here; to move store; errors and
/// suggestions), every store with its accounts and people, and every
/// account.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _account = AccountService.instance;
  late Future<AdminSummary> _summary;
  late Future<List<AdminJoinRequest>> _requests;
  late Future<List<AdminStore>> _stores;
  late Future<List<AdminAccount>> _accounts;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _summary = _account.adminSummary();
    _requests = _account.adminJoinRequests();
    _stores = _account.adminStores();
    _accounts = _account.adminAccounts();
  }

  Future<void> _reload() async {
    setState(_load);
    try {
      await Future.wait([_summary, _requests, _stores, _accounts]);
    } catch (_) {
      // Each tab shows its own error.
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accountErrorText(e)),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
    await _reload();
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _reload();
  }

  @override
  Widget build(BuildContext context) => ResponsiveTabs(
    title: const Text('Administração'),
    actions: [
      IconButton(
        tooltip: 'Atualizar',
        icon: const Icon(Icons.refresh),
        onPressed: _reload,
      ),
    ],
    tabs: [
      (
        'Pedidos',
        _RequestsTab(
          summary: _summary,
          requests: _requests,
          onRefresh: _reload,
          onApprove: (r) => _run(
            () => _account.approveJoin(r.request.userId, storeId: r.storeId),
          ),
          onRefuse: (r) => _run(
            () => _account.refuseJoin(r.request.userId, storeId: r.storeId),
          ),
          onTransfers: () => _open(const StoreTransfersScreen()),
          onFeedback: () => _open(const FeedbackInboxScreen()),
        ),
      ),
      (
        'Lojas',
        _StoresTab(
          stores: _stores,
          onRefresh: _reload,
          onOpen: (s) => _open(_AdminStoreScreen(store: s)),
        ),
      ),
      ('Contas', _AccountsTab(accounts: _accounts, onRefresh: _reload)),
    ],
  );
}

/// [future]'s list, or its error with a retry, or a spinner while it loads;
/// pulled down, [onRefresh].
class _Loaded<T> extends StatelessWidget {
  const _Loaded({
    required this.future,
    required this.onRefresh,
    required this.builder,
  });

  final Future<T> future;
  final Future<void> Function() onRefresh;
  final List<Widget> Function(BuildContext, T) builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: future,
    builder: (context, snap) {
      if (snap.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  accountErrorText(snap.error!),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: onRefresh,
                  child: const Text('Tentar outra vez'),
                ),
              ],
            ),
          ),
        );
      }
      final data = snap.data;
      if (data == null) return const Center(child: CircularProgressIndicator());
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          children: builder(context, data),
        ),
      );
    },
  );
}

Widget _empty(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.all(24),
  child: Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(color: context.muted),
  ),
);

Widget _heading(String text) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
  child: Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  ),
);

final _day = DateFormat('d/M/y', 'pt_PT');
final _dayTime = DateFormat('d/M/y HH:mm', 'pt_PT');

/// Requests to join every store, grouped by store, with the other things
/// waiting (moves, errors and suggestions) above them.
class _RequestsTab extends StatelessWidget {
  const _RequestsTab({
    required this.summary,
    required this.requests,
    required this.onRefresh,
    required this.onApprove,
    required this.onRefuse,
    required this.onTransfers,
    required this.onFeedback,
  });

  final Future<AdminSummary> summary;
  final Future<List<AdminJoinRequest>> requests;
  final Future<void> Function() onRefresh;
  final ValueChanged<AdminJoinRequest> onApprove;
  final ValueChanged<AdminJoinRequest> onRefuse;
  final VoidCallback onTransfers;
  final VoidCallback onFeedback;

  @override
  Widget build(BuildContext context) => _Loaded<List<AdminJoinRequest>>(
    future: requests,
    onRefresh: onRefresh,
    builder: (context, list) {
      final byStore = <String, List<AdminJoinRequest>>{};
      for (final r in list) {
        (byStore[r.storeName] ??= []).add(r);
      }
      return [
        FutureBuilder<AdminSummary>(
          future: summary,
          builder: (context, snap) {
            final s = snap.data;
            return Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Mudanças de loja'),
                  subtitle: Text(switch (s?.transfers) {
                    null => '…',
                    0 => 'Nenhum pedido.',
                    1 => '1 pedido.',
                    final n => '$n pedidos.',
                  }),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onTransfers,
                ),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Erros e sugestões'),
                  subtitle: Text(switch (s?.feedback) {
                    null => '…',
                    0 => 'Nada por tratar.',
                    1 => '1 por tratar.',
                    final n => '$n por tratar.',
                  }),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onFeedback,
                ),
                const Divider(),
              ],
            );
          },
        ),
        _heading('Pedidos para entrar'),
        if (list.isEmpty)
          _empty(context, 'Ninguém está à espera de entrar.')
        else
          for (final MapEntry(key: store, value: rs) in byStore.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                store,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.muted,
                ),
              ),
            ),
            for (final r in rs)
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: Text(r.request.email),
                subtitle: Text(
                  '${r.request.requestedName != null ? 'Novo: ${r.request.requestedName}' : 'É: ${r.request.personName ?? 'pessoa apagada'}'}'
                  ' · ${_day.format(r.request.createdAt)}',
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
          ],
      ];
    },
  );
}

/// Every store, with its counts; opens one.
class _StoresTab extends StatelessWidget {
  const _StoresTab({
    required this.stores,
    required this.onRefresh,
    required this.onOpen,
  });

  final Future<List<AdminStore>> stores;
  final Future<void> Function() onRefresh;
  final ValueChanged<AdminStore> onOpen;

  @override
  Widget build(BuildContext context) => _Loaded<List<AdminStore>>(
    future: stores,
    onRefresh: onRefresh,
    builder: (context, list) => [
      if (list.isEmpty) _empty(context, 'Ainda não há lojas.'),
      for (final s in list)
        ListTile(
          leading: const Icon(Icons.store),
          title: Text(
            s.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            [
              s.members == 1 ? '1 conta' : '${s.members} contas',
              s.people == 1 ? '1 pessoa' : '${s.people} pessoas',
              if (s.pending > 0)
                s.pending == 1 ? '1 pedido' : '${s.pending} pedidos',
            ].join(' · '),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(s),
        ),
    ],
  );
}

/// What an account's line says under its email: its store and person, or
/// that it waits or has no store.
String _accountLine(AdminAccount a) => [
  if (a.isAdmin) 'Administrador',
  if (a.storeName case final s?) s else if (!a.isAdmin) 'Sem loja',
  if (a.pending) 'à espera de aprovação',
  ?a.personName,
].join(' · ');

String _lastSignIn(AdminAccount a) => switch (a.lastSignInAt) {
  final d? => 'Última entrada ${_dayTime.format(d)}',
  null => 'Conta criada ${_day.format(a.createdAt)}',
};

/// Every account, searchable by email, store or person.
class _AccountsTab extends StatefulWidget {
  const _AccountsTab({required this.accounts, required this.onRefresh});

  final Future<List<AdminAccount>> accounts;
  final Future<void> Function() onRefresh;

  @override
  State<_AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends State<_AccountsTab> {
  String _query = '';

  bool _matches(AdminAccount a) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      a.email,
      a.storeName ?? '',
      a.personName ?? '',
    ].any((t) => t.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Procurar email, loja ou pessoa',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      Expanded(
        child: _Loaded<List<AdminAccount>>(
          future: widget.accounts,
          onRefresh: widget.onRefresh,
          builder: (context, list) {
            final shown = list.where(_matches).toList();
            return [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  shown.length == 1 ? '1 conta' : '${shown.length} contas',
                  style: TextStyle(color: context.muted),
                ),
              ),
              if (shown.isEmpty) _empty(context, 'Nenhuma conta encontrada.'),
              for (final a in shown)
                ListTile(
                  leading: Icon(
                    a.isAdmin
                        ? Icons.admin_panel_settings_outlined
                        : a.pending
                        ? Icons.hourglass_top
                        : Icons.person_outline,
                  ),
                  title: Text(a.email),
                  subtitle: Text('${_accountLine(a)}\n${_lastSignIn(a)}'),
                  isThreeLine: true,
                ),
            ];
          },
        ),
      ),
    ],
  );
}

/// One store for the admin: its accounts and its people.
class _AdminStoreScreen extends StatefulWidget {
  const _AdminStoreScreen({required this.store});

  final AdminStore store;

  @override
  State<_AdminStoreScreen> createState() => _AdminStoreScreenState();
}

class _AdminStoreScreenState extends State<_AdminStoreScreen> {
  final _account = AccountService.instance;
  late Future<List<AdminAccount>> _accounts;
  late Future<List<AdminPerson>> _people;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final id = widget.store.id;
    _accounts = _account.adminAccounts().then(
      (all) => [
        for (final a in all)
          if (a.storeId == id) a,
      ],
    );
    _people = _account.adminStorePeople(id);
  }

  Future<void> _reload() async {
    setState(_load);
    try {
      await Future.wait([_accounts, _people]);
    } catch (_) {
      // Each tab shows its own error.
    }
  }

  @override
  Widget build(BuildContext context) => ResponsiveTabs(
    title: Text(widget.store.name),
    tabs: [
      (
        'Pessoas',
        _Loaded<List<AdminPerson>>(
          future: _people,
          onRefresh: _reload,
          builder: (context, list) => [
            if (list.isEmpty) _empty(context, 'Ainda não há pessoas.'),
            for (final p in list)
              ListTile(
                leading: Icon(
                  p.email != null ? Icons.person : Icons.person_outline,
                ),
                title: Text(p.name.isEmpty ? 'Sem nome' : p.name),
                subtitle: Text(
                  [
                    teamById(p.team)?.name ?? 'Sem equipa',
                    if (Role.values.where((r) => r.name == p.role).firstOrNull
                        case final r?)
                      r.label,
                    if (p.number.isNotEmpty) 'Nº ${p.number}',
                    p.email ?? 'Sem conta',
                  ].join(' · '),
                ),
              ),
          ],
        ),
      ),
      (
        'Contas',
        _Loaded<List<AdminAccount>>(
          future: _accounts,
          onRefresh: _reload,
          builder: (context, list) => [
            if (list.isEmpty) _empty(context, 'Ainda não há contas.'),
            for (final a in list)
              ListTile(
                leading: Icon(
                  a.pending ? Icons.hourglass_top : Icons.person_outline,
                ),
                title: Text(a.email),
                subtitle: Text(
                  [
                    if (a.pending) 'À espera de aprovação',
                    a.personName ?? 'Sem pessoa ligada',
                    _lastSignIn(a),
                  ].join(' · '),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
