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
- Tests: `flutter test` (unit tests in `test/`; so far only pure logic such as
  `lib/screens/people_sections.dart` and `lib/models/planning.dart`, no widget tests).

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
  `ShiftService._backfillSync()` fills in missing UUIDs on legacy rows at startup.
- `lib/services/backup_service.dart` implements manual JSON export/import (share a file /
  pick a file) and a "clear all data" wipe, independent of the sync fields above.
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
- `TruckReception` (Receção de Camião) has a `TruckType`, paletes per departamento
  (`PalletCount.department` holds a `truckDepartments` id; read the name through
  `PalletCount.label`, which falls back to the legacy, index-stored `PalletCategory` on older
  rows — never reorder that enum) and `Expositor` lines.

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
  `lib/screens/tabs/*.dart` holds tab bodies used from screens with a `TabBar` (opening/auto/
  report/visual lists). `lib/screens/widgets/*.dart` holds small shared widgets.
- `HomeScreen` (`lib/screens/home_screen.dart`) is the app's single entry route (set as
  `MaterialApp.home` in `lib/main.dart`); other screens are pushed via `Navigator`.
- `lib/theme.dart` defines `buildAppTheme()`, the single `ThemeData` used by `MaterialApp`.
- The app forces `pt_PT` as its only locale (`main.dart`); date formatting is initialized via
  `initializeDateFormatting('pt_PT')` before `runApp`.

### Startup sequence

`main()` in `lib/main.dart` awaits, in order: `SettingsService.instance.init()`,
`ShiftService.init()`.
Any exception during this sequence renders a plain error `Scaffold` instead of the app, so keep
new startup steps inside that same try/catch if they must run before `HomeScreen` is shown.

### Platform notes

- The "Enviar Vasilhame" picker in `truck_form_screen.dart` reads its items from the bundled
  `assets/vasilhame.json` (a JSON array of `{"name", "code"?, "ean"?}`), maintained by hand.
  `barcode_widget` is only used to show a vasilhame item's `ean` as a barcode.
- `image_picker` (person photos) is the only camera use; Android declares no CAMERA permission
  on purpose (declaring it would require a runtime grant before the camera intent works).
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
