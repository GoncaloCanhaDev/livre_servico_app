import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/person.dart';
import '../../services/account_service.dart';
import '../../services/local_db.dart';
import '../../services/person_service.dart';
import '../person_form_screen.dart';

/// On Home, while a chefe or Gerência asks this account's person to update
/// their profile: who asked and when; opens the form, and saving it answers
/// the request.
class ProfileRequestCard extends StatefulWidget {
  const ProfileRequestCard({super.key});

  @override
  State<ProfileRequestCard> createState() => _ProfileRequestCardState();
}

class _ProfileRequestCardState extends State<ProfileRequestCard> {
  Person? _me;

  @override
  void initState() {
    super.initState();
    PersonService.instance.addListener(_load);
    AccountService.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    PersonService.instance.removeListener(_load);
    AccountService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final id = AccountService.instance.store?.personId;
    final me = id == null
        ? null
        : await LocalDb.instance.persons.firstWhere((p) => p.syncUuid == id);
    if (mounted) setState(() => _me = me);
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    final at = me?.profileUpdateRequestedAt;
    if (me == null || at == null) return const SizedBox.shrink();
    final by = me.profileUpdateRequestedBy;
    final when = DateFormat('d/M', 'pt_PT').format(at);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.orange.shade800,
      child: ListTile(
        leading: const Icon(Icons.badge, color: Colors.white),
        title: const Text(
          'Atualize o seu perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          by == null ? 'Pedido em $when.' : 'Pedido por $by em $when.',
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PersonFormScreen(existing: me)),
        ),
      ),
    );
  }
}
