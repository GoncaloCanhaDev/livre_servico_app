import 'package:flutter/material.dart';

import '../../services/account_service.dart';
import '../store_transfers_screen.dart';

/// On Home, for the app's admin: how many people asked to move to another
/// store; opens "Mudanças de loja". Nothing when there are none or offline.
class TransferRequestsCard extends StatefulWidget {
  const TransferRequestsCard({super.key});

  @override
  State<TransferRequestsCard> createState() => _TransferRequestsCardState();
}

class _TransferRequestsCardState extends State<TransferRequestsCard>
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
    var count = 0;
    if (_account.store != null && _account.access.admin) {
      try {
        count = (await _account.transferRequests()).length;
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
        leading: const Icon(Icons.swap_horiz),
        title: Text(
          _count == 1
              ? '1 pedido de mudança de loja'
              : '$_count pedidos de mudança de loja',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StoreTransfersScreen()),
          );
          _load();
        },
      ),
    );
  }
}
