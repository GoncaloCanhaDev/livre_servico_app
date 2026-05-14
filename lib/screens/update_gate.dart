import 'dart:async';

import 'package:flutter/material.dart';

import '../services/update_service.dart';
import '../theme.dart';

/// Wraps [child] and, on first build, checks GitHub for a newer release.
/// If found, takes over the screen with a blocking download/install UI
/// the user must complete before the app continues.
class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

enum _Stage { checking, upToDate, available, downloading, installing, error }

class _UpdateGateState extends State<UpdateGate> {
  _Stage _stage = _Stage.checking;
  UpdateInfo? _info;
  double _progress = 0;
  String? _errorMessage;
  String? _apkPath;
  bool _promptShown = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final results = await Future.wait([
      UpdateService.instance.checkForUpdate(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;
    final info = results[0] as UpdateInfo?;
    setState(() {
      _info = info;
      _stage = info == null ? _Stage.upToDate : _Stage.available;
    });
  }

  Future<void> _download() async {
    final info = _info;
    if (info == null) return;
    setState(() {
      _stage = _Stage.downloading;
      _progress = 0;
      _errorMessage = null;
    });
    try {
      final path = await UpdateService.instance.downloadApk(
        info.apkUrl,
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      _apkPath = path;
      setState(() => _stage = _Stage.installing);
      await UpdateService.instance.install(path);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.error;
        _errorMessage = '$e';
      });
    }
  }

  void _showUpdatePrompt() {
    if (_promptShown || !mounted) return;
    _promptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Atualização disponível'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Versão ${_info?.version ?? ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if ((_info?.notes ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_info!.notes,
                      style: const TextStyle(fontSize: 13)),
                ],
              ],
            ),
            actions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Instalar'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _download();
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _Stage.upToDate) return widget.child;
    if (_stage == _Stage.checking) return const _LoadingSplash();
    if (_stage == _Stage.available) {
      _showUpdatePrompt();
      return widget.child;
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    final info = _info;
    switch (_stage) {
      case _Stage.available:
        return [
          const Icon(Icons.system_update_alt,
              size: 64, color: AppColors.green),
          const SizedBox(height: 16),
          Text(
            'Atualização disponível',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Versão ${info?.version ?? ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          if ((info?.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                info!.notes,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _download,
            icon: const Icon(Icons.download),
            label: const Text('Atualizar agora'),
          ),
          const SizedBox(height: 8),
          const Text(
            'A app precisa de atualizar para continuar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ];
      case _Stage.downloading:
        final pct = (_progress.clamp(0, 1) * 100).round();
        return [
          const Icon(Icons.cloud_download_outlined,
              size: 64, color: AppColors.green),
          const SizedBox(height: 16),
          const Text(
            'A transferir atualização…',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress.clamp(0, 1).toDouble(),
              minHeight: 10,
              color: AppColors.green,
              backgroundColor: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$pct%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ];
      case _Stage.installing:
        return [
          const Icon(Icons.install_mobile,
              size: 64, color: AppColors.green),
          const SizedBox(height: 16),
          const Text(
            'A iniciar instalação',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Toca em "Instalar" no diálogo do sistema. Se for pedido, autoriza esta app a instalar atualizações.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              if (_apkPath != null) {
                UpdateService.instance.install(_apkPath!);
              }
            },
            child: const Text('Reabrir instalador'),
          ),
        ];
      case _Stage.error:
        return [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Erro ao atualizar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Erro desconhecido.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _download,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ];
      case _Stage.checking:
      case _Stage.upToDate:
        return const [SizedBox.shrink()];
    }
  }
}

class _LoadingSplash extends StatefulWidget {
  const _LoadingSplash();

  @override
  State<_LoadingSplash> createState() => _LoadingSplashState();
}

class _LoadingSplashState extends State<_LoadingSplash> {
  final List<String> _revealed = [];
  List<String> _pending = [];
  Timer? _reveal;

  @override
  void initState() {
    super.initState();
    UpdateService.instance.fetchReleaseTags().then((tags) {
      if (!mounted) return;
      _pending = List<String>.from(tags);
      _scheduleNext();
    });
  }

  void _scheduleNext() {
    if (!mounted || _pending.isEmpty) return;
    _reveal?.cancel();
    _reveal = Timer(const Duration(milliseconds: 220), () {
      if (!mounted || _pending.isEmpty) return;
      setState(() => _revealed.add(_pending.removeAt(0)));
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _reveal?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront,
                    size: 72, color: AppColors.green),
                const SizedBox(height: 16),
                const Text(
                  'Livre Serviço',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'A inicializar e a procurar atualizações…',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                _ReleaseList(revealed: _revealed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReleaseList extends StatelessWidget {
  const _ReleaseList({required this.revealed});
  final List<String> revealed;

  @override
  Widget build(BuildContext context) {
    if (revealed.isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Versões encontradas no GitHub',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < revealed.length; i++)
            AnimatedSlide(
              key: ValueKey(revealed[i]),
              offset: Offset.zero,
              duration: const Duration(milliseconds: 180),
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.green.withValues(alpha: 0.12)
                        : AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        i == 0 ? Icons.fiber_new : Icons.history,
                        size: 14,
                        color: i == 0
                            ? AppColors.greenDark
                            : Colors.black45,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          revealed[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                i == 0 ? FontWeight.w700 : FontWeight.w500,
                            color: i == 0
                                ? AppColors.greenDark
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
