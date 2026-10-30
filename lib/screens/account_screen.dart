import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/account_service.dart';
import '../services/sync_service.dart';
import '../theme.dart';
import 'store_members_screen.dart';

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
    } else {
      body = _Connected(account: _account, sync: _sync);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Conta')),
      body: SafeArea(child: body),
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
          onPressed: () => _run(_signUp),
          child: const Text('Criar conta'),
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

  Future<bool> _confirmMerge(String storeName) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ligar a $storeName'),
          content: const Text(
            'Os dados deste aparelho são juntados aos da loja: de cada '
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
    if (!await _confirmMerge(s.name)) return;
    try {
      await AccountService.instance.useStore(s);
    } catch (e) {
      if (mounted) _showError(context, e);
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
    if (!await _confirmMerge(name)) return;
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
              'Ainda não pertence a nenhuma loja. Crie uma, ou peça ao dono '
              'de uma loja que o adicione com o email ${widget.email}.',
              style: TextStyle(color: context.muted),
            );
          }
          return Column(
            children: [
              for (final s in stores)
                ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(s.name),
                  subtitle: Text(s.role.label),
                  onTap: () => _use(s),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _create,
        icon: const Icon(Icons.add_business),
        label: const Text('Criar loja'),
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
          subtitle: store.role == StoreRole.viewer
              ? const Text(
                  'Só leitura: o que guardar neste aparelho não é enviado '
                  'para a loja.',
                )
              : null,
          trailing: IconButton(
            tooltip: 'Sincronizar agora',
            icon: const Icon(Icons.sync),
            onPressed: sync.isSyncing ? null : sync.syncNow,
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.group),
          title: const Text('Membros'),
          subtitle: Text(
            store.role == StoreRole.owner
                ? 'Quem pode abrir os dados da loja, e com que papel.'
                : 'Quem pode abrir os dados da loja.',
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StoreMembersScreen()),
          ),
        ),
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
        ),
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
