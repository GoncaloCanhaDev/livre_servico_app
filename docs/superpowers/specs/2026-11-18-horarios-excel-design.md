# Horários from Excel — design

Date: 2026-11-18

## Intent

The supervisor builds each month's schedule in Excel (one file per month, e.g.
`LS_2027_01.xlsx`). Today the app only knows each person's fixed folgas and fixed
entrada/saída, so "A trabalhar agora", the task picker and the folga tags are often wrong.
The app should take that Excel file **as it is** (no conversion to JSON, unlike the
horários removed in 0.61.0) and know, for every person and every day, whether they work and
from when to when, and let the store see the schedule.

## Goals

- Import a month straight from the `.xlsx` file (phone and web), by level 3 and up and the
  admin.
- Read the codes' hours from the same file, so a new code in Excel just works.
- Every member of the store sees the schedule; nobody outside it does.
- Views: Hoje / Amanhã, A semana, O mês, and "Os meus próximos dias".
- The existing places (A trabalhar agora, task picker, Pessoas' "Hoje · 08:00–15:00",
  folga/férias tags, Hoje card counts) use the schedule on the days it covers.

## Non-goals

- Editing the schedule in the app. Excel stays the source; a change means a new import.
- Pausas (only entrada and saída are read).
- The Excel's own checks (✅/⚠️ column), the Resumo rows, Abertura/Intermédio/Fecho counts.
- Exporting back to Excel.

## Anti-goals

- Making people convert or retype the file. If the file opens in Excel and looks right, the
  import must work.
- Silently attaching a line to the wrong person.
- Showing the schedule to anyone outside the store.

## The file (as seen in `LS_2027_01.xlsx`)

**Sheet "Plano"** (the first sheet; find it by name "Plano", fall back to the first sheet):

- `A1`: the month, as text ("Janeiro 2027") or a date. Use it for the month; if unreadable,
  fall back to the date in `AL2` (first day of the month, an Excel serial) or the file name
  (`LS_YYYY_MM`).
- Row 2: headers. `C2:AK2` are day columns: a formula produces "Q\n31", "S\n01"... (weekday
  letter + day). The first column is the last day of the previous month and the last few are
  the first days of the next month. Derive each column's date from the month (column C =
  day 1 − 1, then one per column), not from the header text; use the header's day number only
  as a sanity check.
- Column A holds group rows: `0129 Livre Serviço` (section), `Dia`, `Noite`, `Resumo`.
  People rows have column A empty and the name in column B. Stop at `Resumo`.
- Each person row: one code per day column. Column `AL` (the check) is ignored.
- Cells may be shared strings or inline values; codes like `0711` may be stored as numbers
  (keep them as 4-digit text, as the sheet's own `TEXT(cod,"0000")` does).

**Sheet "Horário"** (the codes): columns `A` code, `B` Entrada, `E` Saída (times as day
fractions or `hh:mm:ss`). About 15,400 rows; the same code can appear twice (identical).
Only the codes the Plano uses need to be kept. Pausa columns `C`/`D` are ignored. The
"Códigos usados" block `G:K` is a formula helper; don't depend on it.

**Off codes** (not in the Horário sheet):

| Code | Meaning shown |
|---|---|
| `FO`, `.FO` | Folga |
| `F` | Férias |
| `A` | Ausência |
| `LP` | Licença parental |
| `DC`, `DO`, `LIBR`, any other code not found in Horário | off, labelled with the code itself |

An empty cell means "nothing planned": fall back to the person's fixed folgas/hours.

A shift whose saída is earlier than its entrada (e.g. `W82` 22:00–07:00) ends the next
morning and belongs to the day it starts on, which matches the app's 05:00–05:00 service
day.

## Decided with the user

- Read only the Plano for people/days/codes; read codes' entrada/saída from the Horário sheet
  of the same file; no pausa.
- Everyone in the store sees the whole schedule (looser than today's rule for folgas and
  ausências, which only the person and level 3+ reaching them see). The Política de
  Privacidade must say so: update the text and `privacyPolicyVersion`.
- Import: level 3 and up, and the admin.
- Views: Hoje/Amanhã, A semana, O mês, Os meus próximos dias.
- `.FO` is a Folga like `FO`; DC/DO/LIBR need no special meaning.

## Builder's calls (made by Claude, open to the user's veto)

- **Matching lines to people.** By name: compare names folded (case, accents, extra spaces;
  `lib/models/fold_text.dart` / `names.dart` may already help) against the store's people,
  any team. The import shows a preview: each Excel name → matched person, or "Sem
  correspondência" with a picker to choose a person or skip. Remember manual choices (keyed
  by the folded Excel name) so the next month matches on its own. Never guess on an
  ambiguous match: ask.
- **Preview before saving.** Month, number of people matched, unmatched names, codes with no
  hours found. "Importar" saves; re-importing a month replaces that month only.
- **Storage.** A new synced collection (e.g. `HorarioMes`, registered in
  `LocalDb.collections`, `syncKey` by month so two devices share one row) holding the month,
  who imported it and when, and per person (`syncUuid`) the code, entrada and saída (minutes
  after midnight) for each date, plus the Excel name and Dia/Noite group. Self-contained: the
  code table is not stored separately. Store the dates of all columns (including the spill
  days of the previous/next month); when two months overlap on a day, the month that day
  belongs to wins.
- **Visibility online.** Other collections in `records` are readable by every approved
  member already, so no new SQL policy is needed; check that `push_records` doesn't need a
  level check for this collection (the app-side gate is level 3+; a server check like
  inventories' is nice-to-have, decide by looking at how `canPlanInventories` is enforced).
- **Who's off / on shift.** The schedule slots into the existing helpers in this order: an
  app ausência wins, then the schedule's day, then the fixed folgas/`shiftStart`/`shiftEnd`.
  A person's own `shiftStart`/`shiftEnd` no longer overrides a scheduled day (the old feature
  did, for horário de amamentação; drop that unless the user says otherwise). Pass the
  schedule into `offLabelOn` / `awayTagOn` / `offNoteOn` / `shiftSpanOn` / `onShiftAt` /
  `shiftCountsOn` / `buildPeopleSections` the way the old `horario:` parameter did (see
  v0.60.0's `HorarioIndex`), keeping them pure and testable.
- **Parsing.** In Dart, from the `.xlsx` bytes with `archive` (unzip) and `xml` (both already
  in `pubspec.lock`; add them as direct dependencies). No dart:io, so it works on the web.
  Parse sheet2's ~3.5 MB XML in an isolate (`compute`), as `LocalDb` does for big decodes.
  Pure function `parseScheduleXlsx(bytes) → ParsedMonth` in `lib/models/` with unit tests on
  a small fixture xlsx made for the test (not the real file: it has real names).
- **Where it lives.** A new `Horários` destination (Home button and side menu) with tabs
  Hoje · Semana · Mês (`ResponsiveTabs`); "Amanhã" is an arrow/toggle on Hoje. The import
  button in its app bar, shown only with `canImportHorarios` (level ≥ 3 or admin). "Os meus
  próximos dias" as a small card on Home for an account linked to a person who has a
  schedule (next 7 days), and the same list on the person's own page.
- **Colours.** Per code type from the hours, with theme helpers (no hard-coded greys):
  Abertura (entrada before 09:00), Intermédio (09:00–11:59), Fecho (12:00–19:59), Noite
  (20:00 or later), off (muted). Thresholds are a guess from the sheet's own Tipo column;
  tune to match it.
- **Demo.** `seedDemo` gets a generated current month for the invented people.
- **Tutorial / Novidades / Versioning.** A new tutorial section (`horarios`, version 1), a
  `releaseNotes` entry, a MINOR bump, CHANGELOG, CLAUDE.md's "There are no horários"
  paragraph rewritten.
- **Backups.** The collection rides along in the backup JSON like any other.

## Left to the builder

Screen layout details, widget split, names of classes and files, test fixtures, how the
week grid fits on a phone, error messages' exact wording (Portuguese, plain).
