# Horário Perfil Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline; this project never uses subagents). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The profile's folgas and hours win over the Excel (below app changes), and a day can be changed to hours with no code.

**Architecture:** `HorarioIndex.baseDayOf(p, day)` = file day adjusted by the profile; `dayOf` = change, else base. `linesOn(day, people:)` uses `dayOf` for linked lines. Changes with code '' and hours are shifts.

**Tech Stack:** Flutter, Dart, flutter_test.

**Spec:** `docs/superpowers/specs/2026-11-19-horario-perfil-design.md`

## Global Constraints

- `flutter test -j 2`; `flutter analyze` clean.
- Version 0.92.0+221, CHANGELOG, release note, tag v0.92.0. Tutorial `horarios` section version 3.
- Portuguese UI copy: "Perfil", "Só horas".

## Review Focus

- Profile with folgas but no hours, Excel Folga on a working weekday → stays Folga.
- Excel F/A/LP on a profile working day → stays off.
- Hours-only change equal to the profile hours → change removed.
- Swap involving a profile-hours day (code '') → hours carried, not lost.
- Re-import with an hours-only change where the file is empty → still listed, not dropped.

---

### Task 1: Index — profile over file, hours-only changes

**Files:** Modify `lib/models/horario.dart`; Test `test/horario_test.dart`

**Interfaces — Produces:**
- `HorarioDia.fromProfile` (bool, default false); `HorarioDia.fromChange` returns a shift when hours set even with code ''.
- `HorarioIndex.baseDayOf(Person p, DateTime day) → HorarioDia?`
- `HorarioIndex.dayOf`: change (code '' and no hours → null) else `baseDayOf`.
- `HorarioIndex.linesOn(DateTime day, {Map<String, Person> people = const {}})`
- `changesAgainstFile`: a change with code '' and hours is always listed.

- [ ] Tests: profile folga weekday → FO + fromProfile; Excel FO on non-folga weekday with profile hours → shift profile hours, code ''; profile hours replace Excel shift hours; Excel F stays; folgas without hours + Excel FO stays FO; no profile → unchanged; hours-only change is shift; linesOn with people applies the profile; changesAgainstFile lists hours-only change against empty file code.
- [ ] Run, see fail; implement; run, pass.

### Task 2: Service — base comparison, swap

**Files:** Modify `lib/services/horario_service.dart`; Test `test/horario_service_test.dart`

- [ ] Tests: `change(p, d, '', entrada: 540, saida: 1080)` keeps a shift change; same hours as profile base → no change row; swap where a's day is a profile-hours day gives b those hours.
- [ ] `change` compares against `baseDayOf` (code and, for shifts, hours); `known` hours only for a non-empty code.
- [ ] Run, pass.

### Task 3: Screens — people in linesOn, sheet "Perfil" + "Só horas"

**Files:** `lib/screens/horarios/{day,week,edit_sheet}.dart`; Test `test/horarios_screen_test.dart`

- [ ] Day/Week/edit sheet pass `people: view.people` to `linesOn`.
- [ ] Sheet: "Agora" shows no code for '' ; "Perfil: …" line when `now.fromProfile`; "Só horas" button → dialog Entrada/Saída → `_set('', entrada:, saida:)`; "Outro código" dialog reuses the hours fields.
- [ ] Widget test: Só horas saves 09:00–18:00, cell shows "09–18" and the changed dot.

### Task 4: Release

- [ ] Planning docstrings, CLAUDE.md horários paragraph, tutorial step + version, release note, CHANGELOG, version bump, analyze, full tests, commit, tag.
