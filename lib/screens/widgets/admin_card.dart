import 'package:flutter/material.dart';

import '../../services/account_service.dart';
import '../../theme.dart';
import '../admin_screen.dart';

/// On Home, for the app's admin: what waits in every store (requests to
/// join, to move store, errors and suggestions); opens Administração.
/// Nothing for anyone else, or offline.
class AdminCard extends StatefulWidget {
  const AdminCard({super.key});

  @override
  State<AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<AdminCard> with WidgetsBindingObserver {
  final _account = AccountService.instance;
  AdminSummary? _summary;

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
    AdminSummary? summary;
    if (_account.store != null && _account.access.admin) {
      try {
        summary = await _account.adminSummary();
      } catch (_) {
        // Offline: show nothing until the next try.
      }
    }
    if (mounted && summary != _summary) setState(() => _summary = summary);
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    if (s == null) return const SizedBox.shrink();
    final waiting = [
      if (s.joinRequests > 0)
        s.joinRequests == 1
            ? '1 pedido para entrar'
            : '${s.joinRequests} pedidos para entrar',
      if (s.transfers > 0)
        s.transfers == 1
            ? '1 mudança de loja'
            : '${s.transfers} mudanças de loja',
      if (s.feedback > 0)
        s.feedback == 1
            ? '1 erro ou sugestão'
            : '${s.feedback} erros e sugestões',
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.admin_panel_settings_outlined,
          color: waiting.isEmpty ? null : context.colors.primary,
        ),
        title: const Text(
          'Administração',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          waiting.isEmpty
              ? 'Nada à espera. Lojas e contas.'
              : waiting.join(' · '),
          style: waiting.isEmpty
              ? null
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminScreen()),
          );
          _load();
        },
      ),
    );
  }
}
