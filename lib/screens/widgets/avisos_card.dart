import 'package:flutter/material.dart';

import '../../models/aviso.dart';
import '../../services/account_service.dart';
import '../../services/aviso_service.dart';
import '../../theme.dart';
import '../avisos_screen.dart';

/// On Home, the avisos for this account's person not seen yet (see
/// `avisosOnHome`), each with "Visto". Nothing without a linked person or
/// with none to show.
class AvisosCard extends StatefulWidget {
  const AvisosCard({super.key});

  @override
  State<AvisosCard> createState() => _AvisosCardState();
}

class _AvisosCardState extends State<AvisosCard> {
  final _account = AccountService.instance;
  final _service = AvisoService.instance;
  List<Aviso> _avisos = const [];

  String? get _personId => _account.store?.personId;

  @override
  void initState() {
    super.initState();
    _account.addListener(_load);
    _service.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _account.removeListener(_load);
    _service.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final me = _personId;
    final avisos = me == null
        ? const <Aviso>[]
        : avisosOnHome(
            await _service.all(),
            await _service.vistos(),
            me,
            DateTime.now(),
          );
    if (mounted) setState(() => _avisos = avisos);
  }

  @override
  Widget build(BuildContext context) {
    final me = _personId;
    if (me == null || _avisos.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign_outlined),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Avisos',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AvisosScreen()),
                  ),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            for (final a in _avisos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(a.text),
                subtitle: Text(
                  'De ${a.fromName} · ${avisoWhen(a.sentAt, now)}',
                  style: TextStyle(color: context.muted),
                ),
                trailing: TextButton(
                  onPressed: () => _service.markSeen(a, me),
                  child: const Text('Visto'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
