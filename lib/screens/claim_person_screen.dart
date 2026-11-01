import 'package:flutter/material.dart';

import '../models/person.dart';
import '../services/account_service.dart';
import '../services/local_db.dart';
import '../theme.dart';
import 'person_form_screen.dart';
import 'widgets/wide_layout.dart';

/// "Quem é você?": the store's people with no account yet. Pops with
/// `(personId: id, name: null)` for the one picked, `(personId: null, name:
/// typed)` for "Não estou na lista" (only when [canAddNew]), or nothing when
/// cancelled.
class ClaimPersonScreen extends StatefulWidget {
  const ClaimPersonScreen({
    super.key,
    required this.storeName,
    required this.people,
    this.canAddNew = true,
  });

  final String storeName;
  final List<UnlinkedPerson> people;
  final bool canAddNew;

  @override
  State<ClaimPersonScreen> createState() => _ClaimPersonScreenState();
}

class _ClaimPersonScreenState extends State<ClaimPersonScreen> {
  String _query = '';

  Future<void> _notListed() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NameDialog(),
    );
    if (name != null && mounted) {
      Navigator.pop(context, (personId: null, name: name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = [
      for (final p in widget.people)
        if (q.isEmpty ||
            p.name.toLowerCase().contains(q) ||
            p.number.toLowerCase().contains(q))
          p,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Quem é você?')),
      body: ReadableWidth(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Escolha-se na lista de pessoas de ${widget.storeName}. '
                  'Depois pode corrigir ou completar os seus dados. Quem já '
                  'tem conta não aparece aqui.',
                  style: TextStyle(color: context.muted),
                ),
              ),
              if (widget.people.length > 8)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Procurar',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              for (final p in shown)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(p.name.isEmpty ? 'Sem nome' : p.name),
                  subtitle: Text(
                    p.number.isEmpty ? 'Sem número' : 'Nº ${p.number}',
                  ),
                  onTap: () =>
                      Navigator.pop(context, (personId: p.id, name: null)),
                ),
              if (widget.people.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Não há ninguém sem conta na lista.',
                    style: TextStyle(color: context.muted),
                  ),
                ),
              if (widget.canAddNew) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_add_alt),
                  title: const Text('Não estou na lista'),
                  subtitle: const Text(
                    'Quem aprovar o pedido acrescenta-o à lista.',
                  ),
                  onTap: _notListed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks someone not in the list for their name; pops with it, trimmed.
class _NameDialog extends StatefulWidget {
  const _NameDialog();

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('O seu nome'),
    content: TextField(
      controller: _ctrl,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Nome completo',
        border: OutlineInputBorder(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton(
        onPressed: () {
          final name = _ctrl.text.trim();
          if (name.isNotEmpty) Navigator.pop(context, name);
        },
        child: const Text('Continuar'),
      ),
    ],
  );
}

/// After this account was linked to the person [personId], opens that
/// person's form to correct or complete it.
///
/// Takes the navigator and messenger rather than a context: joining a store
/// replaces the screen that started it.
Future<void> completeProfile(
  NavigatorState nav,
  ScaffoldMessengerState messenger, {
  required String personId,
}) async {
  final person = await myPerson(personId);
  if (person == null) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Os seus dados ainda não chegaram a este aparelho. Abra "O meu '
          'perfil" na Conta daqui a pouco.',
        ),
      ),
    );
    return;
  }
  await nav.push(
    MaterialPageRoute(builder: (_) => PersonFormScreen(existing: person)),
  );
}

/// The Person with the `syncUuid` [personId] on this device, if it is here.
Future<Person?> myPerson(String personId) =>
    LocalDb.instance.persons.firstWhere((p) => p.syncUuid == personId);

/// Lets the signed-in member of the current store say which person they
/// are, then opens their profile. For "O meu perfil" before it is linked;
/// someone not in the list asks Gerência to add them.
Future<void> pickMyPerson(BuildContext context) async {
  final nav = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final account = AccountService.instance;
  final store = account.store!;
  final List<UnlinkedPerson> people;
  try {
    people = await account.unlinkedPeople();
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(accountErrorText(e))));
    return;
  }
  final choice = await nav.push<({String? personId, String? name})>(
    MaterialPageRoute(
      builder: (_) => ClaimPersonScreen(
        storeName: store.name,
        people: people,
        canAddNew: false,
      ),
    ),
  );
  final id = choice?.personId;
  if (id == null) return;
  try {
    await account.claimPerson(id);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(accountErrorText(e))));
    return;
  }
  await completeProfile(nav, messenger, personId: id);
}
