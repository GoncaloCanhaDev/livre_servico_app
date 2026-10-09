import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/horario.dart';
import '../models/opening_list.dart';
import '../services/horario_service.dart';
import '../theme.dart';

part 'horarios/month.dart';
part 'horarios/today.dart';

/// The Livre Serviço horários: who is in today, the month as a read-only
/// grid, the codes used, and the file's Exportar / Importar. The horários
/// are only edited in the file.
class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  /// The month shown in the grid; null until there is one.
  String? _month;
  bool _busy = false;

  HorarioService get _service => HorarioService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_changed);
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  /// [_month] if still saved, else the current month, else the latest.
  String? _shownMonth(List<String> months) {
    if (months.isEmpty) return null;
    if (_month case final m? when months.contains(m)) return m;
    final current = monthKey(currentServiceDay());
    return months.contains(current) ? current : months.last;
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await _service.exportFile();
    } catch (e) {
      _snack('Erro ao exportar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final result = await _service.pickAndImport();
      if (result == null || !mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Horários importados'),
          content: Text(
            [
              if (result.meses.isEmpty)
                'O ficheiro não tinha meses; os códigos foram atualizados.'
              else
                'Meses: ${result.meses.map(monthName).join(', ')}.',
              for (final e in result.unmatched.entries)
                '\n${monthName(e.key)} — sem correspondência em Pessoas '
                    '(Livre Serviço): ${e.value.join(', ')}.',
            ].join('\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FormatException catch (e) {
      _snack('Erro ao importar: ${e.message}');
    } catch (e) {
      _snack('Erro ao importar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = _service.horarios;
    final months = h.meses.keys.toList()..sort();
    final month = _shownMonth(months);
    final today = currentServiceDay();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários'),
        actions: [
          IconButton(
            tooltip: 'Exportar horários',
            icon: const Icon(Icons.upload_file),
            onPressed: _busy ? null : _export,
          ),
          IconButton(
            tooltip: 'Importar horários',
            icon: const Icon(Icons.download),
            onPressed: _busy ? null : _import,
          ),
        ],
      ),
      body: SafeArea(
        child: month == null
            ? _Empty(onImport: _busy ? null : _import)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (missingNextMonth(h, today) case final next?)
                    _MissingMonthCard(
                      month: next,
                      onImport: _busy ? null : _import,
                    ),
                  _TodayCard(horarios: h, today: today, index: _service.index),
                  if (_service.index.unmatched(month) case final names
                      when names.isNotEmpty)
                    _UnmatchedCard(month: month, names: names),
                  const SizedBox(height: 12),
                  _MonthHeader(
                    month: month,
                    onPrevious: switch (months.indexOf(month)) {
                      0 => null,
                      final i => () => setState(() => _month = months[i - 1]),
                    },
                    onNext: months.indexOf(month) == months.length - 1
                        ? null
                        : () => setState(
                            () => _month = months[months.indexOf(month) + 1],
                          ),
                  ),
                  const SizedBox(height: 8),
                  _MonthGrid(
                    key: ValueKey(month),
                    horarios: h,
                    month: month,
                    today: today,
                    index: _service.index,
                  ),
                  const SizedBox(height: 12),
                  _MonthTotals(
                    horarios: h,
                    month: month,
                    index: _service.index,
                  ),
                  const SizedBox(height: 12),
                  _Legend(horarios: h, month: month),
                ],
              ),
      ),
    );
  }
}

bool _isNight(Horarios h, String code) => h.codigos[code]?.noturno ?? false;

/// The cell colour for [code]: absences tinted, night shifts darker.
Color? _cellColor(BuildContext context, Horarios h, String code) =>
    switch (code) {
      folgaCode => context.tint(Colors.grey, 300),
      'F' => context.tint(Colors.orange, 100),
      _ when h.ausencias.containsKey(code) => context.tint(Colors.red, 100),
      _ when _isNight(h, code) => context.tint(Colors.indigo),
      _ => null,
    };

class _Empty extends StatelessWidget {
  const _Empty({required this.onImport});

  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month, size: 48, color: context.greyedFill),
            const SizedBox(height: 12),
            Text(
              'Sem horários guardados.\nImporta um ficheiro de horários '
              '(JSON) com os meses do Livre Serviço.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.muted),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.download),
              label: const Text('Importar horários'),
            ),
          ],
        ),
      ),
    );
  }
}
