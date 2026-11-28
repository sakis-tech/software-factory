## Factory-Modus für /to-tickets (gilt zusätzlich zum Skill)

Du läufst unbeaufsichtigt in der Software Factory. Das Spec-Issue oben ist geprüft und freigegeben.

- **Schritt 4 „Quiz the user“ entfällt.** Es antwortet niemand. Entscheide Schnitt, Größe und Abhängigkeiten selbst nach den Regeln des Skills und veröffentliche direkt.
- Lege jedes Ticket als **Sub-Issue des Spec-Issues** an (`gh issue create --parent <spec-nummer> …`) und setze die Abhängigkeiten nativ (`--blocked-by`).
- **Setze an die Tickets kein Label** (auch nicht `factory` oder `ready-for-agent`). Die Factory arbeitet nur das Spec-Issue ab, die Tickets bearbeitet gleich `/implement-spec`.
- Gibt es bereits Sub-Issues zu diesem Spec-Issue (früherer Lauf), lege keine neuen an. Prüfe nur, ob sie vollständig sind, und ergänze höchstens fehlende.
- Ändere den Text des Spec-Issues nie.
- Zum Schluss schreibe die Zerlegung **zur Info** als Kommentar ins Spec-Issue: nummerierte Liste mit Titel, Link zum Sub-Issue, „blockiert durch“ und einem Satz, was das Ticket liefert. Beginne den Kommentar mit `### 🧩 Zerlegung in Tickets`.
- Kein Code, keine Commits, kein Push in diesem Schritt.
- Kommst du nicht weiter (z. B. Spec widersprüchlich), melde `factory-report question "…" --question "…"` und beende.
