import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_version.dart';
import '../services/account_service.dart';
import '../theme.dart';
import 'widgets/wide_layout.dart';

/// The longest message `send_feedback` takes.
const _maxLength = 4000;

/// The platform sent with a report, so the admin knows where it happened.
String get _platform => kIsWeb ? 'web' : defaultTargetPlatform.name;

/// "Reportar erro ou sugestão": anyone signed in writes to the app's admin,
/// who is the only one to read it ([FeedbackInboxScreen]).
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _message = TextEditingController();
  var _kind = FeedbackKind.erro;
  var _sending = false;

  @override
  void initState() {
    super.initState();
    _message.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  bool get _canSend =>
      AccountService.instance.isConfigured &&
      AccountService.instance.isSignedIn;

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      await AccountService.instance.sendFeedback(
        _kind,
        _message.text,
        version: appVersion,
        platform: _platform,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviado. Obrigado!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accountErrorText(e)),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _canSend && !_sending && _message.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Erro ou sugestão')),
      body: ReadableWidth(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Encontrou um erro ou tem uma ideia para melhorar a '
                'aplicação? Escreva aqui. Só o administrador da aplicação '
                'lê esta mensagem, com o seu email e a sua loja.',
                style: TextStyle(color: context.muted),
              ),
              const SizedBox(height: 16),
              SegmentedButton<FeedbackKind>(
                segments: const [
                  ButtonSegment(
                    value: FeedbackKind.erro,
                    label: Text('Erro'),
                    icon: Icon(Icons.bug_report_outlined),
                  ),
                  ButtonSegment(
                    value: FeedbackKind.sugestao,
                    label: Text('Sugestão'),
                    icon: Icon(Icons.lightbulb_outline),
                  ),
                ],
                selected: {_kind},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _kind = s.single),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _message,
                enabled: _canSend && !_sending,
                minLines: 5,
                maxLines: 12,
                maxLength: _maxLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Mensagem',
                  hintText: _kind == FeedbackKind.erro
                      ? 'O que aconteceu, em que ecrã, e o que esperava.'
                      : 'O que gostava que a aplicação fizesse.',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (!_canSend) ...[
                const SizedBox(height: 8),
                Text(
                  'Para enviar, inicie sessão em Definições → Conta e '
                  'Sincronização.',
                  style: TextStyle(color: context.warningText),
                ),
              ],
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: ready ? _send : null,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Erros e sugestões", for the app's admin: everything sent, those still
/// to deal with first; each can be marked dealt with, reopened or removed.
class FeedbackInboxScreen extends StatefulWidget {
  const FeedbackInboxScreen({super.key});

  @override
  State<FeedbackInboxScreen> createState() => _FeedbackInboxScreenState();
}

class _FeedbackInboxScreenState extends State<FeedbackInboxScreen> {
  final _account = AccountService.instance;
  late Future<List<FeedbackItem>> _items = _account.feedbackList();

  void _reload() => setState(() => _items = _account.feedbackList());

  void _showError(Object e) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(accountErrorText(e)),
      duration: const Duration(seconds: 6),
    ),
  );

  Future<void> _setDone(FeedbackItem f, bool done) async {
    try {
      await _account.setFeedbackDone(f.id, done);
    } catch (e) {
      if (mounted) _showError(e);
    }
    if (mounted) _reload();
  }

  Future<void> _delete(FeedbackItem f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Apagar ${f.kind.label.toLowerCase()}'),
        content: const Text('A mensagem é apagada para sempre.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _account.deleteFeedback(f.id);
    } catch (e) {
      if (mounted) _showError(e);
    }
    if (mounted) _reload();
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(
      label,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );

  Widget _card(FeedbackItem f) {
    final when = DateFormat('d/M/y HH:mm', 'pt_PT');
    final who = [
      f.personName ?? f.email,
      if (f.personName != null && f.email.isNotEmpty) f.email,
      f.storeName ?? 'Sem loja',
    ].join(' · ');
    final meta = [
      when.format(f.createdAt),
      if (f.appVersion.isNotEmpty) 'v${f.appVersion}',
      if (f.platform.isNotEmpty) f.platform,
    ].join(' · ');
    final done = f.doneAt != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  f.kind == FeedbackKind.erro
                      ? Icons.bug_report_outlined
                      : Icons.lightbulb_outline,
                  size: 20,
                  color: done ? context.muted : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    f.kind.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: done ? context.muted : null,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (a) => switch (a) {
                    'done' => _setDone(f, !done),
                    _ => _delete(f),
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'done',
                      child: Text(done ? 'Reabrir' : 'Marcar como tratado'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Apagar')),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SelectableText(
                f.message,
                style: TextStyle(color: done ? context.muted : null),
              ),
            ),
            const SizedBox(height: 8),
            Text(who, style: TextStyle(fontSize: 13, color: context.muted)),
            Text(meta, style: TextStyle(fontSize: 13, color: context.muted)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Erros e sugestões')),
    body: ReadableWidth(
      child: SafeArea(
        child: FutureBuilder<List<FeedbackItem>>(
          future: _items,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(accountErrorText(snap.error!)),
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Tentar outra vez'),
                    ),
                  ],
                ),
              );
            }
            final list = snap.data;
            if (list == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (list.isEmpty) {
              return Center(
                child: Text(
                  'Ainda ninguém enviou erros nem sugestões.',
                  style: TextStyle(color: context.muted),
                ),
              );
            }
            final open = [for (final f in list) if (f.doneAt == null) f];
            final done = [for (final f in list) if (f.doneAt != null) f];
            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _items;
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _section('Por tratar (${open.length})'),
                  if (open.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Nada por tratar.',
                        style: TextStyle(color: context.muted),
                      ),
                    ),
                  for (final f in open) _card(f),
                  if (done.isNotEmpty) ...[
                    _section('Tratados (${done.length})'),
                    for (final f in done) _card(f),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
