# Horário changes in the app — design

Date: 2026-11-18. Builds on `2026-11-18-horarios-excel-design.md` (v0.90.0).

## Intent

The horário comes from the month's Excel file, but the day doesn't always go as planned:
someone calls in sick, someone is called in on a folga, two people swap, a folga moves. The
supervisor (and anyone above) fixes the horário right in the app, on the spot. The Excel file
is not updated afterwards, so the app's changes must outlive a re-import, unless the person
importing chooses otherwise.

## Goals

- Level 3 and up, and the admin (the same as import: `canImportHorarios`), change any linked
  person's day: put a shift code or an off code, swap two people's days, undo a change.
- Changes win over the imported file, are visible to the whole store, and are marked as
  changed (who, when, what the file said).
- Re-importing a month lists the changes still different from the new file; the importer
  chooses which to keep.

## Non-goals

- Writing back to the Excel file.
- Telling the affected person (no aviso; the supervisor tells them).
- Editing lines not linked to a person (fix the link by re-importing).
- A history of every change: only the current change per person and day is kept.

## Anti-goals

- A re-import silently wiping changes, or silently keeping them.
- Two devices editing different days and one losing the other's change.

## Decided with the user

- Who: Chefe de Secção and up, plus the admin.
- Days are changed by **code** (as in the Excel), not by hours or shift names.
- Sick = `A` (Ausência) for now. Off codes stay `FO`, `.FO`, `F`, `A`, `LP`.
- Changes survive a re-import, but the import asks, change by change, whether to keep them.
- No notification to the person.

## Builder's calls (made by Claude, open to the user's veto)

- **Storage.** A new synced collection `HorarioAlteracao`, one row per person and day
  (`syncKey`: `'<personId>/<yyyy-mm-dd>'`, so two devices share one row and different days
  never collide). Fields: `date`, `personId` (the person's `syncUuid`), `code`, `entrada` /
  `saida` (the code's hours when it is a shift, so the row is self-contained), `fileCode`
  (what the file said when changed, '' if nothing), `changedBy` (name), `changedAt`. Undo =
  soft delete. Not inside `HorarioMes`, so a re-import never touches them and edits on
  different days merge.
- **Reading.** `HorarioIndex` takes the changes too; `dayOf(person, day)` returns the change
  when there is one (even on a day no month covers), else the file. `HorarioDia` gains
  `changed` (the `HorarioAlteracao`, or null) so screens can mark it. Everything that reads the
  horário today (A trabalhar agora, picker, Pessoas, tags, Próximos dias) follows changes for
  free.
- **Picking a code.** A bottom sheet on the person's day: the file's code and the current one;
  chips with the month's codes, most used first, each with its hours ("G82 · 06:00–15:00"); the
  off codes (FO Folga, F Férias, A Ausência, LP Licença parental); "Outro código" to type one.
  A typed code the month doesn't know asks once for entrada and saída (kept on that change
  row). "Trocar com…" picks another person on the same day and swaps their two days (two
  change rows, saved together). "Repor o do ficheiro" when the day is changed.
- **Where.** Tap a person's row in Dia, or a cell in Semana and Mês, when allowed. A changed
  day shows a small orange corner (grids) or an "alterado" tag (Dia); for everyone, tapping a
  changed day shows "Alterado por Gonçalo a 12/1 · no ficheiro: FO".
- **Re-import.** `HorarioImportScreen` lists the month's changes whose code differs from the
  new file's that day ("Ana Lopes · 12/1 · ficheiro G82 → app FO · por Gonçalo"), each with a
  "Manter" switch, on by default; a "Manter todas / Nenhuma" toggle. Changes now equal to the
  file are dropped silently (the file caught up). On Importar, the switched-off ones are soft
  deleted. `fileCode` of kept changes is updated to the new file's code.
- **Demo.** One or two changes in the seeded month (someone off sick today, someone called in
  on a folga).
- **Tutorial / Novidades / version.** Horários section version 2 with a step on changing a day;
  `releaseNotes` entry; MINOR bump (0.91.0); CHANGELOG; CLAUDE.md's horários paragraph.
- **Server.** No migration: `records` takes any collection; the gate is app-side like the import.

## Left to the builder

Sheet layout, exact wording (Portuguese, plain), how the changed marker looks in dark mode,
class and file names beyond the collection name.
