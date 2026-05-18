#!/bin/bash
# install.sh — Elite Role Constitution one-command deployment
#
# Verifies prerequisites, makes hooks executable, optionally symlinks
# skills user-wide, optionally wires up hooks into ~/.kimi/config.toml,
# and runs a live verification probe.
#
# Safe by default: every mutation is opt-in (y/n prompt), with backups.
# Idempotent: running twice does not break anything.
#
# Usage:
#   bash install.sh                # interactive
#   bash install.sh --yes          # accept all defaults (skills+hooks)
#   bash install.sh --skills-only  # only skill symlinks, skip hooks
#   bash install.sh --hooks-only   # only hooks wire-up, skip skills
#   bash install.sh --no-probe     # skip the live Kimi probe at the end

set -euo pipefail

YES=0
DO_SKILLS=1
DO_HOOKS=1
DO_PROBE=1

for arg in "$@"; do
    case "$arg" in
        --yes|-y) YES=1 ;;
        --skills-only) DO_HOOKS=0 ;;
        --hooks-only) DO_SKILLS=0 ;;
        --no-probe) DO_PROBE=0 ;;
        --help|-h)
            grep '^#' "$0" | sed 's|^# \?||' | head -25
            exit 0 ;;
        *)
            echo "Unknown flag: $arg" >&2
            echo "Run 'bash install.sh --help' for usage." >&2
            exit 1 ;;
    esac
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# ── helpers ──────────────────────────────────────────────────────────

bold()    { printf '\033[1m%s\033[0m\n' "$*"; }
ok()      { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()    { printf '  \033[33m!\033[0m %s\n' "$*"; }
fail()    { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; }
step()    { printf '\n\033[36m▶\033[0m \033[1m%s\033[0m\n' "$*"; }

ask_yn() {
    local prompt="$1"
    local default="${2:-y}"
    if [ "$YES" -eq 1 ]; then return 0; fi
    local hint="[Y/n]"; [ "$default" = "n" ] && hint="[y/N]"
    read -r -p "    $prompt $hint " reply || reply=""
    reply="${reply:-$default}"
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ── 1. prerequisites ─────────────────────────────────────────────────

step "1. Prerequisites"

if ! command -v kimi >/dev/null 2>&1; then
    fail "kimi not found in PATH. Install Kimi CLI 1.43+ first."
    fail "  https://moonshotai.github.io/kimi-cli/en/guides/getting-started"
    exit 1
fi

KIMI_VER="$(kimi --version 2>/dev/null | awk '{print $NF}')"
KIMI_MAJOR_MINOR="${KIMI_VER%.*}"
if [[ -z "$KIMI_VER" ]]; then
    fail "Could not parse kimi --version output."
    exit 1
fi
ok "Kimi CLI $KIMI_VER detected."

# Conservative semver gate — accept 1.43+, refuse 1.42-
if printf '%s\n%s\n' "1.43" "$KIMI_MAJOR_MINOR" | sort -V | head -1 | grep -q "^$KIMI_MAJOR_MINOR$" && [ "$KIMI_MAJOR_MINOR" != "1.43" ]; then
    fail "Kimi CLI 1.43+ required. Detected: $KIMI_VER"
    exit 1
fi
ok "Version 1.43+ (or newer) confirmed."

if ! command -v shellcheck >/dev/null 2>&1 && [ ! -x /tmp/shellcheck-stable/shellcheck ]; then
    warn "shellcheck not installed system-wide and not found at /tmp/shellcheck-stable/."
    warn "  Install with: sudo apt-get install shellcheck"
    warn "  CI will still enforce shellcheck on push (see .github/workflows/integrity.yml)."
else
    ok "shellcheck available."
fi

if ! command -v python3 >/dev/null 2>&1; then
    fail "python3 required by hook JSON parsing. Install python3 first."
    exit 1
fi
ok "python3 available."

# ── 2. integrity check ───────────────────────────────────────────────

step "2. Repository integrity"

if bash SYSTEM_INTEGRITY_CHECK.sh >/dev/null 2>&1; then
    ok "All 10 integrity checks PASS."
else
    fail "SYSTEM_INTEGRITY_CHECK.sh reports failures. Run it directly for details:"
    fail "  bash SYSTEM_INTEGRITY_CHECK.sh"
    exit 1
fi

# ── 3. hook permissions ──────────────────────────────────────────────

step "3. Hook permissions"

NEEDED_CHMOD=0
for h in .kimi/hooks/*.sh; do
    if [ ! -x "$h" ]; then
        chmod +x "$h"
        NEEDED_CHMOD=$((NEEDED_CHMOD + 1))
    fi
done
if [ "$NEEDED_CHMOD" -eq 0 ]; then
    ok "All 9 hook scripts already executable."
else
    ok "Made $NEEDED_CHMOD hook scripts executable."
fi

# ── 4. optional: skills symlinks ─────────────────────────────────────

if [ "$DO_SKILLS" -eq 1 ]; then
    step "4. Optional: install skills user-wide"
    echo "    Project-local skills (in .kimi/skills/) are already discovered when"
    echo "    you launch Kimi from this repo. Symlinking them into ~/.kimi/skills/"
    echo "    makes /skill:elite-role and the three /flow:* commands available in"
    echo "    every project on this host."

    if ask_yn "Install skill symlinks under ~/.kimi/skills/?"; then
        mkdir -p "$HOME/.kimi/skills"
        for s in elite-role audit-mode challenge-grade save-state; do
            target="$HOME/.kimi/skills/$s"
            src="$REPO_ROOT/.kimi/skills/$s"
            if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
                ok "Symlink already in place: $target"
                continue
            fi
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                warn "$target exists and is NOT a symlink — skipping (please remove manually if you want to replace)"
                continue
            fi
            ln -sfn "$src" "$target"
            ok "Symlinked: $target -> $src"
        done
    else
        ok "Skipped user-wide skill install (project-local discovery still works)."
    fi
fi

# ── 5. optional: hook wire-up ────────────────────────────────────────

if [ "$DO_HOOKS" -eq 1 ]; then
    step "5. Optional: wire hooks into ~/.kimi/config.toml"
    echo "    The eight lifecycle hooks under .kimi/hooks/ only fire if they"
    echo "    are registered in ~/.kimi/config.toml. The example block lives"
    echo "    at .kimi/hooks.example.toml and uses project-relative paths."

    USER_CONF="$HOME/.kimi/config.toml"
    EXAMPLE_BLOCK="$REPO_ROOT/.kimi/hooks.example.toml"

    if [ ! -f "$USER_CONF" ]; then
        warn "$USER_CONF does not exist yet. Run 'kimi /login' or 'kimi --version' once to initialise."
    elif grep -q "elite-role-constitution/.kimi/hooks/" "$USER_CONF" 2>/dev/null; then
        ok "Hooks already wired into $USER_CONF (skipping)."
    elif ask_yn "Append the elite-role hook block to $USER_CONF? (a backup is made first)"; then
        cp "$USER_CONF" "$USER_CONF.bak.$(date +%Y%m%d_%H%M%S)"
        ok "Backup created."
        # TOML conflict guard: `hooks = []` (array form) and `[[hooks]]`
        # (table-array form) cannot coexist in the same TOML file.
        # Newer Kimi config templates use `hooks = []` by default; comment
        # it out before appending our table-array block. This was caught
        # in live testing on the first deploy.
        if grep -qE '^hooks[[:space:]]*=[[:space:]]*\[\]' "$USER_CONF"; then
            sed -i.tmp -E 's|^hooks[[:space:]]*=[[:space:]]*\[\]|# &   # commented out by elite-role install.sh — conflicts with [[hooks]] table-array form below|' "$USER_CONF"
            rm -f "$USER_CONF.tmp"
            ok "Commented out the existing 'hooks = []' line to avoid TOML conflict."
        fi
        {
            printf '\n# ─── Elite Role Constitution hooks (added by install.sh on %s) ───\n' "$(date -Iseconds)"
            # Rewrite project-relative paths to absolute paths for the user config
            sed "s|\".kimi/hooks/|\"$REPO_ROOT/.kimi/hooks/|g" "$EXAMPLE_BLOCK"
        } >> "$USER_CONF"
        ok "Hooks block appended. Restart Kimi for it to take effect."
    else
        ok "Skipped hook wire-up. You can do it later by copying .kimi/hooks.example.toml into ~/.kimi/config.toml."
    fi
fi

# ── 6. live probe ────────────────────────────────────────────────────

if [ "$DO_PROBE" -eq 1 ]; then
    step "6. Live runtime probe"
    echo "    Sending a single-word probe to kimi --agent-file agent/elite.yaml ..."
    PROBE_OUT="$(echo "respond with exactly one word: INSTALLED" | \
        kimi --agent-file "$REPO_ROOT/agent/elite.yaml" --print --quiet --input-format text 2>&1 | \
        head -3 || true)"
    if printf '%s' "$PROBE_OUT" | grep -q "INSTALLED"; then
        ok "Agent responded: INSTALLED — deployment is live."
    else
        warn "Probe did not return INSTALLED. Output was:"
        printf '%s\n' "$PROBE_OUT" | sed 's/^/      /'
        warn "Check 'kimi --version' and run 'kimi --agent-file agent/elite.yaml' manually."
    fi
fi

# ── done ─────────────────────────────────────────────────────────────

step "Done"
bold "Elite Role Constitution installed."
cat <<EOF

Next steps:

  • Daily use:
      kimi --agent-file $REPO_ROOT/agent/elite.yaml

  • Or alias it (add to ~/.bashrc):
      elite() { kimi --agent-file $REPO_ROOT/agent/elite.yaml "\$@"; }

  • Useful in-session commands:
      /skill:elite-role          load full doctrine
      /flow:audit-mode           multi-turn audit ritual
      /flow:challenge-grade <x>  full 6-Lens challenge of x
      /flow:save-state           write memory/RESUME.md + CONTEXT.md
      plan only                  trigger PEV PLAN gate
      [APPROVED]                 release the PEV gate

  • To uninstall:
      ~/.kimi/config.toml backup is at \$USER_CONF.bak.*
      Symlinks: rm ~/.kimi/skills/{elite-role,audit-mode,challenge-grade,save-state}
EOF
