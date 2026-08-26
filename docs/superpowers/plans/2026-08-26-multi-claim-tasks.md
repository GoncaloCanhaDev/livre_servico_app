# Multi-Claim Tasks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let more than one person be credited for completing a checklist task, finalizing a list, receiving a truck, or running an inventory session, instead of just one.

**Architecture:** Every "who did this" field in the app is currently a single `String`. This plan adds a parallel `List<String>` field beside each one (the legacy field is kept, frozen, for historical read fallback — never rewritten), switches the shared person-picker dialog to multi-select, and updates every write site to save the picked list and every read/display site to resolve and show it. The picker rename is done additively (old + new functions coexist) so every intermediate task keeps `flutter analyze` clean, with a final cleanup task deleting the old single-select API once nothing references it anymore.

**Tech Stack:** Flutter, Isar (`isar_community`) local database, no backend, pt_PT-only UI strings.

**Spec:** `docs/superpowers/specs/2026-08-26-multi-claim-tasks-design.md`

## Global Constraints

- No automated test suite exists in this repo — verification is `flutter analyze` (zero new issues) plus manual reasoning/UI walkthrough, per `CLAUDE.md`.
- Baseline `flutter analyze` output before this plan starts: exactly 3 pre-existing `info` lints — `historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:330`. Any task must not introduce new issues beyond these. Two tasks shift these line numbers by adding lines above them (each task's own Verify step restates the current expected numbers): Task 7 shifts `truck_form_screen.dart:330` to `:334`; Task 8 shifts `historico_screen.dart:951`/`:953` to `:952`/`:954`. From Task 8 onward (Tasks 8, 9, 10), expect all three at `historico_screen.dart:952`, `historico_screen.dart:954`, `truck_form_screen.dart:334`.
- After any `@collection` model change, run `dart run build_runner build --delete-conflicting-outputs` to regenerate `*.g.dart` before analyzing.
- Legacy single-name fields (`kiwiAberturaBy`, `doneBy`, `createdByInitials`, etc.) are kept on every model, unchanged in type, and are never written again after this plan — only read, via `resolveNames`, as a fallback for rows saved before this feature existed.
- All new UI strings are Portuguese (pt_PT), matching the surrounding text's existing tone/register in each file.
- Out of scope, do not touch: `ShiftEvent.createdByInitials` and `Pedido.createdByInitials` (dead, never written); `historico_screen.dart`'s `_trailingWithInitials` no-op helper; the pre-existing gap where `OpeningListService`/`ReportListService`'s `backfillFinalized()` doesn't record who backdated-finalized something; `dashboard_screen.dart` (confirmed it never reads any "who" field).
- Tasks 1 and 2 are additive-only and must not change behavior for any existing caller. Tasks 3–9 each fully migrate their own file(s) in one commit (no partial/half-migrated state). Task 10 runs last, after every caller has migrated.

---

### Task 1: Shared picker — multi-select + name-list helpers

**Files:**
- Modify: `lib/screens/widgets/person_picker.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces (for every later task): `pickPeople(BuildContext, {required String title, String? subtitle}) -> Future<List<Person>?>`; `pickPeopleAndDay(BuildContext, {required String title, String? subtitle, required DateTime initialDay, DateTime? firstDay, bool Function(DateTime)? selectableDayPredicate}) -> Future<PeopleAndDay?>`; `class PeopleAndDay { final List<Person> people; final DateTime day; }`; `List<String> resolveNames(List<String> names, String? legacy)`; `String joinNames(List<String> names)`; `class PersonInitialsRow extends StatelessWidget` (`{required List<String> names, double size = 32}`). The existing `pickPerson`, `pickPersonAndDay`, and `PersonAndDay` are left completely untouched in this task — every current caller still compiles and works exactly as before. Task 10 deletes them once every caller has migrated.

- [ ] **Step 1: Add the new picker functions, `PeopleAndDay`, `resolveNames`, `joinNames`, and a new multi-select `_MultiPersonPickerDialog`**

The existing `_PersonPickerDialog` is tap-to-choose-one. Rather than change it (which would break every not-yet-migrated caller), add a **second**, separate dialog class `_MultiPersonPickerDialog` for the new functions, leaving `_PersonPickerDialog` untouched.

Replace the entire contents of `lib/screens/widgets/person_picker.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/person.dart';
import '../../services/person_service.dart';
import '../../theme.dart';

/// Prompts the user to pick a person. Returns the chosen [Person] or null
/// if the picker is cancelled / no one is selected.
///
/// Deprecated in favor of [pickPeople] — kept only until every call site in
/// this codebase has migrated (tracked by the multi-claim-tasks plan), then
/// removed.
Future<Person?> pickPerson(
  BuildContext context, {
  required String title,
  String? subtitle,
}) {
  return showDialog<Person>(
    context: context,
    builder: (_) => _PersonPickerDialog(title: title, subtitle: subtitle),
  );
}

/// A person plus the (plain, time-stripped) calendar date the task they
/// picked was actually completed on — defaults to today but can be
/// overridden via [pickPersonAndDay].
class PersonAndDay {
  const PersonAndDay(this.person, this.day);
  final Person person;
  final DateTime day;
}

/// Like [pickPerson], but also lets the user say the task wasn't done today.
/// [initialDay] is the default/selected date (time-of-day is ignored).
///
/// Deprecated in favor of [pickPeopleAndDay] — kept only until every call
/// site in this codebase has migrated, then removed.
Future<PersonAndDay?> pickPersonAndDay(
  BuildContext context, {
  required String title,
  String? subtitle,
  required DateTime initialDay,
  DateTime? firstDay,
  bool Function(DateTime)? selectableDayPredicate,
}) {
  final day = DateTime(initialDay.year, initialDay.month, initialDay.day);
  return showDialog<PersonAndDay>(
    context: context,
    builder: (_) => _PersonPickerDialog(
      title: title,
      subtitle: subtitle,
      initialDay: day,
      firstDay: firstDay ?? day.subtract(const Duration(days: 90)),
      selectableDayPredicate: selectableDayPredicate,
    ),
  );
}

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

/// Names to treat as "who did this": the new list if it has anything,
/// otherwise the single legacy name (wrapped in a list) if there is one,
/// otherwise empty. Read-time fallback for rows saved before this field
/// existed — old rows are never rewritten.
List<String> resolveNames(List<String> names, String? legacy) {
  if (names.isNotEmpty) return names;
  if (legacy == null || legacy.isEmpty) return [];
  return [legacy];
}

/// Portuguese-style join for display: "A", "A e B", "A, B e C".
String joinNames(List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.first;
  return '${names.sublist(0, names.length - 1).join(', ')} e ${names.last}';
}

class _PersonPickerDialog extends StatefulWidget {
  const _PersonPickerDialog({
    required this.title,
    this.subtitle,
    this.initialDay,
    this.firstDay,
    this.selectableDayPredicate,
  });
  final String title;
  final String? subtitle;

  /// When non-null, this dialog is running in "pick person + day" mode and
  /// pops a [PersonAndDay] instead of a bare [Person].
  final DateTime? initialDay;
  final DateTime? firstDay;
  final bool Function(DateTime)? selectableDayPredicate;

  @override
  State<_PersonPickerDialog> createState() => _PersonPickerDialogState();
}

class _PersonPickerDialogState extends State<_PersonPickerDialog> {
  late Future<List<Person>> _future;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _future = PersonService.instance.all();
    _selectedDay = widget.initialDay ?? DateTime.now();
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

  void _choose(Person p) {
    if (widget.initialDay != null) {
      Navigator.of(context).pop(PersonAndDay(p, _selectedDay));
    } else {
      Navigator.of(context).pop(p);
    }
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
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                if (widget.initialDay != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 18,
                          color: Colors.black54,
                        ),
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
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: people.length,
                    itemBuilder: (_, i) {
                      final p = people[i];
                      return ListTile(
                        leading: PersonInitialsBadge(name: p.fullName),
                        title: Text(p.fullName),
                        subtitle: p.collaboratorNumber.isEmpty
                            ? null
                            : Text('Nº ${p.collaboratorNumber}'),
                        onTap: () => _choose(p),
                      );
                    },
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

  @override
  void initState() {
    super.initState();
    _future = PersonService.instance.all();
    _selectedDay = widget.initialDay ?? DateTime.now();
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
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                if (widget.initialDay != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 18,
                          color: Colors.black54,
                        ),
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
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: people.length,
                    itemBuilder: (_, i) {
                      final p = people[i];
                      return CheckboxListTile(
                        secondary: PersonInitialsBadge(name: p.fullName),
                        title: Text(p.fullName),
                        subtitle: p.collaboratorNumber.isEmpty
                            ? null
                            : Text('Nº ${p.collaboratorNumber}'),
                        value: _selectedIds.contains(p.id),
                        onChanged: (checked) => _toggle(p, checked),
                      );
                    },
                  ),
                ),
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
    this.background = AppColors.green,
    this.foreground = Colors.white,
  });

  final String name;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
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
```

- [ ] **Step 2: Verify**

Run: `flutter analyze`
Expected: exactly the 3 pre-existing baseline `info` lints (`historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:330`) and nothing else — this task is purely additive, so every existing caller of `pickPerson`/`pickPersonAndDay` still compiles unchanged.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/widgets/person_picker.dart
git commit -m "feat: add multi-select person picker alongside the single-select one"
```

---

### Task 2: Data models — add name-list fields

**Files:**
- Modify: `lib/models/daily_tasks.dart`
- Modify: `lib/models/weekly_tasks.dart`
- Modify: `lib/models/custom_task.dart`
- Modify: `lib/models/opening_list.dart`
- Modify: `lib/models/report_list.dart`
- Modify: `lib/models/visual_list.dart`
- Modify: `lib/models/auto_list.dart`
- Modify: `lib/models/inventory.dart`
- Modify: `lib/models/truck_reception.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces (for every later task): `DailyTasks.kiwiAberturaByNames`, `.alteracoesPrecoByNames`, `.verificacaoTemperaturasByNames`, `.preenchimentoQuadroByNames`, `.verificacaoValidadesByNames`, `.kiwiFechoByNames` (all `List<String>`, default `[]`); `WeeklyTasks.limpezaMaquinaVoltasByNames`, `.verificar1aByNames`, `.verificar4aByNames` (`List<String>`, default `[]`); `CustomTaskEntry.doneByNames` (`List<String>`, default `[]`); `OpeningList.createdByNames`, `ReportList.createdByNames`, `VisualList.createdByNames`, `AutoList.createdByNames`, `Inventory.createdByNames`, `TruckReception.createdByNames` (all `List<String>`, default `[]`). Every corresponding legacy field (`kiwiAberturaBy`, `doneBy`, `createdByInitials`, etc.) is kept, unchanged in type, and commented as legacy-only.

- [ ] **Step 1: `lib/models/daily_tasks.dart`**

Old:
```dart
  bool kiwiAbertura = false;
  String? kiwiAberturaBy;
  bool alteracoesPreco = false;
  String? alteracoesPrecoBy;
  int alteracoesPrecoCount = 0;
  bool verificacaoTemperaturas = false;
  String? verificacaoTemperaturasBy;
  bool preenchimentoQuadro = false;
  String? preenchimentoQuadroBy;
  bool verificacaoValidades = false;
  String? verificacaoValidadesBy;
  int verificacaoValidadesCount = 0;
  bool kiwiFecho = false;
  String? kiwiFechoBy;
```

New:
```dart
  bool kiwiAbertura = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? kiwiAberturaBy;
  List<String> kiwiAberturaByNames = [];
  bool alteracoesPreco = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? alteracoesPrecoBy;
  List<String> alteracoesPrecoByNames = [];
  int alteracoesPrecoCount = 0;
  bool verificacaoTemperaturas = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? verificacaoTemperaturasBy;
  List<String> verificacaoTemperaturasByNames = [];
  bool preenchimentoQuadro = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? preenchimentoQuadroBy;
  List<String> preenchimentoQuadroByNames = [];
  bool verificacaoValidades = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? verificacaoValidadesBy;
  List<String> verificacaoValidadesByNames = [];
  int verificacaoValidadesCount = 0;
  bool kiwiFecho = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? kiwiFechoBy;
  List<String> kiwiFechoByNames = [];
```

- [ ] **Step 2: `lib/models/weekly_tasks.dart`**

Old:
```dart
  bool limpezaMaquinaVoltas = false;
  String? limpezaMaquinaVoltasBy;

  /// Itens no Mural — mínimo 10, recomendado 20. Due Monday.
  bool verificar1a = false;
  String? verificar1aBy;
  int verificar1aCount = 0;

  /// Itens por colocar preço. Due Monday.
  bool verificar4a = false;
  String? verificar4aBy;
  int verificar4aCount = 0;
```

New:
```dart
  bool limpezaMaquinaVoltas = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? limpezaMaquinaVoltasBy;
  List<String> limpezaMaquinaVoltasByNames = [];

  /// Itens no Mural — mínimo 10, recomendado 20. Due Monday.
  bool verificar1a = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? verificar1aBy;
  List<String> verificar1aByNames = [];
  int verificar1aCount = 0;

  /// Itens por colocar preço. Due Monday.
  bool verificar4a = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? verificar4aBy;
  List<String> verificar4aByNames = [];
  int verificar4aCount = 0;
```

- [ ] **Step 3: `lib/models/custom_task.dart`**

Old:
```dart
  bool done = false;
  String? doneBy;

  /// Only meaningful when the task's [CustomTask.inputType] is `count`.
  int? count;
```

New:
```dart
  bool done = false;
  /// Legacy — kept for historical read fallback only, do not write.
  String? doneBy;
  List<String> doneByNames = [];

  /// Only meaningful when the task's [CustomTask.inputType] is `count`.
  int? count;
```

- [ ] **Step 4: `lib/models/opening_list.dart`, `lib/models/report_list.dart`, `lib/models/visual_list.dart`, `lib/models/auto_list.dart`, `lib/models/inventory.dart`, `lib/models/truck_reception.dart`**

All six collections have this exact same line today:
```dart
  bool synced = true;
  String? createdByInitials;
```

Change it, identically, in each of the six files, to:
```dart
  bool synced = true;
  /// Legacy — kept for historical read fallback only, do not write.
  String? createdByInitials;
  List<String> createdByNames = [];
```

- [ ] **Step 5: Regenerate Isar code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes without errors; `daily_tasks.g.dart`, `weekly_tasks.g.dart`, `custom_task.g.dart`, `opening_list.g.dart`, `report_list.g.dart`, `visual_list.g.dart`, `auto_list.g.dart`, `inventory.g.dart`, `truck_reception.g.dart` are all rewritten.

- [ ] **Step 6: Verify**

Run: `flutter analyze`
Expected: exactly the 3 pre-existing baseline `info` lints (`historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:330`) and nothing else — this task is purely additive, nothing yet reads or writes the new fields.

- [ ] **Step 7: Commit**

```bash
git add lib/models/daily_tasks.dart lib/models/daily_tasks.g.dart lib/models/weekly_tasks.dart lib/models/weekly_tasks.g.dart lib/models/custom_task.dart lib/models/custom_task.g.dart lib/models/opening_list.dart lib/models/opening_list.g.dart lib/models/report_list.dart lib/models/report_list.g.dart lib/models/visual_list.dart lib/models/visual_list.g.dart lib/models/auto_list.dart lib/models/auto_list.g.dart lib/models/inventory.dart lib/models/inventory.g.dart lib/models/truck_reception.dart lib/models/truck_reception.g.dart
git commit -m "feat: add name-list fields for multi-claim tasks"
```

---

### Task 3: Daily Tasks & Weekly Tasks screens — multi-select completion

**Files:**
- Modify: `lib/screens/daily_tasks_screen.dart`
- Modify: `lib/screens/weekly_tasks_screen.dart`

**Interfaces:**
- Consumes: `pickPeopleAndDay`, `PeopleAndDay`, `joinNames`, `PersonInitialsRow`, `resolveNames` from `lib/screens/widgets/person_picker.dart` (Task 1); `kiwiAberturaByNames`, `alteracoesPrecoByNames`, `verificacaoTemperaturasByNames`, `preenchimentoQuadroByNames`, `verificacaoValidadesByNames`, `kiwiFechoByNames` from `lib/models/daily_tasks.dart`, and `limpezaMaquinaVoltasByNames`, `verificar1aByNames`, `verificar4aByNames` from `lib/models/weekly_tasks.dart` (Task 2).
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Update `lib/screens/daily_tasks_screen.dart`**

Replace the `_completeTask` helper (it currently calls `pickPersonAndDay` and threads a single `String who`):

```dart
  Future<void> _completeTask({
    required String taskName,
    required String timerKey,
    required void Function(DailyTasks target, String who) apply,
    required String Function(String who) message,
  }) async {
    final tasks = _tasks;
    if (tasks == null) return;
    final today = DateTime(
      tasks.serviceDay.year,
      tasks.serviceDay.month,
      tasks.serviceDay.day,
    );
    final result = await pickPersonAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '$taskName\n\nDepois de concluída, não poderá ser desmarcada nesse dia.',
      initialDay: today,
    );
    if (result == null) return;
    final who = result.person.fullName;
```

with:

```dart
  Future<void> _completeTask({
    required String taskName,
    required String timerKey,
    required void Function(DailyTasks target, List<String> who) apply,
    required String Function(List<String> who) message,
  }) async {
    final tasks = _tasks;
    if (tasks == null) return;
    final today = DateTime(
      tasks.serviceDay.year,
      tasks.serviceDay.month,
      tasks.serviceDay.day,
    );
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '$taskName\n\nDepois de concluída, não poderá ser desmarcada nesse dia.',
      initialDay: today,
    );
    if (result == null) return;
    final who = result.people.map((p) => p.fullName).toList();
```

The rest of `_completeTask`'s body (`targetDay` computation, both branches, `_sendMsg(message(who))`, the snackbar) is unchanged — `who` is now a `List<String>` flowing through the same code paths, `message(who)` still just calls the passed-in callback.

Now update every one of the 6 `apply`/`message` call sites in `build()` to take `List<String> who` instead of `String who`, and read the new `*ByNames` field pair via `resolveNames`. For each task below, the `by:` param passed to `_ManualTask`/`_CountTask` also changes to `byNames:` fed by `resolveNames`.

**Kiwi Abertura** — replace:

```dart
            _ManualTask(
              label: 'Kiwi Abertura',
              checked: tasks.kiwiAbertura,
              by: tasks.kiwiAberturaBy,
              backdated: tasks.backdatedTaskKeys.contains('kiwi_abertura'),
              parentUuid: tasks.syncUuid,
              timerKey: 'kiwi_abertura',
              onLongPress: tasks.kiwiAbertura
                  ? () => _sendMsg('✅ Tarefa concluída: Kiwi Abertura')
                  : null,
              onChanged: (v) async {
                if (!v) return;
                await _completeTask(
                  taskName: 'Kiwi Abertura',
                  timerKey: 'kiwi_abertura',
                  apply: (t, who) {
                    t.kiwiAbertura = true;
                    t.kiwiAberturaBy = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Kiwi Abertura (por $who)',
                );
              },
            ),
```

with:

```dart
            _ManualTask(
              label: 'Kiwi Abertura',
              checked: tasks.kiwiAbertura,
              byNames: resolveNames(tasks.kiwiAberturaByNames, tasks.kiwiAberturaBy),
              backdated: tasks.backdatedTaskKeys.contains('kiwi_abertura'),
              parentUuid: tasks.syncUuid,
              timerKey: 'kiwi_abertura',
              onLongPress: tasks.kiwiAbertura
                  ? () => _sendMsg('✅ Tarefa concluída: Kiwi Abertura')
                  : null,
              onChanged: (v) async {
                if (!v) return;
                await _completeTask(
                  taskName: 'Kiwi Abertura',
                  timerKey: 'kiwi_abertura',
                  apply: (t, who) {
                    t.kiwiAbertura = true;
                    t.kiwiAberturaByNames = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Kiwi Abertura (por ${joinNames(who)})',
                );
              },
            ),
```

**Alterações de Preço** — replace:

```dart
            _CountTask(
              label: 'Alterações de Preço',
              checked: tasks.alteracoesPreco,
              by: tasks.alteracoesPrecoBy,
              backdated: tasks.backdatedTaskKeys.contains('alteracoes_preco'),
              parentUuid: tasks.syncUuid,
              timerKey: 'alteracoes_preco',
              countController: _alteracoesCtrl,
              onLongPress: tasks.alteracoesPreco
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Alterações de Preço (${tasks.alteracoesPrecoCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.alteracoesPrecoCount;
                await _completeTask(
                  taskName: 'Alterações de Preço',
                  timerKey: 'alteracoes_preco',
                  apply: (t, who) {
                    t.alteracoesPreco = true;
                    t.alteracoesPrecoBy = who;
                    t.alteracoesPrecoCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Alterações de Preço ($count) (por $who)',
                );
              },
              onCountChanged: (n) {
                tasks.alteracoesPrecoCount = n;
                _saveTasks();
              },
            ),
```

with:

```dart
            _CountTask(
              label: 'Alterações de Preço',
              checked: tasks.alteracoesPreco,
              byNames: resolveNames(tasks.alteracoesPrecoByNames, tasks.alteracoesPrecoBy),
              backdated: tasks.backdatedTaskKeys.contains('alteracoes_preco'),
              parentUuid: tasks.syncUuid,
              timerKey: 'alteracoes_preco',
              countController: _alteracoesCtrl,
              onLongPress: tasks.alteracoesPreco
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Alterações de Preço (${tasks.alteracoesPrecoCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.alteracoesPrecoCount;
                await _completeTask(
                  taskName: 'Alterações de Preço',
                  timerKey: 'alteracoes_preco',
                  apply: (t, who) {
                    t.alteracoesPreco = true;
                    t.alteracoesPrecoByNames = who;
                    t.alteracoesPrecoCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Alterações de Preço ($count) (por ${joinNames(who)})',
                );
              },
              onCountChanged: (n) {
                tasks.alteracoesPrecoCount = n;
                _saveTasks();
              },
            ),
```

**Verificação de Temperaturas** — replace:

```dart
            _ManualTask(
              label: 'Verificação de Temperaturas',
              checked: tasks.verificacaoTemperaturas,
              by: tasks.verificacaoTemperaturasBy,
              backdated: tasks.backdatedTaskKeys.contains(
                'verificacao_temperaturas',
              ),
              parentUuid: tasks.syncUuid,
              timerKey: 'verificacao_temperaturas',
              onLongPress: tasks.verificacaoTemperaturas
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificação de Temperaturas',
                    )
                  : null,
              onChanged: (v) async {
                if (!v) return;
                await _completeTask(
                  taskName: 'Verificação de Temperaturas',
                  timerKey: 'verificacao_temperaturas',
                  apply: (t, who) {
                    t.verificacaoTemperaturas = true;
                    t.verificacaoTemperaturasBy = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificação de Temperaturas (por $who)',
                );
              },
            ),
```

with:

```dart
            _ManualTask(
              label: 'Verificação de Temperaturas',
              checked: tasks.verificacaoTemperaturas,
              byNames: resolveNames(tasks.verificacaoTemperaturasByNames, tasks.verificacaoTemperaturasBy),
              backdated: tasks.backdatedTaskKeys.contains(
                'verificacao_temperaturas',
              ),
              parentUuid: tasks.syncUuid,
              timerKey: 'verificacao_temperaturas',
              onLongPress: tasks.verificacaoTemperaturas
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificação de Temperaturas',
                    )
                  : null,
              onChanged: (v) async {
                if (!v) return;
                await _completeTask(
                  taskName: 'Verificação de Temperaturas',
                  timerKey: 'verificacao_temperaturas',
                  apply: (t, who) {
                    t.verificacaoTemperaturas = true;
                    t.verificacaoTemperaturasByNames = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificação de Temperaturas (por ${joinNames(who)})',
                );
              },
            ),
```

**Preenchimento do Quadro** — replace:

```dart
            _ManualTask(
              label: 'Preenchimento do Quadro',
              checked: tasks.preenchimentoQuadro,
              by: tasks.preenchimentoQuadroBy,
              backdated: tasks.backdatedTaskKeys.contains(
                'preenchimento_quadro',
              ),
              parentUuid: tasks.syncUuid,
              timerKey: 'preenchimento_quadro',
              onLongPress: tasks.preenchimentoQuadro
                  ? () =>
                        _sendMsg('✅ Tarefa concluída: Preenchimento do Quadro')
                  : null,
              onChanged: (v) async {
                if (!v) return;
                await _completeTask(
                  taskName: 'Preenchimento do Quadro',
                  timerKey: 'preenchimento_quadro',
                  apply: (t, who) {
                    t.preenchimentoQuadro = true;
                    t.preenchimentoQuadroBy = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Preenchimento do Quadro (por $who)',
                );
              },
            ),
```

with:

```dart
            _ManualTask(
              label: 'Preenchimento do Quadro',
              checked: tasks.preenchimentoQuadro,
              byNames: resolveNames(tasks.preenchimentoQuadroByNames, tasks.preenchimentoQuadroBy),
              backdated: tasks.backdatedTaskKeys.contains(
                'preenchimento_quadro',
              ),
              parentUuid: tasks.syncUuid,
              timerKey: 'preenchimento_quadro',
              onLongPress: tasks.preenchimentoQuadro
                  ? () =>
                        _sendMsg('✅ Tarefa concluída: Preenchimento do Quadro')
                  : null,
              onChanged: (v) async {
                if (!v) return;
                await _completeTask(
                  taskName: 'Preenchimento do Quadro',
                  timerKey: 'preenchimento_quadro',
                  apply: (t, who) {
                    t.preenchimentoQuadro = true;
                    t.preenchimentoQuadroByNames = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Preenchimento do Quadro (por ${joinNames(who)})',
                );
              },
            ),
```

**Verificação de Validades** — replace:

```dart
            _CountTask(
              label: 'Verificação de Validades',
              checked: tasks.verificacaoValidades,
              by: tasks.verificacaoValidadesBy,
              backdated: tasks.backdatedTaskKeys.contains(
                'verificacao_validades',
              ),
              parentUuid: tasks.syncUuid,
              timerKey: 'verificacao_validades',
              countController: _validadesCtrl,
              onLongPress: tasks.verificacaoValidades
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificação de Validades (${tasks.verificacaoValidadesCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.verificacaoValidadesCount;
                await _completeTask(
                  taskName: 'Verificação de Validades',
                  timerKey: 'verificacao_validades',
                  apply: (t, who) {
                    t.verificacaoValidades = true;
                    t.verificacaoValidadesBy = who;
                    t.verificacaoValidadesCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificação de Validades ($count) (por $who)',
                );
              },
              onCountChanged: (n) {
                tasks.verificacaoValidadesCount = n;
                _saveTasks();
              },
            ),
```

with:

```dart
            _CountTask(
              label: 'Verificação de Validades',
              checked: tasks.verificacaoValidades,
              byNames: resolveNames(tasks.verificacaoValidadesByNames, tasks.verificacaoValidadesBy),
              backdated: tasks.backdatedTaskKeys.contains(
                'verificacao_validades',
              ),
              parentUuid: tasks.syncUuid,
              timerKey: 'verificacao_validades',
              countController: _validadesCtrl,
              onLongPress: tasks.verificacaoValidades
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificação de Validades (${tasks.verificacaoValidadesCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.verificacaoValidadesCount;
                await _completeTask(
                  taskName: 'Verificação de Validades',
                  timerKey: 'verificacao_validades',
                  apply: (t, who) {
                    t.verificacaoValidades = true;
                    t.verificacaoValidadesByNames = who;
                    t.verificacaoValidadesCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificação de Validades ($count) (por ${joinNames(who)})',
                );
              },
              onCountChanged: (n) {
                tasks.verificacaoValidadesCount = n;
                _saveTasks();
              },
            ),
```

**Kiwi Fecho** — replace:

```dart
            _ManualTask(
              label: 'Kiwi Fecho',
              checked: tasks.kiwiFecho,
              by: tasks.kiwiFechoBy,
              backdated: tasks.backdatedTaskKeys.contains('kiwi_fecho'),
              parentUuid: tasks.syncUuid,
              timerKey: 'kiwi_fecho',
              onLongPress: tasks.kiwiFecho
                  ? () => _sendMsg('✅ Tarefa concluída: Kiwi Fecho')
                  : null,
              onChanged: (v) async {
                if (!v) return;
                await _completeTask(
                  taskName: 'Kiwi Fecho',
                  timerKey: 'kiwi_fecho',
                  apply: (t, who) {
                    t.kiwiFecho = true;
                    t.kiwiFechoBy = who;
                  },
                  message: (who) => '✅ Tarefa concluída: Kiwi Fecho (por $who)',
                );
              },
            ),
```

with:

```dart
            _ManualTask(
              label: 'Kiwi Fecho',
              checked: tasks.kiwiFecho,
              byNames: resolveNames(tasks.kiwiFechoByNames, tasks.kiwiFechoBy),
              backdated: tasks.backdatedTaskKeys.contains('kiwi_fecho'),
              parentUuid: tasks.syncUuid,
              timerKey: 'kiwi_fecho',
              onLongPress: tasks.kiwiFecho
                  ? () => _sendMsg('✅ Tarefa concluída: Kiwi Fecho')
                  : null,
              onChanged: (v) async {
                if (!v) return;
                await _completeTask(
                  taskName: 'Kiwi Fecho',
                  timerKey: 'kiwi_fecho',
                  apply: (t, who) {
                    t.kiwiFecho = true;
                    t.kiwiFechoByNames = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Kiwi Fecho (por ${joinNames(who)})',
                );
              },
            ),
```

Delete the local `_InitialsBadge` class entirely (it's redundant with the shared `PersonInitialsRow` from Task 1):

```dart
class _InitialsBadge extends StatelessWidget {
  const _InitialsBadge({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: initials,
      child: PersonInitialsBadge(name: initials, size: 30),
    );
  }
}

```

(Delete this whole block, including the trailing blank line, right before `class _BackdatedNote`.)

In `_ManualTask`, replace the field declaration and constructor param:

```dart
  const _ManualTask({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.onLongPress,
    this.by,
    this.backdated = false,
    this.parentUuid,
    this.timerKey,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLongPress;
  final String? by;
  final bool backdated;
  final String? parentUuid;
  final String? timerKey;
```

with:

```dart
  const _ManualTask({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.parentUuid,
    this.timerKey,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;
  final String? parentUuid;
  final String? timerKey;
```

And its `secondary:` usage:

```dart
              secondary: (checked && (by ?? '').isNotEmpty)
                  ? _InitialsBadge(initials: by!)
                  : null,
```

becomes:

```dart
              secondary: (checked && byNames.isNotEmpty)
                  ? PersonInitialsRow(names: byNames, size: 30)
                  : null,
```

In `_CountTask`, the same field-declaration change (`by`/`String? by` → `byNames`/`List<String> byNames = const []`):

```dart
  const _CountTask({
    required this.label,
    required this.checked,
    required this.countController,
    required this.onCheckedChanged,
    required this.onCountChanged,
    this.onLongPress,
    this.by,
    this.backdated = false,
    this.parentUuid,
    this.timerKey,
  });

  final String label;
  final bool checked;
  final TextEditingController countController;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;
  final String? by;
  final bool backdated;
  final String? parentUuid;
  final String? timerKey;
```

with:

```dart
  const _CountTask({
    required this.label,
    required this.checked,
    required this.countController,
    required this.onCheckedChanged,
    required this.onCountChanged,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.parentUuid,
    this.timerKey,
  });

  final String label;
  final bool checked;
  final TextEditingController countController;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;
  final String? parentUuid;
  final String? timerKey;
```

And its inline row usage:

```dart
                  if (checked && (by ?? '').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _InitialsBadge(initials: by!),
                  ],
```

becomes:

```dart
                  if (checked && byNames.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    PersonInitialsRow(names: byNames, size: 30),
                  ],
```

- [ ] **Step 2: Update `lib/screens/weekly_tasks_screen.dart`**

Same shape. Replace the `_completeTask` helper's signature and body opening:

```dart
  Future<void> _completeTask({
    required String taskName,
    required String timerKey,
    required void Function(WeeklyTasks target, String who) apply,
    required String Function(String who) message,
    DateTime? initialDay,
    bool Function(DateTime)? selectableDayPredicate,
  }) async {
    final tasks = _tasks;
    if (tasks == null) return;
    final today = currentServiceDay();
    final result = await pickPersonAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '$taskName\n\nDepois de concluída, não poderá ser desmarcada nessa semana.',
      initialDay: initialDay ?? DateTime(today.year, today.month, today.day),
      selectableDayPredicate: selectableDayPredicate,
    );
    if (result == null) return;
    final who = result.person.fullName;
```

with:

```dart
  Future<void> _completeTask({
    required String taskName,
    required String timerKey,
    required void Function(WeeklyTasks target, List<String> who) apply,
    required String Function(List<String> who) message,
    DateTime? initialDay,
    bool Function(DateTime)? selectableDayPredicate,
  }) async {
    final tasks = _tasks;
    if (tasks == null) return;
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '$taskName\n\nDepois de concluída, não poderá ser desmarcada nessa semana.',
      initialDay: initialDay ?? DateTime(today.year, today.month, today.day),
      selectableDayPredicate: selectableDayPredicate,
    );
    if (result == null) return;
    final who = result.people.map((p) => p.fullName).toList();
```

(Rest of the body — `targetWeek`, both branches, `_sendMsg`, snackbar — unchanged.)

**Verificar 1ª** — replace:

```dart
            _WeeklyCountTask(
              label: 'Verificar 1ª',
              checked: tasks.verificar1a,
              by: tasks.verificar1aBy,
              backdated: tasks.backdatedTaskKeys.contains('verificar_1a'),
              parentUuid: tasks.syncUuid,
              timerKey: 'verificar_1a',
              countController: _verificar1aCtrl,
              goalNote: 'Itens no Mural — mínimo 10, recomendado 20',
              late: mondayPassed && !tasks.verificar1a,
              onLongPress: tasks.verificar1a
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificar 1ª (${tasks.verificar1aCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.verificar1aCount;
                await _completeTask(
                  taskName: 'Verificar 1ª',
                  timerKey: 'verificar_1a',
                  apply: (t, who) {
                    t.verificar1a = true;
                    t.verificar1aBy = who;
                    t.verificar1aCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificar 1ª ($count) (por $who)',
                );
              },
              onCountChanged: (n) {
                tasks.verificar1aCount = n;
                _saveTasks();
              },
            ),
```

with:

```dart
            _WeeklyCountTask(
              label: 'Verificar 1ª',
              checked: tasks.verificar1a,
              byNames: resolveNames(tasks.verificar1aByNames, tasks.verificar1aBy),
              backdated: tasks.backdatedTaskKeys.contains('verificar_1a'),
              parentUuid: tasks.syncUuid,
              timerKey: 'verificar_1a',
              countController: _verificar1aCtrl,
              goalNote: 'Itens no Mural — mínimo 10, recomendado 20',
              late: mondayPassed && !tasks.verificar1a,
              onLongPress: tasks.verificar1a
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificar 1ª (${tasks.verificar1aCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.verificar1aCount;
                await _completeTask(
                  taskName: 'Verificar 1ª',
                  timerKey: 'verificar_1a',
                  apply: (t, who) {
                    t.verificar1a = true;
                    t.verificar1aByNames = who;
                    t.verificar1aCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificar 1ª ($count) (por ${joinNames(who)})',
                );
              },
              onCountChanged: (n) {
                tasks.verificar1aCount = n;
                _saveTasks();
              },
            ),
```

**Verificar 4ª** — replace:

```dart
            _WeeklyCountTask(
              label: 'Verificar 4ª',
              checked: tasks.verificar4a,
              by: tasks.verificar4aBy,
              backdated: tasks.backdatedTaskKeys.contains('verificar_4a'),
              parentUuid: tasks.syncUuid,
              timerKey: 'verificar_4a',
              countController: _verificar4aCtrl,
              goalNote: 'Itens por colocar preço',
              late: mondayPassed && !tasks.verificar4a,
              onLongPress: tasks.verificar4a
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificar 4ª (${tasks.verificar4aCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.verificar4aCount;
                await _completeTask(
                  taskName: 'Verificar 4ª',
                  timerKey: 'verificar_4a',
                  apply: (t, who) {
                    t.verificar4a = true;
                    t.verificar4aBy = who;
                    t.verificar4aCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificar 4ª ($count) (por $who)',
                );
              },
              onCountChanged: (n) {
                tasks.verificar4aCount = n;
                _saveTasks();
              },
            ),
```

with:

```dart
            _WeeklyCountTask(
              label: 'Verificar 4ª',
              checked: tasks.verificar4a,
              byNames: resolveNames(tasks.verificar4aByNames, tasks.verificar4aBy),
              backdated: tasks.backdatedTaskKeys.contains('verificar_4a'),
              parentUuid: tasks.syncUuid,
              timerKey: 'verificar_4a',
              countController: _verificar4aCtrl,
              goalNote: 'Itens por colocar preço',
              late: mondayPassed && !tasks.verificar4a,
              onLongPress: tasks.verificar4a
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Verificar 4ª (${tasks.verificar4aCount})',
                    )
                  : null,
              onCheckedChanged: (v) async {
                if (!v) return;
                final count = tasks.verificar4aCount;
                await _completeTask(
                  taskName: 'Verificar 4ª',
                  timerKey: 'verificar_4a',
                  apply: (t, who) {
                    t.verificar4a = true;
                    t.verificar4aByNames = who;
                    t.verificar4aCount = count;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Verificar 4ª ($count) (por ${joinNames(who)})',
                );
              },
              onCountChanged: (n) {
                tasks.verificar4aCount = n;
                _saveTasks();
              },
            ),
```

**Limpeza da Máquina Voltas** — replace:

```dart
            _WeeklyManualTask(
              label: 'Limpeza da Máquina Voltas',
              checked: tasks.limpezaMaquinaVoltas,
              by: tasks.limpezaMaquinaVoltasBy,
              backdated: tasks.backdatedTaskKeys.contains(
                'limpeza_maquina_voltas',
              ),
              parentUuid: tasks.syncUuid,
              timerKey: 'limpeza_maquina_voltas',
              enabled: isSaturday,
              note: isSaturday ? null : 'Apenas ao sábado',
              onLongPress: tasks.limpezaMaquinaVoltas
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Limpeza da Máquina Voltas',
                    )
                  : null,
              onChanged: (v) async {
                if (!v) return;
                final lastSaturday = _lastSaturdayOnOrBefore(
                  currentServiceDay(),
                );
                await _completeTask(
                  taskName: 'Limpeza da Máquina Voltas',
                  timerKey: 'limpeza_maquina_voltas',
                  initialDay: lastSaturday,
                  selectableDayPredicate: (d) => d.weekday == DateTime.saturday,
                  apply: (t, who) {
                    t.limpezaMaquinaVoltas = true;
                    t.limpezaMaquinaVoltasBy = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Limpeza da Máquina Voltas (por $who)',
                );
              },
            ),
```

with:

```dart
            _WeeklyManualTask(
              label: 'Limpeza da Máquina Voltas',
              checked: tasks.limpezaMaquinaVoltas,
              byNames: resolveNames(tasks.limpezaMaquinaVoltasByNames, tasks.limpezaMaquinaVoltasBy),
              backdated: tasks.backdatedTaskKeys.contains(
                'limpeza_maquina_voltas',
              ),
              parentUuid: tasks.syncUuid,
              timerKey: 'limpeza_maquina_voltas',
              enabled: isSaturday,
              note: isSaturday ? null : 'Apenas ao sábado',
              onLongPress: tasks.limpezaMaquinaVoltas
                  ? () => _sendMsg(
                      '✅ Tarefa concluída: Limpeza da Máquina Voltas',
                    )
                  : null,
              onChanged: (v) async {
                if (!v) return;
                final lastSaturday = _lastSaturdayOnOrBefore(
                  currentServiceDay(),
                );
                await _completeTask(
                  taskName: 'Limpeza da Máquina Voltas',
                  timerKey: 'limpeza_maquina_voltas',
                  initialDay: lastSaturday,
                  selectableDayPredicate: (d) => d.weekday == DateTime.saturday,
                  apply: (t, who) {
                    t.limpezaMaquinaVoltas = true;
                    t.limpezaMaquinaVoltasByNames = who;
                  },
                  message: (who) =>
                      '✅ Tarefa concluída: Limpeza da Máquina Voltas (por ${joinNames(who)})',
                );
              },
            ),
```

Delete the local `_InitialsBadge` class (identical duplicate of the one in `daily_tasks_screen.dart`):

```dart
class _InitialsBadge extends StatelessWidget {
  const _InitialsBadge({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: initials,
      child: PersonInitialsBadge(name: initials, size: 30),
    );
  }
}

```

(Delete this whole block, including the trailing blank line, right before `class _BackdatedNote`.)

In `_WeeklyManualTask`, replace:

```dart
  const _WeeklyManualTask({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.onLongPress,
    this.by,
    this.backdated = false,
    this.parentUuid,
    this.timerKey,
    this.enabled = true,
    this.note,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLongPress;
  final String? by;
  final bool backdated;
  final String? parentUuid;
  final String? timerKey;
  final bool enabled;
  final String? note;
```

with:

```dart
  const _WeeklyManualTask({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.parentUuid,
    this.timerKey,
    this.enabled = true,
    this.note,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;
  final String? parentUuid;
  final String? timerKey;
  final bool enabled;
  final String? note;
```

and its `secondary:`:

```dart
              secondary: (checked && (by ?? '').isNotEmpty)
                  ? _InitialsBadge(initials: by!)
                  : null,
```

becomes:

```dart
              secondary: (checked && byNames.isNotEmpty)
                  ? PersonInitialsRow(names: byNames, size: 30)
                  : null,
```

In `_WeeklyCountTask`, replace:

```dart
  const _WeeklyCountTask({
    required this.label,
    required this.checked,
    required this.countController,
    required this.onCheckedChanged,
    required this.onCountChanged,
    this.onLongPress,
    this.by,
    this.backdated = false,
    this.parentUuid,
    this.timerKey,
    this.goalNote,
    this.late = false,
  });

  final String label;
  final bool checked;
  final TextEditingController countController;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;
  final String? by;
  final bool backdated;
  final String? parentUuid;
  final String? timerKey;
  final String? goalNote;
  final bool late;
```

with:

```dart
  const _WeeklyCountTask({
    required this.label,
    required this.checked,
    required this.countController,
    required this.onCheckedChanged,
    required this.onCountChanged,
    this.onLongPress,
    this.byNames = const [],
    this.backdated = false,
    this.parentUuid,
    this.timerKey,
    this.goalNote,
    this.late = false,
  });

  final String label;
  final bool checked;
  final TextEditingController countController;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onLongPress;
  final List<String> byNames;
  final bool backdated;
  final String? parentUuid;
  final String? timerKey;
  final String? goalNote;
  final bool late;
```

and its inline row usage:

```dart
                  if (checked && (by ?? '').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _InitialsBadge(initials: by!),
                  ],
```

becomes:

```dart
                  if (checked && byNames.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    PersonInitialsRow(names: byNames, size: 30),
                  ],
```

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: no new issues beyond the 3 pre-existing baseline `info` lints (`historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:330`).

- [ ] **Step 4: Manual check**

In "Tarefas Diárias", tap the checkbox on "Kiwi Abertura", pick 2 people in the dialog, tap "Confirmar" — the task should complete once, show both people's initials badges side by side, and the WhatsApp confirmation prompt should read "... (por A e B)". In "Tarefas Semanais", do the same for "Verificar 1ª" with a count value entered first.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/daily_tasks_screen.dart lib/screens/weekly_tasks_screen.dart
git commit -m "feat: allow multiple people to claim daily/weekly tasks"
```

---

### Task 4: Custom Tasks — multi-select completion

**Files:**
- Modify: `lib/services/custom_task_service.dart`
- Modify: `lib/screens/custom_tasks_screen.dart`

**Interfaces:**
- Consumes: `pickPeopleAndDay`, `PeopleAndDay`, `joinNames`, `PersonInitialsRow`, `resolveNames` from `lib/screens/widgets/person_picker.dart` (Task 1); `doneByNames` from `lib/models/custom_task.dart` (Task 2).
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Update `custom_task_service.dart`**

In `lib/services/custom_task_service.dart`, change `complete` (currently lines 59-79) from taking a single `who` to a list, and write it to `doneByNames`:

```dart
  /// Marks the entry for `(taskUuid, periodKey)` as done by [who]. Finds the
  /// existing entry for that period, or creates one if this is the first
  /// completion.
  Future<void> complete({
    required String taskUuid,
    required DateTime periodKey,
    required List<String> who,
    int? count,
    bool backdated = false,
  }) async {
    var entry = await entryFor(taskUuid, periodKey);
    entry ??= CustomTaskEntry()
      ..taskUuid = taskUuid
      ..periodKey = periodKey;
    entry.done = true;
    entry.doneByNames = who;
    entry.doneAt = DateTime.now();
    entry.count = count;
    entry.backdated = backdated;
    SyncMeta.stamp(entry);
    final toSave = entry;
    await _isar.writeTxn(() => _isar.customTaskEntrys.put(toSave));
    notifyListeners();
  }
```

(Only the `who` parameter type and the `entry.doneByNames = who` line change — everything else in the method body is unchanged.)

- [ ] **Step 2: Update `custom_tasks_screen.dart`**

No new import needed — `pickPersonAndDay`/`PersonInitialsBadge` already come from `widgets/person_picker.dart`, which this file already imports; `pickPeopleAndDay`/`joinNames`/`resolveNames`/`PersonInitialsRow` come from the same import.

Replace `_complete` (currently lines 79-133):

```dart
  Future<void> _complete(_TaskRow row, {int? count}) async {
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '${row.task.title}\n\nDepois de concluída, não poderá ser desmarcada neste período.',
      initialDay: DateTime(today.year, today.month, today.day),
    );
    if (result == null) return;
    final names = result.people.map((p) => p.fullName).toList();
    final who = joinNames(names);
    final currentPeriodKey = _periodKeyFor(row.task.frequency);

    late final DateTime targetPeriodKey;
    late final bool backdated;
    switch (row.task.frequency) {
      case CustomTaskFrequency.daily:
        targetPeriodKey = DateTime(
          result.day.year,
          result.day.month,
          result.day.day,
          5,
        );
        backdated = targetPeriodKey != currentPeriodKey;
      case CustomTaskFrequency.weekly:
        targetPeriodKey = currentServiceWeek(
          DateTime(result.day.year, result.day.month, result.day.day, 12),
        );
        backdated = targetPeriodKey != currentPeriodKey;
      case CustomTaskFrequency.oneOff:
        targetPeriodKey = oneOffPeriodKey;
        backdated = false;
    }

    await CustomTaskService.instance.complete(
      taskUuid: row.task.syncUuid,
      periodKey: targetPeriodKey,
      who: names,
      count: count,
      backdated: backdated,
    );
    final countSuffix = count == null ? '' : ' ($count)';
    final baseMsg =
        '✅ Tarefa concluída: ${row.task.title}$countSuffix (por $who)';
    if (!backdated) {
      _sendMsg(baseMsg);
      return;
    }
    final dayFmt = DateFormat("d 'de' MMMM", 'pt_PT').format(result.day);
    _sendMsg('$baseMsg — $dayFmt');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa marcada como concluída em $dayFmt.')),
    );
  }
```

Replace `_tileFor` (currently lines 238-265) — it currently computes a single `by`/`byStr`; switch it to a resolved name list and `joinNames`:

```dart
  Widget _tileFor(_TaskRow row) {
    final names = resolveNames(
      row.entry?.doneByNames ?? const [],
      row.entry?.doneBy,
    );
    final byStr = names.isEmpty ? '' : ' (por ${joinNames(names)})';
    if (row.task.inputType == CustomTaskInputType.count) {
      final count = row.entry?.count;
      final countStr = count == null ? '' : ' ($count)';
      return _CustomCountTile(
        key: ValueKey(row.task.syncUuid),
        row: row,
        onComplete: (count) => _complete(row, count: count),
        onDelete: () => _confirmDelete(row.task),
        onSendWhatsApp: row.done
            ? () => _sendMsg(
                '✅ Tarefa concluída: ${row.task.title}$countStr$byStr',
              )
            : null,
      );
    }
    return _CustomManualTile(
      key: ValueKey(row.task.syncUuid),
      row: row,
      onComplete: () => _complete(row),
      onDelete: () => _confirmDelete(row.task),
      onSendWhatsApp: row.done
          ? () => _sendMsg('✅ Tarefa concluída: ${row.task.title}$byStr')
          : null,
    );
  }
```

In `_CustomManualTile.build` (currently lines 304-350), replace the `by` computation and the single-badge usage:

```dart
  @override
  Widget build(BuildContext context) {
    final done = row.done;
    final names = resolveNames(
      row.entry?.doneByNames ?? const [],
      row.entry?.doneBy,
    );
    return GestureDetector(
      onLongPress: onSendWhatsApp,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: done,
          onChanged: (v) {
            if (done) return;
            if (v == true) onComplete();
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.green,
          title: Text(
            row.task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: (done && row.entry!.backdated)
              ? const _BackdatedNote()
              : null,
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (done && names.isNotEmpty) ...[
                PersonInitialsRow(names: names),
                const SizedBox(width: 4),
              ],
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                tooltip: 'Remover tarefa',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
```

In `_CustomCountTileState.build` (currently lines 389-463), replace the `by` computation and the single-badge usage:

```dart
  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final done = row.done;
    final names = resolveNames(
      row.entry?.doneByNames ?? const [],
      row.entry?.doneBy,
    );
    return GestureDetector(
      onLongPress: widget.onSendWhatsApp,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: done,
          onChanged: (v) {
            if (done) return;
            if (v != true) return;
            final count = int.tryParse(_countCtrl.text) ?? 0;
            widget.onComplete(count);
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  row.task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (done && names.isNotEmpty) ...[
                const SizedBox(width: 8),
                PersonInitialsRow(names: names),
              ],
            ],
          ),
          subtitle: (done && row.entry!.backdated)
              ? const _BackdatedNote()
              : null,
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _countCtrl,
                  enabled: !done,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                tooltip: 'Remover tarefa',
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: no new issues beyond the 3 pre-existing baseline `info` lints (`historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:330`).

- [ ] **Step 4: Manual check**

Run the app (`flutter run`), open "Tarefas Personalizadas". Create a daily simple task and a daily count task if none exist. Tap the checkbox on the simple task: the "Quem concluiu?" dialog should show checkboxes, not tap-to-pick; select two people, tap "Confirmar" — the tile should show two initials badges and lock. Long-press the completed tile: the WhatsApp confirm text should read "(por A e B)". Repeat for the count task, selecting just one person this time, and confirm the completion flow still works with a single selection (the "por A" case, no "e").

- [ ] **Step 5: Commit**

```bash
git add lib/services/custom_task_service.dart lib/screens/custom_tasks_screen.dart
git commit -m "feat: allow multiple people to claim custom tasks"
```

---

### Task 5: Opening & Report list finalization — multi-select

**Files:**
- Modify: `lib/screens/tabs/abertura_tab.dart`
- Modify: `lib/screens/tabs/relatorio_tab.dart`

**Interfaces:**
- Consumes: `pickPeopleAndDay`, `PeopleAndDay`, `joinNames` from `lib/screens/widgets/person_picker.dart` (Task 1); `createdByNames` from `lib/models/opening_list.dart` / `lib/models/report_list.dart` (Task 2).
- Produces: nothing consumed by later tasks.

Note on scope: both files' backdated-finalize branch (the `else` branch calling `backfillFinalized(...)`) already does NOT record who finalized it — `backfillFinalized` has no "who" parameter today and this task does not add one (that's a documented pre-existing gap, out of scope per the spec). Only the same-day branch (`if (targetDay == list.serviceDay)`), which sets `list.createdByInitials` directly, is touched.

- [ ] **Step 1: Update `abertura_tab.dart`**

In `lib/screens/tabs/abertura_tab.dart`, replace `_finalize` (currently lines 73-142):

```dart
  Future<void> _finalize() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    final today = DateTime(
      list.serviceDay.year,
      list.serviceDay.month,
      list.serviceDay.day,
    );
    final result = await pickPeopleAndDay(
      context,
      title: 'Finalizar por quem?',
      subtitle: 'A lista ficará bloqueada. Será criada uma nova às 5h.',
      initialDay: today,
    );
    if (result == null) return;
    final names = result.people.map((p) => p.fullName).toList();
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    final c = list.congelados;
    final o = list.opls;
    final n = list.naoPereciveis;

    await TaskTimerService.instance.finishOrCreateFinished(
      parentKind: TimerKind.opening,
      parentUuid: list.syncUuid,
      taskKey: 'main',
    );

    if (targetDay == list.serviceDay) {
      list.createdByNames = names;
      await _persistField();
      await OpeningListService.instance.finalize(list);
      await TaskNotificationService.instance.rescheduleAll();
    } else {
      await OpeningListService.instance.backfillFinalized(
        serviceDay: targetDay,
        congelados: c,
        opls: o,
        naoPereciveis: n,
      );
      await OpeningListService.instance.updateValues(
        list,
        congelados: 0,
        opls: 0,
        naoPereciveis: 0,
      );
      _congelados.clear();
      _opls.clear();
      _naoPereciveis.clear();
    }

    if (mounted) {
      final dayNote = targetDay == list.serviceDay
          ? ''
          : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay)})';
      final msg =
          '📋 Lista de Abertura$dayNote\n'
          'Congelados: $c\n'
          'OPLS: $o\n'
          'Não Perecíveis: $n\n'
          'Total: ${c + o + n}\n'
          'Por: ${joinNames(names)}';
      await WhatsAppService.sendWithConfirm(context, msg);
    }
    if (mounted) _load();
  }
```

- [ ] **Step 2: Update `relatorio_tab.dart`**

In `lib/screens/tabs/relatorio_tab.dart`, replace `_finalize` (currently lines 77-151):

```dart
  Future<void> _finalize() async {
    final list = _list;
    if (list == null || list.isFinalized) return;
    final today = DateTime(
      list.serviceDay.year,
      list.serviceDay.month,
      list.serviceDay.day,
    );
    final result = await pickPeopleAndDay(
      context,
      title: 'Finalizar por quem?',
      subtitle: 'O relatório ficará bloqueado. Será criado um novo às 5h.',
      initialDay: today,
    );
    if (result == null) return;
    final names = result.people.map((p) => p.fullName).toList();
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    final dsv = list.diasSemVendas;
    final reg = list.regularizacoes;
    final mas = list.massiva;
    final rep = list.repetidos;

    await TaskTimerService.instance.finishOrCreateFinished(
      parentKind: TimerKind.report,
      parentUuid: list.syncUuid,
      taskKey: 'main',
    );

    if (targetDay == list.serviceDay) {
      list.createdByNames = names;
      await _persistField();
      await ReportListService.instance.finalize(list);
      await TaskNotificationService.instance.rescheduleAll();
    } else {
      await ReportListService.instance.backfillFinalized(
        serviceDay: targetDay,
        diasSemVendas: dsv,
        regularizacoes: reg,
        massiva: mas,
        repetidos: rep,
      );
      await ReportListService.instance.updateValues(
        list,
        diasSemVendas: 0,
        regularizacoes: 0,
        massiva: 0,
        repetidos: 0,
      );
      _diasSemVendas.clear();
      _regularizacoes.clear();
      _massiva.clear();
      _repetidos.clear();
    }

    if (mounted) {
      final dayNote = targetDay == list.serviceDay
          ? ''
          : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay)})';
      final msg =
          '📊 Relatório$dayNote\n'
          'Dias s/ vendas: $dsv\n'
          'Regularizações: $reg\n'
          'Massiva: $mas\n'
          'Repetidos: $rep\n'
          'Total: ${dsv + reg + mas + rep}\n'
          'Por: ${joinNames(names)}';
      await WhatsAppService.sendWithConfirm(context, msg);
    }
    if (mounted) _load();
  }
```

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: no new issues beyond the 3 pre-existing baseline `info` lints (`historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:330`).

- [ ] **Step 4: Manual check**

Run the app, go to the "Abertura" tab, enter some numbers, tap "Finalizar". The "Finalizar por quem?" dialog should offer checkboxes; select two people and confirm on today's date — the list should lock and the WhatsApp message should end with "Por: A e B". Repeat on the "Relatório" tab with a single person selected — confirm it still finalizes and the message ends with "Por: A" (no "e").

- [ ] **Step 5: Commit**

```bash
git add lib/screens/tabs/abertura_tab.dart lib/screens/tabs/relatorio_tab.dart
git commit -m "feat: allow multiple people to claim opening/report list finalization"
```

---

### Task 6: Visual & Auto list finalization — multi-select

**Files:**
- Modify: `lib/services/visual_list_service.dart`
- Modify: `lib/services/auto_list_service.dart`
- Modify: `lib/screens/tabs/visual_tab.dart`
- Modify: `lib/screens/tabs/automaticas_tab.dart`

**Interfaces:**
- Consumes: `pickPeopleAndDay`, `PeopleAndDay`, `joinNames` from `lib/screens/widgets/person_picker.dart` (Task 1); `createdByNames` field on `VisualList`/`AutoList` from `lib/models/visual_list.dart` / `lib/models/auto_list.dart` (Task 2).
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Update `visual_list_service.dart`'s `add` and `addForDay`**

In `lib/services/visual_list_service.dart`, change both methods' `by` parameter from `String?` to `List<String>?`, and set the new field instead of the legacy one:

```dart
  Future<void> add({
    String? syncUuid,
    required int itensPicados,
    required int quebraCents,
    required int beneficioCents,
    List<String>? by,
  }) async {
    final now = DateTime.now();
    final entry = VisualList()
      ..createdAt = now
      ..serviceDay = currentServiceDay(now)
      ..itensPicados = itensPicados
      ..quebraCents = quebraCents
      ..beneficioCents = beneficioCents
      ..createdByNames = by ?? [];
    if (syncUuid != null) entry.syncUuid = syncUuid;
    SyncMeta.stamp(entry);
    await _isar.writeTxn(() async {
      await _isar.visualLists.put(entry);
    });
    notifyListeners();
  }

  Future<void> addForDay({
    required DateTime serviceDay,
    required int itensPicados,
    required int quebraCents,
    required int beneficioCents,
    List<String>? by,
  }) async {
    final entry = VisualList()
      ..createdAt = DateTime(
        serviceDay.year,
        serviceDay.month,
        serviceDay.day,
        12,
      )
      ..serviceDay = serviceDay
      ..itensPicados = itensPicados
      ..quebraCents = quebraCents
      ..beneficioCents = beneficioCents
      ..createdByNames = by ?? []
      ..backdated = true;
    SyncMeta.stamp(entry);
    await _isar.writeTxn(() => _isar.visualLists.put(entry));
    notifyListeners();
  }
```

Nothing else in the file changes.

- [ ] **Step 2: Update `auto_list_service.dart`'s `add` and `addForDay`**

In `lib/services/auto_list_service.dart`, same treatment:

```dart
  Future<void> add({
    String? syncUuid,
    required int congelados,
    required int opls,
    required int naoPereciveis,
    List<String>? by,
  }) async {
    final entry = AutoList()
      ..createdAt = DateTime.now()
      ..congelados = congelados
      ..opls = opls
      ..naoPereciveis = naoPereciveis
      ..createdByNames = by ?? [];
    if (syncUuid != null) entry.syncUuid = syncUuid;
    SyncMeta.stamp(entry);
    await _isar.writeTxn(() async {
      await _isar.autoLists.put(entry);
    });
    notifyListeners();
  }

  Future<void> addForDay({
    required DateTime serviceDay,
    required int congelados,
    required int opls,
    required int naoPereciveis,
    List<String>? by,
  }) async {
    final entry = AutoList()
      ..createdAt = DateTime(
        serviceDay.year,
        serviceDay.month,
        serviceDay.day,
        12,
      )
      ..congelados = congelados
      ..opls = opls
      ..naoPereciveis = naoPereciveis
      ..createdByNames = by ?? []
      ..backdated = true;
    SyncMeta.stamp(entry);
    await _isar.writeTxn(() => _isar.autoLists.put(entry));
    notifyListeners();
  }
```

Nothing else in the file changes.

- [ ] **Step 3: Update `visual_tab.dart`'s `_finalize()`**

In `lib/screens/tabs/visual_tab.dart`, replace the `_finalize` body from the `pickPersonAndDay` call through the `add`/`addForDay` calls and the WhatsApp message. No new import needed — `../widgets/person_picker.dart` is already imported.

```dart
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem fez esta lista?',
      initialDay: DateTime(today.year, today.month, today.day),
    );
    if (result == null || !mounted) return;
    final names = result.people.map((p) => p.fullName).toList();
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    await TaskTimerService.instance.finishOrCreateFinished(
      parentKind: TimerKind.visual,
      parentUuid: _draftUuid,
      taskKey: 'main',
    );
    if (targetDay == today) {
      await VisualListService.instance.add(
        syncUuid: _draftUuid,
        itensPicados: i,
        quebraCents: q,
        beneficioCents: b,
        by: names,
      );
      await TaskNotificationService.instance.rescheduleAll();
      await TaskNotificationService.instance.checkVisualGoal(_todayItens + i);
    } else {
      await VisualListService.instance.addForDay(
        serviceDay: targetDay,
        itensPicados: i,
        quebraCents: q,
        beneficioCents: b,
        by: names,
      );
    }
    if (!mounted) return;

    final total = b - q;
    final dayNote = targetDay == today
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay)})';
    final msg =
        '👁 Lista Visual$dayNote\n'
        'Itens Picados: $i\n'
        'Quebra: -${formatCents(q)} €\n'
        'Benefício: ${formatCents(b)} €\n'
        'Total: ${formatCents(total)} €\n'
        'Por: ${joinNames(names)}';
    await WhatsAppService.sendWithConfirm(context, msg);
```

- [ ] **Step 4: Update `automaticas_tab.dart`'s `_finalize()`**

In `lib/screens/tabs/automaticas_tab.dart`, same shape. No new import needed here either.

```dart
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem fez esta lista?',
      initialDay: DateTime(today.year, today.month, today.day),
    );
    if (result == null || !mounted) return;
    final names = result.people.map((p) => p.fullName).toList();
    final targetDay = DateTime(
      result.day.year,
      result.day.month,
      result.day.day,
      5,
    );
    await TaskTimerService.instance.finishOrCreateFinished(
      parentKind: TimerKind.auto,
      parentUuid: _draftUuid,
      taskKey: 'main',
    );
    if (targetDay == today) {
      await AutoListService.instance.add(
        syncUuid: _draftUuid,
        congelados: c,
        opls: o,
        naoPereciveis: n,
        by: names,
      );
      await TaskNotificationService.instance.rescheduleAll();
    } else {
      await AutoListService.instance.addForDay(
        serviceDay: targetDay,
        congelados: c,
        opls: o,
        naoPereciveis: n,
        by: names,
      );
    }
    if (!mounted) return;

    final total = c + o + n;
    final dayNote = targetDay == today
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(targetDay)})';
    final msg =
        '📦 Lista Automática$dayNote\n'
        'Congelados: $c\n'
        'OPLS: $o\n'
        'Não Perecíveis: $n\n'
        'Total: $total\n'
        'Por: ${joinNames(names)}';
    await WhatsAppService.sendWithConfirm(context, msg);
```

- [ ] **Step 5: Verify**

Run: `flutter analyze`
Expected: no new issues beyond the 3 pre-existing baseline `info` lints (`historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:330`).

- [ ] **Step 6: Manual check**

Run the app, open the "Visual" tab, fill in Itens Picados/Quebra/Benefício, tap "Finalizar", pick 2 people in the "Quem fez esta lista?" dialog (checkbox list, "Confirmar" enabled once ≥1 is checked), confirm today as the day. Confirm the entry saves, the WhatsApp confirmation message shows both names joined as "A e B" in the "Por:" line, and the day's totals card updates. Repeat for the "Automáticas" tab with 3 people selected, confirming the WhatsApp message reads "A, B e C".

- [ ] **Step 7: Commit**

```bash
git add lib/services/visual_list_service.dart lib/services/auto_list_service.dart lib/screens/tabs/visual_tab.dart lib/screens/tabs/automaticas_tab.dart
git commit -m "feat: allow multiple people to claim visual/auto list entries"
```

---

### Task 7: Truck Reception & Inventory — multi-select

**Files:**
- Modify: `lib/screens/truck_form_screen.dart`
- Modify: `lib/screens/inventory_screen.dart`
- Modify: `lib/services/inventory_service.dart`

**Interfaces:**
- Consumes: `pickPeople`, `joinNames` from `lib/screens/widgets/person_picker.dart` (Task 1); `createdByNames` field on `TruckReception` (`lib/models/truck_reception.dart`) and `Inventory` (`lib/models/inventory.dart`) (Task 2).
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Update `startSession` in `lib/services/inventory_service.dart`**

Change the signature and body (lines 25-46) from a single `by` string to a list:

```dart
  Future<Inventory> startSession({
    required String name,
    required String code,
    List<String>? by,
  }) async {
    final now = DateTime.now();
    final inv = Inventory()
      ..name = name
      ..code = code
      ..createdAt = now
      ..startedAt = now
      ..runningSince = now
      ..accumulatedSeconds = 0
      ..valueCents = 0
      ..createdByNames = by ?? [];
    SyncMeta.stamp(inv);
    await _isar.writeTxn(() async {
      inv.id = await _isar.inventorys.put(inv);
    });
    notifyListeners();
    return inv;
  }
```

(Only the parameter type — `String? by` → `List<String>? by` — and the last assignment line — `..createdByInitials = by` → `..createdByNames = by ?? []` — actually change; the rest of the method body is unchanged, shown above for context.)

- [ ] **Step 2: Update `_save()` in `lib/screens/truck_form_screen.dart`**

Replace lines 285-289:

```dart
    final person = await pickPerson(context, title: 'Quem recebeu o camião?');
    if (person == null || !mounted) return;
    final truck = TruckReception()
      ..arrivalTime = _arrival
      ..createdByInitials = person.fullName
```

with:

```dart
    final people = await pickPeople(
      context,
      title: 'Quem recebeu o camião?',
    );
    if (people == null || !mounted) return;
    final names = people.map((p) => p.fullName).toList();
    final truck = TruckReception()
      ..arrivalTime = _arrival
      ..createdByNames = names
```

Then update the WhatsApp message line (line 341) from:

```dart
    lines.writeln('Por: ${person.fullName}');
```

to:

```dart
    lines.writeln('Por: ${joinNames(names)}');
```

No new import needed — `widgets/person_picker.dart` is already imported (line 12).

- [ ] **Step 3: Update `_newInventory()` in `lib/screens/inventory_screen.dart`**

Replace lines 58-59:

```dart
    final person = await pickPerson(context, title: 'Quem faz o inventário?');
    if (person == null || !mounted) return;
```

with:

```dart
    final people = await pickPeople(
      context,
      title: 'Quem faz o inventário?',
    );
    if (people == null || !mounted) return;
    final names = people.map((p) => p.fullName).toList();
```

Then update the session-start branch (lines 60-65) — only `by: person.fullName` → `by: names` changes on that call:

```dart
    if (result.action == _NewInventoryAction.start) {
      final inv = await InventoryService.instance.startSession(
        name: result.name,
        code: result.code,
        by: names,
      );
```

Then update the send-only branch's `Inventory()` construction (line 87) from:

```dart
      ..createdByInitials = person.fullName;
```

to:

```dart
      ..createdByNames = names;
```

And its WhatsApp message (line 93) from:

```dart
        'Por: ${person.fullName}';
```

to:

```dart
        'Por: ${joinNames(names)}';
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: no new issues beyond the 3 pre-existing baseline `info` lints. This task's own edit to `truck_form_screen.dart` (Step 2 replaces 5 lines with 9, all above the baseline lint site) shifts that file's baseline lint from `truck_form_screen.dart:330` to `truck_form_screen.dart:334` — expect `historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:334`.

- [ ] **Step 5: Manual check**

Run the app (`flutter run`). Open "Receção de Camião", fill in at least one pallet category, save, and at the "Quem recebeu o camião?" prompt select two people, then confirm — verify the WhatsApp preview text shows "Por: <Nome A> e <Nome B>". Separately, open "Inventário", start a new inventory session, and at the "Quem faz o inventário?" prompt select two people, then confirm — verify the session screen opens normally (no crash). Full verification that both names were saved happens once Task 9 is done (check the person detail screen's activity feed for either person); until then this is a smoke check that nothing crashes.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/truck_form_screen.dart lib/screens/inventory_screen.dart lib/services/inventory_service.dart
git commit -m "feat: allow multiple people to claim truck reception and inventory sessions"
```

---

### Task 8: Historico screen — display multiple names

**Files:**
- Modify: `lib/screens/historico_screen.dart`

**Interfaces:**
- Consumes: `resolveNames`, `joinNames`, `PersonInitialsRow` from `lib/screens/widgets/person_picker.dart` (Task 1); the `*ByNames`/`createdByNames` fields from `DailyTasks`, `OpeningList`, `AutoList`, `ReportList`, `VisualList`, `Inventory`, `TruckReception` (Task 2). Note `ShiftEvent.createdByInitials` has NO new sibling field (it's dead/out of scope per the spec) — that one site only ever has the legacy value, resolved via `resolveNames([], events.first.createdByInitials)`.
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Update `_HistoryInitials` to render multiple names**

Replace (`lib/screens/historico_screen.dart:233-244`):

```dart
class _HistoryInitials extends StatelessWidget {
  const _HistoryInitials({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: initials,
      child: PersonInitialsBadge(name: initials, size: 28),
    );
  }
}
```

with:

```dart
class _HistoryInitials extends StatelessWidget {
  const _HistoryInitials({required this.names});
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();
    return Tooltip(
      message: joinNames(names),
      child: PersonInitialsRow(names: names, size: 28),
    );
  }
}
```

Then update `_DayItem` (`lib/screens/historico_screen.dart:275-294`) — rename the `initials` field to `names` and change its type/default, leaving every other field untouched:

```dart
class _DayItem {
  _DayItem({
    required this.type,
    required this.time,
    required this.title,
    required this.subtitle,
    this.icon = Icons.circle,
    this.iconColor = AppColors.green,
    this.names = const [],
    this.deleted = false,
  });
  final _ItemType type;
  final DateTime time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<String> names;
  final bool deleted;
}
```

Then update `_HistoryInitials`'s one render call site, inside `_AllTabState.build()` (`lib/screens/historico_screen.dart:618-633`). Replace:

```dart
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((item.initials ?? '').isNotEmpty) ...[
                            _HistoryInitials(initials: item.initials!),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            timeFmt.format(item.time),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
```

with:

```dart
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.names.isNotEmpty) ...[
                            _HistoryInitials(names: item.names),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            timeFmt.format(item.time),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
```

- [ ] **Step 2: Update the seven `_DayItem` construction sites in `_AllTabState._load()`**

All seven are single-line `initials: <expr>,` entries inside `_DayItem(...)` calls — each becomes a single-line `names: resolveNames(...)` entry (no other lines in these blocks change). Exact replacements, by current line number:

`lib/screens/historico_screen.dart:377` (shift — `ShiftEvent` has no new field, legacy-only):
```dart
          initials: events.first.createdByInitials,
```
→
```dart
          names: resolveNames(const [], events.first.createdByInitials),
```

`lib/screens/historico_screen.dart:398` (truck):
```dart
          initials: t.createdByInitials,
```
→
```dart
          names: resolveNames(t.createdByNames, t.createdByInitials),
```

`lib/screens/historico_screen.dart:419` (opening):
```dart
          initials: o.createdByInitials,
```
→
```dart
          names: resolveNames(o.createdByNames, o.createdByInitials),
```

`lib/screens/historico_screen.dart:436` (auto):
```dart
          initials: a.createdByInitials,
```
→
```dart
          names: resolveNames(a.createdByNames, a.createdByInitials),
```

`lib/screens/historico_screen.dart:457` (report):
```dart
          initials: r.createdByInitials,
```
→
```dart
          names: resolveNames(r.createdByNames, r.createdByInitials),
```

`lib/screens/historico_screen.dart:473` (visual):
```dart
          initials: v.createdByInitials,
```
→
```dart
          names: resolveNames(v.createdByNames, v.createdByInitials),
```

`lib/screens/historico_screen.dart:541` (inventory):
```dart
          initials: inv.createdByInitials,
```
→
```dart
          names: resolveNames(inv.createdByNames, inv.createdByInitials),
```

(The 8th `_DayItem` construction, for `_ItemType.tasks` around line 517-527, has no `initials:`/`names:` param at all today — leave it as-is, it defaults to `names: const []`.)

- [ ] **Step 3: Update `_TaskEntry`, its 6 `by:` call sites, and `_taskTile`**

Replace the class (`lib/screens/historico_screen.dart:1789-1802`):

```dart
class _TaskEntry {
  const _TaskEntry(
    this.label,
    this.done, {
    this.by,
    this.timerKey,
    this.backdated = false,
  });
  final String label;
  final bool done;
  final String? by;
  final String? timerKey;
  final bool backdated;
}
```

with:

```dart
class _TaskEntry {
  const _TaskEntry(
    this.label,
    this.done, {
    this.byNames = const [],
    this.timerKey,
    this.backdated = false,
  });
  final String label;
  final bool done;
  final List<String> byNames;
  final String? timerKey;
  final bool backdated;
}
```

Update its 6 construction sites that pass `by:` (the other 4 — Lista de Abertura, Relatório das Listas, Lista Visual, Lista Automática — have no `by:` param and are untouched):

`lib/screens/historico_screen.dart:1663` — `by: t.kiwiAberturaBy,` → `byNames: resolveNames(t.kiwiAberturaByNames, t.kiwiAberturaBy),`

`lib/screens/historico_screen.dart:1670` — `by: t.alteracoesPrecoBy,` → `byNames: resolveNames(t.alteracoesPrecoByNames, t.alteracoesPrecoBy),`

`lib/screens/historico_screen.dart:1677` — `by: t.verificacaoTemperaturasBy,` → `byNames: resolveNames(t.verificacaoTemperaturasByNames, t.verificacaoTemperaturasBy),`

`lib/screens/historico_screen.dart:1696` — `by: t.preenchimentoQuadroBy,` → `byNames: resolveNames(t.preenchimentoQuadroByNames, t.preenchimentoQuadroBy),`

`lib/screens/historico_screen.dart:1713` — `by: t.verificacaoValidadesBy,` → `byNames: resolveNames(t.verificacaoValidadesByNames, t.verificacaoValidadesBy),`

`lib/screens/historico_screen.dart:1722` — `by: t.kiwiFechoBy,` → `byNames: resolveNames(t.kiwiFechoByNames, t.kiwiFechoBy),`

Update the pass-through to `_taskTile` inside the `.map(...)` at `lib/screens/historico_screen.dart:1766-1777`. Replace:

```dart
                    children: allTasks
                        .map(
                          (e) => _taskTile(
                            e.label,
                            e.done,
                            by: e.by,
                            parentUuid: t.syncUuid,
                            timerKey: e.timerKey,
                            backdated: e.backdated,
                          ),
                        )
                        .toList(),
```

with:

```dart
                    children: allTasks
                        .map(
                          (e) => _taskTile(
                            e.label,
                            e.done,
                            byNames: e.byNames,
                            parentUuid: t.syncUuid,
                            timerKey: e.timerKey,
                            backdated: e.backdated,
                          ),
                        )
                        .toList(),
```

Finally update `_taskTile` itself (`lib/screens/historico_screen.dart:1831-1879`). Replace the signature and the trailing block:

```dart
Widget _taskTile(
  String label,
  bool done, {
  String? by,
  String? parentUuid,
  String? timerKey,
  bool backdated = false,
}) {
```

with:

```dart
Widget _taskTile(
  String label,
  bool done, {
  List<String> byNames = const [],
  String? parentUuid,
  String? timerKey,
  bool backdated = false,
}) {
```

and, further down in the same function (`lib/screens/historico_screen.dart:1872-1875`), replace:

```dart
        if (done && (by ?? '').isNotEmpty) ...[
          const SizedBox(width: 4),
          _HistoryInitials(initials: by!),
        ],
```

with:

```dart
        if (done && byNames.isNotEmpty) ...[
          const SizedBox(width: 4),
          _HistoryInitials(names: byNames),
        ],
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: no new issues beyond the pre-existing baseline `info` lints in this file, which shift by exactly +1 line each due to `_HistoryInitials` growing by one line in Step 1 (the class body gains an `if (names.isEmpty) return const SizedBox.shrink();` early-return line): the two pre-existing lints move from `historico_screen.dart:951`/`:953` to `historico_screen.dart:952`/`:954`. The third baseline lint, `truck_form_screen.dart:334` (already shifted from `:330` by Task 7), is in a different file and unaffected by this task.

- [ ] **Step 5: Manual check**

After Task 3 lets a daily task be completed by 2 people, open Histórico → "Tudo" tab, find that task's tile, and confirm the trailing area renders two badges side by side (via `PersonInitialsRow`) instead of one — the tooltip text reads "Nome A e Nome B". Then check the "Tarefas" tab's expanded task row for the same completed task, confirming `_taskTile`'s trailing area shows the same two-badge treatment. Finally, for a row saved before this feature shipped (empty `*Names`/`createdByNames`, non-null legacy field), confirm `resolveNames` falls back to the single legacy name and the tile still shows exactly one badge — no blank/missing attribution for old history.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/historico_screen.dart
git commit -m "feat: show multiple names in historico screen"
```

---

### Task 9: Person detail screen — activity feed matches any claimant

**Files:**
- Modify: `lib/screens/person_detail_screen.dart`

**Interfaces:**
- Consumes: `resolveNames` from `lib/screens/widgets/person_picker.dart` (Task 1); the `*ByNames`/`createdByNames` fields from the model files (Task 2) — `DailyTasks.kiwiAberturaByNames`, `alteracoesPrecoByNames`, `verificacaoTemperaturasByNames`, `preenchimentoQuadroByNames`, `verificacaoValidadesByNames`, `kiwiFechoByNames`; `OpeningList.createdByNames`, `AutoList.createdByNames`, `ReportList.createdByNames`, `VisualList.createdByNames`, `Inventory.createdByNames`, `TruckReception.createdByNames`.
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Import `resolveNames`**

`resolveNames` lives in `lib/screens/widgets/person_picker.dart`, which this file already imports (`import 'widgets/person_picker.dart';` at line 20) — no new import needed.

- [ ] **Step 2: Update the six `createdByInitials` membership checks in `_load()` (lines 76-173)**

Change each of these six lines from a direct string comparison to a `resolveNames(...).contains(name)` check, keeping everything else in each block (the `_ActivityItem` construction) exactly as-is:

Opening list (line 83):
```dart
// Before
if (o.createdByInitials != name) continue;
// After
if (!resolveNames(o.createdByNames, o.createdByInitials).contains(name)) continue;
```

Auto list (line 98):
```dart
// Before
if (a.createdByInitials != name) continue;
// After
if (!resolveNames(a.createdByNames, a.createdByInitials).contains(name)) continue;
```

Report list (line 114):
```dart
// Before
if (r.createdByInitials != name) continue;
// After
if (!resolveNames(r.createdByNames, r.createdByInitials).contains(name)) continue;
```

Visual list (line 129):
```dart
// Before
if (v.createdByInitials != name) continue;
// After
if (!resolveNames(v.createdByNames, v.createdByInitials).contains(name)) continue;
```

Inventory (line 144):
```dart
// Before
if (inv.createdByInitials != name) continue;
// After
if (!resolveNames(inv.createdByNames, inv.createdByInitials).contains(name)) continue;
```

Truck reception (line 158):
```dart
// Before
if (t.createdByInitials != name) continue;
// After
if (!resolveNames(t.createdByNames, t.createdByInitials).contains(name)) continue;
```

- [ ] **Step 3: Update the six `DailyTasks` `xBy` membership checks in `_tasksDoneByPerson` (lines 223-244)**

Replace the whole method body:

```dart
// Before
List<({String label})> _tasksDoneByPerson(DailyTasks t, String name) {
  final out = <({String label})>[];
  if (t.kiwiAbertura && t.kiwiAberturaBy == name) {
    out.add((label: 'Kiwi Abertura'));
  }
  if (t.alteracoesPreco && t.alteracoesPrecoBy == name) {
    out.add((label: 'Alterações de Preço'));
  }
  if (t.verificacaoTemperaturas && t.verificacaoTemperaturasBy == name) {
    out.add((label: 'Verificação de Temperaturas'));
  }
  if (t.preenchimentoQuadro && t.preenchimentoQuadroBy == name) {
    out.add((label: 'Preenchimento do Quadro'));
  }
  if (t.verificacaoValidades && t.verificacaoValidadesBy == name) {
    out.add((label: 'Verificação de Validades'));
  }
  if (t.kiwiFecho && t.kiwiFechoBy == name) {
    out.add((label: 'Kiwi Fecho'));
  }
  return out;
}
```

```dart
// After
List<({String label})> _tasksDoneByPerson(DailyTasks t, String name) {
  final out = <({String label})>[];
  if (t.kiwiAbertura &&
      resolveNames(t.kiwiAberturaByNames, t.kiwiAberturaBy).contains(name)) {
    out.add((label: 'Kiwi Abertura'));
  }
  if (t.alteracoesPreco &&
      resolveNames(t.alteracoesPrecoByNames, t.alteracoesPrecoBy)
          .contains(name)) {
    out.add((label: 'Alterações de Preço'));
  }
  if (t.verificacaoTemperaturas &&
      resolveNames(
        t.verificacaoTemperaturasByNames,
        t.verificacaoTemperaturasBy,
      ).contains(name)) {
    out.add((label: 'Verificação de Temperaturas'));
  }
  if (t.preenchimentoQuadro &&
      resolveNames(t.preenchimentoQuadroByNames, t.preenchimentoQuadroBy)
          .contains(name)) {
    out.add((label: 'Preenchimento do Quadro'));
  }
  if (t.verificacaoValidades &&
      resolveNames(t.verificacaoValidadesByNames, t.verificacaoValidadesBy)
          .contains(name)) {
    out.add((label: 'Verificação de Validades'));
  }
  if (t.kiwiFecho &&
      resolveNames(t.kiwiFechoByNames, t.kiwiFechoBy).contains(name)) {
    out.add((label: 'Kiwi Fecho'));
  }
  return out;
}
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: no new issues beyond the 3 pre-existing baseline `info` lints, at their post-Task-7/Task-8 line numbers: `historico_screen.dart:952`, `historico_screen.dart:954`, `truck_form_screen.dart:334`.

- [ ] **Step 5: Manual check**

Run the app, complete a Daily Task (e.g. "Kiwi Abertura") crediting 2 people via the multi-select picker (from Task 3). Open the person detail screen for each of the two people in turn and confirm "Tarefa: Kiwi Abertura" appears in both of their activity feeds for that day, not just one. Repeat for finalizing an Opening List (Task 5) with 2 people and confirm "Lista de Abertura" shows up for both.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/person_detail_screen.dart
git commit -m "feat: show a task in every claimant's activity feed"
```

---

### Task 10: Cleanup — remove the single-select picker API

**Files:**
- Modify: `lib/screens/widgets/person_picker.dart`

**Interfaces:**
- Consumes: nothing new (this task only removes dead code Task 1 added, once nothing references it).
- Produces: nothing — this is the final task.

- [ ] **Step 1: Confirm nothing still calls the old API**

Run:
```bash
grep -rn "pickPerson(\|pickPersonAndDay(\|PersonAndDay(" lib/ --include='*.dart' | grep -v 'lib/screens/widgets/person_picker.dart'
```
Expected: no output. (If anything shows up, a screen was missed by Tasks 3–7 — go fix that call site first, using the same `pickPeople`/`pickPeopleAndDay` pattern shown in those tasks, before continuing here.)

- [ ] **Step 2: Delete the old single-select API from `person_picker.dart`**

Remove the `pickPerson` function, the `PersonAndDay` class, the `pickPersonAndDay` function, the `_PersonPickerDialog` class, and the `_PersonPickerDialogState` class — i.e. delete this entire block (everything from the `pickPerson` doc comment through the end of `_PersonPickerDialogState`, immediately before the `_MultiPersonPickerDialog` class):

```dart
/// Prompts the user to pick a person. Returns the chosen [Person] or null
/// if the picker is cancelled / no one is selected.
///
/// Deprecated in favor of [pickPeople] — kept only until every call site in
/// this codebase has migrated (tracked by the multi-claim-tasks plan), then
/// removed.
Future<Person?> pickPerson(
  BuildContext context, {
  required String title,
  String? subtitle,
}) {
  return showDialog<Person>(
    context: context,
    builder: (_) => _PersonPickerDialog(title: title, subtitle: subtitle),
  );
}

/// A person plus the (plain, time-stripped) calendar date the task they
/// picked was actually completed on — defaults to today but can be
/// overridden via [pickPersonAndDay].
class PersonAndDay {
  const PersonAndDay(this.person, this.day);
  final Person person;
  final DateTime day;
}

/// Like [pickPerson], but also lets the user say the task wasn't done today.
/// [initialDay] is the default/selected date (time-of-day is ignored).
///
/// Deprecated in favor of [pickPeopleAndDay] — kept only until every call
/// site in this codebase has migrated, then removed.
Future<PersonAndDay?> pickPersonAndDay(
  BuildContext context, {
  required String title,
  String? subtitle,
  required DateTime initialDay,
  DateTime? firstDay,
  bool Function(DateTime)? selectableDayPredicate,
}) {
  final day = DateTime(initialDay.year, initialDay.month, initialDay.day);
  return showDialog<PersonAndDay>(
    context: context,
    builder: (_) => _PersonPickerDialog(
      title: title,
      subtitle: subtitle,
      initialDay: day,
      firstDay: firstDay ?? day.subtract(const Duration(days: 90)),
      selectableDayPredicate: selectableDayPredicate,
    ),
  );
}
```

(this precedes the `pickPeople` function — delete up to, but not including, `pickPeople`), and separately delete:

```dart
class _PersonPickerDialog extends StatefulWidget {
  const _PersonPickerDialog({
    required this.title,
    this.subtitle,
    this.initialDay,
    this.firstDay,
    this.selectableDayPredicate,
  });
  final String title;
  final String? subtitle;

  /// When non-null, this dialog is running in "pick person + day" mode and
  /// pops a [PersonAndDay] instead of a bare [Person].
  final DateTime? initialDay;
  final DateTime? firstDay;
  final bool Function(DateTime)? selectableDayPredicate;

  @override
  State<_PersonPickerDialog> createState() => _PersonPickerDialogState();
}

class _PersonPickerDialogState extends State<_PersonPickerDialog> {
  late Future<List<Person>> _future;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _future = PersonService.instance.all();
    _selectedDay = widget.initialDay ?? DateTime.now();
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

  void _choose(Person p) {
    if (widget.initialDay != null) {
      Navigator.of(context).pop(PersonAndDay(p, _selectedDay));
    } else {
      Navigator.of(context).pop(p);
    }
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
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                if (widget.initialDay != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 18,
                          color: Colors.black54,
                        ),
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
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: people.length,
                    itemBuilder: (_, i) {
                      final p = people[i];
                      return ListTile(
                        leading: PersonInitialsBadge(name: p.fullName),
                        title: Text(p.fullName),
                        subtitle: p.collaboratorNumber.isEmpty
                            ? null
                            : Text('Nº ${p.collaboratorNumber}'),
                        onTap: () => _choose(p),
                      );
                    },
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
```

(this whole block precedes `class _MultiPersonPickerDialog` — delete it entirely).

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: exactly the 3 pre-existing baseline `info` lints, at their post-Task-7/Task-8 line numbers (`historico_screen.dart:952`, `historico_screen.dart:954`, `truck_form_screen.dart:334`) — this file (`person_picker.dart`) has no lints of its own before or after this deletion.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/widgets/person_picker.dart
git commit -m "chore: remove single-select person picker now that every caller uses the multi-select one"
```
