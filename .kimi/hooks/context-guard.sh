#!/bin/bash
# context-guard.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: UserPromptSubmit (before every user turn)
# Purpose: 3-phase context protection gate:
#   Phase 1 (warn):  at (trigger_ratio - 0.05) → advisory warning.
#   Phase 2 (stop):  at (trigger_ratio - 0.03) → BLOCK (exit 2) if the
#                    save-state ritual has NOT been performed recently.
#                    Ritual freshness = ALL memory files mtime < 5 min.
#   Phase 3 (compact): at trigger_ratio → Kimi auto-compacts; PreCompact
#                    hook handles post-compact recovery.
#
# v3.0 hardening:
#   - tail -c 100K + timeout 5s on find/grep (no timeout fail-open)
#   - Portable config parsing (no grep -P)
#   - All-memory-files mtime check (not just COMPACT_STATE.md)
#   - cwd-aware COMPACT_STATE location

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

SESSION_ID=$(er_get_session_id "$INPUT")

# If we cannot identify the session, silently allow.
if [ -z "$SESSION_ID" ]; then
    exit 0
fi

# Extract token count (optimised: tail -c 100K, timeout 5s on find).
TOKEN_COUNT=$(er_get_token_count "$SESSION_ID")

# Validate numeric token count.
if ! [[ "$TOKEN_COUNT" =~ ^[0-9]+$ ]] || [ "$TOKEN_COUNT" -eq 0 ]; then
    exit 0
fi

# Read model configuration from Kimi CLI config (portable, no grep -P).
MAX_CTX=$(er_get_config_value "max_context_size" "262144")
RATIO=$(er_get_config_value "compaction_trigger_ratio" "0.85")

# Compute 3-phase thresholds.
WARN_RATIO=$(python3 -c "r = float('$RATIO') - 0.05; print(r if r > 0 else 0.50)" 2>/dev/null || echo "0.80")
STOP_RATIO=$(python3 -c "r = float('$RATIO') - 0.03; print(r if r > 0 else 0.52)" 2>/dev/null || echo "0.82")
WARN_TOKENS=$(python3 -c "print(int($MAX_CTX * $WARN_RATIO))" 2>/dev/null || echo "0")
STOP_TOKENS=$(python3 -c "print(int($MAX_CTX * $STOP_RATIO))" 2>/dev/null || echo "0")
COMPACT_TOKENS=$(python3 -c "print(int($MAX_CTX * float('$RATIO')))" 2>/dev/null || echo "0")

PERCENT=$(python3 -c "print(f'{(int($TOKEN_COUNT) / int($MAX_CTX)) * 100:.1f}')" 2>/dev/null || echo "?")

# Resolve cwd from JSON payload for correct COMPACT_STATE.md location.
CWD=$(er_get_cwd "$INPUT")
COMPACT_STATE="$CWD/memory/COMPACT_STATE.md"

# ── PHASE 3: CRITICAL — STOP if ritual not performed ─────────────────
if [ "$TOKEN_COUNT" -ge "$STOP_TOKENS" ]; then
    # Ritual freshness: ALL memory files must be updated within 5 minutes.
    # This closes the 'touch COMPACT_STATE.md only' bypass.
    RITUAL_FRESH=0
    RITUAL_AGE=""
    if [ -d "$CWD/memory" ]; then
        if er_check_all_mtimes "$CWD/memory" 300; then
            RITUAL_FRESH=1
            RITUAL_AGE="<300s"
        fi
    fi

    # Also accept if COMPACT_STATE.md has a valid ritual token from
    # a recent pre-compact (post-compact path).
    if [ "$RITUAL_FRESH" -eq 0 ] && [ -f "$COMPACT_STATE" ]; then
        if er_verify_ritual_token "$COMPACT_STATE"; then
            RITUAL_FRESH=1
            RITUAL_AGE="token-valid"
        fi
    fi

    if [ "$RITUAL_FRESH" -eq 1 ]; then
        cat <<EOF
elite-role · Context Guard (phase 3 — acknowledged)
  Ritual fresh ($RITUAL_AGE). Save-state complete. Continuing under L6.
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
║  Perform the FULL elite ritual NOW — ALL of these files must be   ║
║  updated (not just touched) within the last 5 minutes:            ║
║                                                                    ║
║  1. memory/CONTEXT.md      → active task + progress + file state  ║
║  2. memory/ASSUMPTIONS.md  → active risks with P×I scores        ║
║  3. memory/DECISIONS.md    → recent decisions                     ║
║  4. memory/COMPACT_STATE.md → compact-safe snapshot               ║
║  5. memory/RESUME.md       → checkpoint summary                   ║
║                                                                    ║
║  ⚠️  touch memory/*.md is NOT sufficient — content must change.   ║
║      The hook checks filesystem mtime of ALL files, not just one. ║
║                                                                    ║
║  6. Confirm: "Elite save-state complete. Acknowledged."           ║
╠════════════════════════════════════════════════════════════════════╣
║  This turn is BLOCKED until the ritual is performed.               ║
║  Once all memory files are fresh (< 5 min), continuation unlocks. ║
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
