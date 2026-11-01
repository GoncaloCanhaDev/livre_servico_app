import 'package:flutter/material.dart';

import '../models/aviso.dart';
import '../models/person.dart';
import '../services/account_service.dart';
import '../services/aviso_service.dart';
import '../services/person_service.dart';
import '../theme.dart';
import 'aviso_form_screen.dart';
import 'widgets/wide_layout.dart';

/// The avisos of the last [avisoKeepDays]: those received and, for those
/// who send them, those sent (with who has seen each).
class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  final _service = AvisoService.instance;
  List<Aviso> _avisos = const [];
  List<AvisoVisto> _vistos = const [];
  Map<String, Person> _people = const {};

  @override
  void initState() {
    super.initState();
    _service.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _service.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final avisos = await _service.all();
    final vistos = await _service.vistos();
    final people = await PersonService.instance.all();
    if (!mounted) return;
    setState(() {
      _avisos = avisos;
      _vistos = vistos;
      _people = {for (final p in people) p.syncUuid: p};
    });
  }

  String _name(String id) => _people[id]?.fullName ?? 'Pessoa removida';

  Future<void> _showSeen(Aviso a) async {
    final seen = seenBy(a, _vistos);
    final now = DateTime.now();
    final unseen = [
      for (final id in a.toPersonIds)
        if (!seen.containsKey(id)) id,
    ];
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(a.text, maxLines: 3, overflow: TextOverflow.ellipsis),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final MapEntry(key: id, value: at) in seen.entries)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.done_all),
                  title: Text(_name(id)),
                  subtitle: Text(avisoWhen(at, now)),
                ),
              if (unseen.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text('Por ver', style: TextStyle(color: ctx.muted)),
                ),
              for (final id in unseen)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.schedule),
                  title: Text(_name(id)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Aviso a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Apagar este aviso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok == true) await _service.delete(a);
  }

  Widget _empty(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, style: TextStyle(color: context.muted)),
    ),
  );

  Widget _received(String me, DateTime now) {
    final avisos = avisosReceived(_avisos, me, now);
    if (avisos.isEmpty) return _empty('Sem avisos.');
    return ListView(
      children: [
        for (final a in avisos)
          ListTile(
            title: Text(a.text),
            subtitle: Text('De ${a.fromName} · ${avisoWhen(a.sentAt, now)}'),
            trailing: seenBy(a, _vistos).containsKey(me)
                ? const Icon(Icons.done)
                : TextButton(
                    onPressed: () => _service.markSeen(a, me),
                    child: const Text('Visto'),
                  ),
          ),
      ],
    );
  }

  Widget _sent(String me, DateTime now) {
    final avisos = avisosSent(_avisos, me, now);
    if (avisos.isEmpty) return _empty('Ainda não enviou avisos.');
    return ListView(
      children: [
        for (final a in avisos)
          ListTile(
            title: Text(a.text),
            subtitle: Text(
              '${avisoWhen(a.sentAt, now)} · Visto por '
              '${seenBy(a, _vistos).length} de ${a.toPersonIds.length}',
            ),
            onTap: () => _showSeen(a),
            trailing: IconButton(
              tooltip: 'Apagar',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(a),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AccountService.instance.store;
    final me = store?.personId;
    final sends = store?.access.canSendAvisos == true;
    final now = DateTime.now();
    return DefaultTabController(
      length: sends ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Avisos'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Recebidos'),
              if (sends) const Tab(text: 'Enviados'),
            ],
          ),
        ),
        floatingActionButton: sends
            ? FloatingActionButton.extended(
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Novo aviso'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AvisoFormScreen()),
                ),
              )
            : null,
        body: ReadableWidth(
          child: SafeArea(
            child: me == null
                ? _empty('Ligue a sua conta a uma pessoa da loja (Conta).')
                : TabBarView(
                    children: [_received(me, now), if (sends) _sent(me, now)],
                  ),
          ),
        ),
      ),
    );
  }
}
