#!/bin/bash
# build-tier2-bundle.sh — Concatenate the Tier-2 review artifact set
# per the SOP in .kimi/skills/elite-role/references/independent-validation.md
# (section "Tier-2 SOP — Artifact bundle").
#
# Usage:
#   bash build-tier2-bundle.sh                  # bundle → stdout
#   bash build-tier2-bundle.sh > /tmp/bundle.md # bundle → file
#
# The output is a single Markdown document with one "=== FILE: <path> ==="
# header per source file, so the external reviewer can cite file:line
# accurately. The bundle itself is NOT committed (regenerable + content-
# rot avoidance); commit SHA at review time is the durable reference.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# Artifact list — keep narrow and reproducible per SOP §1.
# Order matters: doctrine → runtime → roadmap → history → canon.
FILES=(
    "01_ELITE_ROLE.md"
    "KIMI_PROTOCOL.md"
    "ROADMAP_ELITE_v2.md"
    "memory/AUDIT_LOG.md"
    "canon/hooks.yaml"
    "canon/patterns.yaml"
    "canon/thresholds.yaml"
)

# Refuse to emit a partial bundle — Tier-2 reviewer must see the full set.
for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
        printf 'build-tier2-bundle.sh: missing required file: %s\n' "$f" >&2
        exit 1
    fi
done

GIT_REV="$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
GIT_DIRTY="$(git diff --quiet 2>/dev/null && echo 'clean' || echo 'dirty')"
DATE_ISO="$(date -Iseconds)"

cat <<EOF
# Tier-2 Review Bundle

Generated: $DATE_ISO
Source commit: $GIT_REV ($GIT_DIRTY working tree)
Files included: ${#FILES[@]}

This bundle is the input to the Tier-2 SOP defined in
.kimi/skills/elite-role/references/independent-validation.md. Feed
this entire document to the external reviewer along with the SOP
§2 reviewer prompt. Cite by file:line — line numbers refer to the
position within each file's "=== FILE: ... ===" block, starting at
1 for the first line after the header.

---

EOF

for f in "${FILES[@]}"; do
    printf '=== FILE: %s ===\n' "$f"
    cat "$f"
    printf '\n=== END FILE: %s ===\n\n' "$f"
done
