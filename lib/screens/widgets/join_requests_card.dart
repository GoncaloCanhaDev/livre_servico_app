import 'package:flutter/material.dart';

import '../../services/account_service.dart';
import '../store_members_screen.dart';

/// On Home, for those who approve them (level 3 and up, the admin): how
/// many requests to join the store are waiting; opens Membros. Nothing when
/// there are none, offline, or not connected to a store; the admin sees
/// every store's on `AdminCard` instead.
class JoinRequestsCard extends StatefulWidget {
  const JoinRequestsCard({super.key});

  @override
  State<JoinRequestsCard> createState() => _JoinRequestsCardState();
}

class _JoinRequestsCardState extends State<JoinRequestsCard>
    with WidgetsBindingObserver {
  final _account = AccountService.instance;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _account.addListener(_load);
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    _account.removeListener(_load);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final store = _account.store;
    var count = 0;
    if (store != null &&
        !store.pending &&
        store.access.canApprove &&
        !store.access.admin) {
      try {
        count = (await _account.joinRequests()).length;
      } catch (_) {
        // Offline: show nothing until the next try.
      }
    }
    if (mounted && count != _count) setState(() => _count = count);
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person_add_alt),
        title: Text(
          _count == 1 ? '1 pedido para entrar' : '$_count pedidos para entrar',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Aprove ou recuse em Membros.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StoreMembersScreen()),
          );
          _load();
        },
      ),
    );
  }
}
