# Horários from Excel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Import a month's schedule straight from the store's `.xlsx` file and use it for who works when, with Dia/Semana/Mês views and a "next days" card.

**Architecture:** A pure parser (`archive` + `xml`) turns the file into a `HorarioMes` row (a new synced collection, one per month, self-contained: the codes used and their entrada/saída travel with it). A `HorarioIndex` built from the loaded months answers "what is this person doing on this day"; the existing pure helpers in `planning.dart` / `today.dart` / `people_sections.dart` take it as an optional `horario:` argument (ausência in the app > horário > fixed folgas/hours). `HorarioService` keeps the months and the index; the screens read it.

**Tech Stack:** Flutter, Drift-backed `LocalDb` (JSON rows), `archive`, `xml`, `file_picker`.

**Spec:** `docs/superpowers/specs/2026-11-18-horarios-excel-design.md`

## Global Constraints

- No dart:io / path_provider (must build for the web). Parse from bytes.
- UI strings in Portuguese (pt_PT). Theme helpers for colours (`context.muted`, `tint(...)`…), no hard-coded greys; app-bar tabs through `appBarTabs`.
- Lay out for phone and computer widths; respect the bottom safe area.
- Saves through `SyncMeta.stamp`, deletes through `softDelete`; never rename a stored JSON field.
- Import allowed for `admin || level >= 3` (app-side only, like `canPlanInventories`); every store member sees schedules.
- Only entrada and saída are read; pausa is ignored.
- Off codes: `FO`, `.FO` → "Folga"; `F` → "Férias"; `A` → "Ausência"; `LP` → "Licença parental"; any other code not in the Horário sheet → off, labelled with the code itself. Empty cell → no information (fall back to the person's fixed folgas/hours).
- Precedence on a day: app ausência > horário > fixed `folgas` / `shiftStart`/`shiftEnd`. A person's own shiftStart/shiftEnd does **not** override a scheduled shift.
- Test fixtures are generated in the test, never the real file (it has real names).
- Versioning: the whole feature is **one commit**, version `0.90.0+219` (MINOR bump; every commit here is a version, so intermediate tasks end with a green `flutter analyze` + tests, not a commit). Tests with `flutter test -j 2`.

## Review Focus

1. A code stored as a number in the sheet (`0711` saved as `711`, or a time as a day fraction instead of `"07:00:00"` text) — it must still be found and read as `07:00`.
2. The Plano not being `sheet1.xml` (sheets reordered) — resolve "Plano" / "Horário" by name through `workbook.xml` + its rels.
3. Spill days (31/12 in January's file, 01–03/02) overlapping the neighbouring month's own import — the month a day belongs to wins, whichever was imported last.
4. Re-importing the same month after people were renamed or one Excel name now matches two people — never attach silently; ask.
5. A night shift (`W82` 22:00–07:00) seen at 03:00 the next morning — "A trabalhar agora" must still list the person (from the previous day's code).

---

### Task 1: Parse the xlsx

**Files:**
- Modify: `pubspec.yaml` (add `archive` and `xml` as direct deps, versions already in `pubspec.lock`)
- Create: `lib/models/horario_xlsx.dart`
- Create: `test/helpers/xlsx_fixture.dart`
- Test: `test/horario_xlsx_test.dart`

**Interfaces:**
- Produces:
  - `class ParsedHorario { DateTime month /* day 1 */; DateTime firstDay /* date of the first day column */; Map<String, ({int entrada, int saida})> codigos /* only codes used in the Plano, minutes after midnight */; List<ParsedLinha> linhas; Set<String> semHorario /* codes used, not in Horário, not a known off code */; }`
  - `class ParsedLinha { String nome; String grupo /* 'Dia' | 'Noite' | '' */; List<String> codigos /* one per day column, '' for empty, normalized */; }`
  - `ParsedHorario parseHorarioXlsx(Uint8List bytes)` — throws `FormatException` with a Portuguese message ("Não é um ficheiro Excel (.xlsx).", "Falta a folha Plano.", "Não foi possível ler o mês em A1.", "Os dias da linha 2 não batem com o mês.").
  - `String normalizeHorarioCode(String raw)` — trim, uppercase; all-digit codes shorter than 4 left-padded with `0`.
  - `const horarioOffCodes = {'FO': 'Folga', '.FO': 'Folga', 'F': 'Férias', 'A': 'Ausência', 'LP': 'Licença parental'};`
  - `const ignoredOffCodes = {'DC', 'DO', 'LIBR'};` — off, labelled with the code, never listed in `semHorario`.
  - `buildXlsx({required List<List<Object?>> plano, required List<List<Object?>> horario, bool horarioFirst = false, bool inlineStrings = false}) → Uint8List` in the test helper (rows of cells from A1; `String` → shared string or inline string, `num` → number cell).

- [ ] **Step 1: Write the failing tests** in `test/horario_xlsx_test.dart`, using a fixture shaped like the real file: A1 `'Janeiro 2027'`, row 2 `['Secção / Nº Colaborador', 'Nome Colaborador', 'Q\n31', 'S\n01', 'S\n02', 'D\n03']`, A3 `'0129 Livre Serviço'`, A4 `'Dia'`, row 5 `[null, 'Ana Lopes', 'G82', 'FO', 711, '']`, A6 `'Noite'`, row 7 `[null, 'Rui Sá', 'W82', '.FO', 'LIBR', 'XYZ']`, A8 `'Resumo'`, row 9 `['Abertura:', null, 2, 0]`; Horário rows `['Código','Entrada','Pausa','','Saída']`, `['G82','06:00:00','10:00:00','11:00:00','15:00:00']`, `['W82', 22/24, 0, 0, 7/24]`, `['0711','07:00:00','00:00:00','00:00:00','11:00:00']`, `['0711','07:00:00','00:00:00','00:00:00','11:00:00']`.
  - `reads month and first day`: `month == DateTime(2027,1,1)`, `firstDay == DateTime(2026,12,31)`.
  - `reads people, groups and codes, stopping at Resumo`: two linhas; `linhas[0].nome == 'Ana Lopes'`, `grupo == 'Dia'`, `codigos == ['G82','FO','0711','']`; `linhas[1].grupo == 'Noite'`.
  - `reads entrada and saida from text or day fractions`: `codigos['G82'] == (entrada: 360, saida: 900)`, `codigos['W82'] == (entrada: 1320, saida: 420)`, `codigos['0711'] == (entrada: 420, saida: 660)`; `codigos` has no key `'FO'`.
  - `lists codes without hours`: `semHorario == {'XYZ'}` (`LIBR` is in `ignoredOffCodes`, so it is not warned about).
  - `finds sheets by name, not position` (`horarioFirst: true`) and `reads inline strings` (`inlineStrings: true`): same results.
  - `month from a date serial in A1`: A1 `46388` → `month == DateTime(2027,1,1)`.
  - `rejects a non-xlsx` (`Uint8List.fromList([1,2,3])`) and `rejects day headers that don't match the month` (row 2 starting `'Q\n30'`): `throwsFormatException`.

- [ ] **Step 2: Run** `flutter test test/horario_xlsx_test.dart` — FAIL (file/functions missing).

- [ ] **Step 3: Implement** `lib/models/horario_xlsx.dart`. Unzip with `ZipDecoder`; resolve sheet paths via `xl/workbook.xml` (`<sheet name r:id>`) and `xl/_rels/workbook.xml.rels`; read `xl/sharedStrings.xml` (concatenate every `<t>` in an `<si>`). Cell types: `t="s"` shared, `t="inlineStr"` `<is><t>`, `t="str"`/`t="b"`/none → `<v>` text. Times: a number is a day fraction (`round(x*1440) % 1440`, but keep 1440 as-is for 24:00), text `H:MM[:SS]`. Month from A1: Portuguese month name + year (fold accents), or a number = Excel serial (epoch 1899-12-30), else fall back to `AL2`-style serial found in row 2 beyond the day columns. Day columns: consecutive cells from C in row 2 whose text matches `^[A-Za-z]\s*(\d{1,2})$`; `firstDay = month − 1 day`; check each column's day number against `firstDay + i`. Rows: column A text `Dia`/`Noite` sets the group, `Resumo` stops, other A text is ignored; a row with empty A and non-empty B is a person. Only keep `codigos` for codes the Plano uses (first occurrence wins).

- [ ] **Step 4: Run** `flutter test test/horario_xlsx_test.dart` — PASS. Also check the real file by hand once: a throwaway test reading `'/home/goncalo/Pingo Doce/Horários/2027/LS_2027_01.xlsx'` (skip if missing; do not commit it): 18 linhas, 35 day columns, `semHorario` empty.

---

### Task 2: The stored month and the index

**Files:**
- Create: `lib/models/horario.dart`
- Modify: `lib/services/local_db.dart` (new collection `horarioMeses`, registered in `collections`)
- Test: `test/horario_test.dart`

**Interfaces:**
- Consumes: `ParsedHorario`, `horarioOffCodes`, `normalizeHorarioCode` (Task 1).
- Produces:
  - `class HorarioMes with SyncFields` — JSON fields: `month` (date), `firstDay` (date), `codigos` (`{code: {"entrada": int, "saida": int}}`), `linhas` (list of `{nome, grupo, personId?, codigos: [String]}` → `HorarioLinha`), `importedAt` (date), `importedBy` (String). `LocalDb.instance.horarioMeses = LocalCollection<HorarioMes>._('HorarioMes', HorarioMes.fromJson, syncKey: (m) => monthKey(m.month))`.
  - `String monthKey(DateTime d)` → `'2027-01'`.
  - `class HorarioDia { final DateTime date; final String code; final int? entrada; final int? saida; final String? offLabel; bool get isShift => entrada != null; ({DateTime start, DateTime end}) spanOn() /* saída ≤ entrada → next day */; HorarioTipo get tipo; String get text /* '08:00–15:00' or offLabel */; }`
  - `enum HorarioTipo { abertura, intermedio, fecho, noite, folga, ausente }` — from entrada: `< 05:00` or `>= 20:00` noite, `< 09:00` abertura, `< 12:00` intermedio, else fecho; off codes: `Folga` → folga, others → ausente. Labels "Abertura", "Intermédio", "Fecho", "Noite".
  - `class HorarioIndex { HorarioIndex(List<HorarioMes> months); static final empty; HorarioDia? dayOf(Person p, DateTime day); DateTime? lastDayOfSameCode(Person p, DateTime day) /* end of the run of the same off code, for "até d/m" */; List<({HorarioLinha linha, HorarioDia? dia})> linesOn(DateTime day); List<HorarioDia> nextDays(Person p, DateTime from, int days); bool hasMonth(DateTime month); }` — matches by `linha.personId == p.syncUuid`. A date covered by two months: the month whose `month` has that date's month wins; a spill day is used only when no month owns it.

- [ ] **Step 1: Write the failing tests** in `test/horario_test.dart`: `HorarioMes.fromJson(m.toJson())` round-trips; `dayOf` gives `G82` as `08:00–15:00`-style text and `isShift`; `FO` → `offLabel == 'Folga'`, `tipo == folga`; `F` → `'Férias'`, `ausente`; unknown `LIBR` → `offLabel == 'LIBR'`; empty → `null`; `W82` `spanOn()` ends next day 07:00; tipo thresholds (`F82` 05:00 abertura, `J74` 09:00 intermedio, `M79` 12:00 fecho, `W82` 22:00 noite, `A78` 00:00 noite); **spill precedence**: January (with 01/02 = `FO`) and February (01/02 = `G82`) both loaded, in either order → `dayOf(p, 1 Feb) .code == 'G82'`; a spill day with no owning month is used; `lastDayOfSameCode` over `F,F,F,G82` from day 1 → day 3.

- [ ] **Step 2: Run** `flutter test test/horario_test.dart` — FAIL.

- [ ] **Step 3: Implement** `lib/models/horario.dart` and register the collection. `HorarioMes.fromParsed(ParsedHorario, Map<String, String?> personIds /* excel name → syncUuid */, String importedBy)`.

- [ ] **Step 4: Run** `flutter test test/horario_test.dart test/local_db_test.dart` — PASS.

---

### Task 3: Matching Excel names to people

**Files:**
- Modify: `lib/models/horario.dart`
- Test: `test/horario_test.dart`

**Interfaces:**
- Produces: `Map<String, Person?> matchHorarioNames(List<String> names, List<Person> people, {List<HorarioMes> previous = const []})` — for each Excel name: (1) a previous month's linha with the same folded name and a `personId` still among `people` → that person; (2) exactly one person whose folded `fullName` equals the folded name (`foldText`, spaces collapsed); (3) exactly one person whose folded `fullName` starts with the first word and ends with the last word of the folded name; otherwise `null`. Never the same person for two names (the later ones become null).

- [ ] **Step 1: Failing tests**: `'Américo David'` matches `Américo Pinto David` (first+last), `'americo  david'` matches `Américo David` (exact folded); two people `Ana Lopes` and `Ana Maria Lopes` and name `'Ana Lopes'` → exact one wins; name `'Ana Lopes'` with people `Ana Rita Lopes`, `Ana Sofia Lopes` → `null`; previous month linking `'Zé'` to Rui's uuid → Rui; same person never twice.
- [ ] **Step 2: Run** — FAIL. **Step 3: Implement.** **Step 4: Run** — PASS.

---

### Task 4: Who works when reads the horário

**Files:**
- Modify: `lib/models/planning.dart`, `lib/models/today.dart`, `lib/screens/people_sections.dart`
- Modify callers: `lib/screens/people_screen.dart`, `lib/screens/person_detail_screen.dart`, `lib/screens/widgets/person_picker.dart`, `lib/screens/widgets/today_card.dart` (pass `horario: HorarioService.instance.index`; the service comes in Task 5 — in this task callers pass nothing, so behaviour is unchanged)
- Test: `test/planning_test.dart`, `test/today_test.dart`, `test/people_sections_test.dart`

**Interfaces:**
- Consumes: `HorarioIndex`, `HorarioDia` (Task 2).
- Produces (all new parameters optional, default `null` = today's behaviour):
  - `offLabelOn(p, day, {HorarioIndex? horario})`, `awayTagOn(...)`, `offNoteOn(...)` — horário Folga: label/note `'Folga'`, tag null; other off codes: label `'<label> até d/m'`, tag `<label>`, note `'até d/m'` (d/m from `lastDayOfSameCode`).
  - `shiftSpanOn(p, day, {HorarioIndex? horario})` — a scheduled shift → its span; a scheduled off day → null; no entry → the person's own hours.
  - `onShiftAt(people, now, {HorarioIndex? horario})`, `shiftCountsOn(people, day, {HorarioIndex? horario})` (night = `HorarioTipo.noite` for scheduled days).
  - `String? shiftTextOn(Person p, DateTime day, {HorarioIndex? horario})` in `planning.dart` — `'08:00–15:00'` from the horário on that day, else `horarioText(p)`; replaces `horarioText(p)` at the callers that show "today".
  - `buildPeopleSections(..., HorarioIndex? horario)` passes it to `offLabelOn`.

- [ ] **Step 1: Failing tests**: person with fixed folga on Monday and horário `G82` that Monday → `offLabelOn(..., horario:) == null` and `shiftSpanOn` = 06:00–15:00; horário `FO` on a Tuesday with no fixed folga → `'Folga'`; app ausência over a horário shift → the ausência wins; `F,F,F` from the 4th → `offLabelOn == 'Férias até 6/1'`, `awayTagOn == 'Férias'`; **night shift**: `W82` on 4 Jan, `onShiftAt(now: 5 Jan 03:00, horario:)` lists the person; `shiftCountsOn` counts it as noite; no horário entry → unchanged behaviour (existing tests still pass).
- [ ] **Step 2: Run** `flutter test test/planning_test.dart test/today_test.dart test/people_sections_test.dart` — FAIL. **Step 3: Implement.** **Step 4: Run** — PASS.

---

### Task 5: HorarioService and the import flow

**Files:**
- Create: `lib/services/horario_service.dart`
- Create: `lib/screens/horario_import_screen.dart`
- Modify: `lib/models/store_access.dart` (`bool get canImportHorarios => admin || level >= 3;`)
- Modify: the four callers from Task 4 to pass `horario: HorarioService.instance.index` and to listen to `HorarioService` so they redraw after an import or a sync
- Test: `test/horario_service_test.dart`, `test/horario_import_screen_test.dart`, `test/store_access_test.dart`

**Interfaces:**
- Consumes: Tasks 1–4.
- Produces:
  - `class HorarioService extends ChangeNotifier` (singleton `instance`, `LocalDb.listenRemote({'HorarioMes'}, _reload)`): `HorarioIndex get index` (rebuilt on load/import/remote change; `load()` called at first use and from `main()` after `LocalDb.init()` inside the existing try/catch), `Future<List<HorarioMes>> months()` (newest first), `Future<HorarioMes?> monthOf(DateTime month)`, `Future<void> save(ParsedHorario parsed, Map<String, Person?> matches, {required String importedBy})` (soft-deletes any existing row of that month, stamps and puts the new one, notifies), `Future<void> delete(DateTime month)`.
  - `Future<ParsedHorario?> pickHorarioFile()` in the service: `FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['xlsx'])`, `readAsBytes`, `compute(parseHorarioXlsx, bytes)`.
  - `HorarioImportScreen(parsed: ParsedHorario)`: title `'Importar horário'`; header `'<Mês de AAAA> · N pessoas'`; a row per Excel name with the matched person or `'Sem correspondência'` and a tap opening the existing person picker (choose / "Ignorar esta linha"); a warning card `'Códigos sem horário: XYZ — estas pessoas aparecem como ausentes nesses dias.'` when `semHorario` isn't empty; button `'Importar'` (asks `'Substituir o horário de <mês>?'` when the month exists); `importedBy` is the linked person's name or the account email. Unmatched lines are saved with `personId: null` (shown in the grids, not used by the helpers).

- [ ] **Step 1: Failing tests**: service — `save` then `index.dayOf(...)` returns the code; saving the same month again leaves one live row; a remote row (via `applyRemote`) updates `index`. Screen — pump with a parsed fixture and two people, one name unmatched: shows `'Sem correspondência'`; tap Importar → one `HorarioMes` saved with one `personId` null. Store access — level 2 false, level 3 true, admin true.
- [ ] **Step 2: Run** — FAIL. **Step 3: Implement.** **Step 4: Run** `flutter test -j 2` — PASS.

---

### Task 6: The Horários screen (Dia · Semana · Mês)

**Files:**
- Create: `lib/screens/horarios_screen.dart` with parts `lib/screens/horarios/day.dart`, `week.dart`, `month.dart`
- Modify: `lib/screens/destinations.dart` (new `Destination(Icons.calendar_month, 'Horários', () => const HorariosScreen())` in `homeDestinations`, after Pessoas)
- Test: `test/horarios_screen_test.dart` (and `test/home_screen_test.dart` keeps passing: it opens every Home button)

**Interfaces:**
- Consumes: `HorarioService.instance` (`index`, `months`), `canImportHorarios`, `pickHorarioFile`, `HorarioImportScreen`.
- Produces: `HorariosScreen` — app bar `'Horários'`, `appBarTabs` with `Dia`, `Semana`, `Mês`; an import `IconButton(Icons.upload_file, tooltip: 'Importar horário')` only with `canImportHorarios`, which shows a `SnackBar` with the `FormatException` message on a bad file.
  - **Dia**: a date bar with ‹ › and a `'Hoje'` chip (starts on `currentServiceDay()`); groups `Dia` / `Noite` (from `linha.grupo`), each person name + `'08:00–15:00'` coloured by `HorarioTipo`, earliest first; then `'Fora'` with the off label.
  - **Semana**: Monday–Sunday table, names down the side grouped Dia/Noite, cells `'08–15'` (or `'08:30–15'`) or the off code, coloured by tipo; ‹ › moves a week; fits a phone without sideways scroll (name column ellipsized).
  - **Mês**: the whole month, horizontally scrollable with the name column fixed; month picker among imported months (‹ ›); today's column highlighted.
  - Empty state on every tab: `'Ainda não há horário para <mês>.'`, plus `'Importar horário'` button when allowed.
  - Colours: one `tint` per `HorarioTipo` through the theme helpers, light and dark.

- [ ] **Step 1: Failing tests**: with a saved month — Dia shows a person under `Noite` with `22:00–07:00` and a `FO` person under `Fora` with `'Folga'`; Semana shows seven day headers; Mês shows the first and last day of the month; level 2 → no import button; empty DB → the empty-state text.
- [ ] **Step 2: Run** — FAIL. **Step 3: Implement** (phone and ≥1100 px). **Step 4: Run** `flutter test -j 2` — PASS.

---

### Task 7: "Os meus próximos dias"

**Files:**
- Create: `lib/screens/widgets/my_horario_card.dart`
- Modify: `lib/screens/home_screen.dart` (`MyHorarioCard()` in `_cards`, before `TodayCard()`), `lib/screens/person_detail_screen.dart` (a `'Próximos dias'` section)
- Test: `test/my_horario_card_test.dart`

**Interfaces:**
- Consumes: `HorarioIndex.nextDays(p, from, 7)`, `AccountService.instance.access.personId`.
- Produces: `MyHorarioCard` — hidden unless the account is linked to a person with at least one horário day in the next 7 days; title `'Os meus próximos dias'`; one line per day `'Seg 4 · 06:00–15:00'` / `'Ter 5 · Folga'`, coloured by tipo, tap opens `HorariosScreen`. The person page shows the same list for the person viewed (all members may see it).

- [ ] **Step 1: Failing tests**: linked person with a horário → card lists 7 lines starting today; unlinked → nothing rendered.
- [ ] **Step 2–4:** run (FAIL), implement, run `flutter test -j 2` (PASS).

---

### Task 8: Demo, tutorial, privacy, docs, version — and the commit

**Files:**
- Modify: `lib/services/demo_data.dart` (seed a `HorarioMes` for the current month: Dia people rotating `F82`/`I74`/`N80` with two `FO` a week, Noite people `W82` with two `FO`; codes table with those four), `test/demo_data_test.dart` (asserts the month exists)
- Modify: `lib/screens/tutorial_screen.dart` (+ a diagram in `lib/screens/tutorial/diagrams.dart`): new section `id: 'horarios', version: 1` (Dia/Semana/Mês and Importar); raise `inicio`'s version and mention the new button
- Modify: `lib/models/privacy_policy.dart`: a paragraph saying the store's horário (shifts, folgas, férias and ausências as in the imported Excel) is visible to every member of the store; `privacyPolicyVersion = '2026-11-18'`
- Modify: `lib/models/release_notes.dart`: entry `0.90.0` — `'Horários: o chefe de secção importa o Excel do mês e todos na loja veem quem trabalha em cada dia (Dia, Semana e Mês). No Início, veja os seus próximos dias.'`
- Modify: `CLAUDE.md` (replace the "There are no horários…" paragraph with how horários work now; add the new tests to the list), `CHANGELOG.md` (0.90.0 entry), `pubspec.yaml` `version: 0.90.0+219`, `lib/app_version.dart`

- [ ] **Step 1:** Implement the above.
- [ ] **Step 2:** Run `flutter analyze` — `No issues found!`
- [ ] **Step 3:** Run `flutter test -j 2` — all pass.
- [ ] **Step 4: Commit and tag**

```bash
git add -A
git commit -m "feat: import the month's horário from the Excel file and show who works when (Dia, Semana, Mês)"
git tag -a v0.90.0 -m "v0.90.0"
```
(with the Co-Authored-By line)
