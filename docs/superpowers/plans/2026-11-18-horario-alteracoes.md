# Horário changes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Level 3+ change a person's horário day in the app (code, swap, undo); changes win over the file, are marked, and survive a re-import only when the importer keeps them.

**Architecture:** A new synced collection `HorarioAlteracao` (one row per person and day). `HorarioIndex` takes the changes and applies them in `dayOf`/`linesOn`; `HorarioDia.changed` marks them. `HorarioService` adds `change`/`swap`/`revert` and, on `save`, drops the changes the importer switched off. A pure `changesAgainstFile` lists the changes that differ from a new file.

**Tech Stack:** Flutter, `LocalDb` JSON rows.

**Spec:** `docs/superpowers/specs/2026-11-18-horario-alteracoes-design.md`

## Global Constraints

- Edit gate `StoreAccess.canEditHorarios => admin || level >= 3` (app-side only).
- Codes normalized with `normalizeHorarioCode`; off codes `horarioOffCodes`.
- Saves through `SyncMeta.stamp`, undo through `softDelete`.
- Portuguese UI; theme helpers for colours; phone and computer widths.
- One commit, version `0.91.0+220`, with CHANGELOG, `releaseNotes`, tutorial `horarios` version 2, CLAUDE.md.

## Review Focus

1. A change on a day no imported month covers (still shows in Próximos dias and A trabalhar agora).
2. Changing a day back to the file's own code — no stray change row.
3. Swap where one side has no file entry that day (empty) — the other ends up with nothing, not a crash.
4. Re-import where the new file now matches a change — dropped without asking.
5. A typed shift code the month doesn't know — hours asked once, kept on the change.

---

### Task 1: Model and index

**Files:** Create `lib/models/horario.dart` additions (`HorarioAlteracao`, `alteracaoKey`), modify `HorarioIndex`/`HorarioDia`; register `horarioAlteracoes` in `lib/services/local_db.dart` (`syncKey: (a) => alteracaoKey(a.personId, a.date)`). Test: `test/horario_test.dart`.

**Produces:**
- `class HorarioAlteracao with SyncFields { DateTime date; String personId; String code; int? entrada; int? saida; String fileCode; String changedBy; DateTime changedAt; }`
- `String alteracaoKey(String personId, DateTime date)` → `'ana/2027-01-12'` (uses `dayKey`).
- `HorarioIndex(List<HorarioMes> months, {List<HorarioAlteracao> changes = const []})`; `HorarioDia? dayOf(p, day)` (change first); `HorarioDia? fileDayOf(p, day)`; `List<HorarioAlteracao> changesIn(DateTime month)`; `linesOn` applies changes; `Map<String, int> codeUsage(DateTime month)`.
- `HorarioDia.changed` (`HorarioAlteracao?`); `HorarioDia.fromChange(HorarioAlteracao)`.
- `List<({HorarioAlteracao change, String newFileCode})> changesAgainstFile(ParsedHorario parsed, Map<String, String?> personIds, List<HorarioAlteracao> changes)` — only changes inside the file's columns for a person on it whose code differs from the new file's code.

- [ ] Tests: change wins over file and is marked; change on an uncovered day; `fileDayOf` ignores the change; `linesOn` shows the change; JSON round-trip; `changesAgainstFile` keeps differing, leaves out equal and out-of-range ones.
- [ ] Run (FAIL) → implement → run (PASS).

### Task 2: Service and access

**Files:** `lib/services/horario_service.dart`, `lib/models/store_access.dart`. Tests: `test/horario_service_test.dart`, `test/store_access_test.dart`.

**Produces:**
- `Future<void> change(Person p, DateTime day, String code, {int? entrada, int? saida, required String by})` — same as the file → removes the change.
- `Future<void> swap(Person a, Person b, DateTime day, {required String by})` — empty side becomes '' (a change with code '' = nothing that day).
- `Future<void> revert(Person p, DateTime day)`.
- `save(..., {Set<String> drop = const {}})` — drops changes whose `alteracaoKey` is in `drop` and those now equal to the file; updates `fileCode` of kept ones.
- `bool get canEditHorarios`.

- [ ] Tests for each; run (FAIL) → implement → run (PASS).

### Task 3: Screens

**Files:** `lib/screens/horarios/edit_sheet.dart` (part), `day.dart`, `week.dart`, `month.dart`, `horarios_screen.dart`, `horario_import_screen.dart`. Tests: `test/horarios_screen_test.dart`, `test/horario_import_screen_test.dart`.

- Tap a linked person's day (Dia row, Semana/Mês cell): editors get the sheet (title "Ana Lopes · ter, 12 jan"; "No ficheiro: G82 · 06:00–15:00"; code chips by usage; off chips; "Outro código"; "Trocar com…"; "Repor o do ficheiro"); others get the change info only when the day is changed.
- Changed days: orange dot in a cell's corner; "alterado" tag in Dia.
- Import screen: "Alterações feitas na app" with a "Manter" switch each (on by default) → `drop`.

- [ ] Tests: tapping a cell and a code chip saves a change and marks it; import screen lists a differing change and dropping it deletes it on Importar. Run (FAIL) → implement → run (PASS).

### Task 4: Demo, tutorial, docs, version, commit

- `seedDemo`: someone `A` today, someone on a shift on a folga.
- Tutorial `horarios` version 2 (a step on changing a day); `releaseNotes` 0.91.0; CHANGELOG; CLAUDE.md; `0.91.0+220`.
- [ ] `flutter analyze` clean, `flutter test -j 2` green, commit, tag `v0.91.0`.
