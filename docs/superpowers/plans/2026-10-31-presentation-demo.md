# Presentation Page and Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A presentation page for signed-out website visitors and a demo of the real app on an in-memory example store.

**Architecture:** `?demo` in the URL makes `main()` start in demo mode: in-memory SQLite (drift wasm in-memory on the web, `NativeDatabase.memory()` elsewhere, by conditional import), in-memory preferences, no `AccountService.init`, a local-only `StoreInfo` for the example store's Livre Serviço Chefe de Secção, and `seedDemo` writing the example data. `StartScreen` picks the presentation page through a pure `firstPage` helper.

**Tech Stack:** Flutter (web), drift 2.35 (`drift/wasm.dart`), sqlite3 2.9 (`sqlite3/wasm.dart`), shared_preferences_platform_interface 2.4 (`InMemorySharedPreferencesStore`), url_launcher.

**Spec:** `docs/superpowers/specs/2026-10-31-presentation-demo-design.md`

## Global Constraints

- The demo never opens the browser's saved database or preferences and never calls Supabase.
- The demo account: `StoreInfo(id: 'demo', name: 'Loja Demonstração', role: editor, personId: <Livre Serviço Chefe de Secção>, pending: false, access: StoreAccess(admin: false, level: 3, team: 'livre_servico', personId: ...))`.
- All example dates relative to `currentServiceDay()`.
- Banner text exactly `Modo demonstração — nada é guardado`; buttons `Sair`, `Criar conta`. Off-limits message `Não disponível na demonstração.`
- No dart:io outside conditional imports (web build). No new analyzer warnings.
- One commit at the end: `0.70.0+170`, tag `v0.70.0`, CHANGELOG, CLAUDE.md, spec and plan.

## Review Focus

1. A visitor who was signed in before on that browser opens `?demo`: the demo must not show or change their data. → Task 1 test (demo start uses an empty in-memory db even if the default db has rows: covered by construction; test asserts `LocalDb` holds only demo rows).
2. Reloading the demo page: a fresh example (no state survives). → by construction (in-memory), noted.
3. The demo calling the network through a card (JoinRequestsCard, TransferRequestsCard) → those must stay silent in demo: `AccountService.isConfigured` false in demo. → Task 4 test (Home pumps in demo with no exceptions).
4. Phone build: never shows the presentation page or demo. → Task 3 `firstPage` test (`web: false`).
5. Dark mode on the page: only theme helpers. → review.

---

### Task 1: Demo mode plumbing

**Files:** Create `lib/services/demo_mode.dart`, `lib/services/demo_db_io.dart`, `lib/services/demo_db_web.dart`; Modify `lib/main.dart`, `lib/services/account_service.dart` (`isConfigured` false while `DemoMode.active`), `pubspec.yaml` (add `shared_preferences_platform_interface: ^2.4.2`); Test `test/demo_mode_test.dart`

- `bool isDemoUrl(Uri u)` — `u.queryParameters.containsKey('demo')`.
- `class DemoMode { static bool active; static Future<QueryExecutor> inMemoryDatabase(); static void useInMemoryPrefs(); static Future<void> enter(); static Future<void> leave(); }` — `enter`/`leave` reload the page at `Uri.base` with/without `?demo=1` via `launchUrl(..., webOnlyWindowName: '_self')`.
- `main()`: when `kIsWeb && isDemoUrl(Uri.base)`: `DemoMode.active = true; DemoMode.useInMemoryPrefs();` before `SettingsService.init`; `LocalDb.init(executor: await DemoMode.inMemoryDatabase())`; skip `PhotoStore.migrateLegacy` and `AccountService.init`; `await seedDemo()` (Task 2) — all inside the existing try/catch.
- [ ] Tests: `isDemoUrl` cases (`/?demo=1` true, `/?demo` true, `/` false); `'isConfigured is false in demo mode'`. FAIL → implement → PASS.

### Task 2: Example store

**Files:** Create `lib/services/demo_data.dart`; Test `test/demo_data_test.dart`

- `Future<String> seedDemo({DateTime? now})` writes the example store into `LocalDb.instance` (every row through `SyncMeta.stamp`), sets `AccountService.instance.store` to the demo `StoreInfo`, returns the visitor's person uuid. Contents per spec "The example store".
- [ ] Tests on `openAppDb`: `'every role is there'` (`Role.values` all held); `'the visitor is the Livre Serviço Chefe de Secção, dia'`; `'today is alive'` (someone `isBirthdayOn` today, someone with an ausência today, today's `DailyTasks` exists with some done); `'an unseen aviso waits for the visitor'` (`avisosOnHome` non-empty); `'a pedido is overdue'`. FAIL → implement → PASS.

### Task 3: Presentation page and first page

**Files:** Create `lib/screens/presentation_screen.dart`; Modify `lib/screens/start_screen.dart`; Test `test/start_screen_test.dart`, `test/presentation_screen_test.dart`

- `enum FirstPage { presentation, account, home }`; `FirstPage firstPage({required bool web, required bool configured, required bool signedIn, required StoreInfo? store, required bool demo})` — demo → home; `needsAccountFirst(...)` and not signed in → presentation; `needsAccountFirst` → account; else home. `StartScreen` switches on it.
- `PresentationScreen` per spec; `Criar conta`/`Entrar` push `AccountScreen`; `Experimentar a demo` → `DemoMode.enter()`; footer privacy link → `PrivacyPolicyScreen`.
- [ ] Tests: `firstPage` table (phone never presentation; web signed out → presentation; web signed in no store → account; demo → home); widget: the page shows the three buttons and the independence line; `Entrar` opens Conta. FAIL → implement → PASS.

### Task 4: Banner and off-limits

**Files:** Create `lib/screens/widgets/demo_banner.dart`; Modify `lib/main.dart` (`MaterialApp.builder` wraps with `DemoBanner` when active), `lib/screens/settings_screen.dart` (hide Conta e Sincronização, Exportar/Importar, Apagar Todos os Dados in demo), `lib/screens/account_screen.dart` / Membros entry points if reachable; Test `test/demo_mode_test.dart`

- `DemoBanner(child)`: a `Material` bar on top (`SafeArea(bottom: false)`), text and `Sair` (→ `DemoMode.leave`) and `Criar conta` (→ leave to the page; account creation needs the real app).
- [ ] Tests: in demo (`DemoMode.active = true`, seeded): Home pumps with the banner text and the visitor's aviso; Definições hides the three entries. Reset `DemoMode.active` in tearDown. FAIL → implement → PASS; `flutter analyze && flutter test`.

### Task 5: Docs, version, commit

- `CLAUDE.md`: StartScreen/presentation/demo paragraph (demo never touches saved data; seed in `demo_data.dart`; new models must be added there if they matter).
- `pubspec.yaml` `0.70.0+170`; CHANGELOG `## [0.70.0]`.
- Verify `flutter analyze && flutter test`; `flutter build web --release` compiles (checks the conditional imports; no deploy); commit `feat: presentation page and demo on the website`, tag `v0.70.0`.
