import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/horario.dart';
import '../../models/opening_list.dart';
import '../../models/person.dart';
import '../../models/planning.dart';
import '../../models/teams.dart';
import '../../models/today.dart';
import '../../services/horario_service.dart';
import '../../services/person_service.dart';
import '../../theme.dart';
import '../people_sections.dart';
import 'role_badge.dart';
import 'section_header.dart';

export '../../models/names.dart';

/// Prompts the user to pick one or more people. Returns the chosen people
/// (never an empty list) or null if the picker is cancelled.
Future<List<Person>?> pickPeople(
  BuildContext context, {
  required String title,
  String? subtitle,
}) {
  return showDialog<List<Person>>(
    context: context,
    builder: (_) => _MultiPersonPickerDialog(title: title, subtitle: subtitle),
  );
}

/// One or more people plus the (plain, time-stripped) calendar date the
/// task they picked was actually completed on — defaults to today but can
/// be overridden via [pickPeopleAndDay].
class PeopleAndDay {
  const PeopleAndDay(this.people, this.day);
  final List<Person> people;
  final DateTime day;
}

/// Like [pickPeople], but also lets the user say the task wasn't done
/// today. [initialDay] is the default/selected date (time-of-day is
/// ignored).
Future<PeopleAndDay?> pickPeopleAndDay(
  BuildContext context, {
  required String title,
  String? subtitle,
  required DateTime initialDay,
  DateTime? firstDay,
  bool Function(DateTime)? selectableDayPredicate,
}) {
  final day = DateTime(initialDay.year, initialDay.month, initialDay.day);
  return showDialog<PeopleAndDay>(
    context: context,
    builder: (_) => _MultiPersonPickerDialog(
      title: title,
      subtitle: subtitle,
      initialDay: day,
      firstDay: firstDay ?? day.subtract(const Duration(days: 90)),
      selectableDayPredicate: selectableDayPredicate,
    ),
  );
}

class _MultiPersonPickerDialog extends StatefulWidget {
  const _MultiPersonPickerDialog({
    required this.title,
    this.subtitle,
    this.initialDay,
    this.firstDay,
    this.selectableDayPredicate,
  });
  final String title;
  final String? subtitle;

  /// When non-null, this dialog is running in "pick people + day" mode and
  /// pops a [PeopleAndDay] instead of a bare `List<Person>`.
  final DateTime? initialDay;
  final DateTime? firstDay;
  final bool Function(DateTime)? selectableDayPredicate;

  @override
  State<_MultiPersonPickerDialog> createState() =>
      _MultiPersonPickerDialogState();
}

class _MultiPersonPickerDialogState extends State<_MultiPersonPickerDialog> {
  late Future<List<Person>> _future;
  late DateTime _selectedDay;
  final Set<int> _selectedIds = {};
  final _searchCtrl = TextEditingController();

  /// Sections opened/closed in this dialog, by title; the rest start closed
  /// except "A trabalhar agora" and the Livre Serviço turno at work (Dia,
  /// or Noite from 19:00 to 05:00).
  final _openOverrides = <String, bool>{};

  static const _onShiftTitle = 'A trabalhar agora';

  bool get _searching => _searchCtrl.text.trim().isNotEmpty;

  /// Whether the selected day is the current service day (always so without
  /// a day to pick), so who is on shift now is worth showing.
  bool get _isNow {
    if (widget.initialDay == null) return true;
    final d = currentServiceDay();
    return _selectedDay.year == d.year &&
        _selectedDay.month == d.month &&
        _selectedDay.day == d.day;
  }

  /// Every matching section is open while searching.
  bool _isOpen(String title, {Turno? turno, bool onShift = false}) =>
      _searching ||
      (_openOverrides[title] ??
          (onShift || turno == (_isNow ? turnoAt(DateTime.now()) : Turno.dia)));

  @override
  void initState() {
    super.initState();
    _future = PersonService.instance.all();
    _selectedDay = widget.initialDay ?? DateTime.now();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDay.year == now.year &&
        _selectedDay.month == now.month &&
        _selectedDay.day == now.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate:
          widget.firstDay ?? _selectedDay.subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'PT'),
      selectableDayPredicate: widget.selectableDayPredicate,
      helpText: 'Quando foi concluída?',
    );
    if (picked == null) return;
    setState(() {
      _selectedDay = DateTime(picked.year, picked.month, picked.day);
    });
  }

  void _toggle(Person p, bool? checked) {
    setState(() {
      if (checked ?? false) {
        _selectedIds.add(p.id);
      } else {
        _selectedIds.remove(p.id);
      }
    });
  }

  void _confirm(List<Person> people) {
    final chosen = people.where((p) => _selectedIds.contains(p.id)).toList();
    if (chosen.isEmpty) return;
    if (widget.initialDay != null) {
      Navigator.of(context).pop(PeopleAndDay(chosen, _selectedDay));
    } else {
      Navigator.of(context).pop(chosen);
    }
  }

  /// [people] grouped like the Pessoas list, each section collapsible and
  /// showing how many of its people are ticked, after a first "A trabalhar
  /// agora" section (Livre Serviço people inside their horário shift, on the
  /// current service day). People off on the selected day are greyed out
  /// with the reason and listed last, but can still be ticked.
  Widget _sectionList(List<Person> people) {
    final schedule = HorarioService.instance.index;
    final sections = buildPeopleSections(
      people,
      query: _searchCtrl.text,
      offDay: _selectedDay,
      horario: schedule,
    );
    if (sections.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Sem resultados.', textAlign: TextAlign.center),
      );
    }
    final shown = {
      for (final s in sections)
        for (final p in s.people) p.id,
    };
    final onShift = !_isNow
        ? const <OnShift>[]
        : [
            for (final s in onShiftAt(schedule, [
              for (final p in people)
                if (p.team == livreServicoId) p,
            ], DateTime.now()))
              if (shown.contains(s.person.id)) s,
          ];

    Widget header(String title, int count, List<Person> members, bool open) =>
        SectionHeader(
          '$title ($count)',
          open: open,
          note: switch (members
              .where((p) => _selectedIds.contains(p.id))
              .length) {
            0 => null,
            final n => '$n ✓',
          },
          onTap: _searching
              ? null
              : () => setState(() => _openOverrides[title] = !open),
        );

    final onShiftOpen = _isOpen(_onShiftTitle, onShift: true);
    return ListView(
      shrinkWrap: true,
      children: [
        if (onShift.isNotEmpty) ...[
          header(_onShiftTitle, onShift.length, [
            for (final s in onShift) s.person,
          ], onShiftOpen),
          if (onShiftOpen)
            for (final s in onShift) _tile(s.person, schedule),
        ],
        for (final section in sections) ...[
          header(
            section.title,
            section.people.length,
            section.people,
            _isOpen(section.title, turno: section.turno),
          ),
          if (_isOpen(section.title, turno: section.turno))
            for (final p in section.people) _tile(p, schedule),
        ],
      ],
    );
  }

  /// [p]'s row: greyed out with the reason when off on the selected day,
  /// else with their horário shift that day (or nº de colaborador).
  Widget _tile(Person p, HorarioIndex schedule) {
    if (offNoteOn(p, _selectedDay, horario: schedule) case final off?) {
      return CheckboxListTile(
        secondary: PersonInitialsBadge(
          name: p.fullName,
          background: context.greyedFill,
        ),
        title: Wrap(
          spacing: 6,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(p.fullName, style: TextStyle(color: context.muted)),
            if (tenureTagOf(p, _selectedDay) case final tenure?)
              RoleBadge(tenure, tenure: true),
            if (awayTagOn(p, _selectedDay, horario: schedule) case final away?)
              RoleBadge(away, away: true),
          ],
        ),
        subtitle: Text(off, style: TextStyle(color: Colors.orange.shade800)),
        value: _selectedIds.contains(p.id),
        onChanged: (checked) => _toggle(p, checked),
      );
    }
    final shift = horarioTextOn(p, _selectedDay, schedule);
    return CheckboxListTile(
      secondary: PersonInitialsBadge(name: p.fullName),
      title: switch (tenureTagOf(p, _selectedDay)) {
        null => Text(p.fullName),
        final tenure => Wrap(
          spacing: 6,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [Text(p.fullName), RoleBadge(tenure, tenure: true)],
        ),
      },
      subtitle: shift != null
          ? Text(shift)
          : p.collaboratorNumber.isEmpty
          ? null
          : Text('Nº ${p.collaboratorNumber}'),
      value: _selectedIds.contains(p.id),
      onChanged: (checked) => _toggle(p, checked),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<Person>>(
          future: _future,
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final people = snap.data!;
            if (people.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sem pessoas registadas.\nAdiciona-as no separador "Pessoas".',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Text(
                      widget.subtitle!,
                      style: TextStyle(color: context.muted),
                    ),
                  ),
                if (widget.initialDay != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 18, color: context.muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _isToday
                                ? 'Hoje'
                                : DateFormat(
                                    "d 'de' MMMM",
                                    'pt_PT',
                                  ).format(_selectedDay),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDate,
                          child: const Text('Alterar'),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Procurar',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Flexible(child: _sectionList(people)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _selectedIds.isEmpty
                          ? null
                          : () => _confirm(people),
                      child: Text(
                        _selectedIds.isEmpty
                            ? 'Confirmar'
                            : 'Confirmar (${_selectedIds.length})',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

/// Small circular badge displaying the initials derived from a person's name.
class PersonInitialsBadge extends StatelessWidget {
  const PersonInitialsBadge({
    super.key,
    required this.name,
    this.size = 32,
    this.background,
    this.foreground = Colors.white,
  });

  final String name;
  final double size;

  /// The theme's primary colour when null.
  final Color? background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? context.colors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: foreground,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A row of [PersonInitialsBadge]s, one per name — for displaying everyone
/// credited on the same completion. Renders nothing for an empty [names].
class PersonInitialsRow extends StatelessWidget {
  const PersonInitialsRow({super.key, required this.names, this.size = 32});
  final List<String> names;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final name in names) PersonInitialsBadge(name: name, size: size),
      ],
    );
  }
}

String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final s = parts.first;
    return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
