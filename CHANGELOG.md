# Changelog

All notable changes to Livre Serviço Companion. Every commit is a version,
`MAJOR.MINOR.PATCH+BUILD` (see "Versioning" in `CLAUDE.md`), tagged `vMAJOR.MINOR.PATCH` in git.

History was renumbered on 2026-10-07 so that every commit has its own version; the old
v0.2.0–v0.4.0 release tags no longer exist (old 0.4.0 is now 0.27.1). Entries up to 0.27.0 were
written from the commit history.

## [0.77.0] — 2026-11-01

### Added
- **Reportar erro ou sugestão** (Definições): anyone signed in picks Erro or Sugestão and writes
  a message to the app's admin, sent with their account, store, app version and platform. Only
  the admin reads them: a new online `feedback` table with no policies, written through
  `send_feedback` and read through `feedback_list`, `set_feedback_done` and `delete_feedback`
  (`20261101120000_feedback.sql`, admin only). The admin sees them in Definições → "Erros e
  sugestões recebidos" (still to deal with first, then Tratados; mark dealt with, reopen,
  remove) and a count of those still open on Home. Not shown in the demo. The Política de
  Privacidade (version 2026-11-01) says what is kept and that only the admin sees it.

## [0.76.0] — 2026-11-01

### Added
- **A "Novidades" popup after an update**: the first time Home opens on a new version, a
  dialog lists what changed since the version last seen (every version missed, newest first),
  in plain words from `lib/models/release_notes.dart`. Only versions with notes there show it,
  so small fixes don't interrupt. Closing it ("Entendido") marks it seen on the device and,
  signed in, on the account (user metadata `release_notes_seen`), so it shows once per account
  across the phone and the web. Nothing on a first install or in the demo; an install that
  used the app before counts as having seen up to 0.75.1, so everyone gets this version's
  notes (Documentos, Listas 1.0 / 2.0, Feita / Não feita).

## [0.75.1] — 2026-11-01

### Changed
- **Listas Legacy is now Listas 1.0**: on Home, the side menu, the lists page, Listas 2.0's note
  and the tutorial (whose Listas section shows again in "Novidades").

## [0.75.0] — 2026-11-01

### Added
- **Documentos**, a new Home button (and side-menu entry): PDF documents for every store, opened
  in the app (scroll between pages, pinch to zoom; `pdfrx`, on the phone and the web). The app's
  admin adds them ("Adicionar PDF", up to 50 MB), renames and removes them; everyone else only
  reads. They live online in the new `documents` table and private `documents` bucket
  (`20261101090000_documents.sql`), readable by the admin and any approved store member. The
  list is kept on the device and each PDF is saved the first time it is opened, so both work
  offline; PDFs of removed documents are dropped. The demo has two example documents.
- A Documentos section in the tutorial; Início's step lists the new button.

## [0.74.1] — 2026-11-01

### Changed
- **A "BETA" tag beside the app's name**: in Home's bar, the computer's side menu, the
  presentation page's top bar and the demo banner.

## [0.74.0] — 2026-11-01

### Added
- **Listas 2.0**, a new Home button (and side-menu entry) for the store's new lists. Empty for
  now ("Em breve"): the new system's lists will go there.
- **The tutorial is split by section** (Início, Tarefas, Listas 2.0, Listas Legacy, Camiões…),
  each with a version. When a section changes, its version goes up and Home shows a
  "Novidades" card ("Mudou: …") with just those pages, as if they had never been seen.
  Definições → Tutorial (and the side menu) lists the sections, with "Novo" on the changed
  ones, and "Ver tudo". Whoever finished the old tutorial now sees Início, Listas 2.0 and
  Listas Legacy again.

### Changed
- **The old lists moved to Listas Legacy** (Abertura, Automáticas, Relatório Dia Anterior,
  Visual), unchanged and still used by other stores. The computer's dashboard opens the
  Abertura panel there.

## [0.73.0] — 2026-11-01

### Added
- **Tasks have two markers, ✓ Feita and ✗ Não feita**, in Diárias, Semanais and
  Personalizadas: only one can be ticked, and either one closes the task for that day (or
  week). Não feita asks who and which day, then for a reason (required); the card shows
  "Não feita: <motivo>" in red with the names, and WhatsApp gets "❌ Tarefa não feita: … —
  <motivo>". A Validades window that has closed can still be marked Não feita.

### Changed
- A task marked Não feita no longer counts as pending on Hoje. The Histórico shows it with the
  reason and counts the não feitas; its WhatsApp summary marks them ❌ and open tasks ⬜.
- The demo has an example, and the tutorial's "Marcar uma tarefa" shows the two markers.

## [0.72.1] — 2026-11-01

### Fixed
- **The tabs in Avisos (Recebidos, Enviados) were hard to read** on the black app bar: every
  tab bar in an app bar is now white on black, from one shared widget.

## [0.72.0] — 2026-11-01

### Added
- **The app on a computer uses the whole window**: a side menu on the left with Início, every
  page, Avisos, Definições and Tutorial (the store's name and the version on top, the open page
  highlighted), and the page in the rest of the width.
- **Home is a dashboard on a computer**: the cards and Hoje on the left, and the Tarefas
  diárias and the Lista de Abertura open beside them, to tick and send right there.

### Changed
- On a computer, Tarefas, Listas and a person's page show their tabs side by side; Pessoas,
  Inventários and Pedidos are in columns; Informações in two columns, opened; the camião form in
  two columns. Forms and text pages keep a readable width. The phone is unchanged.

## [0.71.1] — 2026-11-01

### Changed
- **The tutorial is more detailed**: 13 pages, each with a sketch of the screen and numbered
  steps that match the numbers on it (the service day, the ecrã inicial, the Hoje card, marking
  a task, Abertura and Automáticas, Relatório and Lista Visual, receiving a camião, Inventários
  and Pedidos, Pessoas, Informações, Histórico, Avisos, Conta e sincronização), with tips where
  useful.

## [0.71.0] — 2026-11-01

### Added
- **Tutorial**: a few pages showing how the app works (Hoje, Tarefas, Listas, Camiões,
  Inventários e Pedidos, Pessoas e Informações, Histórico, Conta e sincronização). Home shows a
  "Primeira vez na aplicação?" card until the tutorial is finished or the card closed; it can
  be seen again in Definições → Tutorial.
- **The app's version** shows next to the title on Home.

## [0.70.3] — 2026-10-31

### Changed
- The presentation page's footer says "© 2026 Gonçalo Canha" (the year range grows on its
  own).

## [0.70.2] — 2026-10-31

### Fixed
- **The demo didn't start on the website** ("no such vfs"): the browser's in-memory SQLite
  needs a file system registered before opening a database; the demo now registers one kept in
  memory.

## [0.70.1] — 2026-10-31

### Changed
- **The presentation page is now a landing page**, using the computer's whole width: a hero
  with the headline "O dia da loja, das 5h às 5h." and a "Hoje na loja" panel showing a day at
  the store as a timeline; the features in three columns; "Como começar" in three numbered
  steps; a black closing band with the demo. Headlines in Roboto Condensed (bundled).
- **The app on a computer**: every page sits in a centred column instead of stretching across
  the screen, and Home's buttons go four across.
- **The light theme is the default** (a theme chosen in Definições is kept).

## [0.70.0] — 2026-10-31

### Added
- **Presentation page on the website**: a visitor who isn't signed in first sees what the app
  does, how to start (account, store code, approval), and three ways in: Experimentar a demo,
  Criar conta, Entrar. Signed in without a store still opens Conta; the phone app is unchanged.
- **Demo**: the real app on an invented example store (people in every role and team, today's
  tasks half done, camiões, inventários, pedidos, Informações, avisos), with dates around
  today. Everything works, but it lives only in the browser's memory: nothing is saved,
  nothing goes online, reloading starts afresh. A bar at the top says so, with Sair and Criar
  conta; Definições hides the account and data copies.

### Changed
- `sqlite3` is now a regular dependency (the demo's in-memory database on the web), and
  `shared_preferences_platform_interface` is added (its in-memory preferences).

## [0.69.1] — 2026-10-31

### Fixed
- **A "Visto" could overwrite someone else's**: the server took an AvisoVisto's key from the
  app without checking it against its aviso and person. Migration
  `20261031233000_aviso_visto_key` binds the key to them and never replaces another person's
  row. Run it in Supabase after `20261031230000_avisos`.

## [0.69.0] — 2026-10-31

### Added
- **Avisos**: short notices inside the app (no phone notifications). From Segunda Linha /
  Supervisor up, "Novo aviso" sends one to whole teams or chosen people among those one is
  responsible for. Recipients see it at the top of Home until they tap "Visto" (7 days at
  most); the Avisos screen keeps 30 days of received and sent avisos, and the sender sees who
  has seen each and can delete it. Only the sender, the recipients and the admin can read an
  aviso. The Política de Privacidade lists them.

Run migration `20261031230000_avisos` in Supabase before using this version with a store.

## [0.68.0] — 2026-10-31

### Changed
- **Roles on five levels of authority** instead of "Chefe"/"Membro" and the Gerência team:
  Operador (1), Segunda Linha and Supervisor (2), Chefe de Secção (3), Gestor de Área and
  Secretária de Loja (4, Gerência only), Gerente de Loja (5, Gerência only). Each person has
  one role, chosen in the person form ("Função"), shown as their badge and in Conta. Pessoas
  lists each team from the highest level down; search finds a role.
- **Who does what follows the level.** A Chefe de Secção sees the whole profile of, plans the
  folgas of and asks for updates from their team; a Gestor de Área or Secretária de Loja does
  that for every team but Gerência; the Gerente de Loja for everyone. Changing someone's team
  or role needs a higher level than theirs, and only roles below one's own can be given (the
  Gerente can hand over theirs). Join requests are approved from level 3, members managed
  from level 4.
- People saved before this version keep what they had: Gerência's chefe becomes Gerente de
  Loja, the rest of Gerência Gestor de Área, the other chefes Chefe de Secção (Livre Serviço:
  on their turno), and Supervisor / Segunda Linha keep their tag as their role.
- The Política de Privacidade says who sees the whole profile now.

### Added
- **A Chefe de Secção (and up) adds and removes people** in the teams they reach; a removed
  person's account leaves the store. Removing everyone at once stays the admin's.

Run migration `20261031220000_authority_levels` in Supabase before using this version with a
store.

## [0.67.1] — 2026-10-31

### Added
- **Design for authority levels** (`docs/superpowers/specs/2026-10-31-authority-levels-design.md`):
  one role per person (Operador, Segunda Linha, Supervisor, Chefe de Secção, Gestor de Área,
  Secretária de Loja, Gerente de Loja) on five levels, replacing chefe slots and Gerência as
  the source of permissions. No app change yet.

## [0.67.0] — 2026-10-31

### Removed
- **People's phone numbers.** Gone from the person form, the person page (no more call
  button), the WhatsApp registration form and the database: migration
  `20261031200000_no_phone_birthday_only` erases the ones saved and a trigger keeps any from
  coming back. (Contactos Úteis in Informações keep theirs.)

### Changed
- **Birthday instead of date of birth**: only the day and the month ("Aniversário"), no year.
  Saved dates of birth become birthdays, on the phone, online and in backups; "Faz anos" and
  the Hoje card work as before. Backups only carry what the app keeps.
- The Política de Privacidade says so.

## [0.66.2] — 2026-10-31

### Changed
- Política de Privacidade complete: the data is kept in Supabase's West EU (Ireland) region,
  under the legitimate interest in organising the store's work (which anyone may object to).

## [0.66.1] — 2026-10-31

### Changed
- Política de Privacidade: the responsible person and the privacy contact are filled in.

## [0.66.0] — 2026-10-31

### Added
- **Política de Privacidade**: what the app keeps, why, who sees it, where, for how long and
  how to exercise data rights. "Criar conta" opens it first and only goes on with "Li e
  aceito" at the end of the text; the account records the version and when it was accepted.
  Always available in Definições. (The responsible person, contact and Supabase region are to
  be filled in.)

## [0.65.0] — 2026-10-31

### Added
- **One store per person; moves through the admin** (migration
  `20261031180000_store_transfers`). Everyone but the admin belongs to one store, which opens
  on its own at sign-in; they can't join or be added to another. Conta → "Pedir mudança de
  loja" asks the admin, with a note saying where to (it can be withdrawn). The admin sees the
  requests on Home ("N pedidos de mudança de loja"), picks the store and moves the person: the
  account and the profile go to the new store, the history stays in the old one, and the
  person's phone follows by itself. "Mudar de loja" is now only for the admin.

## [0.64.0] — 2026-10-31

### Changed
- **The website opens on Conta**: sign in and choose the store first; Home shows once connected
  (and approved). Leaving the store or signing out goes back there. The phone still works
  without an account.

### Removed
- The weekly reminder to export a backup, and the "Sincronizar agora" button: the data syncs on
  its own. Exporting and importing the file stays in Definições.

## [0.63.2] — 2026-10-31

### Changed
- Pessoas: the admin sees the store's name under each person's name.

## [0.63.1] — 2026-10-31

### Fixed
- **Switching stores no longer mixes them.** Choosing a different store used to keep the
  previous store's data on the phone and merge it into the new one. Now that data leaves the
  phone (it stays in its store) and the new store's comes down; if the previous store still
  has changes not sent, the switch is refused until they are. "Mudar de loja" tries one last
  sync first. Data from before any store still joins the first one.

## [0.63.0] — 2026-10-31

### Removed
- **Store owners.** The app's admin creates stores ("Criar loja" only shows for them) and is the
  only one who may "Apagar Todos os Dados" while syncing or see and edit everyone's data
  everywhere. Gerência now shares and resets the join code and adds, links and removes members
  in Membros; members can only change which person an account is (never a role). Migration
  `20261031150000_no_store_owners` (existing owners become members).

## [0.62.5] — 2026-10-31

### Fixed
- A member could push someone's row with a time in the future, changing nothing but making
  every real edit after it lose (last write wins). A push with no field the caller may change
  now leaves the row alone, and a person is never saved later than the server's clock.

## [0.62.4] — 2026-10-31

### Fixed
- An account not linked to its person (added by email) couldn't be linked to a chefe or to
  Gerência at all: now the owner does it in Membros → "Ligar a uma pessoa", and the message a
  member gets says so.

## [0.62.3] — 2026-10-31

### Changed
- **Profiles follow who may see and edit them.** The person form locks what this account can't
  change (each person their name, photo, phone, birth date, género and notes; chefes their
  team's folgas and ausências; Gerência those, the team, chefe, turno and tags; the owner and
  the admin everything) and hides personal fields it can't see. Editar only shows when
  something can be changed; only Gerência, the owner and the admin add people, and only the
  owner and the admin remove them. Signed out, nothing changes.
- **Pedir atualização** on a person's page (their chefe, Gerência, the owner): they see
  "Atualize o seu perfil" on Home, with who asked, until they save their profile.
- Gerência can also set a person's turno (with the team).

### Fixed
- The person page threw an error when a person was saved while it was open.

## [0.62.2] — 2026-10-31

### Added
- `StoreAccess` says who sees and edits each part of a profile, the same rules as the
  database; a person can be asked to update their profile (`profileUpdateRequestedAt`/`By`),
  which they answer by saving it. The screens follow in the next version.

## [0.62.1] — 2026-10-31

### Changed
- **Sync pulls through `pull_records`**: people come as this account may read them. A phone
  that kept everyone's details whole from before pulls everyone again, once, and keeps only
  what it may see; so does a phone whose account is promoted, demoted or moved team (checked
  after syncs, at most every 10 minutes).

## [0.62.0] — 2026-10-31

### Added
- **People's personal data by hierarchy** (database, migration `20261031120000_person_access`).
  Everyone in a store reads others' name, photo, género, date of birth and role; the rest of a
  person is read only by themselves, the chefe de secção of their team, Gerência, the owner and
  the app admin. The app pulls through `pull_records`, which hides the rest; a plain select
  (and Realtime) doesn't give those rows out. Each field of a person is saved only from someone
  who may edit it: the person their name, photo, phone, birth date, género and notes; their
  chefe their folgas and ausências; Gerência those and the roles; the owner and the admin
  everything. A copy without the hidden fields, pushed back, wipes nothing. Only Gerência, the
  owner and the admin add people; only the owner and the admin delete them. The app follows
  in the next versions.

## [0.61.0] — 2026-10-31

### Removed
- **Horários.** The monthly shift sheet (screen, import/export, codes) is gone: it showed
  everyone's folgas and absences. Who's off comes from each person's folgas and ausências;
  "A trabalhar agora" (Hoje card, task picker) and "Hoje · 07:00–15:00" in Pessoas come from
  each person's own entrada and saída. Older backups with a "horarios" section still import
  (it is ignored).

## [0.60.2] — 2026-10-31

### Changed
- **Asking to join a store** in the app: "Entrar com código" now sends a request; Conta shows
  "Pedido enviado" (Verificar, Cancelar pedido) and nothing of the store reaches the phone
  until it is approved. "Não estou na lista" asks for the name instead of a form: whoever
  approves adds the person. Once approved, "Verificar" syncs and opens the profile.
- **Pedidos para entrar** in Membros (and a count on Home) for chefes, Gerência and the owner,
  to approve or refuse. Members no longer have roles to choose: "Só leitura" is gone.
- "O meu perfil" only lets a member pick themselves from the list; someone missing asks
  Gerência.

## [0.60.1] — 2026-10-31

### Fixed
- A member could take a chefe's or Gerência's access by linking their account to that person.
  Now a member links themselves only once, and never to a chefe or to Gerência (that goes
  through an approver, or the owner); the owner and the admin still link freely.

## [0.60.0] — 2026-10-31

### Added
- **Joining a store waits for approval** (database). Joining with the code now sends a request
  (with the person picked, or a typed name for someone not in the list); until a chefe de
  secção, a member of Gerência, the owner or the app admin approves it, the requester sees
  nothing of the store. Approving a typed name creates that person. Requests can be refused,
  or cancelled by whoever sent them.
- **App admin**: accounts in `app_admins` own every store. "Só leitura" members become normal
  members. Migration `20261031090000_join_approval_admin`; the app follows in the next version.

## [0.59.2] — 2026-10-30

### Docs
- Design for store access: join approval by chefes and Gerência, personal data visible by
  hierarchy, a single app admin, and removing Horários
  (`docs/superpowers/specs/2026-10-30-store-access-design.md`).

## [0.59.1] — 2026-10-30

### Changed
- **"Quem é você?" shows only names and numbers.** Before joining, the list of the store's
  people shows each one's collaborator number (searchable) instead of their team, and the
  database sends nothing else about them (migration `20261030210000_unlinked_people_number`).

## [0.59.0] — 2026-10-30

### Added
- **Joining a store with its code.** The owner sees the store's code in Conta → Membros (copy
  it, or make a new one so the old stops working). Someone signed in taps "Entrar com código",
  picks who they are in the store's list of people (only those without an account show) or
  "Não estou na lista", and joins with Edição; then their person form opens to correct or
  complete it.
- **"O meu perfil"** in Conta: each account is linked to one person in the store (never two
  accounts to the same person), and opens that person's page. Members added by email say who
  they are there. Membros shows each account's person, and the owner can unlink one.
- Run the new `supabase/migrations/20261030190000_join_code_profiles.sql` in the SQL Editor.

## [0.58.1] — 2026-10-30

### Changed
- What another device saves in the store shows up within a couple of seconds instead of up to
  a minute (Supabase Realtime), and the app also syncs as soon as it is opened again.

## [0.58.0] — 2026-10-30

### Added
- **The app runs in a browser**, from the same code: `flutter build web` and put `build/web` on
  any static host. Data, photos and backups work there as on the phone; with an account, the
  browser and the phones share the store's data.
- Photos of people and Informações are shared with the store: they are sent online with each
  sync, and another device downloads one the first time it shows it.

### Changed
- Photos are kept inside the app's database instead of as separate files; the ones already
  on the phone are moved in at the first start of this version.
- In a browser, the backup and horários exports download a file, and WhatsApp opens WhatsApp
  Web in a new tab.
- The web page is called "Livre Serviço Companion", in Portuguese.

### Other
- The online database gets a private `photos` bucket, one folder per store, readable by its
  members and writable by editors and owners
  (`supabase/migrations/20261030170000_photos_bucket.sql`: run it in the SQL Editor).

## [0.57.0] — 2026-10-30

### Added
- **Conta e Sincronização** (Definições): optionally sign in with an email and password, create
  the store or choose one you were added to, and the app keeps this device's data and the
  store's online copy in step with each other. Without an account it works as before, only on
  this device. Signing out or changing store keeps the data here.
- **Membros**: the store's owner adds people by the email of their account, as Edição (reads
  and changes the data) or Só leitura (only reads), changes their role or removes them.

### Changed
- While syncing, only the store's owner can "Apagar Todos os Dados", since it would empty the
  data on every device.

### Other
- The online database gets `store_member_list`, so the Membros screen can show emails
  (`supabase/migrations/20261030150000_store_member_list.sql`: run it in the SQL Editor).
- Builds read the Supabase project from `.env`: `flutter run --dart-define-from-file=.env`.

## [0.56.17] — 2026-10-30

### Other
- Third step towards the web version: the sync engine, which keeps the app's data and a
  store's online database up to date with each other (pushing what was saved here, pulling
  what other devices saved, the copy saved last winning). Nothing starts it until there is a
  login, so there is no visible change yet.
- A day's tasks and lists, a week's tasks, a custom task's entry for a period and a horário
  month are each one row online, so two devices filling in the same day share it.
- Deleting or replacing a horário month now keeps a deleted marker instead of erasing the row,
  so the delete can reach other devices.
- After importing a backup, the next sync sends everything and fetches the store's data again.

## [0.56.16] — 2026-10-30

### Other
- `pubspec.lock` and the generated plugin files no longer list Isar; they now match the move to
  Drift in 0.56.15, which is now checked: `flutter analyze` is clean and every test passes.
- `web/` has `sqlite3.wasm` and `drift_worker.js`, which the web build needs to open its
  database.
- Tests find SQLite on Linux without the `libsqlite3-dev` package.

## [0.56.15] — 2026-10-30

### Changed
- The app's data is now kept in SQLite (through Drift) instead of Isar, which can't run in a
  browser: the second step towards the web version. **Data saved by an earlier version is not
  carried over on its own:** make a backup (Definições → Cópia de segurança) before updating,
  then import it in this version. Backup files keep the same format, so older ones still
  import. The old database file is left on the phone untouched.

### Other
- Tests for the new database and for reading rows in the old backup format.

## [0.56.14] — 2026-10-30

### Other
- First step towards using the app on the web with an online database: the Supabase schema
  (`supabase/migrations`). Stores, their members (viewer, editor, owner) and every synced row
  as a JSON document, with last-write-wins saving and access rules, checked by tests on an
  in-memory Postgres (`supabase/tests`). The app doesn't use it yet: no visible change.

## [0.56.13] — 2026-10-09

### Fixed
- Receção de Camião: the "Expositores" and "Vasilhame a Enviar" titles no longer push their
  buttons off the right edge on a narrow screen or with a large font size, and the Paletes /
  Mistas / Expositores totals shrink to fit instead of overflowing.

### Other
- Screen tests for saving a camião (who received it, paletes, matrícula; nothing saved when
  empty or with more mistas than paletes) and for sending the Abertura sections one by one
  until the list is complete.

## [0.56.12] — 2026-10-09

### Other
- Libraries updated to their latest versions, among them share_plus (10 → 13) and file_picker
  (8 → 13), which share the backup, the horários and Informações photos and pick the file to
  import. No visible change.

## [0.56.11] — 2026-10-09

### Other
- First screen tests: every screen and tab opens from Home, and the Pessoa form saves what was
  filled in. They run on a real, empty database in a temp folder.

## [0.56.10] — 2026-10-09

### Other
- The Pessoa form and Horários screens are split into smaller files
  (`lib/screens/person_form/`, `lib/screens/horarios/`); no change in the app.

## [0.56.9] — 2026-10-09

### Fixed
- Sending a camião again from Histórico now gives the same message as when it was saved: it
  was missing "Por:" (who received it) and the Vasilhame Enviado list.

## [0.56.8] — 2026-10-08

### Fixed
- The entrada and saída set on a person (e.g. a horário de amamentação) now win over their
  horário code: someone on J74 (09:00–18:00) who leaves at 16:00 shows 09:00–16:00 in Pessoas,
  on their page, in the Hoje card, in Horários (Hoje, the tapped cell and the month's hours) and
  in the task picker. The pausa is kept while it still fits inside.

## [0.56.7] — 2026-10-08

### Changed
- Smoother Pessoas: photos are decoded at the size they're shown (not up to 1024 px for a small
  circle), and whether a photo file exists is checked once instead of on every redraw.

### Fixed
- After changing a person's photo, the old one no longer shows until the app restarts (the new
  photo is saved under the same file name, and the decoded old one is now forgotten).

## [0.56.6] — 2026-10-08

### Changed
- Faster startup: the check that fills in ids on very old rows used to read every row of every
  list at each start; it now runs once (and again after importing a backup, which may be old).

## [0.56.5] — 2026-10-08

### Changed
- The "Hoje" card reads only today's automáticas and camiões and the open pedidos (not every
  one ever saved), and its every-minute refresh recounts shifts and Validades from what it
  already read; it only goes back to the database on a change or when a new service day starts.
- Diárias reads only today's automáticas.

## [0.56.4] — 2026-10-08

### Changed
- Histórico: a change (a list sent, a task ticked) reloads only the open tab; the other tabs
  reload when you open them. The Tarefas tab now also updates when an Abertura, Relatório,
  Visual or Automática changes, not only the Diárias.

## [0.56.3] — 2026-10-08

### Changed
- Histórico opens faster: the Tudo and Tarefas tabs read the Abertura, Relatório, Visual and
  Automáticas lists once and group them by day, instead of four queries per day of history.

## [0.56.2] — 2026-10-08

### Changed
- Faster lookups: finding a day's tarefas, listas and relatório, a week's tarefas, a day's
  automáticas, a custom task's entries and rows by id now use the database indexes instead of
  reading every row.

## [0.56.1] — 2026-10-08

### Changed
- The Pessoas form message says the app is a personal project and that every line is
  optional: fill in only what you want, or ignore the message.

## [0.56.0] — 2026-10-08

### Added
- Pessoas: an "Enviar formulário" button next to + opens WhatsApp with a message asking someone
  new for their primeiro e último nome, nº de colaborador, data de nascimento, telefone, género,
  início no Pingo Doce and início nesta loja, to reply with and be added by hand.

## [0.55.0] — 2026-10-08

### Added
- Dark mode. Definições → Aparência: Automático (follows the phone), Claro or Escuro. The dark
  theme keeps the black app bar, uses lighter greens, and every grey text, line and tinted
  cell (Horários table, warning cards, locked lists) follows the theme. The light theme looks
  as before.

## [0.54.0] — 2026-10-08

### Added
- Birthdays, from the date of birth already on the person page: a pink "🎂 Faz anos" tag in
  Pessoas and on the person page on the day, and an "Aniversários" line on the "Hoje" card with
  today's and the next 7 days' birthdays (everyone in Pessoas). A 29 February birthday shows on
  the 28th outside leap years.

## [0.53.1] — 2026-10-08

### Changed
- From the 25th of the month, when next month's horário hasn't been imported yet (and there are
  horários saved), Horários shows "Falta o horário de novembro de 2026" with an Importar button,
  and the "Hoje" card shows the same line.

## [0.53.0] — 2026-10-08

### Added
- Horários: a "Totais do mês" card with each line's hours at work (without pausas), number of
  turnos and days of each ausência (Folga, Férias…), beside the person's contracted hours a
  week when Pessoas has them.
- Horários: two rows under the month table count how many people work each day de dia and de
  noite.

## [0.52.0] — 2026-10-08

### Added
- Search in Histórico: the 🔍 button opens a search field that filters the open tab, ignoring
  accents and capitals. Every word must match: names, matrícula, fornecedor, pedido nº,
  inventory name and code, expositores, the numbers shown and the date ("8/10/2026", "8 de
  outubro", "quinta").

## [0.51.0] — 2026-10-08

### Added
- The "Quem concluiu?" picker starts with an open "A trabalhar agora" section: the Livre Serviço
  people inside their horário shift right now (when the date is today's service day).
- From 19:00 to 05:00 the picker opens Livre Serviço · Noite instead of · Dia.
- People working on the chosen day show their shift ("22:00–07:00") instead of the nº de
  colaborador.

## [0.50.0] — 2026-10-08

### Added
- A "Hoje" card at the top of the home screen for the service day: who of Livre Serviço is on
  shift right now and how many work de dia / de noite today (from the horário), the daily tasks
  still to do (Validades only while its window is open), late pedidos and today's camiões with
  their paletes. Each line opens its page; the card updates as things change and every minute.

## [0.49.4] — 2026-10-08

### Changed
- Internal: the Histórico screen is split into one file per tab (`lib/screens/historico/`) and
  the Receção de Camião form into the form plus its paletes, expositores, totals and vasilhame
  pieces (`lib/screens/truck_form/`). No visible change.

## [0.49.3] — 2026-10-08

### Changed
- The vasilhame list comes filled in with the 27 items of the Jerónimo Martins "Acessórios
  Transporte" sheet (paletes, meias paletes, rolls, skates, carros, caixas), each with its SAP
  code and EAN barcode. It is used until a non-empty list is imported through the backup file,
  and shows in the backup's "vasilhame" section for editing.

## [0.49.2] — 2026-10-08

### Changed
- Pessoas shows only the times of today's shift ("Hoje · 07:00–16:00"), without the horário
  code; the code stays on the person page and the Horários page.

## [0.49.1] — 2026-10-08

### Changed
- Pessoas no longer shows the nº de colaborador under each name; it stays on the person page
  (and searching by it still works).

## [0.49.0] — 2026-10-08

### Added
- Horários for Livre Serviço, kept as a JSON file you export, edit (by hand or with Claude) and
  import: the shift codes with their times, the absence codes (FO, F, A, LP) and, per month, one
  line of codes per person. Importing replaces only the months in the file, so months build up;
  `null` deletes a month. Lines are checked (days in the month, known codes) before anything is
  saved, and names are matched to Livre Serviço people (full name, first and last name, or a
  unique first name); unmatched names are listed.
- Horários page (home): who works today (Dia and Noite, with times) and who is off; the month as
  a read-only grid like the paper sheet, starting at today; the codes used that month.
- Pessoas shows "Hoje · H73 · 07:00–16:00" for people on a shift today; the person page gets
  a Horário block with the next 7 days.
- The codes table comes filled in from the store's sheet, plus W82 (22:00–07:00, pausa
  03:00–04:00) and W3 (22:00–02:00). The horários travel in the full backup too.

### Changed
- Folga, Férias, Ausência and Parentalidade now come from the horário on days that have one (an
  ausência entered in the app still wins; months without a horário use the fixed folgas), in
  Pessoas, the person page and the task picker.

## [0.48.0] — 2026-10-08

### Added
- The vasilhame list lives in the app and travels in the backup file: export, edit its
  `"vasilhame"` section by hand (`{"name", "code"?, "ean"?}` per item), import. A file without
  that section leaves the current list alone; an item without a name stops the import before
  anything changes. The bundled `assets/vasilhame.json` is gone.
- The backup now also carries Pedidos, Tarefas Personalizadas (and their completions) and the
  Lista Visual goal; "Apagar tudo" clears Pedidos and Tarefas Personalizadas too.

### Changed
- The backup file is written indented, one value per line, so it can be edited by hand.
- Import errors show what is wrong in the file (for a JSON typo, its line), for longer.
- Importing an older backup keeps any collection the file doesn't have instead of emptying it.

## [0.47.0] — 2026-10-08

### Added
- Informações entries can be edited, pinned to a new Afixadas card at the top, shared (WhatsApp
  text, or the share menu when they have photos) and carry photos from the camera or gallery,
  shown as thumbnails that open full screen. Tapping an entry offers these actions.
- Contactos Úteis has groups you create (e.g. Fornecedores); each contact has name, phone,
  email and note, with call, WhatsApp and email buttons. Tapping a group renames it. The old
  Responsável de Loja and Suporte Técnico contacts become groups of those names.
- Phone numbers inside any Informações text are tappable to call.

### Fixed
- Deleted Informações entries no longer stay on the page greyed out.

## [0.46.2] — 2026-10-08

### Changed
- A pedido is a form: Novo asks for the número (required), fornecedor and data prevista, and
  "Criar pedido" saves it. An open pedido shows the same form, saving each change as it is made,
  and Finalizar closes it without asking for the número again. Cancelling Novo no longer leaves
  an empty pedido behind. The número shows on open pedidos in the list.

## [0.46.1] — 2026-10-08

### Changed
- A ♂ / ♀ symbol follows the name in Pessoas and on the person page when the género is set.

## [0.46.0] — 2026-10-08

### Changed
- Abertura and Automáticas are sent one section at a time (Congelados, OPLS, Não Perecíveis),
  each with its own "Quem fez?" and WhatsApp message; the Finalizar buttons are gone.
- The Lista de Abertura finalizes itself once all three sections are sent (ticking it in
  Tarefas → Diárias); the last message adds the total. Each section shows who sent it, here and
  in Histórico.
- Each Automáticas send saves a list with just that section; Lista Automática in Diárias is done
  as soon as any section was sent that day.

## [0.45.0] — 2026-10-08

### Added
- Automatic blue tags from the Pingo Doce start date: "Em formação" in the first month, then
  "Novo" or "Nova" until six months. Shown next to the role tags in Pessoas, on the person page
  and in the task picker; searching Pessoas for "formação" or "novo" finds them.
- Optional Género (Masculino / Feminino) on the person form, used to write "Nova" for women
  ("Novo" when not set).

## [0.44.1] — 2026-10-08

### Changed
- Verificar 1ª and Verificar 4ª are due on Tuesday (terça-feira) instead of Monday; they only
  turn red as late from Wednesday.

## [0.44.0] — 2026-10-08

### Added
- Verificação de Validades is split in two daily tasks, each with its own count and people:
  Validades · Manhã (05:00–14:00) and Validades · Noite (19:00–05:00). Each can only be ticked
  while its window is open; under the name it says "Aberta até às 14h", "Abre às 19h", or "Não
  feita" in orange once the Manhã closed undone. Histórico and the person page list both.
  Verificações saved before show as Manhã.

## [0.43.3] — 2026-10-08

### Changed
- Tarefas Diárias, Semanais and Personalizadas are now one Tarefas page with a tab each; home has
  a single Tarefas button. A new personal task is added with the + button on the Personalizadas
  tab.

## [0.43.2] — 2026-10-08

### Changed
- The camião type is now only Perecíveis or Não Perecíveis; Congelados is just a departamento.
  A camião saved as Congelados shows without a type.

## [0.43.1] — 2026-10-08

### Changed
- Congelados is a departamento again in Adicionar, after Bazar.

## [0.43.0] — 2026-10-08

### Added
- Receção de Camião starts by choosing the type of camião: Congelados, Perecíveis or Não
  Perecíveis. It shows at the top of the form (tap to change), in Histórico, on the person page
  and in the WhatsApp message.
- Expositores: lines of Quantidade and Conteúdo / marca ("3 · Coca-Cola"), counted in the totals
  card, listed in Histórico and in the WhatsApp message.

### Changed
- Paletes are counted per departamento: DPH, Mercearia, Bebidas, Bazar, Charcutaria, Iogurtes,
  Meal Solutions, Talho, Peixaria, Bem Estar, Padaria, Fruta and Prodout. Camiões recorded
  before keep their old categories.
- A camião can be saved with only expositores.

## [0.42.1] — 2026-10-08

### Changed
- Someone on férias, baixa, formação or another ausência gets an orange tag with its type next
  to their role tags, in Pessoas, on their page and in the task picker (for the chosen day); the
  orange text under the name now just says until when ("até 14/10"). A folga gets no tag.

## [0.42.0] — 2026-10-07

### Added
- Planning for each person: hours per week, entrada and saída times, weekly folgas, and
  ausências (Férias, Baixa, Formação or other, with first and last day; no reason is kept).
- Someone off today shows it in orange in Pessoas ("Folga", "Férias até 14/10") and on their
  page. In the task picker, people off on the chosen day are greyed out with the reason and
  listed last in their section, but can still be ticked.
- Separate start dates for the store (Início na loja) and the company (Início no Pingo Doce),
  each with how long ago it was ("4 anos e 7 meses").
- Notes, as a list of short entries.

### Changed
- The person form is split into Pessoa, Equipa, Planeamento, Datas and Notas; the person
  page groups its fields the same way.

## [0.41.0] — 2026-10-07

### Changed
- The people picker for marking tasks done is grouped like Pessoas, with collapsible sections:
  only Livre Serviço · Dia starts open. Headers show how many are ticked inside ("2 ✓"), and a
  search field opens every matching section.

## [0.40.0] — 2026-10-07

### Changed
- The person page has two swipeable tabs: Detalhes (photo, name, role badges, then team,
  horário, nº, phone, birth date and start date) and Histórico (the activity list). It opens on
  Detalhes.

## [0.39.0] — 2026-10-07

### Added
- Collapsible sections in Pessoas: tap a team's header to open or close it. Livre Serviço
  starts open and the other teams collapsed; while searching, every matching section is open.

## [0.38.0] — 2026-10-07

### Added
- Segunda Linha tag for Charcutaria, Meal Solutions, Talho, Peixaria, Padaria and Fruta.
- Personnel count at the top of Pessoas ("42 pessoas · 35 tempo inteiro · 7 tempo parcial";
  "5 de 42 pessoas" while searching).

### Changed
- Roles are combinable tags, shown as badges (Chefe filled; Supervisor, Segunda Linha and
  Permanência outlined) in Pessoas and on the person page. In the form, Função na equipa is
  Membro/Chefe and the tags are tick-chips; Permanência moved there from its switch.
- Frente de Loja and Bem Estar no longer have a chefe.

## [0.37.0] — 2026-10-07

### Added
- Supervisor role in Frente de Loja (any number, between chefe and member): pick it under
  Função na equipa. Pessoas lists supervisors after the chefe, the person page shows it, and
  search matches "supervisor".

## [0.36.0] — 2026-10-07

### Added
- Horário for people: Tempo inteiro (default) or Tempo parcial, set in the person form. Pessoas
  marks part-timers ("Tempo parcial"), the person page shows either, and search matches
  "parcial".

## [0.35.0] — 2026-10-07

### Added
- "Permanência" tag for people who can stand in for management when no chefia is present: a
  switch in the person form, a badge in Pessoas and on the person page, and search matches it.

## [0.34.0] — 2026-10-07

### Added
- Fruta team.

### Changed
- "BemEstar" is now shown as "Bem Estar".

## [0.33.0] — 2026-10-07

### Added
- Livre Serviço is split into a day and a night team: each member picks a turno (Dia/Noite) in
  the form, and Pessoas shows "Livre Serviço · Dia" and "Livre Serviço · Noite", each led by its
  chefe. Members without a turno yet show under "Livre Serviço · Sem turno".

## [0.32.1] — 2026-10-07

### Fixed
- Pessoas: the delete confirmation no longer mentions managers/hierarchy, and the search hint
  says "equipa" instead of "cargo".

## [0.32.0] — 2026-10-07

### Added
- Premade teams for people (Livre Serviço, Gerência, Charcutaria, Meal Solutions, Talho,
  Peixaria, Frente de Loja, BemEstar, Padaria), each with a chefe; Livre Serviço has a chefe de
  dia and a chefe de noite. Pessoas is grouped by team, chefes first.

### Removed
- The cargo (job title) field, manager links ("Reporta a") and the manager-grouped Equipas view.
  Existing people start in "Sem equipa".

## [0.31.1] — 2026-10-07

### Other
- Design spec for premade teams (replacing cargo and managers).

## [0.31.0] — 2026-10-07

### Removed
- The "Ordenar" menu on the Pessoas list (name, nº de colaborador and antiguidade orders,
  letter headers). The list is now always grouped by cargo, people A–Z inside each group.

## [0.30.0] — 2026-10-07

### Added
- Pessoas list: a search bar (name, cargo or nº de colaborador, ignoring accents) and an
  "Ordenar" menu: by name with letter headers, by cargo with a section per cargo, by nº de
  colaborador, or by antiguidade (hire date). The last choice is remembered.

## [0.29.0] — 2026-10-07

### Removed
- The organograma (org chart) view on Pessoas; the page now opens in the list view and the
  app-bar button switches between list and teams.

## [0.28.0] — 2026-10-07

### Removed
- The statistics page (Estatísticas), the missed-day justifications that lived on it, and the
  daily goal for automatic lists that only it used.

## [0.27.2] — 2026-10-07

### Other
- Build with Gradle 9.3.1 and a 3 GB Gradle heap.

## [0.27.1] — 2026-10-07

### Other
- Changelog and versioning rules.

## [0.27.0] — 2026-10-07

### Removed
- The people points system.

## [0.26.0] — 2026-10-07

### Removed
- Product catalogue and barcode scanning; Inventário is now a quick record and Pedidos keep only their header.

## [0.25.0] — 2026-10-07

### Removed
- Shift tracking, task and inventory timers, local notifications, and the Supabase cloud sync, login and in-app updater.

## [0.24.8] — 2026-08-26

### Other
- Remove the single-select person picker.

## [0.24.7] — 2026-08-26

### Changed
- A task shows in every claimant's activity feed.

## [0.24.6] — 2026-08-26

### Changed
- History shows multiple names.

## [0.24.5] — 2026-08-26

### Changed
- Multiple people can claim truck receptions and inventory sessions.

## [0.24.4] — 2026-08-26

### Fixed
- Notification rescheduling in visual/auto list services.

## [0.24.3] — 2026-08-26

### Changed
- Multiple people can claim visual/auto list entries.

## [0.24.2] — 2026-08-26

### Changed
- Multiple people can claim opening/report list finalization.

## [0.24.1] — 2026-08-26

### Changed
- Multiple people can claim custom tasks.

## [0.24.0] — 2026-08-26

### Added
- Multiple people can claim daily/weekly tasks.

## [0.23.5] — 2026-08-26

### Changed
- Name-list fields for multi-claim tasks.

## [0.23.4] — 2026-08-26

### Changed
- Multi-select person picker.

## [0.23.3] — 2026-08-26

### Other
- Implementation plan for multi-claim tasks.

## [0.23.2] — 2026-08-26

### Other
- Design spec for multi-claim tasks.

## [0.23.1] — 2026-08-26

### Fixed
- Backdate feedback and a stale period-key comparison in custom tasks.

## [0.23.0] — 2026-08-26

### Added
- Tarefas Personalizadas (custom tasks) on the home screen.

## [0.22.9] — 2026-08-26

### Fixed
- Custom task completion uses the service day, not the wall clock.

## [0.22.8] — 2026-08-26

### Changed
- CustomTasksScreen.

## [0.22.7] — 2026-08-26

### Changed
- CustomTaskService.

## [0.22.6] — 2026-08-26

### Changed
- CustomTask/CustomTaskEntry models.

## [0.22.5] — 2026-08-26

### Changed
- Shift service and home screen updates.

## [0.22.4] — 2026-08-26

### Other
- Implementation plan for custom tasks.

## [0.22.3] — 2026-08-26

### Other
- Design spec for custom tasks.

## [0.22.2] — 2026-08-25

### Fixed
- Review findings for the multi-manager migration and messaging.

## [0.22.1] — 2026-08-25

### Changed
- Backup service updates.

## [0.22.0] — 2026-08-25

### Added
- Grouped-by-team view on the people screen.

## [0.21.1] — 2026-08-25

### Other
- Extract person row into _PersonTile.

## [0.21.0] — 2026-08-25

### Added
- Selecting multiple managers in the person form.

## [0.20.2] — 2026-08-25

### Changed
- Org chart shows a dual-report person under every manager.

## [0.20.1] — 2026-08-25

### Changed
- Multiple managers per person in PersonService.

## [0.20.0] — 2026-08-25

### Added
- People screen, person form and org chart.

## [0.19.5] — 2026-08-25

### Changed
- Person.managerUuids with a startup migration from managerUuid.

## [0.19.4] — 2026-08-25

### Changed
- People feature backend; main.dart cleanup.

## [0.19.3] — 2026-08-25

### Other
- Ignore the .superpowers/ scratch directory.

## [0.19.2] — 2026-08-25

### Other
- Implementation plan for multi-manager reporting and team grouping.

## [0.19.1] — 2026-08-25

### Other
- Design doc for multi-manager reporting and team grouping.

## [0.19.0] — 2026-06-03

### Added
- Pedidos page: orders built by scanning products, with supplier, expected date and WhatsApp sending.

## [0.18.0] — 2026-05-25

### Changed
- Inventory overhauled into timed sessions with scanned lines; fixed adding products.

## [0.17.0] — 2026-05-23

### Removed
- User badges from the history; improved statistics and justifications for missed days.

## [0.16.0] — 2026-05-15

### Added
- Usernames and employee numbers; various fixes.

## [0.15.2] — 2026-05-14

### Fixed
- Update issues; visual improvements.

## [0.15.1] — 2026-05-14

### Fixed
- Update issues.

## [0.15.0] — 2026-05-14

### Added
- In-app updater.

## [0.14.1] — 2026-05-14

### Changed
- Release build setup (dependencies).

## [0.14.0] — 2026-05-14

### Added
- Cloud saving and user authentication.

## [0.13.0] — 2026-05-13

### Added
- Statistics page (Estatísticas).

## [0.12.1] — 2026-05-13

### Fixed
- History issues.

## [0.12.0] — 2026-05-13

### Added
- Information page (Informações).

## [0.11.0] — 2026-05-13

### Added
- Data import/export.

## [0.10.8] — 2026-05-12

### Fixed
- Various issues.

## [0.10.7] — 2026-05-12

### Fixed
- Various issues.

## [0.10.6] — 2026-05-11

### Changed
- Improved performance.

## [0.10.5] — 2026-05-11

### Fixed
- Various issues.

## [0.10.4] — 2026-05-11

### Fixed
- Various issues.

## [0.10.3] — 2026-05-11

### Changed
- Improved the settings page.

## [0.10.2] — 2026-05-11

### Changed
- More notifications.

## [0.10.1] — 2026-05-11

### Fixed
- Shift tracking.

## [0.10.0] — 2026-05-11

### Added
- Notification system and settings page.

## [0.9.1] — 2026-05-11

### Changed
- Expanded messaging; improved the history page.

## [0.9.0] — 2026-05-11

### Added
- WhatsApp messaging.

## [0.8.0] — 2026-05-11

### Added
- Inventories page (Inventários).

## [0.7.5] — 2026-05-11

### Changed
- Improved the products page.

## [0.7.4] — 2026-05-11

### Fixed
- Text formatting on the tasks page; issue in the visual list.

## [0.7.3] — 2026-05-11

### Changed
- Improved truck reception.

## [0.7.2] — 2026-05-11

### Fixed
- More issues.

## [0.7.1] — 2026-05-10

### Fixed
- Various issues.

## [0.7.0] — 2026-05-10

### Added
- Dedicated history page.

## [0.6.2] — 2026-05-10

### Fixed
- Added a missing daily task.

## [0.6.1] — 2026-05-10

### Changed
- Clock in and daily tasks updates.

## [0.6.0] — 2026-05-10

### Added
- Daily tasks (Tarefas Diárias).

## [0.5.0] — 2026-05-10

### Added
- Replenishment lists (Listas de Reposição).

## [0.4.0] — 2026-05-10

### Added
- Vasilhame as a product department.

## [0.3.0] — 2026-05-10

### Added
- Barcode scanning.

## [0.2.0] — 2026-05-10

### Added
- Truck reception (Receção de Camiões).

## [0.1.1] — 2026-05-10

### Changed
- App translated to Portuguese.

## [0.1.0] — 2026-05-10

### Added
- Initial app: local Isar database and clock in/out.
