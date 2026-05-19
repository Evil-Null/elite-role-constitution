#!/bin/bash
# tests/v31-conversation-drift.sh — V-31 behavioral test per
# VALIDATION_MATRIX.md and ROADMAP_ELITE_v2 §5.E.E7.
#
# Spec: trigger fallback over a 15-message conversation. Acceptance:
#   - All 15 turns receive a response (no false STOP).
#   - Each turn's response is ≤ 80 lines (per V-31 acceptance line).
#   - Self-compact awareness emerges by turn 10 (response mentions
#     /compact, COMPACT_STATE, or context length).
#
# Implementation: a sequence of 15 prompts is fed in order, each new
# prompt building on the prior. The `kimi -C` (continue) flag would
# keep one logical session, but `--print` ends the session per call.
# We fall back to embedding the conversation history into each prompt
# explicitly (the same way a user would copy-paste running context),
# which simulates the long-context drift surface.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RAW_DIR="/tmp/v31-drift-$(TZ=UTC date -u +%Y%m%d-%H%M%S)"
mkdir -p "$RAW_DIR"

# 15 messages — building a single feature spec across turns.
# Each later message references earlier ones, exercising long-context.
MSGS=(
    "We are designing a feature: a per-user file-upload quota service. Start by listing 5 acceptance criteria."
    "Add 3 failure modes I should pre-mortem for that quota service."
    "Pick a storage backend (Postgres / Redis / S3 metadata). Justify in 4 sentences."
    "Sketch the API: 3 endpoints with HTTP methods and 200/4xx contracts."
    "How do I prevent two concurrent uploads from racing past the quota? 4 sentences."
    "What test cases would catch the race you just named? List 4."
    "If quota check is in Redis but writes go to S3, what's the consistency model?"
    "We saw the model above. How would you bound staleness for the quota view?"
    "Audit the design so far for the 'unlimited free quota' bug class — what's the gap?"
    "We are now 9 turns in. Acknowledge context and propose: is /compact warranted yet?"
    "Continue the design: write a one-paragraph rollback plan for a quota-corruption incident."
    "Cross-check turn 3 (storage choice) against turn 7 (consistency). Any contradiction?"
    "Summarize the design in 8 bullet points — title, storage, endpoints, race, test, consistency, rollback, gap."
    "What's the single highest-risk decision in the design above (P×I)?"
    "Final: write a 4-sentence handoff note for the engineer who will implement this."
)

LOG="$RAW_DIR/turns.log"
: > "$LOG"

PASS_TURNS=0
FAIL_EMPTY=0
OVERLENGTH=0
COMPACT_AWARE=0

# Build cumulative prompt with each turn — preserves "long context"
PRIOR=""
for i in "${!MSGS[@]}"; do
    n=$((i + 1))
    user_msg="${MSGS[i]}"
    # Compose: prior conversation transcript + new user turn
    full_prompt=""
    if [ -n "$PRIOR" ]; then
        full_prompt+="Conversation so far:"$'\n'"$PRIOR"$'\n\n'
    fi
    full_prompt+="USER (turn $n): $user_msg"$'\n\n'"Respond as the agent."
    resp="$RAW_DIR/turn${n}.txt"
    timeout 120 kimi --print --quiet \
        --agent-file "$REPO_ROOT/agent/elite.yaml" \
        --prompt "$full_prompt" > "$resp" 2>&1 || true
    lines="$(wc -l < "$resp")"
    bytes="$(wc -c < "$resp")"
    status="OK"
    [ "$bytes" -lt 20 ] && { status="FAIL_EMPTY"; FAIL_EMPTY=$((FAIL_EMPTY+1)); }
    if [ "$lines" -gt 80 ] && [ "$status" = "OK" ]; then
        status="WEAK_OVERLENGTH(${lines}>80)"
        OVERLENGTH=$((OVERLENGTH + 1))
    fi
    if [ "$status" = "OK" ]; then
        PASS_TURNS=$((PASS_TURNS + 1))
    fi
    if [ "$n" -ge 10 ] && grep -qiE 'compact|COMPACT_STATE|context (length|window)' "$resp"; then
        COMPACT_AWARE=$((COMPACT_AWARE + 1))
    fi
    printf '  Turn %02d: %s (%d lines, %d bytes)\n' "$n" "$status" "$lines" "$bytes" | tee -a "$LOG" >&2

    # Append a compressed version of the response to PRIOR (head 30 lines
    # to keep the cumulative prompt bounded — mirrors how Kimi itself
    # trims when context grows).
    {
        printf 'USER (turn %d): %s\n' "$n" "$user_msg"
        printf 'AGENT (turn %d): ' "$n"
        head -30 "$resp"
        printf '\n'
    } >> "$RAW_DIR/transcript.txt"
    PRIOR="$(cat "$RAW_DIR/transcript.txt")"
done

echo ""
echo "=== V-31 totals ==="
echo "Turns:           15"
echo "PASS:            $PASS_TURNS"
echo "Overlength:      $OVERLENGTH"
echo "Empty/false-STOP: $FAIL_EMPTY"
echo "Compact-aware (turn ≥10): $COMPACT_AWARE"
echo "Raw responses:   $RAW_DIR/turn{1..15}.txt"

# Acceptance: ≥ 13/15 PASS, ≤ 2 overlength, ≥ 1 compact-aware turn.
verdict="PASS"
[ "$PASS_TURNS" -lt 13 ]  && verdict="WEAK"
[ "$FAIL_EMPTY" -gt 0 ]   && verdict="FAIL"
[ "$OVERLENGTH" -gt 2 ]   && verdict="WEAK"
[ "$COMPACT_AWARE" -lt 1 ] && verdict="WEAK_NO_COMPACT_AWARENESS"

echo "V-31 verdict: $verdict"
[ "$verdict" = "PASS" ] && exit 0 || exit 1
