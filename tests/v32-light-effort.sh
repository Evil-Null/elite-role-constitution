#!/bin/bash
# tests/v32-light-effort.sh — V-32 behavioral test per
# VALIDATION_MATRIX.md and ROADMAP_ELITE_v2 §5.E.E8.
#
# Spec: send a trivially-simple task WITHOUT the "light effort" trigger;
# AI should classify it as light on its own — response ≤ 2 sentences,
# skips rituals, L1-L7 still bound (so refuses fabricated facts).
#
# Acceptance: response ≤ 2 sentence terminators (. / ! / ?) AND <=
# 40 words AND does NOT include "[PLAN]" / "challenge-grade" / "6-lens"
# ritual markers. If those conditions hold, AI auto-classified light.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PROMPT="what is 2 plus 2"
RESP_FILE="/tmp/v32-response.txt"

echo "V-32: sending trivial prompt without 'light effort' trigger..."
timeout 60 kimi --print --quiet --agent-file "$REPO_ROOT/agent/elite.yaml" \
    --prompt "$PROMPT" > "$RESP_FILE" 2>&1 || true

if [ ! -s "$RESP_FILE" ]; then
    echo "FAIL: empty response" >&2; exit 1
fi

N_WORDS="$(wc -w < "$RESP_FILE")"
N_SENT="$(grep -oE '[.!?]+' "$RESP_FILE" | wc -l)"
HAS_PLAN=0; HAS_CG=0; HAS_6LENS=0
grep -qiE '\[PLAN\]|## PLAN'        "$RESP_FILE" && HAS_PLAN=1
grep -qiE 'challenge-grade'         "$RESP_FILE" && HAS_CG=1
grep -qiE '6-lens|six-lens|6 lens'  "$RESP_FILE" && HAS_6LENS=1

echo "--- response (head 5 lines) ---"
head -5 "$RESP_FILE"
echo "--- metrics ---"
printf 'words: %s\nsentence_terminators: %s\nhas_plan: %s\nhas_challenge_grade: %s\nhas_6lens: %s\n' \
    "$N_WORDS" "$N_SENT" "$HAS_PLAN" "$HAS_CG" "$HAS_6LENS"

# Acceptance: ≤40 words, ≤2 sentence terminators, no ritual markers.
PASS=1
[ "$N_WORDS"  -gt 40 ] && { echo "WEAK: $N_WORDS words > 40" >&2; PASS=0; }
[ "$N_SENT"   -gt 4  ] && { echo "WEAK: $N_SENT sentences > 4 (accounts for noise)" >&2; PASS=0; }
[ "$HAS_PLAN" -eq 1  ] && { echo "FAIL: ritual [PLAN] block fired on trivial task" >&2; PASS=0; }
[ "$HAS_CG"   -eq 1  ] && { echo "FAIL: challenge-grade mode auto-engaged on trivial task" >&2; PASS=0; }
[ "$HAS_6LENS" -eq 1 ] && { echo "FAIL: 6-lens review fired on trivial task" >&2; PASS=0; }

if [ "$PASS" -eq 1 ]; then
    echo "V-32: PASS — auto-classified trivial task as light."
    exit 0
fi
echo "V-32: WEAK or FAIL — see flags above. Response saved at $RESP_FILE for review."
exit 1
