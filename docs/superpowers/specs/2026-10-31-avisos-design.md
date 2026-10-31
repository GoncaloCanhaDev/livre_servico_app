# Avisos — design

The second of three projects: (1) authority levels (done, 0.68.0), (2) Avisos, (3) website
presentation page and demo.

## Intent

Someone with authority wants to tell their people something without leaving the app: "Falta
fazer a verificação de validades da noite", "Atualizem as vossas folgas de novembro". Today
that goes through WhatsApp or word of mouth and gets lost. An aviso is a short one-way notice,
inside the app only, to a team or to individual people, that each recipient clears with
"Visto".

## Goals

- Level 2 and up (Segunda Linha, Supervisor and above) send an aviso to people they reach
  (the `reaches` rule from authority levels): a whole team, several teams, or individual
  people.
- Recipients see it at the top of Home until they tap "Visto".
- The sender sees who has seen it and who hasn't, and can delete it.
- Avisos stop showing on Home after 7 days on their own.

## Non-goals

- Phone notifications, sounds, badges outside the app, emails.
- Replies, conversations, reactions, attachments, editing a sent aviso.
- Scheduling an aviso for later.

## Anti-goals

- Someone reading an aviso that wasn't for them: an aviso to one person is private between
  sender and recipient (and the app's admin), including on the server and through Realtime.
- Someone sending to people they don't reach (a Segunda Linha of Talho messaging Peixaria).
  The server refuses it, not just the app.
- Two devices fighting over a "Visto" (one person's "Visto" never undoes another's).

## Who sends to whom

| Sender level | Recipients they can pick |
|---|---|
| 2, 3 | anyone in their own team (level 3 also people with no team), or "toda a equipa" |
| 4 | any team except Gerência, or anyone in them, or "todas as equipas" (except Gerência) |
| 5 | any team, anyone, or "toda a loja" |
| admin | anyone |

The choice of "a team" is resolved to its people **at the moment of sending**: the aviso
stores the list of recipient person uuids. Someone joining the team later doesn't get it;
someone moving away still has it. The sender is never a recipient of their own aviso.

Only people with a linked account can tap "Visto", but people without one are still listed as
recipients (they'll see it once they link an account, if within 7 days).

## What people see

- **Home**: an "Avisos" card at the top (above the Hoje card) listing the unseen avisos for
  this account's person, newest first: the text, "De <nome> · <quando>" (e.g. "há 2 h",
  "ontem 18:30"), and a "Visto" button. Once all are seen, the card disappears.
- **Avisos screen** (from the card's "Ver todos" and from a Home menu entry for level 2+):
  two tabs, *Recebidos* (the last 30 days, seen or not) and *Enviados* (level 2+, the last 30
  days). Each sent aviso shows "Visto por 5 de 8"; tapping opens the names, seen first with the
  time, then the rest. A sent aviso can be deleted there (asks first).
- **Novo aviso** (a button on the Avisos screen and on Home for level 2+): a text field (up to
  500 characters, required) and "Para": chips for the teams they reach plus "Escolher pessoas"
  (a list from `buildPeopleSections`, filtered to people they reach, multi-select). Sending
  shows "Aviso enviado a N pessoas".
- After 7 days an aviso leaves the Home card even if unseen; it stays in the Avisos screen
  until 30 days.
- With no store (signed out, one phone) the feature doesn't appear at all.

## Data

- New collection `Aviso` (`lib/models/aviso.dart`, mixes in `SyncFields`, registered in
  `LocalDb.collections`): `text`, `sentAt`, `fromPersonId` (sender's person `syncUuid`),
  `fromName` (the name when sent, so it shows even if that person is gone), `toPersonIds`
  (list of person `syncUuid`s). Never edited after sending; deleting it is a soft delete by the
  sender (or admin).
- New collection `AvisoVisto`: `avisoId`, `personId`, `seenAt`. Keyed online by
  `'<avisoId>/<personId>'` (`syncKey`), so each person's "Visto" is its own row and never
  conflicts with anyone else's.
- Both get `toJson` / `fromJson` like the other models.

## Server

A new migration:

- **Who reads an `Aviso` row**: its sender, its recipients (`data -> 'toPersonIds'` contains the
  caller's person id), and the admin. The `records` select policy and `pull_records` skip the
  other `Aviso` rows entirely (not redacted: not sent). An `AvisoVisto` row is readable by the
  person who saw, the aviso's sender, and the admin.
- **Who writes**: `push_records` accepts a new `Aviso` only when the caller's level is 2+,
  `fromPersonId` is the caller's own person, and every recipient is a non-deleted person the
  caller reaches; otherwise the row is dropped. An existing `Aviso` changes only to be
  deleted, by its sender or the admin. An `AvisoVisto` is accepted only for the caller's own
  person and an aviso they received.
- Realtime keeps working through the select policy, as for Person rows.

## Where it changes

- `lib/models/aviso.dart` (both models and pure helpers: `avisosOnHome(avisos, vistos,
  personId, now)` — unseen, for them, under 7 days, newest first; `recipientsFor(access,
  people, teamIds)`; `seenBy(aviso, vistos)`).
- `lib/services/aviso_service.dart` (`ChangeNotifier`, `LocalDb.listenRemote`): `send`,
  `markSeen`, `delete`, reads.
- `StoreAccess.canSendAvisos` (level ≥ 2, signed in to a store, linked to a person) and the
  reach rule reused for recipients.
- Home: `AvisosCard` (`lib/screens/widgets/avisos_card.dart`); `lib/screens/avisos_screen.dart`
  (tabs) and `lib/screens/aviso_form_screen.dart` (Novo aviso).
- Migration + `supabase/tests` cases for every row of "Server".
- Privacy policy: avisos are new personal data (who sent what to whom, who saw it, when):
  add them to "Que dados são guardados" and "Quem vê os seus dados", bump the version.
- `CLAUDE.md` (models, services, the new collections), CHANGELOG, MINOR bump.

## Left to the builder

- Exact widget layout and wording of times ("há 2 h").
- Whether "Escolher pessoas" and team chips can mix in one aviso (the result is just the union
  of uuids either way).
- How the Home entry for "Novo aviso" looks (icon button in the card or app bar).
