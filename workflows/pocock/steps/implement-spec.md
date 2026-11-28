## Factory-Modus für /implement-spec (gilt zusätzlich zum Skill)

Du läufst unbeaufsichtigt in der Software Factory. Spec = das Issue oben, Tickets = seine Sub-Issues.

- **Integrations-Branch ist `factory/$ISSUE`.** Er ist bereits ausgecheckt. Lege keinen anderen an. Pushe ihn (`git push -u origin factory/$ISSUE`) nach dem ersten Merge eines Tickets.
- Öffne dann einen **Entwurfs-PR** von `factory/$ISSUE` gegen `$FACTORY_DEFAULT_BRANCH`. Im PR-Text stehen `Closes #$ISSUE` und je Ticket `Closes #<ticket>`. Schreibe den PR-Text nach dem Skill `pr`.
- Gibt es schon einen offenen PR für `factory/$ISSUE`, nutze ihn weiter.
- Arbeite **nur offene Tickets** ab. Bereits erledigte (geschlossene) Tickets nicht erneut umsetzen.
- Halte dich an `docs/stack.md` und die Stack-Regeln unter `/factory/workflows/starter-kit/stacks/`.
- **Nie mergen in den Standard-Branch.** Kein `gh pr merge`, kein Auto-Merge. Merges zwischen Ticket-Branches und dem Integrations-Branch sind erlaubt.
- Den Entwurfs-PR **noch nicht** als bereit markieren. Das macht der Abschluss-Schritt nach den Pflicht-Checks.
- Schließe Tickets nicht von Hand. Sie schließen sich beim Merge des PRs.
- Nie im Chat fragen. Bei echter Unklarheit `factory-report question "…" --question "…"` und beenden. Technisch festgefahren: `factory-report failed "…"`.
