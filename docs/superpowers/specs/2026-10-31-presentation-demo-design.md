# Presentation page and demo — design

The third of three projects: (1) authority levels (0.68.0), (2) Avisos (0.69.x), (3) this.

## Intent

The website will be shared between Pingo Doce colleagues: a chefe or supervisor sends the link
to someone in another store or their own team. Today the site opens straight on Conta (sign in
/ create account), which says nothing about what the app is. A first-time visitor should see
what the app does, try it with a believable example store without signing up, and then create
an account and bring their team in.

## Goals

- On the website, a visitor who isn't signed in lands on a **presentation page** instead of
  Conta.
- From it, **Experimentar a demo** opens the real app filled with an example store, where
  everything works but nothing is kept and nothing goes online.
- From the demo or the page, **Criar conta** / **Entrar** lead to the account flow as today.

## Non-goals

- Any change to the phone app (it never shows the page and has no demo).
- Marketing analytics, sign-up tracking, a separate static website.
- Translating the app or the page out of Portuguese.

## Anti-goals

- The demo touching real data: no read or write of the visitor's local database, preferences,
  or Supabase, ever — not even if they were signed in before on that browser.
- A demo that looks dead: dates must be relative to today so "Hoje", folgas, birthdays and
  "A trabalhar agora" are always alive.
- Looking official: no Pingo Doce or Jerónimo Martins logo; a line says it's independent.

## Presentation page (`PresentationScreen`)

Shown when: web, the online database configured, not signed in, not in the demo. (Signed in
without an approved store still opens Conta, as now. A web build without `.env` still opens
Home, as now.)

Same look as the app (its theme, light and dark). Content, top to bottom, Portuguese:

1. Name "Livre Serviço Companion" and a one-line headline: the day-to-day of the store's
   teams in one place — checklists, tasks, receções and people.
2. Buttons: **Experimentar a demo** (filled, main), **Criar conta**, **Entrar**.
3. Feature blocks (icon, title, one or two lines each): Tarefas diárias e semanais;
   Listas de Abertura e Automáticas; Receção de camiões e vasilhame; Inventários e pedidos;
   Pessoas, equipas, folgas e ausências; Avisos à equipa; Funciona sem rede no telemóvel e
   sincroniza com a equipa.
4. "Como começar" in three steps: criar conta → pedir o código da loja à chefia → esperar
   aprovação.
5. The same three buttons again.
6. Footer: "Aplicação independente, não oficial do Pingo Doce nem da Jerónimo Martins." and a
   link to the Política de Privacidade.

Criar conta / Entrar open `AccountScreen` (pushed, with a back arrow to the page).

## The demo

- **Entering**: "Experimentar a demo" reloads the site at `?demo` (e.g. `/?demo=1`). At
  startup, `main()` sees it (web only) and starts the app in demo mode instead of normally:
  - the database is a fresh **in-memory** SQLite (on the web, drift's in-memory wasm database;
    elsewhere `NativeDatabase.memory()`), never the browser's saved one;
  - preferences are an in-memory store, never the browser's;
  - `AccountService` is not started and never talks to Supabase; `SyncService` never starts;
  - the example store is written in (below).
  So reloading the demo page starts a fresh example, two visitors never see each other's
  changes, and closing the tab leaves nothing behind.
- **Who you are in the demo**: signed in as the example store's Chefe de Secção of Livre
  Serviço (turno Dia), level 3, linked to that person (a local-only `StoreInfo`, no network).
  So the visitor sees what a chefe sees: their team's full profiles, Avisos they can send and
  have received, a profile badge in Conta-less form.
- **Banner**: a thin bar across the top of every screen, "Modo demonstração — nada é
  guardado", with **Sair** (back to the presentation page: reload without `?demo`) and **Criar
  conta**.
- **Off-limits in the demo** (hidden, or a short "Não disponível na demonstração" when tapped):
  Definições → Conta e Sincronização, Exportar/Importar Dados, Apagar Todos os Dados; Membros;
  "Entrar com código"; anything else that would call Supabase. WhatsApp sending still works
  (it only opens WhatsApp with the text). Photos can be added (they stay in memory).

## The example store (`demo_data.dart`)

All names invented; dates relative to today's service day.

- **People (~18)** across Livre Serviço (dia and noite), Gerência, Talho, Peixaria, Padaria,
  Frente de Loja: one person per role at least (Gerente de Loja, Gestor de Área, Secretária,
  Chefes de Secção including the visitor, Segunda Linha, Supervisor, Operadores), with folgas,
  shifts, one on férias this week, one baixa, one birthday today, one "Em formação" (hired
  two weeks ago), a couple Permanência, part-time.
- **Today**: Diárias partly done (some ticked by others), Abertura with one section sent, a
  Verificação de Validades Manhã done; Semanais partly done; a custom task.
- **History**: a few camiões on past days with paletes and expositores; an inventário or two;
  pedidos (one overdue, one expected tomorrow, one finished).
- **Informações**: store fields, a couple of Contactos Úteis, an Avaria.
- **Avisos**: one unseen from the Gestor de Área to the visitor; one the visitor sent to their
  team yesterday, seen by some.

## Where it changes

- `lib/main.dart`: demo startup path (`isDemoUrl`, `startDemo`), inside the same try/catch.
- `lib/services/demo_mode.dart`: `DemoMode.active`, entering/leaving (URL reload through
  `url_launcher` with `webOnlyWindowName: '_self'`), the in-memory database executor through a
  conditional import (web vs io), in-memory preferences.
- `lib/services/demo_data.dart`: writes the example store through the services/`LocalDb`.
- `lib/screens/presentation_screen.dart`; `StartScreen` / `needsAccountFirst` choose it.
- `DemoBanner` wrapping the app's pages (`MaterialApp.builder`), shown only in demo mode.
- Definições, Conta, Membros: hide the off-limits entries in demo mode.
- Tests: presentation shows for a signed-out web visitor (pure helper deciding the first
  page); the demo data loads into an empty in-memory database and Home shows its people,
  tasks and the aviso; off-limits entries hidden in demo mode.
- `CLAUDE.md`, CHANGELOG, MINOR bump.

## Left to the builder

- Exact copy, icons and spacing on the page (respect `lib/theme.dart` helpers, phone-width
  layout, SafeArea).
- How in-memory preferences are installed, as long as no analyzer warning is added.
- The exact example names and numbers.
