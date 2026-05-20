#!/bin/bash
# context-guard.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: UserPromptSubmit (before every user turn)
# Purpose: 3-phase context protection gate:
#   Phase 1 (warn):  at (trigger_ratio - 0.05) → advisory warning to begin
#                    save-state ritual (exit 0).
#   Phase 2 (stop):  at (trigger_ratio - 0.03) → BLOCK (exit 2) if the elite
#                    save-state ritual has NOT been performed recently.
#                    Ritual freshness is detected by COMPACT_STATE.md mtime
#                    (< 5 min). Once fresh, allow with reminder (exit 0).
#   Phase 3 (compact): at trigger_ratio → Kimi auto-compacts; PreCompact
#                    hook handles post-compact recovery.
#
# Hook protocol: exit 0 = allow; exit 2 + stderr = BLOCK; stdout on
# exit 0 is appended to agent context.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "")

# If we cannot identify the session, silently allow.
if [ -z "$SESSION_ID" ]; then
    exit 0
fi

# Locate the context file for this session.
CONTEXT_FILE=$(find ~/.kimi/sessions -path "*/${SESSION_ID}/context.jsonl" -type f 2>/dev/null | head -1)
if [ -z "$CONTEXT_FILE" ] || [ ! -f "$CONTEXT_FILE" ]; then
    exit 0
fi

# Extract the latest token_count from _usage records.
TOKEN_COUNT=$(grep '"_usage"' "$CONTEXT_FILE" 2>/dev/null | tail -1 | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('token_count', 0))
except Exception:
    print(0)
" 2>/dev/null || echo "0")

# Validate numeric token count.
if ! [[ "$TOKEN_COUNT" =~ ^[0-9]+$ ]] || [ "$TOKEN_COUNT" -eq 0 ]; then
    exit 0
fi

# Read model configuration from Kimi CLI config.
CONFIG_FILE="${HOME}/.kimi/config.toml"
MAX_CTX=262144
RATIO=0.85

if [ -f "$CONFIG_FILE" ]; then
    CFG_MAX=$(grep -oP '(?<=^max_context_size = )\d+' "$CONFIG_FILE" 2>/dev/null | head -1 || true)
    CFG_RATIO=$(grep -oP '(?<=^compaction_trigger_ratio = )[0-9.]+' "$CONFIG_FILE" 2>/dev/null | head -1 || true)
    [ -n "$CFG_MAX" ] && MAX_CTX="$CFG_MAX"
    [ -n "$CFG_RATIO" ] && RATIO="$CFG_RATIO"
fi

# Compute 3-phase thresholds relative to the configured trigger ratio.
WARN_RATIO=$(python3 -c "r = float('$RATIO') - 0.05; print(r if r > 0 else 0.50)" 2>/dev/null || echo "0.80")
STOP_RATIO=$(python3 -c "r = float('$RATIO') - 0.03; print(r if r > 0 else 0.52)" 2>/dev/null || echo "0.82")
WARN_TOKENS=$(python3 -c "print(int($MAX_CTX * $WARN_RATIO))" 2>/dev/null || echo "0")
STOP_TOKENS=$(python3 -c "print(int($MAX_CTX * $STOP_RATIO))" 2>/dev/null || echo "0")
COMPACT_TOKENS=$(python3 -c "print(int($MAX_CTX * float('$RATIO')))" 2>/dev/null || echo "0")

PERCENT=$(python3 -c "print(f'{(int($TOKEN_COUNT) / int($MAX_CTX)) * 100:.1f}')" 2>/dev/null || echo "?")

# Resolve cwd from JSON payload (like pre-compact.sh does) for correct
# COMPACT_STATE.md location. Falls back to script's repo root.
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Use cwd if available and valid, else fall back to repo root
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
    COMPACT_STATE="$CWD/memory/COMPACT_STATE.md"
else
    COMPACT_STATE="$PROJECT_ROOT/memory/COMPACT_STATE.md"
fi

# ── PHASE 3: CRITICAL — STOP if ritual not performed ─────────────────
if [ "$TOKEN_COUNT" -ge "$STOP_TOKENS" ]; then
    # Check if save-state ritual was already performed recently.
    # We detect this by COMPACT_STATE.md mtime within last 5 minutes.
    RITUAL_FRESH=0
    RITUAL_AGE=""
    if [ -f "$COMPACT_STATE" ]; then
        NOW=$(date +%s)
        MTIME=$(stat -c %Y "$COMPACT_STATE" 2>/dev/null || echo 0)
        if [ "$MTIME" -gt 0 ]; then
            AGE=$(( NOW - MTIME ))
            if [ "$AGE" -lt 300 ] && [ "$AGE" -ge 0 ]; then
                RITUAL_FRESH=1
                RITUAL_AGE="$AGE"
            fi
        fi
    fi

    if [ "$RITUAL_FRESH" -eq 1 ]; then
        # Ritual already done recently — allow with a light reminder.
        cat <<EOF
elite-role · Context Guard (phase 3 — acknowledged)
  COMPACT_STATE.md updated ${RITUAL_AGE}s ago. Save-state ritual is fresh.
  Continuing under L6 self-check. Remain vigilant until compact resolves.
EOF
        exit 0
    fi

    # BLOCK: ritual not performed yet.
    cat <<EOF >&2
╔════════════════════════════════════════════════════════════════════╗
║  🛑 CONTEXT GUARD — STOP: Session at ${PERCENT}% (${TOKEN_COUNT}/${MAX_CTX})    ║
╠════════════════════════════════════════════════════════════════════╣
║  CRITICAL THRESHOLD CROSSED: ${STOP_RATIO} (${STOP_TOKENS} tokens)                ║
║  Auto-compact imminent at:   ${RATIO} (${COMPACT_TOKENS} tokens)                  ║
╠════════════════════════════════════════════════════════════════════╣
║  SAVE-STATE RITUAL IS MANDATORY BEFORE PROCEEDING.                ║
║                                                                    ║
║  Perform the FULL elite ritual NOW:                               ║
║  1. memory/CONTEXT.md      → active task + progress + file state  ║
║  2. memory/ASSUMPTIONS.md  → active risks with P×I scores        ║
║  3. memory/DECISIONS.md    → recent decisions                     ║
║  4. memory/COMPACT_STATE.md → compact-safe snapshot (this file    ║
║                                must be touched to unlock Phase 3) ║
║  5. memory/RESUME.md       → checkpoint summary                   ║
║  6. Confirm: "Elite save-state complete. Acknowledged."           ║
╠════════════════════════════════════════════════════════════════════╣
║  This turn is BLOCKED until the ritual is performed.               ║
║  Once COMPACT_STATE.md is fresh (< 5 min), continuation unlocks.  ║
╚════════════════════════════════════════════════════════════════════╝
EOF
    exit 2
fi

# ── PHASE 2: WARNING — advise ritual ─────────────────────────────────
if [ "$TOKEN_COUNT" -ge "$WARN_TOKENS" ]; then
    cat <<EOF
╔════════════════════════════════════════════════════════════════════╗
║  ⚠️  CONTEXT GUARD — WARNING: Session at ${PERCENT}% (${TOKEN_COUNT}/${MAX_CTX})  ║
╠════════════════════════════════════════════════════════════════════╣
║  Warning threshold: ${WARN_RATIO} (${WARN_TOKENS} tokens)                         ║
║  STOP threshold:    ${STOP_RATIO} (${STOP_TOKENS} tokens)  ← 3% ahead             ║
║  Auto-compact at:   ${RATIO} (${COMPACT_TOKENS} tokens)                           ║
╠════════════════════════════════════════════════════════════════════╣
║  ADVISORY: Begin save-state ritual NOW to avoid mandatory STOP.   ║
║                                                                    ║
║  Recommended:                                                      ║
║  1. memory/CONTEXT.md      → current task + progress              ║
║  2. memory/ASSUMPTIONS.md  → active risks                         ║
║  3. memory/COMPACT_STATE.md → snapshot (unlocks Phase 3 block)    ║
╚════════════════════════════════════════════════════════════════════╝
EOF
    exit 0
fi

# ── Phase 1: Silent — no action needed ──────────────────────────────
exit 0
