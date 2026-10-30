# Store access: join approval, personal data, app admin

Date: 2026-10-30. Status: approved.

## Why

Since v0.59.0 anyone with a store's join code becomes an editor at once and every member
pulls every row of the store: phones, birth dates, ausências, notes, horários, all of it,
and can change anyone's profile. The app holds colleagues' personal data, so access has to
follow the store's own hierarchy: chefes de secção look after their team, Gerência after
everyone, and the app's author (the only admin) can see and fix anything anywhere.

## Goals

1. **Join approval.** Joining with the code only *asks* to join. The requester sees nothing
   of the store until a chefe de secção, a member of Gerência or the admin approves them.
2. **Personal data by hierarchy.** A regular member sees only the public part of other
   people's profiles. A chefe de secção sees everything about their own team's people,
   Gerência about everyone in the store, the admin about everyone in every store.
3. **Profile edits by hierarchy** (table below), enforced by the server, not just the UI.
4. **"Atualize o seu perfil".** Chefes (own team), Gerência and the admin can ask a person to
   update their profile; the person sees it in the app until they save their profile.
5. **Horários removed** from the app entirely (they would expose everyone's folgas and
   absences by another route).
6. **App admin.** One global admin (the author) sees and edits everything in every store,
   and can open any store from the Conta store list without being a member.

## Non-goals

- No push/phone notifications (the app has none); the update request lives in the app.
- No change to who edits everyday data: lists, tasks, camiões, inventories, pedidos,
  Informações stay readable and editable by every approved member.
- No per-team restriction on everyday data.
- No UI to manage admins: the admin is set once by hand in SQL.

## Anti-goals (a failure even if it "works")

- Personal data reaching a device that may not see it, by any route: pull, Realtime payload,
  RPC, photo listing or backup. Hiding it only in the UI is a failure.
- Anyone able to grant themselves access by editing their own profile (e.g. setting their
  team to Gerência or giving themselves a chefe slot) or by tampering with the app.
- A redacted copy of a person, pushed back by a device that can't see everything,
  wiping the hidden fields on the server.
- Losing existing data or locking the owner out during the migration.

## Who is what

Derived on the server from the **Person the account is linked to**
(`store_members.person_id` → that Person's record in `records`):

- **Chefe de secção** of team T: their Person has `team = T` and a non-null `chefe`
  slot that T has (Livre Serviço: Chefe de dia / Chefe de noite; Gerência's Chefe counts as
  Gerência anyway). Supervisor, Segunda Linha and Permanência tags are *not* chefes.
- **Gerência**: their Person has `team = 'gerencia'`.
- **Member**: any other approved account, including one not linked to a person yet.
- **Admin**: the user id listed in a new `app_admins` table (just the author). Admin
  powers apply in every store, member or not.
- The store's **owner** (its creator, the existing `owner` role) keeps the owner-only
  powers it has today (join code, members list management, "Apagar Todos os Dados") and
  otherwise counts as whatever their linked person makes them.

Promoting someone in the app (team or chefe slot) is what gives them access.

## Profile fields

**Public** (every approved member sees them for everyone): `fullName`, `photoPath`,
`genero`, `dateOfBirth`, `team`, `chefe`, `supervisor`, `segundaLinha`, `permanencia`
(the role), plus the sync fields and `createdAt`.

**Personal** (everything else): `collaboratorNumber`, `phoneNumber`, `hireDate`,
`storeStartDate`, `turno`, `partTime`, `weeklyHours`, `folgas`, `shiftStart`, `shiftEnd`,
`ausencias`, `notes`, and the new update-request fields.

Exception kept on purpose: the "Quem é você?" list before joining shows name and
collaborator number (v0.59.1), so a joiner can tell apart two people with the same name.

## Who edits what

| Fields | The person | Chefe (own team) | Gerência | Admin |
|---|---|---|---|---|
| `fullName`, `photoPath`, `phoneNumber`, `dateOfBirth`, `genero`, `notes` | ✓ | | | ✓ |
| `folgas`, `ausencias` | | ✓ | ✓ | ✓ |
| `team`, `chefe`, `supervisor`, `segundaLinha`, `permanencia` | | | ✓ | ✓ |
| update request (set) | | ✓ | ✓ | ✓ |
| update request (clear) | ✓ (by saving) | ✓ | ✓ | ✓ |
| every other field (`collaboratorNumber`, dates, turno, hours, shifts…) | | | | ✓ |
| add a new person | (own, when joining) | | ✓ | ✓ |
| delete a person | | | | ✓ |

Builder's call, flagged: Gerência can also make someone Gerência or a chefe (it is "any
role"), and `turno`/`partTime`/`weeklyHours`/shift times stay admin-only since nobody asked
otherwise.

## Joining

- `join_store` no longer makes an editor: it records a **pending** membership (a new
  `status` column on `store_members`, `pending` / `approved`) with the person the joiner
  picked, or with the name they typed under "Não estou na lista". A pending member reads no
  records, photos or Realtime events of the store.
- The app shows the joiner "Pedido enviado: aguarde aprovação" in Conta until approved,
  and lets them cancel the request.
- Chefes, Gerência and the admin see pending requests (Conta → Membros, and a count on
  Home) with the person picked or the typed name, and approve or refuse. Any chefe may
  approve any request (a new joiner has no team yet). Approving a typed name creates that
  Person (name only) and links it. Refusing deletes the request.
- After approval the joiner's next sync pulls the store and `completeProfile` opens their
  profile as today, limited to the fields they may edit.
- Existing members at migration time become `approved`. The `viewer`/`editor` roles stop
  meaning anything (everyone approved edits everyday data); keep the enum values for old
  rows, drop "Só leitura" from the UI.

## Server enforcement (the how that matters)

Records stay one JSON document per Person locally and online (no model split), but:

- **Reads.** The `records` select policy stops returning `Person` rows to a caller unless
  they may see that person's personal data (self, chefe of the person's team, Gerência,
  admin). Everyone pulls Person rows through a new RPC (e.g. `pull_people(store, since)`)
  that returns the full document to those allowed and the public fields only to the rest.
  Because Realtime postgres_changes respects the select policy, regular members never get
  a full Person payload over Realtime; the app's other triggers (every minute, after saves)
  still bring the redacted rows.
- **Writes.** `push_records` handles `Person` rows field by field: starting from the
  server's copy, it applies only the fields the caller may edit (table above), keeps
  every other field as the server has it, and refuses (returns the server copy) a new
  Person the caller may not add or a delete they may not make. Last-write-wins on
  `updated_at` still applies to the row. So a redacted local copy pushed back can never
  blank hidden fields, and a tampered client can't widen its own access.
- Direct `insert`/`update` on `records` by the client is no longer allowed for `Person`
  (only through `push_records`).
- Pending members match no store in `my_store_ids`, so the existing policies on `records`,
  `stores` and the photos bucket already shut them out.
- Admin: `my_store_role`/`my_store_ids` (or a new helper) treat an `app_admins` user as
  owner of every store; Conta lists every store for the admin.
- `supabase/tests` covers each row of the edit table, the redaction, pending members seeing
  nothing, and a redacted push not wiping fields.

## App changes

- Person form: fields the current account may not edit are read-only; fields it may not
  see are not shown (the local copy simply doesn't have them).
- Pessoas, person page, Hoje card, task picker: work from what's on the device. For a
  regular member, folgas/ausências/shifts of others aren't there, so "who's off" and the
  away/tenure tags only show where the data is visible. Faz anos keeps working (public
  `dateOfBirth`).
- "Pedir atualização" on a person's page for those allowed; the person sees an
  "Atualize o seu perfil" card on Home (who asked, when) until they save their profile,
  which clears the request.
- Signed out (no store) the app behaves as today: one local user who sees and edits
  everything.
- Remove Horários: `horarios_screen.dart` and `screens/horarios/`, `HorarioService`,
  `HorarioMes`, `horario.dart`, `horario_codigos.dart`, their tests and prefs, the Home
  entry, and the `horario:` parameters of `offLabelOn` / `awayTagOn` / `offNoteOn` /
  `buildPeopleSections` and `today.dart`. Backups with a horários section still import
  (it is ignored). Online `HorarioMes` rows are left as they are. Update `CLAUDE.md`.

## Order of work

Each step is its own version (CLAUDE.md "Versioning"):

1. Join approval (pending members, approve/refuse UI, admin table and store list).
2. Remove Horários.
3. Personal data: redacted pull, field-level push, update requests, form restrictions.

## Left to the builder

SQL and RPC names, the exact UI wording and placement, how the app stores the
update-request fields (`profileUpdateRequestedAt` / `…By` on `Person` is the obvious
choice), and the sync engine changes needed to pull `Person` through the new RPC.
