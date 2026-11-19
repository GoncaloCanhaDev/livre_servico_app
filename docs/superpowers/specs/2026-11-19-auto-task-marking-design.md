# Tarefas marcadas sozinhas (auto-marking from the horário)

## Why

Tasks are ticked by hand, choosing who did them. The app already knows who works when
(horário, profile, ausências). After a task's time window closes, the app marks it done by the
Livre Serviço people who were working during it. Supervisores and above check those marks and
fix them (Não feita, or other people). People can still mark by hand at any time.

## Goals

- Every task with a window gets marked done by itself after the window closes, unless someone
  marked it (feita or não feita) first.
- Credit goes to the Livre Serviço people working during the window.
- Level 2 and up confirm or correct an automatic mark.
- Chefes (level 3+) edit the windows; every phone of the store uses the same ones.
- Tasks with a number can be marked (by hand or automatically) with the number left empty, to
  fill in later.

## Non-goals

- Other teams (only Livre Serviço for now).
- Background work or phone notifications: marking happens when the app is open.
- Listas (Abertura, Automáticas, Visível): the Lista Visível already ticks itself from the
  Visível, the Lista Automática is never pending.
- One-off custom tasks: never marked automatically.

## Anti-goals

- A task marked with nobody: when no Livre Serviço person worked during the window (no
  horário, everyone off), it stays pending as now.
- An automatic mark overwriting a manual one, on this phone or another.
- An automatic mark that looks like a manual one: it is always labelled until confirmed.

## Approaches

1. **Picked: keep automatic marks in the existing rows.** The automatic mark sets the same done
   flag and names a manual tick sets (`DailyTasks`, `WeeklyTasks`, `CustomTaskEntry`), plus an
   `AutoMark` note per task. Tarefas, Histórico, Hoje and `pendingDailyTasks` keep working;
   they only add a label. Risk: a day row syncs whole, so the runner only writes after a sync
   finished (below).
2. Rejected: a separate row per task per day. No clashes between tasks, but every reader of
   tasks would merge two sources (a big rewrite for a rare clash).

Windows: **picked a new synced collection** (`TaskWindow`, one row per task). Rejected:
`SettingsService` prefs (they don't sync, so each phone would differ).

## Windows

`TaskWindow` (`lib/models/task_window.dart`, registered in `LocalDb.collections`, `syncKey` =
`taskKey`, no server change: `push_records` accepts any collection):

- `taskKey` (the existing keys: `kiwi_abertura`, `alteracoes_preco`,
  `verificacao_temperaturas`, `preenchimento_quadro`, `verificacao_validades`,
  `validades_noite`, `kiwi_fecho`, `limpeza_maquina_voltas`, `verificar_1a`, `verificar_4a`;
  a custom task's `syncUuid`)
- `opensAt`, `closesAt`: minutes after midnight, inside the service day (05:00–05:00); a
  close at 05:00 means the end of the service day.
- `auto`: whether the task is marked automatically (default true).

With no row, the defaults in code (`defaultTaskWindows`):

| Task | Window |
|---|---|
| Kiwi Abertura | 05:00–09:00 |
| Alterações de Preço | 05:00–07:30 |
| Verificação de Temperaturas | 05:00–12:00 |
| Preenchimento do Quadro | 05:00–14:00 |
| Validades · Manhã | 05:00–14:00 |
| Validades · Noite | 19:00–05:00 |
| Kiwi Fecho | 19:00–22:00 |
| Limpeza da Máquina Voltas | Saturday, 05:00–05:00 |
| Verificar 1ª / 4ª | Tuesday, 05:00–05:00 |
| Custom daily | 05:00–05:00 |
| Custom weekly | the whole service week (hours not editable) |

The weekly tasks' days stay fixed; only their hours are editable. The Validades windows replace
the fixed hours in `ValidadesTurno` (`validadesStateAt` and the "Abre às / Aberta até" notes
take the window).

Editing: Definições → "Horas das tarefas", shown when `StoreAccess.canEditTaskWindows`
(admin or level 3+, app-side only like the other checks). One line per task: name, the two
times (time pickers), the auto switch, and "Repor" back to the default (soft-deletes the row).
A change applies to windows that haven't closed yet; marks already made stay.

## Who is credited

`autoMarkPeople(window span, people, horario)` (pure, in `lib/models/auto_mark.dart`): every
Person with `teamOf(p) == livreServicoId` whose working span (`shiftSpanOn` over the day before
and the day, skipping days `offLabelOn` says they're off, with `horario:
HorarioService.instance.index`) overlaps the window by at least one minute. Names are
`fullName`, earliest shift start first, then by name. Empty → no mark.

## The runner

`AutoMarkService` (singleton, like the other services):

- `run(now)`: for each service day from `max(today − 7 days, autoMarkSince)` up to today, each
  task whose window closed before `now`, whose `auto` is on, and that has no done flag and no
  `notDone`: set the done flag, its names, and `autoMarks[key] = AutoMark(at: now)`. All of a
  day's marks go in one save (one `LocalDb.transaction`). No WhatsApp message.
- `autoMarkSince`: a device pref set to today's service day on the first run, so history from
  before this version is never filled in.
- When: after `HorarioService.load` at startup, when the app comes back to the foreground, and
  every minute while open. While a store is connected, only after `SyncService` finished a sync
  in this session and again after each sync, so a phone with stale rows doesn't overwrite marks
  it hasn't pulled yet. Signed out (or in the demo): straight away.
- Two phones writing the same automatic mark agree (same people, same flag), so a clash between
  them loses nothing.

## The automatic mark

`AutoMark` (`lib/models/auto_mark.dart`, like `NotDone`): `at`, `confirmedByNames`,
`confirmedAt`. Kept as `DailyTasks.autoMarks` / `WeeklyTasks.autoMarks` (map by task key) and
`CustomTaskEntry.autoMark`, in `toJson`/`fromJson`.

In Tarefas (and Home's Diárias panel) an automatically marked task shows its names and an orange
"Automática · por confirmar" tag; once confirmed, a muted "Automática · confirmada por X". For
`StoreAccess.canConfirmTasks` (admin or level 2+):

- **Confirmar**: sets `confirmedByNames` (the linked person's name) and `confirmedAt`.
- **Alterar quem fez**: the people picker, preselected with the current names; saving makes it
  a manual mark (the `AutoMark` is removed).
- **Não feita**: the usual Não feita flow (reason); the done flag and `AutoMark` are cleared.

Manual marks stay as they are now (can't be undone). Histórico shows the same tag. Home shows
level 2+ a line "N tarefas automáticas por confirmar" (last 7 days) opening Tarefas.

## Numbers left empty

Counted tasks (Alterações de Preço, Validades Manhã/Noite with their artigos left, Verificar
1ª/4ª, custom count tasks) can be done without a number:

- A new `pendingCounts` list of task keys on `DailyTasks` / `WeeklyTasks` (custom: `count`
  null). An automatic mark adds its key; a manual mark with the number field empty does too.
- The task shows "Número por preencher" and a field to fill it in later (anyone); filling it
  removes the key.
- Validades: the "artigos que ficaram" question is skipped by an automatic mark (it stays
  pending too); filled in later, it carries to the next window as now, unless that window was
  already marked.

## Elsewhere

- Demo: `seedDemo` gets a few automatic marks, one confirmed, one with a number to fill in.
- Tutorial: Tarefas section updated, its `version` raised; Definições step mentions the hours.
- `releaseNotes` entry; version bump (MINOR); CHANGELOG; CLAUDE.md section on auto-marking.
- No new personal data, so the Política de Privacidade doesn't change.

## Tests

- `autoMarkPeople`: overlap, night shifts from the day before, folga/ausência, other teams,
  nobody.
- `AutoMarkService.run`: marks after close only, skips manual/não feita, `auto` off,
  `autoMarkSince`, catch-up over several days, weekly due day, custom daily/weekly, one-off
  never.
- `TaskWindow` defaults and editing; `validadesStateAt` with edited windows.
- Widget: Tarefas shows the tag, Confirmar / Alterar / Não feita for level 2, not for level 1;
  filling in a pending number.
- `local_db_test` round-trips the new fields.

## Follow-up (0.95.1): the three limits

- Only phones that see Livre Serviço's whole schedule create automatic marks
  (`StoreAccess.canAutoMark`: admin or signed out, level 4+, level 3 of Livre Serviço), since
  shifts, folgas and ausências are personal and redacted for others.
- Per-task "pings": each mark and correction carries its time (`TaskStamp`, a custom entry's
  `doneAt` / `editedAt`), in server time (`ServerClock`: the phone's clock plus the offset
  measured with `server_now` at each sync, kept for offline). When two copies of a day meet,
  sync merges task by task (marked beats unmarked; the latest correction; by hand beats the
  app; the earliest mark), the same on every phone, and sends the result back. Offline marks
  keep their time and are compared when the phone is back online.
- The first run marks no window that closed before it (`autoMarkSince` is a moment).

## Left to the builder

- Exact layout of the windows screen and the tag (follow `context` colour helpers, both widths).
- Splitting `daily_tasks_tab.dart` further if the new actions make it too long.
