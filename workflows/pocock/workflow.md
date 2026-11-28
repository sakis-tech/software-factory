# Workflow: Matt Pocock

Baut auf den Skills aus [mattpocock/skills](https://github.com/mattpocock/skills) von Matt Pocock auf (MIT-Lizenz). Die Skills sind im Job-Image installiert (fester Commit, siehe `image/Dockerfile`).

## Aufgabenteilung

- **Du (lokal mit Claude Code):** einmal pro Repo `/setup-matt-pocock-skills` (GitHub als Tracker, das Label für `ready-for-agent` heißt `factory`). Pro Feature: `/grill-with-docs` → `/to-spec`. Die Spec landet als GitHub Issue und bekommt automatisch das Label `factory`. Damit übernimmt die Factory.
- **Factory (auf dem Server, ohne dich):** Prüfung der Spec, `/to-tickets` (Tickets als Sub-Issues), `/implement-spec` (inkl. `/code-review`), Pull Request, unabhängige Abnahme.
- **Du:** Pull Request prüfen, mergen, danach `/retro` bzw. der Verbesserungs-Lauf der Factory.

## Ablage

- **Spec:** das GitHub Issue selbst (Vorlage aus `/to-spec`: Problem Statement, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope). Die Factory ändert den Issue-Text nie.
- **Tickets:** Sub-Issues des Spec-Issues mit nativen Abhängigkeiten („blocked by“). Kein Label `factory` an Tickets.
- **Domänen-Doku:** `GLOSSARY.md` und `docs/adr/` im Repo (entstehen beim Grillen).
- **Konfiguration für die Skills:** `docs/agents/*.md` im Repo (von `/setup-matt-pocock-skills`).
- **Stack und Prüfbefehle:** weiterhin `docs/stack.md` und `.factory/setup.json`.

## Zuordnung zu den Factory-Phasen

- **Prüfung** (eigener Lauf, entwickelt nichts): Ist das Issue eine vollständige Spec bzw. ein klarer Bug? Testbar, widerspruchsfrei, im Stack? Bei Freigabe Testszenarien nach `/scenarios/scenarios.md` (außerhalb des Repos).
- **Bau** (die Factory ruft die Skills nacheinander auf, jeder Schritt mit frischem Kontext):
  1. Schritt **Architektur** → `/to-tickets` (ohne Rückfrage an den Menschen; Zerlegung als Info-Kommentar ins Spec-Issue)
  2. Schritt **Umsetzung** → `/implement-spec` auf dem Branch `factory/<nummer>` (Sub-Agents, `/tdd`, `/code-review`), Entwurfs-PR
  3. Schritt **Tests** → Abschluss: `factory-verify` auf dem gepushten Stand, PR-Text nach `/pr`, Meldung `built`
- **Abnahme** (eigener Lauf, neuer Agent): Spec-Issue, Akzeptanzkriterien der Tickets und Testszenarien im Browser prüfen. Bestanden → **Review**, sonst zurück in den Bau (max. 2 Runden, danach Review mit „Abnahme nicht bestanden“).
- **Rückgabe, Änderungswunsch, erneuter Versuch:** `/implement` mit den Befunden auf demselben Branch, dann wieder Abschluss.

Stack-Regeln: `/factory/workflows/starter-kit/stacks/<name>.md` (laut `docs/stack.md`).
