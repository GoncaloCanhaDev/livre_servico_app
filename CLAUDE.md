# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Livre Serviço Companion — a Flutter app for recording inventories (name, code, final value),
truck receptions, opening/report/visual/auto checklists, daily/weekly/custom tasks, "pedidos"
(order headers: number, supplier, expected date), and the store's people, grouped into fixed teams with chefes, used at a
single site. There is no product catalogue, no barcode scanning and no points system. UI text
and user-facing strings are in Portuguese (pt_PT locale). The app is fully offline/local: all
data lives in an on-device Isar database, there is no backend or remote sync currently wired up.
It's built for and used by a single supervisor (livre serviço / reposição team lead at a Pingo
Doce store) running it on their own phone to manage their team's checklists day to day — not a
multi-tenant product.

## Commands

- Install deps: `flutter pub get`
- Run app: `flutter run`
- Regenerate Isar model code (`*.g.dart`) after changing any `@collection` class:
  `dart run build_runner build --delete-conflicting-outputs`
- Lint/analyze: `flutter analyze`
- Tests: `flutter test` (in `test/`: mostly pure logic such as
  `lib/screens/people_sections.dart`, `lib/models/planning.dart`, `lib/models/validades.dart` and
  `lib/models/info_contacts.dart`, `lib/models/vasilhame.dart`, `lib/models/horario.dart`,
  `lib/models/today.dart`, `lib/models/historico_search.dart` and `lib/theme.dart`, plus a
  few widget tests: `test/home_screen_test.dart` opens every screen and tab from Home, and
  `test/person_form_screen_test.dart` fills in and saves the person form). Widget tests run
  against a real, empty Isar database in a temp folder: `openAppDb` / `closeAppDb` in
  `test/helpers/app_db.dart` start the services like `main()` does, loading the host
  `libisar.so` from the pub cache. A database call only completes inside `runAsync` and the
  code awaiting it only resumes on a pump, so use the helpers in `test/helpers/pump.dart`
  (`pumpApp`, `settle`, `tapAndSettle`, `dbCall`), never `pumpAndSettle`.

## Architecture

### Data layer: Isar

- `ShiftService.init()` (`lib/services/shift_service.dart`) opens the single `Isar` instance
  for the whole app, registering every collection schema. All other services obtain the
  database via `ShiftService.instance.isar` — there is one Isar instance for the app's
  lifetime. The name is historical: clock in/out shift tracking was removed and this class
  now only owns the database.
- Every persisted model lives in `lib/models/*.dart` as an `@collection` class with a generated
  `*.g.dart` counterpart. After adding/editing a model, run the build_runner command above.
- Models carry legacy sync-related fields (`syncUuid`, `syncUpdatedAt`, `syncDeletedAt`,
  `synced`). These are **not** wired to any backend anymore — a prior Supabase-based sync/auth
  layer was removed (see `lib/services/sync_meta.dart` docstring) — but the fields are kept
  because on-device data already has them and the soft-delete pattern built on top of them is
  still how deletes work: `SyncMeta.stamp(row)` on every save, `SyncMeta.softDelete(row)` on
  every delete. Reads must filter with `.syncDeletedAtIsNull()` to exclude tombstoned rows;
  `ShiftService.backfillSync()` fills in missing UUIDs on legacy rows: once at the first startup
  (then the `syncBackfilled` pref skips it) and after every backup import. Look rows up
  by an indexed field with `.where()` (then `.filter()` for the rest), not `.filter()` alone,
  which reads every row.
- `lib/services/backup_service.dart` implements manual JSON export/import (share a file /
  pick a file) and a "clear all data" wipe, independent of the sync fields above. The export is
  indented JSON with `vasilhame` and `settings` before `collections` (every Isar collection);
  import replaces only the collections and sections the file has. Add new collections there.
- People belong to one of the fixed teams in `lib/models/teams.dart` (`Person.team` stores the
  `Team.id`; null or unknown = "Sem equipa"). `Person.chefe` stores a `ChefeSlot.name`; read it
  through `chefeSlotOf`, which ignores slots the team doesn't have. `PersonService.save` keeps
  one holder per (team, slot) by clearing the previous holder in the same transaction.
  Livre Serviço is split into a day and a night turno (`Team.hasTurnos`): `Person.turno`
  stores a `Turno.name`; read it through `turnoOf`, which takes a chefe's turno from their slot
  (Chefe de dia / Chefe de noite). `Person.permanencia` is an independent tag ("Permanência":
  can stand in for management when no chefia is present). `Person.partTime` is false for full
  time ("Tempo inteiro", the default) and true for "Tempo parcial". Frente de Loja and Bem
  Estar have no chefe (empty `chefeSlots`). Besides the chefe slot, roles are combinable tags:
  Supervisor (`Team.hasSupervisors`, Frente de Loja), Segunda Linha (`Team.hasSegundaLinha`,
  the production teams) and Permanência (anyone). Read them through `isSupervisor` /
  `isSegundaLinha` (which ignore the flag outside such teams and for chefes); `roleTagsOf`
  gives the badge labels the UI shows.
- Planning data on `Person` (`folgas` weekdays, `weeklyHours`, `shiftStart`/`shiftEnd` in
  minutes after midnight, embedded `Ausencia` list) is read through the pure helpers in
  `lib/models/planning.dart`: `offLabelOn(p, day)` says why someone isn't working that day (an
  ausência beats a folga), used by Pessoas, the person page and the task picker
  (`buildPeopleSections(offDay:)` lists them last). During an ausência, `awayTagOn` gives
  the orange tag shown next to the role tags and `offNoteOn` the "até 14/10" text beside it.
  `hireDate` is the company (Pingo Doce) start; `storeStartDate` is the start at this store.
  `tenureTagOf` derives the blue "Em formação" (first month at Pingo Doce) / "Novo" / "Nova"
  (until six months; `Person.genero` picks the form) tag from `hireDate`. `isBirthdayOn` /
  `upcomingBirthdays` read `dateOfBirth` for the "🎂 Faz anos" tag and the "Hoje" card.
- `TruckReception` (Receção de Camião) has a `TruckType`, paletes per departamento
  (`PalletCount.department` holds a `truckDepartments` id; read the name through
  `PalletCount.label`, which falls back to the legacy, index-stored `PalletCategory` on older
  rows — never reorder that enum) and `Expositor` lines.
- Daily tasks belong to a service day (05:00 to 05:00, `currentServiceDay`). The Verificação de
  Validades is split into two windows inside that day, `ValidadesTurno` in
  `lib/models/validades.dart`: Manhã (05–14, the original `verificacaoValidades*` fields) and
  Noite (19–05, `validadesNoite*`); `validadesStateAt` says whether each is open.
- The Abertura and Automáticas lists are sent per `ListSection` (Congelados, OPLS, Não
  Perecíveis). An `OpeningList` records who sent each section and when; `markSectionDone`
  finalizes it (and so ticks Lista de Abertura in Diárias) once all three are sent. Each
  Automáticas send saves an `AutoList` holding only that section.
- Horários (Livre Serviço only) come from Pingo Doce's monthly sheet of shift codes ("H73",
  "W82") and absence codes ("FO", "F", "A", "LP"). They are edited as a JSON file (export, edit
  by hand or with Claude, import): `codigos`, `ausencias` and `meses` ("2026-10" → name → one
  space-separated code per day). `HorarioService` keeps months in Isar (`HorarioMes`), codes in
  shared preferences (defaults in `lib/models/horario_codigos.dart`), and a `HorarioIndex`
  linking lines to Livre Serviço people by name (`personForRow`). An import replaces only the
  months it has. Pass `HorarioService.instance.index` as `horario:` to `offLabelOn` /
  `awayTagOn` / `offNoteOn` / `buildPeopleSections`: an app ausência wins, then the horário,
  then the fixed folgas. "Today" for horários is `currentServiceDay()`. A person's own
  `shiftStart`/`shiftEnd` (each optional, e.g. a horário de amamentação) replace the code's
  entrada/saída: read a person's shift through `HorarioIndex.shiftOn` or
  `HorarioCodigo.forPerson`, never `horarios.codigos[code]` directly.
- Informações (`InfoEntry`, read/written through `InfoService`) holds the store fields, bucket
  entries (Protocolos, Avarias, Reclamações) and Contactos Úteis (bucket `contactos`, grouped by
  `InfoEntry.group`). Contacts from the old fixed buckets are read through the helpers in
  `lib/models/info_contacts.dart` and moved to the new fields when edited.

### Services layer

- `lib/services/*.dart` holds one service per feature area (e.g. `PersonService`,
  `InventoryService`, `DailyTasksService`, `PedidoService`, `TruckService`...), generally as a
  private-constructor singleton (`Foo._()`, `static final instance = Foo._()`).
  Feature services extending `ChangeNotifier` call `notifyListeners()` after mutations; screens
  subscribe via `addListener`/`removeListener` in `initState`/`dispose` rather than a state
  management package — there is no Provider/Riverpod/Bloc in this codebase.
- `SettingsService` wraps `shared_preferences` for simple user prefs (goals) and is initialized
  in `main()` before the app runs. There are no notifications/reminders of any kind.
- `WhatsAppService` sends prefilled messages via `url_launcher`, trying an Android intent URL,
  then an HTTPS fallback, then the `whatsapp://` scheme.

### UI layer

- `lib/screens/*.dart` are mostly `StatefulWidget`s that read/write through the services above;
  `lib/screens/tabs/*.dart` holds tab bodies used from screens with a `TabBar`: the opening/
  auto/report/visual lists (`ReplenishmentListsScreen`) and the daily/weekly/custom tasks
  (`TasksScreen`). `lib/screens/widgets/*.dart` holds small shared widgets. The largest
  screens are split with `part` files, so their private widgets stay private:
  `historico_screen.dart` (one part per tab in `lib/screens/historico/`; each tab filters its
  rows by the search box through `_searched` and a `*SearchText` function from
  `lib/models/historico_search.dart`, and listens to its services through `_ReloadWhenOpen`,
  passing `_changed`, so only the open tab reloads),
  `truck_form_screen.dart` (`lib/screens/truck_form/`), `person_form_screen.dart`
  (`lib/screens/person_form/`: the fields as small widgets taking values and callbacks, and
  the ausência dialog) and `horarios_screen.dart` (`lib/screens/horarios/`: today's cards,
  the month grid).
- `HomeScreen` (`lib/screens/home_screen.dart`) is the app's single entry route (set as
  `MaterialApp.home` in `lib/main.dart`); other screens are pushed via `Navigator`. Its
  `TodayCard` (`widgets/today_card.dart`) summarizes the service day from the pure helpers in
  `lib/models/today.dart` (`onShiftAt`, `shiftCountsOn`, `pendingDailyTasks`); a new daily task
  must be added to `pendingDailyTasks` too.
- `lib/theme.dart` defines `buildAppTheme(brightness)`, the light and dark `ThemeData`;
  `MaterialApp.themeMode` comes from `SettingsService.themeMode` (Definições → Aparência).
  Don't hard-code greys or light tints in widgets: use the `BuildContext` helpers there
  (`context.colors`, `muted`, `faint`, `faintest`, `hairline`, `greyedFill`, `tint(...)`,
  `warningText`), which keep the light theme's original colours and adapt in the dark one.
  White on the black app bar and on filled badges is fine.
- The app forces `pt_PT` as its only locale (`main.dart`); date formatting is initialized via
  `initializeDateFormatting('pt_PT')` before `runApp`.

### Startup sequence

`main()` in `lib/main.dart` awaits, in order: `SettingsService.instance.init()`,
`ShiftService.init()`, `HorarioService.instance.init()`.
Any exception during this sequence renders a plain error `Scaffold` instead of the app, so keep
new startup steps inside that same try/catch if they must run before `HomeScreen` is shown.

### Platform notes

- The "Enviar Vasilhame" picker in `truck_form_screen.dart` reads its items from
  `SettingsService.vasilhame` (`lib/models/vasilhame.dart`). The list is maintained by hand in
  the backup file's top-level `"vasilhame"` array of `{"name", "code"?, "ean"?}`: export, edit,
  import. Until a non-empty list is imported, it is `defaultVasilhame` (the Jerónimo Martins
  "Acessórios Transporte" sheet: SAP code as `code`, EAN as `ean`). `barcode_widget` is only used to show a vasilhame item's `ean` as a barcode.
- `image_picker` (person photos, Informações photos) is the only camera use; Android declares
  no CAMERA permission on purpose (declaring it would require a runtime grant before the camera
  intent works). Photos are copied into the app's documents folder (`people_photos/`,
  `info_photos/`); backups only carry their paths, not the files.
- `.env.example` still references `SUPABASE_URL`/`SUPABASE_ANON_KEY` from the removed backend
  integration; nothing in `lib/` reads env vars or calls Supabase today, so treat that file as
  stale rather than as a sign of an active integration.

## Versioning

- Every commit is a version. `pubspec.yaml` `version: MAJOR.MINOR.PATCH+BUILD` is the single
  source of truth; bump it in the commit itself and tag that commit with an annotated tag
  `vX.Y.Z` (`git tag -a vX.Y.Z -m "vX.Y.Z"`).
- While the app is pre-1.0, a commit that adds or removes a feature bumps MINOR and resets PATCH;
  any other commit (fix, improvement, refactor, docs, build change) bumps PATCH. BUILD (the
  Android `versionCode`) goes up by exactly one on every commit, never reset.
- Add the version's entry at the top of `CHANGELOG.md` in the same commit.
- History was renumbered under this scheme on 2026-10-07 (old v0.4.0 is now v0.27.1); the old
  v0.2.0–v0.4.0 release tags no longer exist.
