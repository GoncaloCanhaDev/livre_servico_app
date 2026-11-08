import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_version.dart';
import '../models/feedback_status.dart';
import '../services/account_service.dart';
import '../services/share_file.dart';
import '../theme.dart';
import 'widgets/wide_layout.dart';

/// The longest message `send_feedback` takes.
const _maxLength = 4000;

/// The platform sent with a report, so the admin knows where it happened.
String get _platform => kIsWeb ? 'web' : defaultTargetPlatform.name;

/// Every error report and suggestion in [items] as one plain text file, for
/// the admin to keep or read elsewhere: those still to deal with first, then
/// those dealt with, each with who sent it, when, from which version.
String feedbackExportText(List<FeedbackItem> items, {required DateTime now}) {
  final when = DateFormat('d/M/y HH:mm', 'pt_PT');
  final open = [
    for (final f in items)
      if (f.status.isOpen) f,
  ];
  final done = [
    for (final f in items)
      if (!f.status.isOpen) f,
  ];
  final out = StringBuffer()
    ..writeln('Livre Serviço — Erros e sugestões')
    ..writeln(
      'Exportado em ${when.format(now)} · ${items.length} '
      '${items.length == 1 ? 'mensagem' : 'mensagens'} '
      '(${open.length} por tratar, ${done.length} '
      '${done.length == 1 ? 'tratada' : 'tratadas'})',
    );
  var n = 0;
  void section(String title, List<FeedbackItem> list) {
    if (list.isEmpty) return;
    out
      ..writeln()
      ..writeln('==== $title (${list.length}) ====');
    for (final f in list) {
      n++;
      final who = [
        f.personName ?? f.email,
        if (f.personName != null && f.email.isNotEmpty) f.email,
        f.storeName ?? 'Sem loja',
      ].join(' · ');
      final from = [
        if (f.appVersion.isNotEmpty) 'v${f.appVersion}',
        if (f.platform.isNotEmpty) f.platform,
      ].join(' · ');
      out
        ..writeln()
        ..writeln(
          '[$n] ${f.kind.label} · ${when.format(f.createdAt)} · '
          '${f.status.label}',
        )
        ..writeln('De: $who');
      if (from.isNotEmpty) out.writeln('Versão: $from');
      if (f.doneAt != null) out.writeln('Fechado em ${when.format(f.doneAt!)}');
      out
        ..writeln()
        ..writeln(f.message.trim())
        ..writeln()
        ..writeln('-' * 40);
    }
  }

  section('POR TRATAR', open);
  section('TRATADOS', done);
  return out.toString();
}

/// A state badge: white on its colour.
class FeedbackStatusBadge extends StatelessWidget {
  const FeedbackStatusBadge(this.status, {super.key});

  final FeedbackStatus status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: status.color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      status.label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// "Erros e sugestões" (a Home button): Escrever, where anyone signed in
/// writes to the app's admin, and Todos, where everyone reads the messages
/// and their state, without who sent them. The admin reads everything, with
/// the senders, in [FeedbackInboxScreen], opened from the app bar.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  Widget build(BuildContext context) => ResponsiveTabs(
    title: const Text('Erros e sugestões'),
    actions: [
      if (AccountService.instance.store != null &&
          AccountService.instance.access.admin)
        IconButton(
          tooltip: 'Ver os recebidos',
          icon: const Icon(Icons.inbox_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackInboxScreen()),
          ),
        ),
    ],
    tabs: [('Escrever', _WriteTab()), ('Todos', _AllTab())],
  );
}

class _WriteTab extends StatefulWidget {
  const _WriteTab();

  @override
  State<_WriteTab> createState() => _WriteTabState();
}

class _WriteTabState extends State<_WriteTab> {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enviado. Obrigado!')));
      setState(() {
        _sending = false;
        _message.clear();
      });
      DefaultTabController.maybeOf(context)?.animateTo(1);
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
    return ReadableWidth(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Encontrou um erro ou tem uma ideia para melhorar a aplicação? '
            'Escreva aqui. Todos os utilizadores podem ler a mensagem e o seu '
            'estado em Todos, sem o seu nome nem a sua loja; só o '
            'administrador da aplicação vê quem a enviou.',
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
    );
  }
}

/// Todos: every public message and this account's own, with their state.
/// Read again every 30 seconds while open, when the app comes back and
/// as soon as this device sends or changes one
/// ([AccountService.feedbackChanges]).
class _AllTab extends StatefulWidget {
  const _AllTab();

  @override
  State<_AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<_AllTab> with WidgetsBindingObserver {
  final _account = AccountService.instance;
  List<PublicFeedback>? _items;
  Object? _error;
  Timer? _timer;

  bool get _signedIn => _account.isConfigured && _account.isSignedIn;

  @override
  void initState() {
    super.initState();
    if (!_signedIn) return;
    WidgetsBinding.instance.addObserver(this);
    _account.feedbackChanges.addListener(_load);
    _timer = Timer.periodic(FeedbackInboxScreen.refreshEvery, (_) => _load());
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _account.feedbackChanges.removeListener(_load);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  /// Keeps what is shown when a read fails, once there is something.
  Future<void> _load() async {
    try {
      final list = await _account.feedbackPublicList();
      if (mounted) {
        setState(() {
          _items = list;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && _items == null) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (!_signedIn) {
      return _centred(
        'Para ver os erros e sugestões, inicie sessão em Definições → Conta '
        'e Sincronização.',
      );
    }
    if (_error case final e? when items == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(accountErrorText(e)),
            TextButton(onPressed: _load, child: const Text('Tentar outra vez')),
          ],
        ),
      );
    }
    if (items == null) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return _centred('Ainda não há erros nem sugestões.');
    }
    final when = DateFormat('d/M/y', 'pt_PT');
    return RefreshIndicator(
      onRefresh: _load,
      child: ReadableWidth(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final f in items)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              [
                                f.kind.label,
                                when.format(f.createdAt),
                                if (f.mine) 'Enviado por si',
                              ].join(' · '),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          FeedbackStatusBadge(f.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SelectableText(f.message),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _centred(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.muted),
      ),
    ),
  );
}

/// "Erros e sugestões", for the app's admin: everything sent, those still
/// to deal with first; each can be marked dealt with, reopened or removed.
/// While open it reads the list again every [refreshEvery] and when the app
/// comes back, so new ones show without reloading.
class FeedbackInboxScreen extends StatefulWidget {
  const FeedbackInboxScreen({super.key});

  @override
  State<FeedbackInboxScreen> createState() => _FeedbackInboxScreenState();

  static const refreshEvery = Duration(seconds: 30);
}

class _FeedbackInboxScreenState extends State<FeedbackInboxScreen>
    with WidgetsBindingObserver {
  final _account = AccountService.instance;
  late Future<List<FeedbackItem>> _items = _openList();
  late final Timer _timer;

  /// The list, after making every new message Visto (the admin opened it).
  Future<List<FeedbackItem>> _openList() async {
    try {
      await _account.markFeedbackSeen();
    } catch (_) {
      // Offline: the list says so.
    }
    return _account.feedbackList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(FeedbackInboxScreen.refreshEvery, (_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _reload() => setState(() {
    _items = _account.feedbackList();
  });

  /// Reads the list again in the background: shown once it arrives, and
  /// nothing changes if it fails (offline), until the next try.
  Future<void> _refresh() async {
    if (_saving > 0) return;
    try {
      final list = await _account.feedbackList();
      if (!mounted) return;
      setState(() {
        _items = Future.value(list);
      });
    } catch (_) {
      // Keep what is shown.
    }
  }

  void _showError(Object e) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(accountErrorText(e)),
      duration: const Duration(seconds: 6),
    ),
  );

  /// Changes being saved: the timer doesn't read the list meanwhile, so it
  /// never shows what was there before.
  var _saving = 0;

  /// Shows [edit] of the list at once, then runs [save]: on an error the
  /// list goes back to what it was. Either way it is read again after.
  Future<void> _changeLocally(
    List<FeedbackItem> Function(List<FeedbackItem>) edit,
    Future<void> Function() save,
  ) async {
    final List<FeedbackItem> before;
    try {
      before = await _items;
    } catch (_) {
      return; // Nothing shown to change.
    }
    if (!mounted) return;
    setState(() {
      _items = Future.value(edit(before));
    });
    _saving++;
    try {
      await save();
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = Future.value(before);
        });
        _showError(e);
      }
    } finally {
      _saving--;
    }
    if (mounted) await _refresh();
  }

  /// Sets [f]'s state: shown at once, then saved.
  Future<void> _setStatus(FeedbackItem f, FeedbackStatus status) async {
    if (status == f.status) return;
    await _changeLocally(
      (list) => [
        for (final i in list) i.id == f.id ? _withStatus(i, status) : i,
      ],
      () => _account.setFeedbackStatus(f.id, status),
    );
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
    await _changeLocally(
      (list) => [
        for (final i in list)
          if (i.id != f.id) i,
      ],
      () => _account.deleteFeedback(f.id),
    );
  }

  Future<void> _export(List<FeedbackItem> list) async {
    final now = DateTime.now();
    try {
      await shareTextFile(
        feedbackExportText(list, now: now),
        name:
            'erros_e_sugestoes_${DateFormat('yyyy-MM-dd_HH-mm').format(now)}.txt',
        subject: 'Erros e sugestões - Livre Serviço',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Não foi possível exportar: $e')));
    }
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
      if (!f.isPublic) 'só o administrador',
    ].join(' · ');
    final done = !f.status.isOpen;
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
                FeedbackStatusBadge(f.status),
                PopupMenuButton<String>(
                  tooltip: 'Estado',
                  onSelected: (v) => v == 'delete'
                      ? _delete(f)
                      : _setStatus(f, FeedbackStatus.fromName(v)),
                  itemBuilder: (_) => [
                    for (final s in FeedbackStatus.values)
                      CheckedPopupMenuItem(
                        value: s.dbName,
                        checked: s == f.status,
                        child: Text(s.label),
                      ),
                    const PopupMenuDivider(),
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
    appBar: AppBar(
      title: const Text('Erros e sugestões'),
      actions: [
        FutureBuilder<List<FeedbackItem>>(
          future: _items,
          builder: (context, snap) {
            final list = snap.data;
            return IconButton(
              tooltip: 'Exportar tudo (texto)',
              icon: const Icon(Icons.file_download_outlined),
              onPressed: list == null || list.isEmpty
                  ? null
                  : () => _export(list),
            );
          },
        ),
      ],
    ),
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
            final open = [
              for (final f in list)
                if (f.status.isOpen) f,
            ];
            final done = [
              for (final f in list)
                if (!f.status.isOpen) f,
            ];
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

/// [f] with its state set to [status], closed now if it wasn't already.
FeedbackItem _withStatus(FeedbackItem f, FeedbackStatus status) => (
  id: f.id,
  kind: f.kind,
  message: f.message,
  email: f.email,
  storeName: f.storeName,
  personName: f.personName,
  appVersion: f.appVersion,
  platform: f.platform,
  createdAt: f.createdAt,
  doneAt: status.isOpen ? null : (f.doneAt ?? DateTime.now()),
  status: status,
  isPublic: f.isPublic,
);
