import 'package:flutter/material.dart';

import '../../services/account_service.dart';
import '../feedback_screen.dart';

/// On Home, for the app's admin: how many error reports and suggestions are
/// still to deal with; opens "Erros e sugestões". Nothing when there are
/// none or offline.
class FeedbackCard extends StatefulWidget {
  const FeedbackCard({super.key});

  @override
  State<FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<FeedbackCard>
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
        count = (await _account.feedbackList())
            .where((f) => f.doneAt == null)
            .length;
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
        leading: const Icon(Icons.feedback_outlined),
        title: Text(
          _count == 1
              ? '1 erro ou sugestão por tratar'
              : '$_count erros e sugestões por tratar',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackInboxScreen()),
          );
          _load();
        },
      ),
    );
  }
}
