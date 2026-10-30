import 'package:flutter/material.dart';

import '../models/person.dart';
import '../models/teams.dart';
import '../services/account_service.dart';
import '../services/local_db.dart';
import '../theme.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

/// "Quem é você?": the store's people with no account yet. Pops with
/// `(personId: id)` for the one picked, `(personId: null)` for "Não estou na
/// lista" (only when [canAddNew]), or nothing when cancelled.
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

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = [
      for (final p in widget.people)
        if (q.isEmpty || p.name.toLowerCase().contains(q)) p,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Quem é você?')),
      body: SafeArea(
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
                subtitle: Text(teamById(p.team)?.name ?? 'Sem equipa'),
                onTap: () => Navigator.pop(context, (personId: p.id)),
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
                subtitle: const Text('Preencha os seus dados de raiz.'),
                onTap: () => Navigator.pop(context, (personId: null)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// After this account was linked to the person [personId] (or joined with
/// none), opens that person's form to correct or complete it; with none,
/// the form for a new person, which then becomes this account's profile.
///
/// Takes the navigator and messenger rather than a context: joining a store
/// replaces the screen that started it.
Future<void> completeProfile(
  NavigatorState nav,
  ScaffoldMessengerState messenger, {
  required String? personId,
}) async {
  if (personId == null) {
    final created = await nav.push<Person>(
      MaterialPageRoute(builder: (_) => const PersonFormScreen()),
    );
    if (created == null) return;
    try {
      await AccountService.instance.claimPerson(created.syncUuid);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(accountErrorText(e))));
    }
    return;
  }
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
  final editable = AccountService.instance.store?.role != StoreRole.viewer;
  await nav.push(
    MaterialPageRoute(
      builder: (_) => editable
          ? PersonFormScreen(existing: person)
          : PersonDetailScreen(person: person),
    ),
  );
}

/// The Person with the `syncUuid` [personId] on this device, if it is here.
Future<Person?> myPerson(String personId) =>
    LocalDb.instance.persons.firstWhere((p) => p.syncUuid == personId);

/// Lets the signed-in member of the current store say which person they
/// are, then opens their profile. For "O meu perfil" before it is linked.
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
  final choice = await nav.push<({String? personId})>(
    MaterialPageRoute(
      builder: (_) => ClaimPersonScreen(
        storeName: store.name,
        people: people,
        // A viewer's new person would never reach the store.
        canAddNew: store.role != StoreRole.viewer,
      ),
    ),
  );
  if (choice == null) return;
  if (choice.personId case final id?) {
    try {
      await account.claimPerson(id);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(accountErrorText(e))));
      return;
    }
  }
  await completeProfile(nav, messenger, personId: choice.personId);
}
