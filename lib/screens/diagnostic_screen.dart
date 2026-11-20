import 'dart:async';

import 'package:flutter/material.dart';

import '../app_version.dart';
import '../models/diagnostic.dart';
import '../services/account_service.dart';
import '../services/auto_mark_service.dart';
import '../services/demo_mode.dart';
import '../services/local_db.dart';
import '../services/server_clock.dart';
import '../services/settings_service.dart';
import '../services/share_file.dart';
import '../services/sync_service.dart';
import '../theme.dart';
import 'widgets/sync_status.dart';
import 'widgets/wide_layout.dart';

/// Definições → Diagnóstico: how sync and the tasks marked by themselves
/// are doing on this device, to see why something didn't arrive without
/// plugging the phone in. "Partilhar" sends it all as a text file.
class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  late final StreamSubscription<String> _writes;
  Timer? _tick;
  int? _unconfirmed;

  static final List<ChangeNotifier> _sources = [
    SyncService.instance,
    AutoMarkService.instance,
    AccountService.instance,
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _sources) {
      s.addListener(_changed);
    }
    _writes = LocalDb.localWrites.listen((_) => _changed());
    // "Há 12 s" moves on its own.
    _tick = Timer.periodic(const Duration(seconds: 5), (_) => _changed());
    _countUnconfirmed();
  }

  @override
  void dispose() {
    for (final s in _sources) {
      s.removeListener(_changed);
    }
    _writes.cancel();
    _tick?.cancel();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _countUnconfirmed() async {
    final n = await AutoMarkService.instance.unconfirmed();
    if (mounted) setState(() => _unconfirmed = n);
  }

  List<DiagSection> _sections() {
    final sync = SyncService.instance;
    final auto = AutoMarkService.instance;
    final account = AccountService.instance;
    final access = account.access;
    final offset = ServerClock.offset;

    final syncLines = <DiagLine>[
      if (DemoMode.active)
        const DiagLine('Ligação', 'Demonstração: nada vai online')
      else if (!account.isConfigured)
        const DiagLine('Ligação', 'Sem base de dados online nesta versão')
      else if (!account.isSignedIn)
        const DiagLine('Ligação', 'Sem conta: os dados ficam neste aparelho')
      else if (account.store case final store?)
        DiagLine(
          'Ligação',
          store.pending
              ? '${store.name} (pedido por aprovar: nada sincroniza)'
              : sync.isConnected
              ? store.name
              : '${store.name} (desligado)',
          warn: store.pending || !sync.isConnected,
        )
      else
        const DiagLine('Ligação', 'Sem loja escolhida', warn: true),
      if (sync.isConnected) ...[
        DiagLine(
          'Estado',
          syncStatusText(sync),
          warn: sync.lastError != null,
        ),
        DiagLine('Última com sucesso', diagTimeText(sync.lastSyncedAt)),
        if (sync.canPush)
          DiagLine(
            'Por enviar',
            pendingText(sync.pendingCount, photos: sync.pendingPhotos),
            warn: sync.pendingCount + sync.pendingPhotos > 0,
          )
        else
          const DiagLine('Envio', 'Este aparelho só recebe'),
        for (final MapEntry(:key, :value) in sync.pendingByCollection.entries)
          DiagLine('  $key', '$value por enviar'),
        DiagLine('Recebido até', diagTimeText(sync.cursor?.toLocal())),
      ],
      DiagLine(
        'Relógio do telemóvel',
        clockOffsetText(offset),
        warn: clockOffsetWorrying(offset),
      ),
    ];

    final blocked = autoMarkBlockedReason(
      canAutoMark: access.canAutoMark,
      connected: sync.isConnected,
      synced: sync.lastSyncedAt != null,
    );
    final autoLines = <DiagLine>[
      DiagLine('Estado', blocked ?? 'Ativo'),
      DiagLine(
        'Marca a partir de',
        diagTimeText(SettingsService.instance.autoMarkSince),
      ),
      DiagLine(
        'Última verificação',
        auto.lastRunAt == null
            ? '—'
            : '${diagTimeText(auto.lastRunAt)} · '
                  '${_tasks(auto.lastRunMarked)} marcada'
                  '${auto.lastRunMarked == 1 ? '' : 's'}',
      ),
      if (auto.lastRunError case final e?)
        DiagLine('Erro', '$e', warn: true),
      DiagLine('Marcadas nesta sessão', '${auto.markedThisSession}'),
      DiagLine(
        'Por confirmar (7 dias)',
        _unconfirmed == null ? '…' : '$_unconfirmed',
      ),
    ];

    final db = LocalDb.instance;
    final counts = [
      for (final c in db.collections)
        if (c.count > 0) (name: c.name, count: c.count),
    ];
    final deviceLines = <DiagLine>[
      const DiagLine('Versão', appVersion),
      if (!DemoMode.active && account.isSignedIn)
        DiagLine('Conta', account.email ?? '—'),
      DiagLine(
        'Permissões',
        access.admin
            ? (account.isSignedIn ? 'Administrador' : 'Tudo (sem conta)')
            : 'Nível ${access.level}',
      ),
      DiagLine(
        'Registos guardados',
        '${counts.fold(0, (sum, c) => sum + c.count)}',
      ),
      for (final c in counts) DiagLine('  ${c.name}', '${c.count}'),
    ];

    return [
      DiagSection('Sincronização', syncLines),
      if (sync.log.isNotEmpty)
        DiagSection('Últimas sincronizações', [
          for (final e in sync.log)
            DiagLine(
              diagTimeText(e.at),
              e.error != null
                  ? 'Falhou (${durationText(e.took)}): '
                        '${accountErrorText(e.error!)}'
                  : '↑ ${e.pushed} ↓ ${e.pulled} · ${durationText(e.took)}',
              warn: e.error != null,
            ),
        ]),
      DiagSection('Tarefas marcadas sozinhas', autoLines),
      DiagSection('Este aparelho', deviceLines),
    ];
  }

  static String _tasks(int n) => n == 1 ? '1 tarefa' : '$n tarefas';

  Future<void> _share(List<DiagSection> sections) async {
    final now = DateTime.now();
    final text = diagnosticText(sections, at: now, version: appVersion);
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    try {
      await shareTextFile(
        text,
        name: 'diagnostico_$stamp.txt',
        subject: 'Diagnóstico',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao partilhar: $e')));
    }
  }

  Future<void> _checkTasks() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final marked = await AutoMarkService.instance.runNow();
      await _countUnconfirmed();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            marked == 0
                ? 'Nenhuma tarefa por marcar.'
                : '${_tasks(marked)} marcada${marked == 1 ? '' : 's'}.',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = SyncService.instance;
    final sections = _sections();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico'),
        actions: [
          IconButton(
            tooltip: 'Partilhar',
            icon: const Icon(Icons.share),
            onPressed: () => _share(sections),
          ),
        ],
      ),
      body: SafeArea(
        child: ReadableWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Como está a sincronização e a marcação automática das '
                'tarefas neste aparelho. Se algo não chegar a outro '
                'telemóvel, partilhe isto com quem o ajuda.',
                style: TextStyle(color: context.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (sync.isConnected)
                    FilledButton.icon(
                      onPressed: sync.isSyncing ? null : sync.syncNow,
                      icon: const Icon(Icons.sync),
                      label: const Text('Sincronizar agora'),
                    ),
                  if (AutoMarkService.instance.canRun)
                    OutlinedButton.icon(
                      onPressed: _checkTasks,
                      icon: const Icon(Icons.task_alt),
                      label: const Text('Verificar tarefas agora'),
                    ),
                ],
              ),
              for (final s in sections) _SectionCard(section: s),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final DiagSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              section.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final l in section.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        l.label,
                        style: TextStyle(color: context.muted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Text(
                        l.value,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: l.warn ? context.warningText : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
