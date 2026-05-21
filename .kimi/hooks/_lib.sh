#!/bin/bash
# _lib.sh — Elite Role shared helper library for Kimi CLI hooks
#
# Purpose: centralise common operations that were duplicated across 11 hooks:
#   - JSON payload parsing (cwd, session_id, token_count)
#   - Config file reading (portable, no grep -P)
#   - Context file scanning (tail -c optimised, timeout-protected)
#   - Ritual freshness checks (all-memory-files mtime, not just COMPACT_STATE.md)
#   - Atomic file writes (same-FS tempfile + mv)
#   - Ritual token generation/verification (random nonce, compact-bound)
#
# Usage: source this file AFTER 'set -euo pipefail' in the calling hook.
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"
#
# Design notes:
#   - This file is SOURCED, not executed directly. It defines functions only.
#   - It does NOT set shell options (set -e, pipefail, etc.) — the caller owns that.
#   - All functions are prefixed 'er_' (elite role) to avoid namespace collisions.
#   - Every function that may fail returns a defined value; empty string means
#     "could not determine" and the caller decides whether to fail-open or fail-closed.

# ── 1. JSON payload helpers ──────────────────────────────────────────

# Extract a top-level string field from JSON.
# Args: $1 = json_string, $2 = key
# Usage: VAL=$(er_json_str "$INPUT" "cwd")
er_json_str() {
    local input="${1:-}"
    local key="${2:-}"
    if [ -z "$key" ]; then
        echo ""
        return
    fi
    printf '%s' "$input" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('$key', ''))
except Exception:
    print('')
" 2>/dev/null || echo ""
}

# Extract cwd from the Kimi event payload, with fallback to the
# elite-role-constitution repo root (legacy behaviour for backwards compat).
# Args: $1 = json_string
# Usage: CWD=$(er_get_cwd "$INPUT")
er_get_cwd() {
    local input="${1:-}"
    local cwd=""
    cwd=$(er_json_str "$input" "cwd")
    if [ -n "$cwd" ] && [ -d "$cwd" ]; then
        printf '%s' "$cwd"
        return
    fi
    # Legacy fallback: resolve from this script's location.
    # _lib.sh lives in .kimi/hooks/ → project root is ../..
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root
    project_root="$(cd "$script_dir/../.." && pwd)"
    printf '%s' "$project_root"
}

# Extract session_id from payload.
# Usage: SID=$(er_get_session_id "$INPUT")
er_get_session_id() {
    er_json_str "$1" "session_id"
}

# ── 2. Config parsing (portable, no PCRE) ────────────────────────────

# Read a simple key = value line from ~/.kimi/config.toml.
# Only handles top-level scalar keys (int, float, string).
# Args: $1 = key, $2 = default_value
# Usage: VAL=$(er_get_config_value "max_context_size" "262144")
er_get_config_value() {
    local key="$1"
    local default="$2"
    local config_file="${HOME}/.kimi/config.toml"
    local val=""
    if [ -f "$config_file" ]; then
        # Portable sed: extract value after "key = "
        # Handles: key = 123 | key = 0.85 | key = "string"
        val=$(sed -n "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\([0-9A-Za-z._/-]*\).*/\1/p" "$config_file" 2>/dev/null | head -1 || true)
        # Remove surrounding quotes if present
        val="${val#\"}"
        val="${val%\"}"
        val="${val#\'}"
        val="${val%\'}"
    fi
    printf '%s' "${val:-$default}"
}

# ── 3. Token count from context.jsonl (optimised) ────────────────────

# Get the latest token_count from a session's context.jsonl.
# Uses tail -c 100K to avoid scanning huge files, and timeout 5s on find.
# Args: $1 = session_id
# Usage: COUNT=$(er_get_token_count "$SESSION_ID")
er_get_token_count() {
    local session_id="$1"
    if [ -z "$session_id" ]; then
        echo ""
        return
    fi
    local context_file
    context_file=$(timeout 5 find ~/.kimi/sessions -path "*/${session_id}/context.jsonl" -type f 2>/dev/null | head -1 || true)
    if [ -z "$context_file" ] || [ ! -f "$context_file" ]; then
        echo ""
        return
    fi
    # tail -c 100K: only scan last 100KB (recent turns)
    tail -c 100K "$context_file" 2>/dev/null | grep '"_usage"' | tail -1 | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('token_count', ''))
except Exception:
    print('')
" 2>/dev/null || echo ""
}

# ── 4. Ritual freshness check (all memory files) ─────────────────────

# Check that ALL memory files have mtime within max_age seconds.
# This closes the 'touch COMPACT_STATE.md only' bypass.
# Args: $1 = memory_dir, $2 = max_age_seconds
# Returns: 0 if all fresh, 1 otherwise
# Usage: if er_check_all_mtimes "$CWD/memory" 300; then ...
er_check_all_mtimes() {
    local mem_dir="${1:-memory}"
    local max_age="${2:-300}"
    local now
    now=$(date +%s)
    local files=("CONTEXT.md" "RESUME.md" "ASSUMPTIONS.md" "DECISIONS.md" "COMPACT_STATE.md")
    local missing=0
    for f in "${files[@]}"; do
        local fp="${mem_dir}/${f}"
        if [ ! -f "$fp" ]; then
            missing=$((missing + 1))
            continue
        fi
        local mtime
        mtime=$(stat -c %Y "$fp" 2>/dev/null || echo 0)
        local age=$(( now - mtime ))
        if [ "$age" -ge "$max_age" ] || [ "$age" -lt 0 ]; then
            return 1
        fi
    done
    # COMPACT_STATE.md is mandatory; others may be missing in new projects
    if [ ! -f "${mem_dir}/COMPACT_STATE.md" ]; then
        return 1
    fi
    return 0
}

# ── 5. Atomic file write ─────────────────────────────────────────────

# Write content atomically using a same-directory tempfile + mv.
# Reads content from stdin.
# Usage: printf '%s' "$content" | er_atomic_write "memory/RESUME.md"
er_atomic_write() {
    local target="$1"
    local dir
    dir=$(dirname "$target")
    local tmpf="${dir}/.tmp.atomic.$$"
    cat > "$tmpf"
    mv "$tmpf" "$target"
}

# ── 6. Ritual token (compact-bound nonce) ────────────────────────────

# Generate a random ritual token for pre-compact.sh to embed in COMPACT_STATE.md.
# The token proves that pre-compact.sh ran (which only happens at compact time).
# AI cannot predict or forge this without the compact event firing.
# Usage: TOKEN=$(er_generate_ritual_token)
er_generate_ritual_token() {
    # Use /dev/urandom for randomness; fallback to python3; fallback to date + PID
    if [ -r /dev/urandom ]; then
        head -c 16 /dev/urandom 2>/dev/null | xxd -p -c 32 2>/dev/null || true
    fi
    # If xxd not available or failed, try python3
    python3 -c "import secrets; print(secrets.token_hex(16))" 2>/dev/null || echo ""
}

# Verify that COMPACT_STATE.md contains a valid ritual token line.
# Args: $1 = compact_state_file_path
# Returns: 0 if token found, 1 otherwise
# Usage: if er_verify_ritual_token "$COMPACT_STATE"; then ...
er_verify_ritual_token() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 1
    fi
    # Look for a line like: > **Ritual Token:** a1b2c3d4...
    if grep -qE '^> \*\*Ritual Token:\*\*[[:space:]]*[0-9a-fA-F]{32}' "$file" 2>/dev/null; then
        return 0
    fi
    return 1
}

# ── 7. Script project root resolver ──────────────────────────────────

# Get the elite-role-constitution repo root from _lib.sh's location.
# Usage: ROOT=$(er_get_script_project_root)
er_get_script_project_root() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$script_dir/../.." && pwd
}

# ── 8. Global state directory for C4 PEV gate ────────────────────────

# Return a global, host-wide state directory for cross-hook state
# (e.g., cached user prompts for the C4 approval gate).
# This avoids creating .kimi/state/ inside foreign projects.
# Usage: DIR=$(er_get_state_dir)
er_get_state_dir() {
    local dir="${HOME}/.kimi/state/elite-role"
    mkdir -p "$dir" 2>/dev/null || true
    printf '%s' "$dir"
}
