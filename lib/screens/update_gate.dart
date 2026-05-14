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

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final info = await UpdateService.instance.checkForUpdate();
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    if (_stage == _Stage.upToDate) return widget.child;
    if (_stage == _Stage.checking) {
      // Don't block the UI while we're still checking — show the app.
      // The gate only takes over once we've confirmed an update exists.
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
