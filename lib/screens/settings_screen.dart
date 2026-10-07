import 'package:flutter/material.dart';

import '../services/backup_service.dart';
import '../services/settings_service.dart';

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
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsChanged);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Definições')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('Objetivos Diários'),
            _goalTile(
              title: 'Lista Visual',
              subtitle: 'Itens picados necessários por dia.',
              unitLabel: 'Itens picados',
              value: SettingsService.instance.visualGoal,
              onSave: SettingsService.instance.setVisualGoal,
            ),
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
              title: const Text(
                'Apagar Todos os Dados',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              subtitle: const Text(
                'Remove permanentemente todos os dados da aplicação.',
              ),
              trailing: const Icon(Icons.delete_forever, color: Colors.red),
              onTap: _onDeleteAll,
            ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao importar: $e')));
    }
  }
}
