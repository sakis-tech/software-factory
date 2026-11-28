#!/usr/bin/env bash
# Startet einen Factory-Job: Repo holen, Branch auschecken, Claude Code mit Playbook laufen lassen.
# Erwartet: REPO, ISSUE, BRANCH, MODEL, WORKFLOW, GH_TOKEN, CLAUDE_CODE_OAUTH_TOKEN (oder ANTHROPIC_API_KEY)
# und /work/prompt.md (vom Runner geschrieben).
set -euo pipefail

log() { echo "[factory] $*"; }

: "${REPO:?}" "${ISSUE:?}" "${BRANCH:?}"
MODEL="${MODEL:-opus}"
export PHASE="${PHASE:-build}"   # check = prüfen, build = entwickeln, accept = unabhängige Abnahme
WORKFLOW="${WORKFLOW:-starter-kit}"

# Workflow-Skills als Nutzer-Skills bereitstellen (landen nicht im Ziel-Repo)
mkdir -p "$HOME/.claude/skills"
if [ -d "/factory/workflows/$WORKFLOW/skills" ]; then
  cp -r "/factory/workflows/$WORKFLOW/skills/." "$HOME/.claude/skills/"
fi

gh auth setup-git >/dev/null
GH_LOGIN=$(gh api user --jq .login)
GH_ID=$(gh api user --jq .id)
git config --global user.name "$GH_LOGIN (Software Factory)"
git config --global user.email "${GH_ID}+${GH_LOGIN}@users.noreply.github.com"
git config --global init.defaultBranch main

cd /work
if [ ! -d repo/.git ]; then
  log "Klone $REPO"
  gh repo clone "$REPO" repo -- --quiet
fi
cd repo
git fetch --quiet origin
DEFAULT_BRANCH=$(gh repo view "$REPO" --json defaultBranchRef --jq .defaultBranchRef.name)
if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
  git checkout --quiet -B "$BRANCH" "origin/$BRANCH"
  # Die Abnahme startet immer mit genau dem gepushten Stand, ohne Reste früherer Läufe
  if [ "$PHASE" = "accept" ]; then git reset --quiet --hard "origin/$BRANCH" && git clean -ffdxq; fi
else
  git checkout --quiet -B "$BRANCH" "origin/$DEFAULT_BRANCH"
fi

# Abhängigkeiten installieren (zum Entwickeln und für die Abnahme nötig)
if [ "$PHASE" != "check" ] && [ -f .factory/setup.json ]; then
  INSTALL=$(jq -r '.install // empty' .factory/setup.json)
  if [ -n "$INSTALL" ]; then
    log "Setup: $INSTALL"
    bash -lc "$INSTALL" > /work/setup.log 2>&1 || log "Setup fehlgeschlagen (siehe /work/setup.log), der Agent kümmert sich"
  fi
fi

export FACTORY_DEFAULT_BRANCH="$DEFAULT_BRANCH"
MODE="${MODE:-new}"

# Playbook: eigenes pro Workflow, sonst das allgemeine
PLAYBOOK="/factory/workflows/$WORKFLOW/playbook.md"
[ -f "$PLAYBOOK" ] || PLAYBOOK=/factory/playbook.md

# Ein Claude-Code-Aufruf. Alle Aufrufe eines Laufs landen hintereinander in /work/claude.jsonl.
run_claude() {
  claude -p "$1" \
    --append-system-prompt-file "$PLAYBOOK" \
    --add-dir "/factory/workflows" \
    --model "$MODEL" \
    --dangerously-skip-permissions \
    --output-format stream-json --verbose \
    >> /work/claude.jsonl 2>> /work/claude.err < /dev/null
}

# Hat der Agent schon einen Endstand gemeldet (Rückfrage, Fehlschlag …)? Dann keinen weiteren Schritt starten.
reported_end() {
  local st; st=$(jq -r '.status // empty' /work/status.json 2>/dev/null || true)
  case "$st" in question|failed|rejected|approved|accepting|review) return 0 ;; esac
  return 1
}

# Anweisungen eines Schritts mit den Werten dieses Laufs
step_text() { sed -e 's/\$FACTORY_DEFAULT_BRANCH/'"$DEFAULT_BRANCH"'/g' -e 's/\$ISSUE/'"$ISSUE"'/g' "/factory/workflows/$WORKFLOW/steps/$1.md"; }

: > /work/claude.jsonl; : > /work/claude.err
set +e
if [ "$WORKFLOW" = "pocock" ] && [ "$PHASE" = "build" ]; then
  # Matt Pococks Skills dürfen nur per /befehl gestartet werden: die Factory ruft sie nacheinander auf, jeder Schritt mit frischem Kontext.
  ISSUE_URL="https://github.com/$REPO/issues/$ISSUE"
  CODE=0
  if [ "$MODE" = "new" ] || [ "$MODE" = "retry" ]; then
    SUBS=$(gh issue view "$ISSUE" -R "$REPO" --json subIssues --jq '.subIssues.totalCount' 2>/dev/null || echo 0)
    if [ "${SUBS:-0}" = "0" ]; then
      log "Schritt 1: /to-tickets"
      factory-report architecture "Spec wird in Tickets zerlegt (/to-tickets)" >/dev/null
      run_claude "/to-tickets $ISSUE_URL

$(step_text to-tickets)

$(cat /work/prompt.md)"; CODE=$?
    fi
    if [ $CODE -eq 0 ] && ! reported_end; then
      log "Schritt 2: /implement-spec"
      factory-report implementing "Tickets werden umgesetzt (/implement-spec)" >/dev/null
      run_claude "/implement-spec $ISSUE_URL

$(step_text implement-spec)

$(cat /work/prompt.md)"; CODE=$?
    fi
  else
    log "Schritt 2: /implement ($MODE)"
    factory-report implementing "Befunde bzw. Änderungswunsch werden umgesetzt (/implement)" >/dev/null
    run_claude "/implement $ISSUE_URL

$(step_text implement)

$(cat /work/prompt.md)"; CODE=$?
  fi
  if [ $CODE -eq 0 ] && ! reported_end; then
    log "Schritt 3: Abschluss"
    run_claude "$(cat /work/prompt.md)

$(step_text finish)"; CODE=$?
  fi
  # Eine Gesamtzeile für den Runner: Kosten, Schritte und Dauer aller Aufrufe zusammen
  jq -s -c '[.[] | select(.type == "result")] | {type: "result", subtype: "factory-total",
      is_error: (map(.is_error // false) | any), num_turns: (map(.num_turns // 0) | add // 0),
      duration_ms: (map(.duration_ms // 0) | add // 0), total_cost_usd: (map(.total_cost_usd // 0) | add // 0),
      result: (last.result // "")}' /work/claude.jsonl >> /work/claude.jsonl 2>/dev/null
else
  log "Starte Claude Code ($MODEL, Phase: $PHASE, Workflow: $WORKFLOW) für $REPO#$ISSUE auf $BRANCH"
  run_claude "$(cat /work/prompt.md)"; CODE=$?
fi
set -e
log "Claude Code beendet mit Exit-Code $CODE"
tail -n 1 /work/claude.jsonl | jq -r '"Ergebnis: " + ((.result // "-") | tostring | .[0:500])' 2>/dev/null || true
exit $CODE
