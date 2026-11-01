import 'package:flutter/material.dart';

import '../services/account_service.dart';
import '../services/backup_service.dart';
import '../services/demo_mode.dart';
import '../services/settings_service.dart';
import 'account_screen.dart';
import 'privacy_policy_screen.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    SettingsService.instance.addListener(_onSettingsChanged);
    AccountService.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsChanged);
    AccountService.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  Widget _goalTile({
    required String title,
    required String subtitle,
    required String unitLabel,
    required int value,
    required Future<void> Function(int) onSave,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Text(
        value.toString(),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        final ctrl = TextEditingController(text: value.toString());
        final val = await showDialog<int>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Objetivo: $title'),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: unitLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, int.tryParse(ctrl.text.trim())),
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
        if (val != null && val > 0) {
          await onSave(val);
        }
      },
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _accountSubtitle() {
    final account = AccountService.instance;
    if (account.store case final s?) return 'A sincronizar com ${s.name}.';
    if (account.isSignedIn) return 'Escolha a loja para sincronizar.';
    return 'Sem conta: os dados ficam só neste aparelho.';
  }

  @override
  Widget build(BuildContext context) {
    final canWipeAll = AccountService.instance.canWipeAll;
    return Scaffold(
      appBar: AppBar(title: const Text('Definições')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('Conta'),
            if (!DemoMode.active)
              ListTile(
                title: const Text(
                  'Conta e Sincronização',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_accountSubtitle()),
                trailing: const Icon(Icons.cloud_sync),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
              ),
            ListTile(
              title: const Text(
                'Política de Privacidade',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Que dados são guardados e quem os vê.'),
              trailing: const Icon(Icons.privacy_tip_outlined),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            ListTile(
              title: const Text(
                'Tutorial',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Como funciona a aplicação, passo a passo.'),
              trailing: const Icon(Icons.school_outlined),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TutorialScreen()),
              ),
            ),
            const Divider(),
            _sectionHeader('Objetivos Diários'),
            _goalTile(
              title: 'Lista Visual',
              subtitle: 'Itens picados necessários por dia.',
              unitLabel: 'Itens picados',
              value: SettingsService.instance.visualGoal,
              onSave: SettingsService.instance.setVisualGoal,
            ),
            const Divider(),
            _sectionHeader('Aparência'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Automático'),
                    icon: Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Claro'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Escuro'),
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: {SettingsService.instance.themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (s) async {
                  await SettingsService.instance.setThemeMode(s.single);
                  if (mounted) setState(() {});
                },
              ),
            ),
            // The demo keeps nothing: no copies in or out, nothing to wipe.
            if (!DemoMode.active) ...[
              const Divider(),
              _sectionHeader('Dados'),
              ListTile(
                title: const Text(
                  'Exportar Dados',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Guarda uma cópia de segurança da base de dados.',
                ),
                trailing: const Icon(Icons.upload_file),
                onTap: _onExport,
              ),
              ListTile(
                title: const Text(
                  'Importar Dados',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Substitui todos os dados atuais por uma cópia de segurança.',
                ),
                trailing: const Icon(Icons.download),
                onTap: _onImport,
              ),
              ListTile(
                enabled: canWipeAll,
                title: Text(
                  'Apagar Todos os Dados',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: canWipeAll ? Colors.red : null,
                  ),
                ),
                subtitle: Text(
                  canWipeAll
                      ? 'Remove permanentemente todos os dados da aplicação.'
                      : 'Só o administrador: apagaria os dados de todos os '
                            'aparelhos.',
                ),
                trailing: Icon(
                  Icons.delete_forever,
                  color: canWipeAll ? Colors.red : null,
                ),
                onTap: _onDeleteAll,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onExport() async {
    try {
      await BackupService.instance.exportToFile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
    }
  }

  Future<void> _onDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar Todos os Dados'),
        content: const Text(
          'Esta ação irá apagar permanentemente todos os dados da aplicação (listas, inventários, pedidos, tarefas, receções, pessoas).\n\nEsta ação não pode ser revertida. Desejas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar Tudo'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await BackupService.instance.clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os dados foram apagados.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao apagar: $e')));
    }
  }

  Future<void> _onImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar Dados'),
        content: const Text(
          'Esta ação irá apagar todos os dados atuais e substituí-los pelos dados do ficheiro selecionado.\n\nDesejas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar e Importar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final imported = await BackupService.instance.pickAndImport();
      if (!mounted) return;
      if (imported) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados importados com sucesso.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // A FormatException says what is wrong in the file (a JSON typo with
      // its line, or a vasilhame item without a name).
      final detail = e is FormatException ? e.message : '$e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao importar: $detail'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }
}
