# Changelog

All notable changes to Livre Serviço Companion. Every commit is a version,
`MAJOR.MINOR.PATCH+BUILD` (see "Versioning" in `CLAUDE.md`), tagged `vMAJOR.MINOR.PATCH` in git.

History was renumbered on 2026-10-07 so that every commit has its own version; the old
v0.2.0–v0.4.0 release tags no longer exist (old 0.4.0 is now 0.27.1). Entries up to 0.27.0 were
written from the commit history.

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
