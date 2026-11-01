# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Livre Serviço Companion — a Flutter app for recording inventories (name, code, final value),
truck receptions, opening/report/visual/auto checklists, daily/weekly/custom tasks, "pedidos"
(order headers: number, supplier, expected date), and the store's people, grouped into fixed teams with chefes, used at a
single site. There is no product catalogue, no barcode scanning and no points system. UI text
and user-facing strings are in Portuguese (pt_PT locale). The app is fully offline/local: all
data lives in an on-device SQLite database (Drift), and optionally syncs with an online
Supabase database once signed in (Definições → Conta e Sincronização; see "Online database"
below).
It's built for and used by a single supervisor (livre serviço / reposição team lead at a Pingo
Doce store) running it on their own phone to manage their team's checklists day to day — not a
multi-tenant product.

## Commands

- Install deps: `flutter pub get`
- Run app: `flutter run --dart-define-from-file=.env` (copy `.env.example` to `.env`, which is
  git-ignored, and fill in the Supabase project; without it the app runs signed out, as before)
- Web: `flutter run -d chrome --dart-define-from-file=.env`; to host, `flutter build web
  --release --dart-define-from-file=.env` and upload `build/web/` to any static host (e.g.
  `npx wrangler pages deploy build/web --project-name livre-servico` for Cloudflare Pages). Add
  the hosted URL in Supabase (Authentication → URL Configuration: Site URL) so email
  confirmation links land there. Never use dart:io or path_provider outside a conditional
  import (see `legacy_photos_io.dart`): `flutter build web` fails or the browser throws.
- Lint/analyze: `flutter analyze`
- Tests: `flutter test` (in `test/`: mostly pure logic such as
  `lib/screens/people_sections.dart`, `lib/models/planning.dart`, `lib/models/validades.dart` and
  `lib/models/info_contacts.dart`, `lib/models/vasilhame.dart`,
  `lib/models/today.dart`, `lib/models/historico_search.dart`, `lib/models/store_access.dart`,
  `lib/models/teams.dart`, `lib/models/aviso.dart`, `lib/models/release_notes.dart`, `lib/services/document_service.dart` and
  `lib/theme.dart`, plus a
  few widget tests: `test/home_screen_test.dart` opens every screen and tab from Home,
  `test/person_form_screen_test.dart` fills in and saves the person form,
  `test/truck_form_screen_test.dart` saves a camião, `test/claim_person_screen_test.dart`
  picks a person to join a store as and `test/abertura_tab_test.dart` sends the
  Abertura sections; `test/local_db_test.dart` covers the store and the backup JSON format,
  `test/sync_engine_test.dart` the sync engine between two devices, `test/demo_data_test.dart`
  and `test/demo_mode_test.dart` the demo).
  Widget tests run against a real, empty in-memory SQLite database: `openAppDb` /
  `closeAppDb` in `test/helpers/app_db.dart` start the services like `main()` does, with
  `NativeDatabase.memory()` (needs the host's SQLite library; on Linux
  `test/flutter_test_config.dart` falls back to `libsqlite3.so.0` when the -dev package's
  `libsqlite3.so` is missing). A database call only completes inside `runAsync` and the
  code awaiting it only resumes on a pump, so use the helpers in `test/helpers/pump.dart`
  (`pumpApp`, `settle`, `tapAndSettle`, `dbCall`), never `pumpAndSettle`.

## Architecture

### Data layer: LocalDb (Drift / SQLite)

- `LocalDb.init()` (`lib/services/local_db.dart`) opens the app's single SQLite database
  through Drift (`drift_flutter`: a file on the phone; on the web, `sqlite3.wasm` and
  `drift_worker.js` in `web/`, downloaded from the sqlite3.dart and drift GitHub releases
  matching the versions in `pubspec.lock`: replace them when those packages are upgraded).
  There is no Drift code generation: one table, `local_rows` (collection, id, data), made
  with plain SQL, holds every row as a JSON document, like the online `records`. Each collection (`LocalDb.instance.persons`, `.dailyTasks`...) is read
  into memory at startup and queried in Dart with `all`, `where`, `firstWhere` and `get`;
  every read builds new objects, so a row changes nothing until it is `put`. Writes go to
  SQLite first; `LocalDb.transaction` groups several.
- Every persisted model in `lib/models/*.dart` mixes in `SyncFields` (`lib/models/local_row.dart`:
  the local `id`, 0 until saved, and the sync fields) and has `toJson` / `fromJson`. Adding a
  field means adding it to both; no migration is needed. The JSON is the format Isar's
  `exportJson` wrote before the move to Drift (dates as microseconds since the epoch, enums by
  name or by index as each model's `toJson` writes them), so older backups still import: never
  rename a field or reorder an enum stored by index. Register a new model in
  `LocalDb.collections`.
- The sync fields (`syncUuid`, `syncUpdatedAt`, `syncDeletedAt`, `synced`) are what the sync
  engine works from (see "Online database" below), so every save must go through
  `SyncMeta.stamp(row)` (it also marks the row pending a push, `synced` false) and every delete
  through `SyncMeta.softDelete(row)` (or a collection's `softDelete` / `softDeleteAll`): never
  remove rows for good (`clear`, `deleteWhere`), or the delete never reaches other devices.
  The one exception is `prepareLocalDataFor` (`lib/services/store_data.dart`): choosing a
  different store than the one this phone's data is from (`localDataStore` pref) clears it
  from the phone only (refusing while changes wait to be sent), so nobody sees or copies a
  store they didn't choose; data from before any store still joins the first one.
  Reads skip tombstoned rows unless they pass `includeDeleted: true`. `LocalDb.backfillSync()` fills in missing UUIDs:
  once at the first startup (then the `syncBackfilled` pref skips it) and after every backup
  import. Compare dates kept as keys (`serviceDay`, `serviceWeek`, `periodKey`) with
  `isAtSameMomentAs`, not `==`.
- `lib/services/backup_service.dart` implements manual JSON export/import (share a file /
  pick a file; never prompted for, since the data syncs on its own) and a "clear all data" wipe, independent of the sync fields above. The export is
  indented JSON with `vasilhame` and `settings` before `collections` (every `LocalDb`
  collection, keyed by its name); import replaces only the collections and
  sections the file has.
- People belong to one of the fixed teams in `lib/models/teams.dart` (`Person.team` stores the
  `Team.id`; null or unknown = "Sem equipa") and have one role: `Person.role` stores a
  `Role.name` (never an index), each with a level: Operador 1, Segunda Linha and Supervisor 2,
  Chefe de Secção 3, Gestor de Área and Secretária de Loja 4, Gerente de Loja 5. Levels 1–3
  exist in every team, 4–5 only in Gerência (`rolesIn`). Read it through `roleOf` / `levelOf`,
  which read a role the team doesn't allow as Operador and, on rows saved before 0.68.0 (no
  `role`), derive it from the old `chefe` slot (`ChefeSlot`), `supervisor` and `segundaLinha`
  fields (Gerência's chefe → Gerente, the rest of Gerência → Gestor de Área, other chefes →
  Chefe de Secção); `person_role` in the migrations does the same. The form clears those old
  fields on save; never rename them. `PersonService.save` keeps one Chefe de Secção per team
  (per turno in Livre Serviço) and one Gerente (`roleConflicts`) by making the previous holder
  Operador in the same transaction. Livre Serviço is split into a day and a night turno
  (`Team.hasTurnos`): `Person.turno` stores a `Turno.name`; read it through `turnoOf` (an old
  chefe without a role is on their slot's turno). `Person.permanencia` is an independent tag
  ("Permanência": can stand in for management when no chefia is present; no permissions).
  `Person.partTime` is false for full time ("Tempo inteiro", the default) and true for "Tempo
  parcial". `roleTagsOf` gives the badge labels the UI shows (the role from level 2, then
  Permanência), `roleLineOf` the "role · team · turno" line in Conta.
- Planning data on `Person` (`folgas` weekdays, `weeklyHours`, `shiftStart`/`shiftEnd` in
  minutes after midnight, embedded `Ausencia` list) is read through the pure helpers in
  `lib/models/planning.dart`: `offLabelOn(p, day)` says why someone isn't working that day (an
  ausência beats a folga), used by Pessoas, the person page and the task picker
  (`buildPeopleSections(offDay:)` lists them last). During an ausência, `awayTagOn` gives
  the orange tag shown next to the role tags and `offNoteOn` the "até 14/10" text beside it.
  `hireDate` is the company (Pingo Doce) start; `storeStartDate` is the start at this store.
  `tenureTagOf` derives the blue "Em formação" (first month at Pingo Doce) / "Novo" / "Nova"
  (until six months; `Person.genero` picks the form) tag from `hireDate`. `isBirthdayOn` /
  `upcomingBirthdays` read `birthDay`/`birthMonth` for the "🎂 Faz anos" tag and the "Hoje" card.
  People keep no phone number and no year of birth: a trigger on `records`
  (`person_without_removed_fields`) strips `phoneNumber` and turns an old `dateOfBirth` into
  the birthday, and `Person.fromJson` does the same for rows saved before 0.67.0.
- `TruckReception` (Receção de Camião) has a `TruckType`, paletes per departamento
  (`PalletCount.department` holds a `truckDepartments` id; read the name through
  `PalletCount.label`, which falls back to the legacy, index-stored `PalletCategory` on older
  rows — never reorder that enum) and `Expositor` lines.
- Daily tasks belong to a service day (05:00 to 05:00, `currentServiceDay`). The Verificação de
  Validades is split into two windows inside that day, `ValidadesTurno` in
  `lib/models/validades.dart`: Manhã (05–14, the original `verificacaoValidades*` fields) and
  Noite (19–05, `validadesNoite*`); `validadesStateAt` says whether each is open.
- Each manual task has two markers (`TaskMarkers` in `widgets/task_markers.dart`): ✓ Feita
  (the old done flags) and ✗ Não feita, a `NotDone` (`lib/models/not_done.dart`: who, reason,
  when) kept in `DailyTasks.notDone` / `WeeklyTasks.notDone` by task key (the keys of
  `backdatedTaskKeys`) and `CustomTaskEntry.notDone`. Only one is ever set; a Não feita task
  isn't pending (`pendingDailyTasks`).
- The Abertura and Automáticas lists are sent per `ListSection` (Congelados, OPLS, Não
  Perecíveis). An `OpeningList` records who sent each section and when; `markSectionDone`
  finalizes it (and so ticks Lista de Abertura in Diárias) once all three are sent. Each
  Automáticas send saves an `AutoList` holding only that section.
- There are no horários (the monthly shift sheet was removed in 0.61.0, since it showed
  everyone's folgas and absences): who works when comes from each person's `folgas`,
  `ausencias` and own `shiftStart`/`shiftEnd`. `shiftSpanOn`, `onShiftAt` and `shiftCountsOn`
  (`lib/models/today.dart`) read those for the "A trabalhar agora" line and the picker.
- Avisos (`lib/models/aviso.dart`, `AvisoService`): a short notice from level 2 and up
  (`StoreAccess.canSendAvisos`, linked to a person) to people they reach, resolved to person
  uuids when sent (`recipientsFor`); each recipient's "Visto" is its own `AvisoVisto` row
  (keyed online `'<aviso>/<person>'`). `AvisosCard` on Home shows the unseen ones under 7 days
  (`avisosOnHome`); `AvisosScreen` (Recebidos / Enviados with who saw it) keeps 30 days;
  `AvisoFormScreen` sends. The server (`20261031230000_avisos.sql`, `aviso_visible`) lets only
  the sender, the recipients and the admin read them, and `push_records` checks the sender's
  level, name and reach.
- Documentos (`DocumentService`, `lib/models/app_document.dart`, `documents_screen.dart` and
  `document_viewer_screen.dart` on `pdfrx`): PDFs the same for every store, not local rows and
  not synced by `SyncEngine`. They live online in the `documents` table and bucket
  (`20261101090000_documents.sql`: read by the admin and approved members of any store, written
  only by the admin, `DocumentService.canManage`); `AccountService` sets
  `DocumentService.remote` (`SupabaseDocumentRemote`) with the store sync. The list is cached in
  the `documents_cache` pref, each opened PDF in `LocalDb`'s `local_files` table (dropped when
  no longer listed). The demo and tests use `MemoryDocumentRemote` with PDFs from `simplePdf`.
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
  in `main()` before the app runs. There are no phone notifications or reminders; avisos (below)
  live inside the app.
- `WhatsAppService` sends prefilled messages via `url_launcher`, trying an Android intent URL,
  then an HTTPS fallback, then the `whatsapp://` scheme; on the web only the HTTPS link, in a
  new tab.
- Exports (backup) go through `shareJsonFile` (`lib/services/share_file.dart`), an
  in-memory file: the share sheet on the phone, a download in a browser.

### UI layer

- `lib/screens/*.dart` are mostly `StatefulWidget`s that read/write through the services above;
  `lib/screens/tabs/*.dart` holds tab bodies used from screens with a `TabBar`: the opening/
  auto/report/visual lists (`ReplenishmentListsScreen`, shown as "Listas 1.0": the old
  lists, kept for the stores still using them; the new ones go in `Listas2Screen`, "Listas
  2.0", empty for now) and the daily/weekly/custom tasks
  (`TasksScreen`). `lib/screens/widgets/*.dart` holds small shared widgets. The largest
  screens are split with `part` files, so their private widgets stay private:
  `historico_screen.dart` (one part per tab in `lib/screens/historico/`; each tab filters its
  rows by the search box through `_searched` and a `*SearchText` function from
  `lib/models/historico_search.dart`, and listens to its services through `_ReloadWhenOpen`,
  passing `_changed`, so only the open tab reloads),
  `truck_form_screen.dart` (`lib/screens/truck_form/`), `person_form_screen.dart`
  (`lib/screens/person_form/`: the fields as small widgets taking values and callbacks, and
  the ausência dialog), `tutorial_screen.dart` (`lib/screens/tutorial/`).
- `StartScreen` (`lib/screens/start_screen.dart`, `MaterialApp.home` in `lib/main.dart`)
  picks the first page with `firstPage`: on the website, `PresentationScreen` (a landing page
  using the whole width: a hero with the "Hoje na loja" day timeline, features, "Como
  começar", a closing band; headlines in Roboto Condensed Bold, bundled in `assets/fonts`) for
  a visitor who isn't signed in,
  `AccountScreen` while signed in without an approved store (`needsAccountFirst`), then
  `HomeScreen` (`lib/screens/home_screen.dart`), the app's entry page on the phone and in the
  demo; other screens are pushed via `Navigator`. `AppFrame` (`widgets/app_frame.dart`, put
  around the navigator by `MaterialApp.builder`) lays out a computer's window: in the app proper
  (`menu`, from 1100 px) a side menu with Início and every `Destination`
  (`lib/screens/destinations.dart`, also Home's buttons; it opens them through
  `appNavigatorKey`, and `appMenuObserver` highlights the open one by route name) and the page
  in the rest of the width (`MediaQuery` size is that width, `hasSideMenu` is true); otherwise
  (Conta first, pages pushed from the presentation page) a centred 840 px column. Beside the
  menu, Home is a dashboard (the cards, then the Diárias and the Abertura open in panels).
  `widgets/wide_layout.dart` has the pieces to use the width: `ResponsiveTabs` (tabs on a
  phone, side by side when `columnsFor` fits them: Tarefas, Listas, a person's page),
  `GridRows` (Pessoas, Inventários, Pedidos), `ReadableWidth` (forms and text keep 760 px).
  Lay out new screens for both widths.
- The demo (`lib/services/demo_mode.dart`): the website at `?demo` (`isDemoUrl`,
  `DemoMode.enter`/`leave` reload the page) starts with `DemoMode.active`: an in-memory
  SQLite (`demo_db_web.dart` / `demo_db_io.dart`, conditional import) and in-memory
  preferences, never the browser's saved ones; `AccountService.isConfigured` is false, so
  nothing goes online. `seedDemo` (`lib/services/demo_data.dart`) writes an invented store
  around today and signs in locally as its Livre Serviço Chefe de Secção (dia). `DemoBanner`
  (`MaterialApp.builder`) says nothing is kept; Definições hides Conta and the Dados
  section. A new feature worth showing gets example rows in `seedDemo`.
- `TutorialScreen` (`lib/screens/tutorial_screen.dart`) pages through `tutorialSteps`, each a
  sketch of a screen (drawn from small widgets in the `lib/screens/tutorial/diagrams.dart` part,
  so it follows the theme) with orange numbered markers matching its steps; Home's
  `TutorialCard` offers it until `SettingsService.tutorialSeen`, and Definições → Tutorial
  reopens it. The steps are grouped in `tutorialSections`, each with an `id` and a `version`
  (the seen versions are kept per id in `SettingsService.tutorialSeenVersion`): when a part
  of the app changes, update its steps and raise its section's `version`, so Home's
  `TutorialCard` offers it again ("Novidades") to everyone who saw it; a new area gets a new
  section (new id, version 1). Never rename or reuse an id. Definições → Tutorial opens
  `TutorialIndexScreen` (whole tutorial or one section). A new Home button or a big change to
  one gets its step updated.
- Home's `TodayCard` (`widgets/today_card.dart`) summarizes the service day from the pure helpers in
  `lib/models/today.dart` (`onShiftAt`, `shiftCountsOn`, `pendingDailyTasks`); a new daily task
  must be added to `pendingDailyTasks` too.
- After an update, Home shows the "Novidades" popup once (`showReleaseNotesIfNew`,
  `widgets/release_notes_dialog.dart`): the entries of `releaseNotes`
  (`lib/models/release_notes.dart`, plain Portuguese for the people using the app, not the
  CHANGELOG) newer than the version last seen, which is the newer of the device's
  `releaseNotesSeen` pref and the account's user metadata `release_notes_seen`, so it follows
  the account across devices. A version with no entry shows nothing; a first install and the
  demo show nothing.
- `lib/theme.dart` defines `buildAppTheme(brightness)`, the light and dark `ThemeData`;
  `MaterialApp.themeMode` comes from `SettingsService.themeMode` (Definições → Aparência;
  light unless chosen otherwise). `context.backdrop` is the colour beside `AppFrame`.
  Don't hard-code greys or light tints in widgets: use the `BuildContext` helpers there
  (`context.colors`, `muted`, `faint`, `faintest`, `hairline`, `greyedFill`, `tint(...)`,
  `warningText`), which keep the light theme's original colours and adapt in the dark one.
  White on the black app bar and on filled badges is fine. Text must always stand out from
  what is behind it: tabs in an app bar's `bottom` go through `appBarTabs`
  (`widgets/app_bar_tabs.dart`: white on the black bar), never a bare `TabBar` (the theme's
  default colours are for the page and vanish on the bar); tabs in a page's body take
  `context.colors.onSurface` / `context.muted`.
- The app forces `pt_PT` as its only locale (`main.dart`); date formatting is initialized via
  `initializeDateFormatting('pt_PT')` before `runApp`.

### Startup sequence

`main()` in `lib/main.dart` awaits, in order: `SettingsService.instance.init()`,
`LocalDb.init()`, `PhotoStore.instance.migrateLegacy()` (its own try/catch: a failure there
doesn't stop the app), `AccountService.instance.init()`
(which restores the saved session in the background, so it never waits for the network).
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
  intent works). Photos are kept by `PhotoStore` (`lib/services/photo_store.dart`): rows hold a
  `photo:<name>` reference (`Person.photoPath`, `InfoEntry.photoPaths`), the bytes live in the
  local database's `local_photos` table (so they work in the browser too) and, while a store is
  connected, in its folder of the `photos` bucket in Supabase Storage (uploaded with each sync,
  downloaded the first time another device shows them). Show one with `PhotoImage(ref)`.
  Photos never change (a new one gets a new name) and are never deleted online. Older
  versions saved files in the documents folder: `migrateLegacy` moves them in once. Backups
  only carry the references, not the photos.
- `.env.example` lists `SUPABASE_URL`/`SUPABASE_ANON_KEY`; `AccountService` reads them with
  `String.fromEnvironment`, so they are baked in at build time with
  `--dart-define-from-file=.env`. The anon key is public by design (access is the RLS rules).

### Online database

The app runs on the phone and on the web, with an optional online Supabase database shared
by several users, while staying offline-first on the phone. It was built in five phases, all
done: (1) Supabase schema, (2) Isar replaced by Drift (SQLite, which also runs on the web),
(3) the sync engine, (4) login and roles, (5) web fixes (photos to Supabase Storage, backup
files, WhatsApp links, hosting).

- `supabase/migrations/*.sql` is the schema (run in the dashboard's SQL Editor or with
  `supabase db push`); new changes go in a new, later-timestamped file. Every local row is one
  JSON document in `records`, keyed by (`store_id`, `collection`, `id`): the model name and its
  `syncUuid` (or a fixed key, like the day for `DailyTasks`), so model fields never need a
  migration. Users belong to a store through `store_members` as editors (old viewers and owners
  became editors; there are no store owners), pending until approved.
- Push with the `push_records` RPC (last write wins on `updated_at` = `syncUpdatedAt`; it
  returns the rows where the server's copy won). Pull with the `pull_records` RPC by
  `server_updated_at`, the server's clock, starting a minute before the last cursor. Person
  rows are redacted per account there and merged field by field in `push_records` (see
  "Personal data" below). Rows are never deleted, only tombstoned
  with `deleted_at` = `syncDeletedAt`.
- `SyncEngine` (`lib/services/sync_engine.dart`) does one sync of `LocalDb` with a
  `SyncRemote` (`SupabaseSyncRemote` on the `supabase` package, or the in-memory `FakeRemote`
  in `test/sync_engine_test.dart`): pushes each collection's pending rows (every row on the
  first sync with a store), marks them synced unless saved again meanwhile, then pulls pages
  from the cursor kept in shared preferences (`syncCursor:<storeId>`). Rows from the server go
  through `LocalCollection.applyRemote`, which keeps a local row saved at the same time or later
  (for `Person`, `replaceSynced`: a row with nothing pending takes the server's copy, so a
  redacted copy replaces one kept whole), and `LocalDb.remoteChanges` then tells the services (each subscribes with
  `LocalDb.listenRemote` in its constructor, so its screens reload). A row there is one of per
  day, week or month is keyed online by that period (`syncKey` in `LocalDb`: `DailyTasks`,
  `WeeklyTasks`, `OpeningList`, `ReportList`, `CustomTaskEntry`), so two devices
  share one row instead of each making its own. A backup import calls
  `SyncEngine.forgetCursors`, so the next sync pushes and pulls everything again;
  `AccountService` calls `SyncEngine.forgetCursor` when this account's access changes (checked
  after syncs, every 10 minutes at most) and once per store (`peopleRedacted:<storeId>`).
- `SyncService` runs the engine while a store is connected (`start(remote, storeId)`): at once,
  three seconds after a save (`LocalDb.localWrites`), a second after Realtime says the store's
  `records` changed (`SyncRemote.changes`: a Supabase Realtime channel filtered by store; the
  event only triggers the usual sync, so it needs no merge logic of its own), when the app
  comes back to the foreground, and every minute in case an event was missed. Settings in shared preferences (vasilhame, goals) don't sync.
- `AccountService` (`lib/services/account_service.dart`) is the optional login: email and
  password on the `supabase` package (not `supabase_flutter`, so no extra plugins; the session
  is kept in shared preferences, implicit auth flow), the chosen store (`account_store` pref)
  and its members (`store_member_list`, `add_store_member`). Choosing a store starts
  `SyncService` (`my_stores` lists them). `StoreInfo.access` (`lib/models/store_access.dart`,
  from the server's `my_access`; `AccountService.access` is `StoreAccess.full` with no store)
  says whether this account is the admin, and the level and team of the Person it is linked
  to. Level 4 and up manages members (`can_manage_members`: join code, adding by email,
  linking, removing; `canManageMembers`); only the admin creates
  stores (`create_store`, "Criar loja" via `isAppAdmin`). While syncing, only the admin may
  "Apagar Todos os Dados" (`canWipeAll`), since the tombstones reach every device. The old
  viewer role ("Só leitura") is gone: every approved member edits the everyday data. Screens: `account_screen.dart` (Conta) and `store_members_screen.dart` (Membros).
  `accountErrorText` turns auth and network errors into Portuguese; the database's own errors
  already are.
- Each store has a join code (`store_codes`, read only through `store_join_code` /
  `reset_store_join_code`, Gerência and the admin). With it, `join_store_preview` shows a signed-in
  stranger the store's name and its people with no account yet (name and collaborator number
  only), and `join_store` records a *pending* request (`store_members.status`) for the person
  they picked or the name they typed (`requested_name`). A pending member sees nothing of the
  store and doesn't sync (`StoreInfo.pending`; Conta shows "Pedido enviado"). Level 3 and
  up and the admin (`can_approve`) list requests (`store_join_requests`, in
  Membros and a count on Home) and `approve_join` (a typed name becomes a new Person) or
  `refuse_join`. `store_members.person_id` holds the linked Person's `syncUuid` (unique per
  store, so one account per person); `claim_person` lets a member link themselves once, never
  to someone at level 3 or up (only the admin links freely; level 4+ links others in Membros → "Ligar a uma pessoa",
  `linkMember`, and unlinks by setting it to null; members may update only `person_id`). `StoreInfo.personId` is this account's person; `claim_person_screen.dart`
  holds the picker and `completeProfile`, which opens the person form once approved.
- One store per person: everyone but the admin belongs to one store (`in_other_store`:
  `join_store` and `add_store_member` refuse a second). At sign-in that store opens on its own
  (`storeToOpen` in `start_screen.dart`); "Entrar com código" only shows with no store, and
  "Mudar de loja" only for the admin. Others ask in Conta → "Pedir mudança de loja"
  (`request_store_transfer`, `store_transfers`, with a note); the admin sees them on Home and in
  `StoreTransfersScreen` (`store_transfer_requests`) and moves them (`transfer_member`: the
  membership and the Person go to the new store, the old store keeps a tombstone and the
  history). The moved phone follows on its next access check (`refreshStore`, which clears the
  old store's data with `force`).
- The Política de Privacidade is `lib/models/privacy_policy.dart` (shown by
  `PrivacyPolicyScreen`, from Definições). "Criar conta" opens it first, with "Li e aceito" at
  the end of the text; the account's user metadata keeps `privacy_policy` (the version, a date)
  and `privacy_accepted_at`. When the app starts keeping new kinds of personal data, or shows
  them to someone new, update the text and `privacyPolicyVersion`.
- The app's admin is a row in `app_admins` (no UI; in the SQL Editor:
  `insert into public.app_admins select id from auth.users where email = '...';`): it is owner of
  every store (`my_store_role`, `my_store_ids`), all listed in Conta.
- Authority: two rules decide who does what to whom, the same in SQL
  (`20261031220000_authority_levels.sql`: `reaches`, `is_above`, `can_assign`, `my_level`) and
  in `StoreAccess` (`reaches`, `isAbove`, `assignableRoles`, `assignableTeams`). An account
  *reaches* a person when its level covers their team: 5 every team, 4 every team but
  Gerência, 2 and 3 their own (3 also people with no team), 1 nobody; it is *above* a person
  it reaches with a lower level (level 5: anyone). Level 2 adds nothing yet (Avisos will).
- Personal data: every member reads the others' public fields (`person_public_keys`: name,
  photo, género, birthday, team, role and the old role fields); the whole Person is read by
  the person, level 3+ reaching them and the admin (`person_access`). The server redacts in
  `pull_records` and the `records` select policy hides the rest (so Realtime too);
  `push_records` keeps only the fields the caller may edit (`person_edit_keys`: the person
  their name, photo, birthday, género, notes; level 3+ reaching them folgas and ausências;
  level 3+ above them (or themselves) team, role, turno and Permanência, kept only when
  `can_assign` allows the result; the admin everything), so a redacted copy pushed back wipes
  nothing. Level 3+ adds people into teams they reach with a role below their own and removes
  those they are above (their account leaves the store); "Remover todas as pessoas" is the
  admin's. The app mirrors this in `StoreAccess` (`canSeePersonal`, `canEdit(person,
  PersonFieldGroup)`, `canRequestUpdate`, `canAddPeople`, `canDeletePerson`,
  `canDeleteAll`): the person form locks fields with `EditLock` and offers only assignable
  teams and roles ("Função"), and the person page, Pessoas and Home hide what the account
  can't do. Keep the Dart groups and the SQL key lists the same. "Pedir atualização" sets
  `Person.profileUpdateRequestedAt`/`By`; the person sees `ProfileRequestCard` on Home until
  saving their own profile clears it (`PersonService.save`).
- `supabase/tests` checks the migrations on an in-memory Postgres (PGlite) with a stand-in
  `auth` schema: `npm install` then `npm test` there.

## Versioning

- Every commit is a version. `pubspec.yaml` `version: MAJOR.MINOR.PATCH+BUILD` is the single
  source of truth; bump it in the commit itself (and `appVersion` in `lib/app_version.dart`,
  shown on Home; `test/app_version_test.dart` checks they match) and tag that commit with an annotated tag
  `vX.Y.Z` (`git tag -a vX.Y.Z -m "vX.Y.Z"`).
- While the app is pre-1.0, a commit that adds or removes a feature bumps MINOR and resets PATCH;
  any other commit (fix, improvement, refactor, docs, build change) bumps PATCH. BUILD (the
  Android `versionCode`) goes up by exactly one on every commit, never reset.
- Add the version's entry at the top of `CHANGELOG.md` in the same commit.
- A version everyone should hear about (a new feature, a visible change) also gets an entry at
  the top of `releaseNotes` in `lib/models/release_notes.dart`, so the "Novidades" popup shows
  it once after the update; small fixes get none.
- History was renumbered under this scheme on 2026-10-07 (old v0.4.0 is now v0.27.1); the old
  v0.2.0–v0.4.0 release tags no longer exist.
