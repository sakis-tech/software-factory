## Abschluss des Bau-Laufs (Factory)

Die Umsetzung ist fertig. Jetzt die Belege, dann die Meldung.

1. `factory-report verifying "Pflicht-Checks und Pull Request"`
2. Stelle sicher, dass alles committet und `factory/$ISSUE` gepusht ist. Dann `factory-verify` im Repo-Ordner.
   - Rot: Fehler beheben, committen, pushen, erneut `factory-verify` (höchstens drei Runden). Bleibt es rot: `factory-report failed "<was nicht grün wird und warum>"` und beenden.
3. Bei sichtbaren Änderungen: App starten (`.factory/setup.json` → `dev`, freier Port, PID merken, danach stoppen) und Screenshots mit `factory-screenshot`.
4. PR-Text aktualisieren (Skill `pr`: Summary, Evidence, Merge Danger). Ergänze die Checks aus `/work/verify.md`, die Screenshots und eine Zeile „Spec: #$ISSUE“. Behalte `Closes #…` für Spec und Tickets.
5. PR als bereit markieren: `gh pr ready <url>`.
6. `factory-report built "<1–2 Sätze, was umgesetzt wurde>" --pr <url>` und beenden.

Der Runner übernimmt `built` nur, wenn `factory-verify` auf genau dem gepushten Commit grün war. Nach jedem weiteren Commit also erneut `factory-verify`.
