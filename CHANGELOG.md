# Changelog

All notable changes to Livre Serviço Companion. Every commit is a version,
`MAJOR.MINOR.PATCH+BUILD` (see "Versioning" in `CLAUDE.md`), tagged `vMAJOR.MINOR.PATCH` in git.

History was renumbered on 2026-10-07 so that every commit has its own version; the old
v0.2.0–v0.4.0 release tags no longer exist (old 0.4.0 is now 0.27.1). Entries up to 0.27.0 were
written from the commit history.

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
