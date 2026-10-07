# Premade Teams Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace a person's free-text cargo and manager links with one premade team plus an optional chefe role, and show Pessoas as a single list grouped by team.

**Architecture:** Teams are a `const` list in a new plain-Dart file `lib/models/teams.dart`, together with the pure helpers that read a person's chefe slot and find who already holds a slot. `Person` stores only a team id and a slot name. `PersonService.save` clears the previous holder of a slot in the same write. `people_sections.dart` groups by team for the list. No migration code: Isar drops the removed fields and the new ones start null ("Sem equipa").

**Tech Stack:** Flutter, Dart 3, Isar Community 3.3.2 (`isar_community`, codegen via `build_runner`), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-10-07-premade-teams-design.md`

## Global Constraints

- Team order and names, exactly: Livre Serviço, Gerência, Charcutaria, Meal Solutions, Talho, Peixaria, Frente de Loja, BemEstar, Padaria. Ids: `livre_servico`, `gerencia`, `charcutaria`, `meal_solutions`, `talho`, `peixaria`, `frente_de_loja`, `bem_estar`, `padaria`.
- Chefe slots: Livre Serviço has `dia` ("Chefe de dia") and `noite` ("Chefe de noite"), in that order; every other team has one `chefe` ("Chefe").
- A person is in exactly one team or none ("Sem equipa"). A chefe must be a member of that team. At most one non-deleted person per (team, slot).
- UI strings are Portuguese (pt_PT).
- Versioning (CLAUDE.md): every commit bumps `pubspec.yaml` and gets an annotated tag and a CHANGELOG entry. Because the model change breaks compilation until the screens are updated, **this plan lands as one commit, 0.32.0+86, tagged `v0.32.0`** (Task 7). Tasks 1–6 end with green `flutter test` / `flutter analyze` checkpoints, not commits.
- `flutter analyze` must show only the 3 pre-existing `curly_braces_in_flow_control_structures` infos (`historico_screen.dart:724`, `:726`, `truck_form_screen.dart:341`).
- Don't run `dart format` on whole existing files: it rewraps unrelated code (e.g. `people_screen.dart`'s `_TeamsList` before this plan deletes it, `person_service.dart`'s `all()`). Format new files only, and keep edits in existing files hand-formatted.

## Review Focus

1. **Restoring an old backup** (exported ≤0.31.1, Person rows carry `role`, `managerUuids`, `managerUuid`): import must succeed, with everyone in "Sem equipa". Pinned by `personJsonForImport` tests in Task 5.
2. **Re-saving the current chefe** (edit Ana, who is already Chefe de Talho, and press Guardar) must not ask "Substituir?" or clear her own slot. Pinned by the "the person themself" tests in Task 1 (both by identity and by a different instance with the same `syncUuid`, which is what `PersonService.save` sees).
3. **A deleted former chefe** must not block or be "replaced". Pinned by the "deleted person" tests in Task 1.
4. **A slot that doesn't fit the team** (e.g. `chefe: 'dia'` on a Talho person, from a backup or a team change) must read as a plain member everywhere: list order, label and conflicts. Pinned by the `chefeSlotOf` and `buildPeopleSections` tests in Tasks 1 and 3.
5. **Search with accents in team names** ("gerencia" finds Gerência people, "frente" finds Frente de Loja). Pinned in Task 3.

---

### Task 1: Team list, Person fields and chefe helpers

**Files:**
- Create: `lib/models/teams.dart`
- Modify: `lib/models/person.dart` (add fields; removals happen in Task 5)
- Regenerate: `lib/models/person.g.dart`
- Test: `test/teams_test.dart`

**Interfaces:**
- Consumes: `Person` from `lib/models/person.dart`.
- Produces:
  - `Person.team` (`String?`, a `Team.id`) and `Person.chefe` (`String?`, a `ChefeSlot.name`)
  - `enum ChefeSlot { chefe, dia, noite }` with `String get label` ('Chefe', 'Chefe de dia', 'Chefe de noite')
  - `class Team { final String id; final String name; final List<ChefeSlot> chefeSlots; }`
  - `const List<Team> teams` (in the order above)
  - `Team? teamById(String? id)`
  - `ChefeSlot? chefeSlotOf(Person p)`: null unless `p.chefe` names a slot of `p`'s team
  - `Person? chefeHolder(List<Person> all, String teamId, ChefeSlot slot, {required Person except})`
  - `List<Person> chefeConflicts(Person saving, List<Person> all)`

- [ ] **Step 1: Add the fields to `Person`**, after `phoneNumber`:

```dart
  /// [Team.id] of the person's team (see `teams.dart`); null = Sem equipa.
  String? team;

  /// [ChefeSlot.name] if the person is a chefe of their team, else null.
  /// Only meaningful when it is one of the team's slots — read it through
  /// `chefeSlotOf`.
  String? chefe;
```

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `person.g.dart` rewritten; `flutter analyze` still at the 3 old infos.

- [ ] **Step 2: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/teams.dart';

Person _p(
  String name, {
  String? team,
  String? chefe,
  String uuid = '',
  bool deleted = false,
}) => Person()
  ..fullName = name
  ..createdAt = DateTime(2026)
  ..syncUuid = uuid
  ..team = team
  ..chefe = chefe
  ..syncDeletedAt = deleted ? DateTime(2026) : null;

void main() {
  group('teams', () {
    test('are in the agreed order with Livre Serviço first', () {
      expect(teams.map((t) => t.name), [
        'Livre Serviço',
        'Gerência',
        'Charcutaria',
        'Meal Solutions',
        'Talho',
        'Peixaria',
        'Frente de Loja',
        'BemEstar',
        'Padaria',
      ]);
    });

    test('Livre Serviço has day and night chefes, others one chefe', () {
      expect(teamById('livre_servico')!.chefeSlots, [
        ChefeSlot.dia,
        ChefeSlot.noite,
      ]);
      for (final t in teams.skip(1)) {
        expect(t.chefeSlots, [ChefeSlot.chefe], reason: t.name);
      }
    });

    test('teamById returns null for null or unknown ids', () {
      expect(teamById('talho')!.name, 'Talho');
      expect(teamById(null), isNull);
      expect(teamById('caixas'), isNull);
    });

    test('slot labels', () {
      expect(ChefeSlot.chefe.label, 'Chefe');
      expect(ChefeSlot.dia.label, 'Chefe de dia');
      expect(ChefeSlot.noite.label, 'Chefe de noite');
    });
  });

  group('chefeSlotOf', () {
    test('returns the slot when it belongs to the team', () {
      expect(chefeSlotOf(_p('A', team: 'talho', chefe: 'chefe')),
          ChefeSlot.chefe);
      expect(chefeSlotOf(_p('B', team: 'livre_servico', chefe: 'noite')),
          ChefeSlot.noite);
    });

    test('is null for members, wrong slots, unknown teams and no team', () {
      expect(chefeSlotOf(_p('A', team: 'talho')), isNull);
      expect(chefeSlotOf(_p('B', team: 'talho', chefe: 'dia')), isNull);
      expect(chefeSlotOf(_p('C', team: 'livre_servico', chefe: 'chefe')),
          isNull);
      expect(chefeSlotOf(_p('D', team: 'caixas', chefe: 'chefe')), isNull);
      expect(chefeSlotOf(_p('E', chefe: 'chefe')), isNull);
    });
  });

  group('chefeHolder', () {
    final ana = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
    final rui = _p('Rui', team: 'talho', uuid: 'r');

    test('finds the current holder', () {
      expect(chefeHolder([ana, rui], 'talho', ChefeSlot.chefe, except: rui),
          same(ana));
    });

    test('ignores the person themself, by identity or by uuid', () {
      expect(chefeHolder([ana], 'talho', ChefeSlot.chefe, except: ana),
          isNull);
      final anaCopy = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      expect(chefeHolder([ana], 'talho', ChefeSlot.chefe, except: anaCopy),
          isNull);
    });

    test('ignores deleted people and other slots/teams', () {
      final gone = _p('Zé', team: 'talho', chefe: 'chefe', deleted: true);
      final night = _p('Bia', team: 'livre_servico', chefe: 'noite');
      expect(chefeHolder([gone], 'talho', ChefeSlot.chefe, except: rui),
          isNull);
      expect(
          chefeHolder([night], 'livre_servico', ChefeSlot.dia, except: rui),
          isNull);
      expect(chefeHolder([ana], 'peixaria', ChefeSlot.chefe, except: rui),
          isNull);
    });

    test('a new person (no uuid yet) is not mistaken for others', () {
      final newbie = _p('Novo', team: 'talho', chefe: 'chefe');
      final oldNoUuid = _p('Velho', team: 'talho', chefe: 'chefe');
      expect(
          chefeHolder([oldNoUuid], 'talho', ChefeSlot.chefe, except: newbie),
          same(oldNoUuid));
    });
  });

  group('chefeConflicts', () {
    test('returns whoever else holds the same team and slot', () {
      final ana = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      final rui = _p('Rui', team: 'talho', chefe: 'chefe', uuid: 'r');
      expect(chefeConflicts(rui, [ana, rui]), [ana]);
    });

    test('is empty for members and for invalid slots', () {
      final ana = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      expect(chefeConflicts(_p('Rui', team: 'talho'), [ana]), isEmpty);
      expect(chefeConflicts(_p('Rui', team: 'talho', chefe: 'dia'), [ana]),
          isEmpty);
    });

    test('day and night chefes of Livre Serviço do not conflict', () {
      final day = _p('Ana', team: 'livre_servico', chefe: 'dia', uuid: 'a');
      final night =
          _p('Rui', team: 'livre_servico', chefe: 'noite', uuid: 'r');
      expect(chefeConflicts(night, [day]), isEmpty);
    });

    test('skips the person themself and deleted people', () {
      final ana = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      final anaFromDb = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      final gone = _p('Zé', team: 'talho', chefe: 'chefe', uuid: 'z',
          deleted: true);
      expect(chefeConflicts(ana, [anaFromDb, gone]), isEmpty);
    });
  });
}
```

- [ ] **Step 3: Run to verify it fails**

Run: `flutter test test/teams_test.dart`
Expected: compile error, `teams.dart` not found.

- [ ] **Step 4: Implement `lib/models/teams.dart`**

```dart
import 'person.dart';

/// A chefe position within a team. Stored on [Person.chefe] by name.
enum ChefeSlot {
  chefe('Chefe'),
  dia('Chefe de dia'),
  noite('Chefe de noite');

  const ChefeSlot(this.label);
  final String label;
}

/// One of the store's fixed teams. [id] is what [Person.team] stores, so
/// [name] can change without touching saved data.
class Team {
  const Team(this.id, this.name, this.chefeSlots);

  final String id;
  final String name;

  /// The team's chefe positions, in display order. Each is held by at most
  /// one (non-deleted) member.
  final List<ChefeSlot> chefeSlots;
}

/// Every team, in the order the Pessoas list shows them.
const teams = [
  Team('livre_servico', 'Livre Serviço', [ChefeSlot.dia, ChefeSlot.noite]),
  Team('gerencia', 'Gerência', [ChefeSlot.chefe]),
  Team('charcutaria', 'Charcutaria', [ChefeSlot.chefe]),
  Team('meal_solutions', 'Meal Solutions', [ChefeSlot.chefe]),
  Team('talho', 'Talho', [ChefeSlot.chefe]),
  Team('peixaria', 'Peixaria', [ChefeSlot.chefe]),
  Team('frente_de_loja', 'Frente de Loja', [ChefeSlot.chefe]),
  Team('bem_estar', 'BemEstar', [ChefeSlot.chefe]),
  Team('padaria', 'Padaria', [ChefeSlot.chefe]),
];

/// The team with [id], or null for null/unknown ids (shown as "Sem equipa").
Team? teamById(String? id) {
  for (final t in teams) {
    if (t.id == id) return t;
  }
  return null;
}

/// [p]'s chefe slot, or null if they're a member, have no (known) team, or
/// [Person.chefe] isn't one of their team's slots.
ChefeSlot? chefeSlotOf(Person p) {
  final team = teamById(p.team);
  if (team == null) return null;
  for (final s in team.chefeSlots) {
    if (s.name == p.chefe) return s;
  }
  return null;
}

/// Whether [a] and [b] are the same person: the same object, or the same
/// (non-empty) syncUuid, e.g. the form's copy and the one read from Isar.
bool _same(Person a, Person b) =>
    identical(a, b) || (a.syncUuid.isNotEmpty && a.syncUuid == b.syncUuid);

/// The non-deleted person in [all] other than [except] who holds [slot] in
/// team [teamId], if any.
Person? chefeHolder(
  List<Person> all,
  String teamId,
  ChefeSlot slot, {
  required Person except,
}) {
  for (final p in all) {
    if (p.syncDeletedAt != null || _same(p, except)) continue;
    if (p.team == teamId && chefeSlotOf(p) == slot) return p;
  }
  return null;
}

/// People in [all] who must lose their chefe slot when [saving] is saved:
/// anyone else (non-deleted) holding [saving]'s team and slot.
List<Person> chefeConflicts(Person saving, List<Person> all) {
  final slot = chefeSlotOf(saving);
  if (slot == null) return const [];
  return [
    for (final p in all)
      if (p.syncDeletedAt == null &&
          !_same(p, saving) &&
          p.team == saving.team &&
          chefeSlotOf(p) == slot)
        p,
  ];
}
```

- [ ] **Step 5: Run to verify it passes**

Run: `flutter test test/teams_test.dart`
Expected: all pass. Then `dart format lib/models/teams.dart test/teams_test.dart`.

---

### Task 2: One holder per chefe slot on save

**Files:**
- Modify: `lib/services/person_service.dart` (`save`)

**Interfaces:**
- Consumes: `chefeConflicts`, `Person.team`/`chefe` (Task 1).
- Produces: `PersonService.save(Person)` clears conflicting holders in the same transaction.

The service talks to Isar, so it isn't unit-tested here; the rule itself is `chefeConflicts`, which Task 1 tests.

- [ ] **Step 1: Enforce one holder per slot in `PersonService.save`.** Add `import '../models/teams.dart';` and replace `save`:

```dart
  /// Saves [p]. If [p] is now a chefe, whoever else held that team's slot
  /// loses it in the same transaction (one holder per slot).
  Future<int> save(Person p) async {
    SyncMeta.stamp(p);
    final others = await _isar.persons
        .filter()
        .syncDeletedAtIsNull()
        .findAll();
    final demoted = chefeConflicts(p, others);
    for (final d in demoted) {
      d.chefe = null;
      SyncMeta.stamp(d);
    }
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.persons.put(p);
      await _isar.persons.putAll(demoted);
    });
    notifyListeners();
    return id;
  }
```

(`chefeConflicts` skips the copy of [p] that `findAll` returns, because it has the same `syncUuid`; that case is covered in Task 1.)

- [ ] **Step 2: Verify**

Run: `flutter analyze && flutter test`
Expected: 3 old infos; all tests pass.

---

### Task 3: Group the Pessoas list by team

**Files:**
- Modify: `lib/screens/people_sections.dart`
- Test: `test/people_sections_test.dart` (rewrite)

**Interfaces:**
- Consumes: `teams`, `teamById`, `chefeSlotOf`, `Person.team`/`chefe` (Task 1).
- Produces (same signature as today, so `people_screen.dart` keeps compiling): `class PeopleSection { final String title; final List<Person> people; }` and `List<PeopleSection> buildPeopleSections(List<Person> people, {String query = ''})`; `String foldText(String)` unchanged.

- [ ] **Step 1: Rewrite the tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/people_sections.dart';

Person _p(String name, {String? team, String? chefe, String number = ''}) =>
    Person()
      ..fullName = name
      ..createdAt = DateTime(2026)
      ..team = team
      ..chefe = chefe
      ..collaboratorNumber = number;

List<String> _names(PeopleSection s) =>
    s.people.map((p) => p.fullName).toList();

List<String> _titles(List<PeopleSection> sections) =>
    sections.map((s) => s.title).toList();

void main() {
  group('foldText', () {
    test('lowercases and strips Portuguese accents', () {
      expect(foldText('ÁÀÂÃ éê Í ÓÔÕ Ú Ç'), 'aaaa ee i ooo u c');
    });
  });

  group('grouping', () {
    test('follows the fixed team order, Sem equipa last, empty hidden', () {
      final sections = buildPeopleSections([
        _p('Rui', team: 'talho'),
        _p('João'),
        _p('Ana', team: 'livre_servico'),
        _p('Bia', team: 'gerencia'),
        _p('Velho', team: 'caixas'),
      ]);
      expect(_titles(sections), [
        'Livre Serviço',
        'Gerência',
        'Talho',
        'Sem equipa',
      ]);
      expect(_names(sections.last), ['João', 'Velho']);
    });

    test('chefes first in slot order, then members A–Z', () {
      final sections = buildPeopleSections([
        _p('Bruno', team: 'livre_servico'),
        _p('Noite', team: 'livre_servico', chefe: 'noite'),
        _p('álvaro', team: 'livre_servico'),
        _p('Dia', team: 'livre_servico', chefe: 'dia'),
      ]);
      expect(_names(sections.single), ['Dia', 'Noite', 'álvaro', 'Bruno']);
    });

    test('a slot that does not fit the team counts as a member', () {
      final sections = buildPeopleSections([
        _p('Zé', team: 'talho'),
        _p('Ana', team: 'talho', chefe: 'dia'),
        _p('Chefe', team: 'talho', chefe: 'chefe'),
      ]);
      expect(_names(sections.single), ['Chefe', 'Ana', 'Zé']);
    });
  });

  group('search', () {
    final people = [
      _p('João Pinto', team: 'talho', number: '3101'),
      _p('Ana Martins', team: 'gerencia', number: '1234'),
      _p('Rita Sousa', team: 'frente_de_loja'),
    ];

    List<String> found(String q) =>
        buildPeopleSections(people, query: q).expand(_names).toList();

    test('matches name ignoring case and accents', () {
      expect(found('joao'), ['João Pinto']);
    });

    test('matches team name ignoring accents', () {
      expect(found('gerencia'), ['Ana Martins']);
      expect(found('frente'), ['Rita Sousa']);
    });

    test('matches nº de colaborador', () {
      expect(found('310'), ['João Pinto']);
    });

    test('drops sections left empty', () {
      expect(_titles(buildPeopleSections(people, query: 'ana')), [
        'Gerência',
      ]);
    });

    test('blank query keeps everyone', () {
      expect(found('  '), ['Ana Martins', 'João Pinto', 'Rita Sousa']);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/people_sections_test.dart`
Expected: FAIL. Sections are still by cargo, so titles come out as `['Sem equipa']`-style cargo groups and the orders don't match.

- [ ] **Step 3: Rewrite `buildPeopleSections`** in `lib/screens/people_sections.dart`. Keep `_accents`, `foldText` and `_byName`; add `import '../models/teams.dart';`; replace the rest:

```dart
/// A team's people in the Pessoas list view.
class PeopleSection {
  const PeopleSection(this.title, this.people);

  final String title;
  final List<Person> people;
}

bool _matches(Person p, String foldedQuery) =>
    foldText(p.fullName).contains(foldedQuery) ||
    foldText(teamById(p.team)?.name ?? '').contains(foldedQuery) ||
    foldText(p.collaboratorNumber).contains(foldedQuery);

/// Filters [people] by [query] (name, team name or nº de colaborador,
/// ignoring case and accents) and groups them by team in [teams] order,
/// with people without a (known) team in a final "Sem equipa" section.
/// Within a team, chefes come first in the team's slot order, then members
/// A–Z. Empty sections are left out.
List<PeopleSection> buildPeopleSections(
  List<Person> people, {
  String query = '',
}) {
  final q = foldText(query.trim());
  final byTeam = <String?, List<Person>>{};
  for (final p in people) {
    if (q.isNotEmpty && !_matches(p, q)) continue;
    (byTeam[teamById(p.team)?.id] ??= []).add(p);
  }

  int byRank(Team team, Person a, Person b) {
    int rank(Person p) {
      final slot = chefeSlotOf(p);
      return slot == null ? team.chefeSlots.length : team.chefeSlots.indexOf(slot);
    }

    final r = rank(a).compareTo(rank(b));
    return r != 0 ? r : _byName(a, b);
  }

  return [
    for (final t in teams)
      if (byTeam[t.id] case final members?)
        PeopleSection(t.name, members..sort((a, b) => byRank(t, a, b))),
    if (byTeam[null] case final rest?)
      PeopleSection('Sem equipa', rest..sort(_byName)),
  ];
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `flutter test` (whole suite)
Expected: all pass. Then `dart format lib/screens/people_sections.dart test/people_sections_test.dart`.

---

### Task 4: Pessoas screen and person detail

**Files:**
- Modify: `lib/screens/people_screen.dart`
- Modify: `lib/screens/person_detail_screen.dart:310-319`

**Interfaces:**
- Consumes: `buildPeopleSections` (Task 3); `teamById`, `chefeSlotOf`, `ChefeSlot.label` (Task 1).
- Produces: nothing new.

- [ ] **Step 1: One view in `people_screen.dart`.** Delete `enum _ViewMode`, the `_viewMode` field, `_viewModeLabel`, `_viewModeIcon`, `_nextViewMode`, the view-switch `IconButton` in the AppBar, the `if (_viewMode == _ViewMode.list) { … }` wrapper (keep its body, the search `Column`, as the only return), the trailing `return _TeamsList(…)`, and the classes `_TeamSection` and `_TeamsList`. Keep `_SectionHeader` (used by `_PeopleList`).

- [ ] **Step 2: Chefe label on rows.** Add `import '../models/teams.dart';` and change `_PersonTile`'s subtitle list to:

```dart
        [
          if (chefeSlotOf(p) case final slot?) slot.label,
          if (p.collaboratorNumber.isNotEmpty) 'Nº ${p.collaboratorNumber}',
        ].join(' · '),
```

- [ ] **Step 3: Person detail.** Add `import '../models/teams.dart';` and replace the `role` block at `person_detail_screen.dart:310-319`:

```dart
                        if (_teamLine(_person) != null ||
                            _person.collaboratorNumber.isNotEmpty)
                          Text(
                            [
                              ?_teamLine(_person),
                              if (_person.collaboratorNumber.isNotEmpty)
                                'Nº colaborador: ${_person.collaboratorNumber}',
                            ].join(' · '),
                            style: const TextStyle(color: Colors.black54),
                          ),
```

and add this top-level function at the end of the file:

```dart
/// "Talho · Chefe", "Talho", or null for Sem equipa.
String? _teamLine(Person p) {
  final team = teamById(p.team);
  if (team == null) return null;
  final slot = chefeSlotOf(p);
  return slot == null ? team.name : '${team.name} · ${slot.label}';
}
```


- [ ] **Step 4: Verify**

Run: `flutter analyze && flutter test`
Expected: 3 old infos (`people_screen.dart` must not mention `groupByManager`, `_TeamsList` or `_ViewMode`); tests pass.

---

### Task 5: Person form, remove cargo and managers

**Files:**
- Modify: `lib/screens/person_form_screen.dart`
- Modify: `lib/models/person.dart` (remove `role`, `managerUuid`, `managerUuids`); regenerate `person.g.dart`
- Modify: `lib/services/person_service.dart` (remove `migrateManagerUuids`, `groupByManager`, `subtreeUuids`, manager clean-up in `delete`)
- Modify: `lib/main.dart:19` (remove the `migrateManagerUuids()` call)
- Modify: `lib/services/backup_service.dart` (strip legacy keys; remove the trailing `migrateManagerUuids()` call and its comment)
- Test: `test/backup_person_json_test.dart`

**Interfaces:**
- Consumes: `teams`, `teamById`, `chefeSlotOf`, `chefeHolder`, `ChefeSlot` (Task 1); `PersonService.save` (Task 2).
- Produces: `Map<String, dynamic> personJsonForImport(Map<String, dynamic> json)` in `backup_service.dart` (top-level, public for the test).

- [ ] **Step 1: Failing test for old backups**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/services/backup_service.dart';

void main() {
  test('drops the pre-0.32 cargo and manager keys from a Person row', () {
    final old = {
      'id': 3,
      'fullName': 'Ana',
      'role': 'Operadora',
      'managerUuid': 'x',
      'managerUuids': ['x', 'y'],
    };
    expect(personJsonForImport(old), {'id': 3, 'fullName': 'Ana'});
    expect(old.containsKey('role'), isTrue, reason: 'input is not mutated');
  });

  test('leaves current rows untouched', () {
    final row = {'id': 1, 'fullName': 'Rui', 'team': 'talho', 'chefe': null};
    expect(personJsonForImport(row), row);
  });
}
```

Run: `flutter test test/backup_person_json_test.dart`. Expected: compile error, `personJsonForImport` not defined.

- [ ] **Step 2: Implement it and use it in `BackupService`.** Add at the end of `backup_service.dart`:

```dart
/// [json] (a Person row from a backup file) without the fields removed in
/// 0.32.0 (cargo and manager links), so older backups still import.
Map<String, dynamic> personJsonForImport(Map<String, dynamic> json) =>
    Map.of(json)
      ..remove('role')
      ..remove('managerUuid')
      ..remove('managerUuids');
```

Change the import line to
`await _isar.persons.importJson(items('Person').map(personJsonForImport).toList());`
and delete the comment block plus `await PersonService.instance.migrateManagerUuids();` after the transaction (drop the `person_service.dart` import if it becomes unused).

Run: `flutter test test/backup_person_json_test.dart`. Expected: PASS.

- [ ] **Step 3: Remove the old fields.** In `person.dart` delete `role`, `managerUuid` (and its doc comment) and `managerUuids` (and its doc comment). In `person_service.dart` delete `migrateManagerUuids`, `groupByManager`, `subtreeUuids`, and in `delete` everything about `reports`, leaving:

```dart
  Future<void> delete(int id) async {
    final row = await _isar.persons.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() => _isar.persons.put(row));
    notifyListeners();
  }
```

In `main.dart` delete `await PersonService.instance.migrateManagerUuids();` (and the `person_service.dart` import if unused). Then run `dart run build_runner build --delete-conflicting-outputs`.

- [ ] **Step 4: Rebuild the form.** In `person_form_screen.dart`:
  - Remove `_roleCtrl` (field, init, dispose, the Cargo `TextFormField` and its `SizedBox`), `_managers`, `_pickManagers`, the "Reporta a" `ListTile`, `_ManagerPickerDialog` and its state class, and the `widgets/person_picker.dart` import if nothing else uses it. Keep `_allPeople` / `_loadingPeople`, because the chefe check needs everyone. `_loadPeople` becomes:

```dart
  Future<void> _loadPeople() async {
    final all = await PersonService.instance.all();
    if (!mounted) return;
    setState(() {
      _allPeople = all;
      _loadingPeople = false;
    });
  }
```

  - Add `import '../models/teams.dart';`, plus state initialised in `initState` from `widget.existing`:

```dart
  String? _team; // Team.id, null = Sem equipa
  ChefeSlot? _chefe; // null = Membro
```

```dart
    _team = teamById(e?.team)?.id;
    _chefe = e == null ? null : chefeSlotOf(e);
```

  - Where the Cargo field was (after Nome completo), add:

```dart
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _team,
                decoration: const InputDecoration(
                  labelText: 'Equipa',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final t in teams)
                    DropdownMenuItem(value: t.id, child: Text(t.name)),
                  const DropdownMenuItem(value: null, child: Text('Sem equipa')),
                ],
                onChanged: (v) => setState(() {
                  _team = v;
                  _chefe = null;
                }),
              ),
              if (teamById(_team) case final team?) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<ChefeSlot?>(
                  key: ValueKey(team.id),
                  initialValue: _chefe,
                  decoration: const InputDecoration(
                    labelText: 'Função na equipa',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Membro')),
                    for (final s in team.chefeSlots)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (v) => setState(() => _chefe = v),
                ),
              ],
```

  (`initialValue` is `DropdownButtonFormField`'s current name for the starting value on this Flutter (3.47). The `ValueKey(team.id)` rebuilds the Função field when the team changes, so its `Membro` reset shows.)

  - In `_save()`, replace the `role`/`managerUuids` lines. Right after `if (!_formKey.currentState!.validate()) return;`, before `setState(() => _saving = true)`, add the replace prompt:

```dart
    final person = widget.existing ?? (Person()..createdAt = DateTime.now());
    if (_team != null && _chefe != null) {
      final holder = chefeHolder(_allPeople, _team!, _chefe!, except: person);
      if (holder != null) {
        final team = teamById(_team)!;
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(
              '${holder.fullName} é ${_chefe!.label} de ${team.name}. '
              'Substituir?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Substituir'),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
    }
```

  Then remove the old `final person = …` line further down so it isn't declared twice, and set:

```dart
    person.team = _team;
    person.chefe = _chefe?.name;
```

  - Disable the save button while people are loading, so the replace check never runs on an empty list: `onPressed: _saving || _loadingPeople ? null : _save,`.
  - Update the class doc comment: "identity fields plus team and chefe role, and a profile picture".

- [ ] **Step 5: Verify**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test`
Then: `grep -rnE 'managerUuid|groupByManager|subtreeUuids|migrateManagerUuids|\.role\b|_roleCtrl|Reporta a' lib --include=*.dart | grep -v '\.g\.dart'`
Expected: 3 old infos; all tests pass; grep prints nothing.

---

### Task 6: Docs

**Files:**
- Modify: `CLAUDE.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: `CLAUDE.md`.**
  - Line 9: "the team's people and teams" → "the store's people, grouped into fixed teams with chefes".
  - Startup sequence (line ~74): drop ", then `PersonService.instance.migrateManagerUuids()`", so it reads "`SettingsService.instance.init()`, then `ShiftService.init()`."
  - Under Architecture, after the backup_service bullet, add:

```markdown
- People belong to one of the fixed teams in `lib/models/teams.dart` (`Person.team` stores the
  `Team.id`; null or unknown = "Sem equipa"). `Person.chefe` stores a `ChefeSlot.name`; read it
  through `chefeSlotOf`, which ignores slots the team doesn't have. `PersonService.save` keeps
  one holder per (team, slot) by clearing the previous holder in the same transaction.
```

- [ ] **Step 2: `CHANGELOG.md`.** Insert above `## [0.31.1]`:

```markdown
## [0.32.0] — 2026-10-07

### Added
- Premade teams for people (Livre Serviço, Gerência, Charcutaria, Meal Solutions, Talho,
  Peixaria, Frente de Loja, BemEstar, Padaria), each with a chefe; Livre Serviço has a chefe de
  dia and a chefe de noite. Pessoas is grouped by team, chefes first.

### Removed
- The cargo (job title) field, manager links ("Reporta a") and the manager-grouped Equipas view.
  Existing people start in "Sem equipa".
```

---

### Task 7: Release commit

- [ ] **Step 1: Bump** `pubspec.yaml` `version: 0.31.1+85` → `version: 0.32.0+86`.
- [ ] **Step 2: Final check:** `flutter analyze` (3 old infos), `flutter test` (all pass), `git status` (only intended files, including this plan).
- [ ] **Step 3: Commit and tag**

```bash
git add -A lib test CHANGELOG.md CLAUDE.md pubspec.yaml docs/superpowers/plans/2026-10-07-premade-teams.md
git commit -m "feat: premade teams with chefes replace cargo and managers"
git tag -a v0.32.0 -m "v0.32.0"
```

(Commit body ends with the `Co-Authored-By` line the session asks for.)
