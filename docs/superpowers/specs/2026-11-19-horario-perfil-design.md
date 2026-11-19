# Horário: the profile before the Excel, and hours without a code

## Why

Some people's real schedule is the one in their profile (fixed folgas, `shiftStart`/`shiftEnd`),
not the Excel's codes. And a one-off day (works 9h–18h instead of 9h–16h) must be markable
even when no code has those hours.

## Order on a day

1. ausência in the app
2. change made in Horários (`HorarioAlteracao`)
3. the profile
4. the Excel file

## The profile over the Excel (`HorarioIndex.dayOf` / `baseDayOf`)

- Excel off codes other than Folga (F, A, LP, unknown) stay.
- Profile folgas (when the person has any) decide: a folga weekday is Folga (code `FO`); an Excel
  Folga on another weekday becomes working.
- Profile hours (both set) replace the hours of any working day (code '').
- A working day with no hours known (Excel Folga, profile has folgas but no hours) stays Folga.
- No profile data: unchanged.
- `HorarioDia.fromProfile` marks a day the profile changed; `fileDayOf` stays the raw file.
- Only for people who have an Excel line that day; with no month, the old fallback is unchanged.

## Changes

- `HorarioService.change` drops the change when it equals the base (code and hours).
- A change with code '' and hours is a shift with no code ("Só horas"); '' with no hours is nothing.
- `changesAgainstFile` always lists an hours-only change.
- `linesOn(day, people:)` gives the same days as `dayOf` for linked lines.
- Day sheet: "Perfil" line when the profile changed the day; "Só horas" button (entrada, saída).

## Approaches

Picked: adjust inside `HorarioIndex.dayOf` (one place, every screen and planning helper follows).
Rejected: adjusting in each planning helper and screen (many places, drift).
