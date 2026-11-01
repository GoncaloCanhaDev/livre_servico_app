import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/person.dart';
import '../models/teams.dart';
import '../services/account_service.dart';
import '../services/person_service.dart';
import '../services/sync_service.dart';
import '../theme.dart';
import 'claim_person_screen.dart';
import 'privacy_policy_screen.dart';
import 'person_detail_screen.dart';
import 'start_screen.dart';
import 'store_members_screen.dart';
import 'widgets/wide_layout.dart';

/// Definições → Conta: sign in to the online database, choose the store
/// this device syncs with, and see how the sync is going.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _account = AccountService.instance;
  final _sync = SyncService.instance;

  @override
  void initState() {
    super.initState();
    _account.addListener(_changed);
    _sync.addListener(_changed);
  }

  @override
  void dispose() {
    _account.removeListener(_changed);
    _sync.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (!_account.isConfigured) {
      body = const _Note(
        icon: Icons.cloud_off,
        text:
            'Esta versão da aplicação não tem a base de dados online '
            'configurada. Os dados ficam só neste aparelho.',
      );
    } else if (!_account.isSignedIn) {
      body = const _SignInForm();
    } else if (_account.store == null) {
      body = _StorePicker(email: _account.email!);
    } else if (_account.store!.pending) {
      body = _Pending(account: _account);
    } else {
      body = _Connected(account: _account, sync: _sync);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Conta')),
      body: ReadableWidth(child: SafeArea(child: body)),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: context.muted),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

void _showError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(accountErrorText(e)),
      duration: const Duration(seconds: 6),
    ),
  );
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o email e a palavra-passe.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) _showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Creates the account once the Política de Privacidade was read to its
  /// end and accepted.
  Future<void> _readPolicyThenSignUp() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o email e a palavra-passe.')),
      );
      return;
    }
    final accepted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(accept: true),
      ),
    );
    if (accepted == true && mounted) await _run(_signUp);
  }

  Future<void> _signUp() async {
    final signedIn = await AccountService.instance.signUp(
      _email.text,
      _password.text,
    );
    if (signedIn || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirme o email'),
        content: Text(
          'Foi enviada uma ligação para ${_email.text.trim()}. Abra-a e '
          'depois volte aqui para entrar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Entre para guardar os dados também online e os partilhar com '
        'outros aparelhos da loja. Sem conta, a aplicação funciona como '
        'até aqui, só neste aparelho.',
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _password,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        decoration: const InputDecoration(
          labelText: 'Palavra-passe',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _run(
          () => AccountService.instance.signIn(_email.text, _password.text),
        ),
      ),
      const SizedBox(height: 16),
      if (_busy)
        const Center(child: CircularProgressIndicator())
      else ...[
        FilledButton(
          onPressed: () => _run(
            () => AccountService.instance.signIn(_email.text, _password.text),
          ),
          child: const Text('Entrar'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _readPolicyThenSignUp,
          child: const Text('Criar conta'),
        ),
        const SizedBox(height: 4),
        Text(
          'Ao criar a conta, lê e aceita a Política de Privacidade.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.muted, fontSize: 12),
        ),
      ],
    ],
  );
}

class _StorePicker extends StatefulWidget {
  const _StorePicker({required this.email});

  final String email;

  @override
  State<_StorePicker> createState() => _StorePickerState();
}

class _StorePickerState extends State<_StorePicker> {
  late Future<List<StoreInfo>> _stores = AccountService.instance.myStores();
  late final Future<bool> _isAdmin = AccountService.instance.isAppAdmin();

  @override
  void initState() {
    super.initState();
    _openOwnStore();
  }

  /// Everyone but the admin belongs to one store: open it at once.
  Future<void> _openOwnStore() async {
    final List<StoreInfo> stores;
    final bool admin;
    try {
      stores = await _stores;
      admin = await _isAdmin;
    } catch (_) {
      return; // The list shows the error.
    }
    final s = storeToOpen(stores, admin: admin);
    if (s == null || !mounted) return;
    if (AccountService.instance.replacesLocalData(s.id)) {
      await _use(s);
      return;
    }
    try {
      await AccountService.instance.useStore(s);
    } catch (e) {
      if (mounted) _showError(context, e);
    }
  }

  /// Asks before syncing with [storeName] ([storeId]; null for a new
  /// store): this phone's data joins it, or, when it is another store's,
  /// leaves the phone.
  Future<bool> _confirmMerge(String storeName, String? storeId) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ligar a $storeName'),
          content: Text(
            AccountService.instance.replacesLocalData(storeId ?? '')
                ? 'Os dados de outra loja saem deste aparelho (continuam na '
                      'loja) e os de $storeName são descarregados.'
                : 'Os dados deste aparelho são juntados aos da loja: de cada '
                      'registo fica a versão guardada por último.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ligar'),
            ),
          ],
        ),
      ) ==
      true;

  Future<void> _use(StoreInfo s) async {
    if (!await _confirmMerge(s.name, s.id)) return;
    try {
      await AccountService.instance.useStore(s);
    } catch (e) {
      if (mounted) _showError(context, e);
    }
  }

  /// Asks to join a store with the code Gerência shares: the person says
  /// who they are in its list of people (or types their name), then waits
  /// for a Chefe de Secção or Gerência to approve.
  Future<void> _join() async {
    final ctrl = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Entrar numa loja'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Código da loja',
            helperText: 'Peça-o à gerência da loja.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (code == null || code.isEmpty || !mounted) return;
    // Joining replaces this screen with the pending one, so keep these.
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final account = AccountService.instance;
    try {
      final preview = await account.previewJoin(code);
      final choice = await nav.push<({String? personId, String? name})>(
        MaterialPageRoute(
          builder: (_) => ClaimPersonScreen(
            storeName: preview.storeName,
            people: preview.people,
          ),
        ),
      );
      if (choice == null || !mounted) return;
      if (!await _confirmMerge(preview.storeName, preview.storeId)) return;
      await account.joinStore(
        code,
        personId: choice.personId,
        name: choice.name,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(accountErrorText(e)),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Future<void> _create() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova loja'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nome da loja',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    if (!await _confirmMerge(name, null)) return;
    try {
      await AccountService.instance.createStore(name);
    } catch (e) {
      if (mounted) _showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Sessão iniciada como ${widget.email}.'),
      const SizedBox(height: 16),
      const Text(
        'Escolha a loja',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      FutureBuilder<List<StoreInfo>>(
        future: _stores,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                Text(accountErrorText(snap.error!)),
                TextButton(
                  onPressed: () => setState(
                    () => _stores = AccountService.instance.myStores(),
                  ),
                  child: const Text('Tentar outra vez'),
                ),
              ],
            );
          }
          final stores = snap.data;
          if (stores == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (stores.isEmpty) {
            return Text(
              'Ainda não pertence a nenhuma loja. Entre com o código que a '
              'gerência da loja lhe der.',
              style: TextStyle(color: context.muted),
            );
          }
          return Column(
            children: [
              for (final s in stores)
                ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(s.name),
                  subtitle: Text(
                    s.pending ? 'Pedido à espera de aprovação' : s.role.label,
                  ),
                  onTap: () => _use(s),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
      // Someone already in a store moves only through the admin.
      FutureBuilder<List<Object>>(
        future: Future.wait<Object>([_stores, _isAdmin]),
        builder: (context, snap) {
          final data = snap.data;
          if (data == null) return const SizedBox.shrink();
          final stores = data[0] as List<StoreInfo>;
          if (data[1] != true && stores.isNotEmpty) {
            return const SizedBox.shrink();
          }
          return FilledButton.icon(
            onPressed: _join,
            icon: const Icon(Icons.vpn_key),
            label: const Text('Entrar com código'),
          );
        },
      ),
      // Only the app's admin creates stores.
      FutureBuilder<bool>(
        future: _isAdmin,
        builder: (context, snap) => snap.data != true
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.add_business),
                  label: const Text('Criar loja'),
                ),
              ),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: AccountService.instance.signOut,
        child: const Text('Terminar sessão'),
      ),
    ],
  );
}

class _Connected extends StatelessWidget {
  const _Connected({required this.account, required this.sync});

  final AccountService account;
  final SyncService sync;

  String _status() {
    if (sync.isSyncing) return 'A sincronizar…';
    if (sync.lastError case final e?) {
      return 'Não sincronizou: ${accountErrorText(e)}';
    }
    if (sync.lastSyncedAt case final t?) {
      return 'Sincronizado às ${DateFormat.Hm('pt_PT').format(t)}.';
    }
    return 'Ainda não sincronizou.';
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String text,
    required String action,
    required Future<void> Function() onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (ok == true) await onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final store = account.store!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.store),
          title: Text(
            store.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${account.email} · ${store.role.label}'),
        ),
        ListTile(
          leading: Icon(
            sync.lastError == null ? Icons.cloud_done : Icons.cloud_off,
            color: sync.lastError == null ? null : context.warningText,
          ),
          title: Text(_status()),
        ),
        const Divider(),
        _MyProfileTile(personId: store.personId),
        ListTile(
          leading: const Icon(Icons.group),
          title: const Text('Membros'),
          subtitle: Text(
            store.access.canApprove
                ? 'Quem pode abrir os dados da loja, e pedidos para entrar.'
                : 'Quem pode abrir os dados da loja.',
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StoreMembersScreen()),
          ),
        ),
        if (account.access.admin)
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Mudar de loja'),
            subtitle: const Text('Deixa de sincronizar com esta loja.'),
            onTap: () => _confirm(
              context,
              title: 'Mudar de loja',
              text:
                  'Este aparelho deixa de sincronizar com ${store.name}. Os '
                  'dados ficam neste aparelho.',
              action: 'Mudar',
              onConfirm: account.leaveStore,
            ),
          )
        else
          const _TransferTile(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Terminar sessão'),
          subtitle: const Text('Os dados ficam neste aparelho.'),
          onTap: () => _confirm(
            context,
            title: 'Terminar sessão',
            text:
                'Este aparelho deixa de sincronizar. Os dados ficam neste '
                'aparelho.',
            action: 'Terminar sessão',
            onConfirm: account.signOut,
          ),
        ),
      ],
    );
  }
}

/// A request to join the store, waiting for approval: check again (and,
/// once approved, open the profile) or withdraw it.
class _Pending extends StatefulWidget {
  const _Pending({required this.account});

  final AccountService account;

  @override
  State<_Pending> createState() => _PendingState();
}

class _PendingState extends State<_Pending> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) _showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _check() async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final account = widget.account;
    await _run(account.refreshStore);
    final store = account.store;
    if (store == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('O pedido para entrar foi recusado.')),
      );
    } else if (!store.pending) {
      // refreshStore ran the first sync: the profile is here to check.
      if (store.personId case final id?) {
        await completeProfile(nav, messenger, personId: id);
      }
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ainda à espera de aprovação.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.account.store!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.hourglass_top, size: 48),
        const SizedBox(height: 16),
        Text(
          'Pedido enviado a ${store.name}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Aguarde que um Chefe de Secção ou a gerência da loja '
          'aprove o pedido. Até lá, nada da loja chega a este aparelho.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.muted),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _busy ? null : _check,
          icon: const Icon(Icons.refresh),
          label: const Text('Verificar'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _busy
              ? null
              : () => _run(widget.account.cancelJoinRequest),
          child: const Text('Cancelar pedido'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : widget.account.signOut,
          child: const Text('Terminar sessão'),
        ),
      ],
    );
  }
}

/// "Pedir mudança de loja": asks the admin to move this account (and its
/// person) to another store, with a note; while asked, the note and a way
/// to withdraw it.
class _TransferTile extends StatefulWidget {
  const _TransferTile();

  @override
  State<_TransferTile> createState() => _TransferTileState();
}

class _TransferTileState extends State<_TransferTile> {
  late Future<({String note, DateTime createdAt})?> _request = AccountService
      .instance
      .myTransfer();

  void _reload() =>
      setState(() => _request = AccountService.instance.myTransfer());

  Future<void> _ask() async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => const _TransferNoteDialog(),
    );
    if (note == null || !mounted) return;
    try {
      await AccountService.instance.requestTransfer(note);
    } catch (e) {
      if (mounted) _showError(context, e);
    }
    _reload();
  }

  Future<void> _cancel() async {
    try {
      await AccountService.instance.cancelTransfer();
    } catch (e) {
      if (mounted) _showError(context, e);
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<({String note, DateTime createdAt})?>(
        future: _request,
        builder: (context, snap) {
          final request = snap.data;
          if (request == null) {
            return ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Pedir mudança de loja'),
              subtitle: const Text('O administrador muda-o de loja.'),
              onTap: _ask,
            );
          }
          return ListTile(
            leading: const Icon(Icons.hourglass_top),
            title: const Text('Mudança de loja pedida'),
            subtitle: Text(
              request.note.isEmpty
                  ? 'À espera do administrador.'
                  : '${request.note} · à espera do administrador.',
            ),
            trailing: TextButton(
              onPressed: _cancel,
              child: const Text('Cancelar'),
            ),
          );
        },
      );
}

/// Asks where to move (and from when); pops with the note, trimmed.
class _TransferNoteDialog extends StatefulWidget {
  const _TransferNoteDialog();

  @override
  State<_TransferNoteDialog> createState() => _TransferNoteDialogState();
}

class _TransferNoteDialogState extends State<_TransferNoteDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Pedir mudança de loja'),
    content: TextField(
      controller: _ctrl,
      autofocus: true,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Para que loja, e a partir de quando',
        hintText: 'Pingo Doce Braga, a partir de 1/11',
        border: OutlineInputBorder(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
        child: const Text('Pedir'),
      ),
    ],
  );
}

/// "O meu perfil": the person this account is in the store; before it is
/// linked, a way to say which one.
class _MyProfileTile extends StatefulWidget {
  const _MyProfileTile({required this.personId});

  final String? personId;

  @override
  State<_MyProfileTile> createState() => _MyProfileTileState();
}

class _MyProfileTileState extends State<_MyProfileTile> {
  Person? _person;

  @override
  void initState() {
    super.initState();
    PersonService.instance.addListener(_load);
    _load();
  }

  @override
  void didUpdateWidget(_MyProfileTile old) {
    super.didUpdateWidget(old);
    if (old.personId != widget.personId) _load();
  }

  @override
  void dispose() {
    PersonService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.personId;
    final p = id == null ? null : await myPerson(id);
    if (mounted) setState(() => _person = p);
  }

  @override
  Widget build(BuildContext context) {
    final person = _person;
    if (widget.personId == null) {
      return ListTile(
        leading: const Icon(Icons.badge_outlined),
        title: const Text('O meu perfil'),
        subtitle: const Text('Diga quem é na lista de pessoas da loja.'),
        onTap: () => pickMyPerson(context),
      );
    }
    return ListTile(
      leading: const Icon(Icons.badge),
      title: const Text('O meu perfil'),
      subtitle: Text(
        person == null
            ? 'Os seus dados ainda não chegaram a este aparelho.'
            : '${person.fullName}\n${roleLineOf(person)}',
      ),
      onTap: person == null
          ? SyncService.instance.syncNow
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PersonDetailScreen(person: person),
              ),
            ),
    );
  }
}
