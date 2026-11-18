import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/horario.dart';
import '../models/opening_list.dart';
import '../models/person.dart';
import '../models/today.dart';
import '../services/account_service.dart';
import '../services/horario_service.dart';
import '../services/person_service.dart';
import '../theme.dart';
import 'horario_import_screen.dart';
import 'widgets/app_bar_tabs.dart';
import 'widgets/wide_layout.dart';

part 'horarios/day.dart';
part 'horarios/week.dart';
part 'horarios/month.dart';

/// The store's horário, imported from its monthly Excel file: who works on
/// a day, a week and the month. Every member sees it; level 3 and up
/// import it.
class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  Map<String, Person> _people = {};

  @override
  void initState() {
    super.initState();
    HorarioService.instance.addListener(_changed);
    PersonService.instance.addListener(_loadPeople);
    _loadPeople();
  }

  @override
  void dispose() {
    HorarioService.instance.removeListener(_changed);
    PersonService.instance.removeListener(_loadPeople);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPeople() async {
    final people = await PersonService.instance.all();
    if (!mounted) return;
    setState(() => _people = {for (final p in people) p.syncUuid: p});
  }

  bool get _canImport => AccountService.instance.access.canImportHorarios;

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final parsed = await HorarioService.instance.pickFile();
      if (parsed == null || !mounted) return;
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => HorarioImportScreen(parsed: parsed)),
      );
      if (saved == true) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Horário de ${monthTitle(parsed.month)} importado.'),
          ),
        );
      }
    } on FormatException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Não foi possível ler o ficheiro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = _HorarioView(
      index: HorarioService.instance.index,
      people: _people,
      canImport: _canImport,
      onImport: _import,
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Horários'),
          actions: [
            if (_canImport)
              IconButton(
                icon: const Icon(Icons.upload_file),
                tooltip: 'Importar horário',
                onPressed: _import,
              ),
          ],
          bottom: appBarTabs(const [
            Tab(text: 'Dia'),
            Tab(text: 'Semana'),
            Tab(text: 'Mês'),
          ]),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            children: [_DayTab(view), _WeekTab(view), _MonthTab(view)],
          ),
        ),
      ),
    );
  }
}

/// What every tab reads.
class _HorarioView {
  const _HorarioView({
    required this.index,
    required this.people,
    required this.canImport,
    required this.onImport,
  });

  final HorarioIndex index;

  /// The store's people by `syncUuid`.
  final Map<String, Person> people;
  final bool canImport;
  final VoidCallback onImport;

  /// The linked person's name, or the name in the Excel file.
  String nameOf(HorarioLinha l) => people[l.personId]?.fullName ?? l.nome;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The background of a day of kind [tipo].
Color horarioColor(BuildContext context, HorarioTipo tipo) => switch (tipo) {
  HorarioTipo.abertura => context.tint(Colors.lightBlue, 100),
  HorarioTipo.intermedio => context.tint(Colors.teal, 100),
  HorarioTipo.fecho => context.tint(Colors.amber, 100),
  HorarioTipo.noite => context.tint(Colors.indigo, 100),
  HorarioTipo.folga => Colors.transparent,
  HorarioTipo.ausente => context.tint(Colors.orange, 100),
};

/// "Ainda não há horário para janeiro de 2027." and, when allowed, the import button.
class _NoHorario extends StatelessWidget {
  const _NoHorario(this.view, this.month);

  final _HorarioView view;
  final DateTime month;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ainda não há horário para ${monthTitle(month)}.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.muted),
          ),
          if (view.canImport) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Importar horário'),
              onPressed: view.onImport,
            ),
          ],
        ],
      ),
    ),
  );
}

/// ‹ [label] › with a tap on the label going back to [onToday].
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.onToday,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Anterior',
          onPressed: onPrevious,
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (onToday != null)
          TextButton(onPressed: onToday, child: const Text('Hoje')),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Seguinte',
          onPressed: onNext,
        ),
      ],
    ),
  );
}

/// The colours' meaning, under the Semana and Mês grids.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final t in HorarioTipo.values)
          if (t != HorarioTipo.folga)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: horarioColor(context, t),
                    border: Border.all(color: context.hairline),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(t.label, style: TextStyle(color: context.muted, fontSize: 12)),
              ],
            ),
      ],
    ),
  );
}

/// One cell of the Semana and Mês grids.
class _Cell extends StatelessWidget {
  const _Cell(this.dia, {required this.width, this.today = false});

  final HorarioDia? dia;
  final double width;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final d = dia;
    return Container(
      width: width,
      height: 36,
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: d == null ? null : horarioColor(context, d.tipo),
        borderRadius: BorderRadius.circular(4),
        border: today ? Border.all(color: context.colors.primary, width: 2) : null,
      ),
      child: d == null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  d.shortText,
                  style: TextStyle(
                    fontSize: 12,
                    color: d.isShift ? context.colors.onSurface : context.muted,
                    fontWeight: d.isShift ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
    );
  }
}

/// The lines of the month read for [day], grouped as in the Excel file
/// (Dia, Noite) in their order there.
List<({String grupo, List<HorarioLinha> linhas})> _groups(
  List<HorarioLinha> linhas,
) {
  final out = <String, List<HorarioLinha>>{};
  for (final l in linhas) {
    (out[l.grupo.isEmpty ? 'Outros' : l.grupo] ??= []).add(l);
  }
  return [for (final e in out.entries) (grupo: e.key, linhas: e.value)];
}
