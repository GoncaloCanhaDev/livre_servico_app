import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/horario.dart';
import '../models/horario_xlsx.dart';
import '../models/person.dart';
import '../services/account_service.dart';
import '../services/horario_service.dart';
import '../services/person_service.dart';
import '../theme.dart';
import 'widgets/wide_layout.dart';

/// "janeiro de 2027".
String monthTitle(DateTime month) =>
    DateFormat("MMMM 'de' y", 'pt_PT').format(month);

/// Checks a horário read from its Excel file before saving it: who each
/// line is for (found by name, or chosen here) and the codes with no hours.
/// Pops true once saved.
class HorarioImportScreen extends StatefulWidget {
  const HorarioImportScreen({super.key, required this.parsed});

  final ParsedHorario parsed;

  @override
  State<HorarioImportScreen> createState() => _HorarioImportScreenState();
}

class _HorarioImportScreenState extends State<HorarioImportScreen> {
  List<Person> _people = [];
  Map<String, Person?> _matches = {};
  bool _exists = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final people = await PersonService.instance.all();
    final months = await HorarioService.instance.months();
    if (!mounted) return;
    setState(() {
      _people = people;
      _matches = matchHorarioNames(
        [for (final l in widget.parsed.linhas) l.nome],
        people,
        previous: months,
      );
      _exists = months.any(
        (m) => monthKey(m.month) == monthKey(widget.parsed.month),
      );
      _loading = false;
    });
  }

  Future<void> _choose(String nome) async {
    final taken = {
      for (final e in _matches.entries)
        if (e.key != nome && e.value != null) e.value!.syncUuid,
    };
    final chosen = await showDialog<Object>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(nome),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Ignorar esta linha',
              style: TextStyle(color: context.muted),
            ),
          ),
          for (final p in _people)
            if (!taken.contains(p.syncUuid))
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, p),
                child: Text(p.fullName),
              ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() => _matches[nome] = chosen is Person ? chosen : null);
  }

  Future<void> _save() async {
    final month = monthTitle(widget.parsed.month);
    if (_exists) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Substituir horário?'),
          content: Text('Já há um horário de $month. Substituir pelo deste ficheiro?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Substituir'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _saving = true);
    final account = AccountService.instance;
    final me = account.access.personId;
    final by = me == null
        ? null
        : await PersonService.instance.bySyncUuid(me);
    await HorarioService.instance.save(
      widget.parsed,
      _matches,
      importedBy: by?.fullName ?? account.email ?? '',
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final parsed = widget.parsed;
    final unmatched = _matches.values.where((p) => p == null).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Importar horário')),
      body: ReadableWidth(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '${monthTitle(parsed.month)} · ${parsed.linhas.length} pessoas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unmatched == 0
                          ? 'Todas as linhas têm uma pessoa.'
                          : 'Toque numa linha para escolher a pessoa. '
                                'As linhas sem pessoa aparecem no horário, '
                                'mas não contam para quem está a trabalhar.',
                      style: TextStyle(color: context.muted),
                    ),
                    if (parsed.semHorario.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: context.tint(Colors.orange),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Códigos sem horário: '
                            '${(parsed.semHorario.toList()..sort()).join(', ')}'
                            ' — nesses dias a pessoa aparece como ausente.',
                            style: TextStyle(color: context.warningText),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    for (final grupo in {for (final l in parsed.linhas) l.grupo}) ...[
                      if (grupo.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                          child: Text(
                            grupo,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      for (final l in parsed.linhas)
                        if (l.grupo == grupo) _line(l.nome),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Importar'),
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _line(String nome) {
    final p = _matches[nome];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(nome),
      subtitle: Text(
        p?.fullName ?? 'Sem correspondência',
        style: TextStyle(color: p == null ? context.warningText : context.muted),
      ),
      leading: Icon(
        p == null ? Icons.help_outline : Icons.check_circle_outline,
        color: p == null ? context.warningText : Colors.green,
      ),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () => _choose(nome),
    );
  }
}
