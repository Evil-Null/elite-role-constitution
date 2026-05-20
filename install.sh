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
#   bash install.sh --yes          # accept all defaults (skills+hooks+launcher)
#   bash install.sh --skills-only  # only skill symlinks, skip hooks/launcher
#   bash install.sh --hooks-only   # only hooks wire-up, skip skills/launcher
#   bash install.sh --no-launcher  # skip the kimi-elite wrapper + shell alias
#   bash install.sh --no-probe     # skip the live Kimi probe at the end

set -euo pipefail

YES=0
DO_SKILLS=1
DO_HOOKS=1
DO_LAUNCHER=1
DO_PROBE=1

for arg in "$@"; do
    case "$arg" in
        --yes|-y) YES=1 ;;
        --skills-only) DO_HOOKS=0; DO_LAUNCHER=0 ;;
        --hooks-only) DO_SKILLS=0; DO_LAUNCHER=0 ;;
        --no-launcher) DO_LAUNCHER=0 ;;
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
    # Underscore-prefixed files (_patterns.sh, etc.) are helpers that are
    # SOURCED by the real hooks, not executed directly. The CI integrity
    # check skips them too (see .github/workflows/integrity.yml).
    case "$(basename "$h")" in _*) continue ;; esac
    if [ ! -x "$h" ]; then
        chmod +x "$h"
        NEEDED_CHMOD=$((NEEDED_CHMOD + 1))
    fi
done
if [ "$NEEDED_CHMOD" -eq 0 ]; then
    ok "All hook scripts already executable."
else
    ok "Made $NEEDED_CHMOD hook script(s) executable."
fi

# ── 4. flow skill parse validation ───────────────────────────────────
#
# Catch the Kimi 1.44 mermaid parser footgun before any user sees the
# runtime error "END node is not reachable from BEGIN". The parser uses
# rfind('>') to locate the arrow, so any literal '<' or '>' inside a
# node label (e.g. >=, <X>, <subject>) silently drops the edge and
# breaks reachability. Validate every flow skill with Kimi's own parser.

step "4. Flow skill validation"

# Locate the Python interpreter bundled with the installed kimi-cli so
# we can import kimi_cli.skill.flow.mermaid without a separate venv.
KIMI_BIN="$(command -v kimi)"
KIMI_REAL="$(readlink -f "$KIMI_BIN" 2>/dev/null || echo "$KIMI_BIN")"
KIMI_PY="$(dirname "$KIMI_REAL")/python"
if [ ! -x "$KIMI_PY" ]; then
    # Some installs name it python3 instead
    KIMI_PY="$(dirname "$KIMI_REAL")/python3"
fi
if [ ! -x "$KIMI_PY" ]; then
    # Fall back to shebang of the kimi launcher script
    KIMI_PY="$(head -1 "$KIMI_REAL" 2>/dev/null | sed 's|^#!||' | awk '{print $1}')"
fi

if [ ! -x "$KIMI_PY" ]; then
    warn "Could not locate Kimi's bundled Python; skipping flow parser check."
    warn "  Flow skills will be validated at runtime; failures land in ~/.kimi/logs/."
else
    PARSE_ERRORS=0
    while IFS= read -r skill_md; do
        skill_name="$(basename "$(dirname "$skill_md")")"
        if ! "$KIMI_PY" - "$skill_md" "$skill_name" >/dev/null 2>/tmp/elite-flow-parse.err <<'PYEOF'
import re, sys
try:
    from kimi_cli.skill.flow.mermaid import parse_mermaid_flowchart
except Exception as exc:
    sys.stderr.write(f"IMPORT_FAIL: {exc}\n")
    sys.exit(0)  # treat as 'cannot validate' — let install proceed
path, name = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
m = re.search(r"```mermaid(.*?)```", text, re.DOTALL)
if not m:
    sys.exit(0)  # non-flow skill — nothing to validate
try:
    parse_mermaid_flowchart(m.group(1))
except Exception as exc:
    sys.stderr.write(f"{name}: {exc}\n")
    sys.exit(2)
PYEOF
        then
            fail "Flow skill '$skill_name' would fail to load:"
            sed 's/^/      /' /tmp/elite-flow-parse.err >&2
            PARSE_ERRORS=$((PARSE_ERRORS + 1))
        else
            ok "Skill '$skill_name' parses cleanly."
        fi
    done < <(find .kimi/skills -name SKILL.md -type f)
    rm -f /tmp/elite-flow-parse.err

    if [ "$PARSE_ERRORS" -gt 0 ]; then
        fail "$PARSE_ERRORS skill(s) failed parser validation."
        fail "  Common cause: literal '<' or '>' inside mermaid node labels."
        fail "  Replace '>=' with '≥', and '<placeholder>' with '(placeholder)'"
        fail "  inside the \`\`\`mermaid\`\`\` block only — prose can keep the"
        fail "  angle-bracket form. See agent/elite.system.md Output Contract."
        exit 1
    fi
fi

# ── 5. optional: skills symlinks ─────────────────────────────────────

if [ "$DO_SKILLS" -eq 1 ]; then
    step "5. Optional: install skills user-wide"
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

# ── 6. optional: hook wire-up ────────────────────────────────────────

if [ "$DO_HOOKS" -eq 1 ]; then
    step "6. Optional: wire hooks into ~/.kimi/config.toml"
    echo "    The lifecycle hooks under .kimi/hooks/ only fire if they"
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

# ── 7. optional: launcher (alias + wrapper) ──────────────────────────
#
# Background: Kimi has no config setting for a default agent — the
# doctrine only loads when `--agent-file` is passed. Without this step
# the user ends up in a "half-installed" state: hooks fire host-wide
# (absolute paths in ~/.kimi/config.toml) but the system prompt is the
# stock Kimi default. Both a wrapper script (for scripts/automation)
# and an interactive shell alias (for daily REPL use) are offered.

if [ "$DO_LAUNCHER" -eq 1 ]; then
    step "7. Optional: doctrine launcher (alias + wrapper)"
    echo "    Without this step you must pass --agent-file every time you"
    echo "    launch kimi. This installs two helpers so plain 'kimi' (alias)"
    echo "    and 'kimi-elite' (wrapper) both load the Elite Role agent."

    # (a) wrapper for non-interactive contexts (scripts, cron, etc.)
    WRAPPER_DIR="$HOME/.local/bin"
    WRAPPER="$WRAPPER_DIR/kimi-elite"
    KIMI_REAL_BIN="$(command -v kimi)"
    if [ -e "$WRAPPER" ] && ! grep -q "elite-role-constitution" "$WRAPPER" 2>/dev/null; then
        warn "$WRAPPER exists and is not the elite-role wrapper — skipping."
    elif [ -L "$WRAPPER" ] || [ -f "$WRAPPER" ]; then
        # Refresh in case REPO_ROOT moved
        mkdir -p "$WRAPPER_DIR"
        cat > "$WRAPPER" <<WRAPPER_EOF
#!/usr/bin/env bash
# kimi-elite — auto-generated by elite-role-constitution install.sh
# Launches kimi with the Elite Role doctrine agent active.
exec "$KIMI_REAL_BIN" --agent-file "$REPO_ROOT/agent/elite.yaml" "\$@"
WRAPPER_EOF
        chmod +x "$WRAPPER"
        ok "Refreshed $WRAPPER"
    elif ask_yn "Install wrapper '$WRAPPER' (for scripts and non-interactive use)?"; then
        mkdir -p "$WRAPPER_DIR"
        cat > "$WRAPPER" <<WRAPPER_EOF
#!/usr/bin/env bash
# kimi-elite — auto-generated by elite-role-constitution install.sh
# Launches kimi with the Elite Role doctrine agent active.
exec "$KIMI_REAL_BIN" --agent-file "$REPO_ROOT/agent/elite.yaml" "\$@"
WRAPPER_EOF
        chmod +x "$WRAPPER"
        ok "Installed $WRAPPER"
        case ":$PATH:" in
            *":$WRAPPER_DIR:"*) ;;
            *) warn "$WRAPPER_DIR is not in PATH. Add 'export PATH=\"$WRAPPER_DIR:\$PATH\"' to your shell rc." ;;
        esac
    fi

    # (b) shell alias so plain `kimi` works in interactive REPLs
    ALIAS_MARK="# Elite Role Constitution alias (install.sh)"
    ALIAS_LINE="alias kimi='command kimi --agent-file $REPO_ROOT/agent/elite.yaml'"
    if ask_yn "Add 'alias kimi=...' to ~/.bashrc and ~/.zshrc (recommended)?"; then
        APPENDED=0
        for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
            [ ! -f "$rc" ] && continue
            if grep -qF "$ALIAS_MARK" "$rc"; then
                ok "$rc already has the alias (skipping)."
            else
                {
                    printf '\n%s\n%s\n' "$ALIAS_MARK" "$ALIAS_LINE"
                } >> "$rc"
                ok "Appended alias to $rc"
                APPENDED=1
            fi
        done
        if [ "$APPENDED" -eq 1 ]; then
            warn "Open a NEW shell, or run 'source ~/.bashrc' / 'source ~/.zshrc'"
            warn "  for the alias to take effect in this terminal."
        fi
    else
        ok "Skipped shell alias. Use 'kimi-elite' or pass --agent-file manually."
    fi
fi

# ── 8. live probe ────────────────────────────────────────────────────

if [ "$DO_PROBE" -eq 1 ]; then
    step "8. Live runtime probe"
    echo "    Sending a single-word probe via kimi --agent-file ..."
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

    # Bonus probe: confirm the kimi-elite wrapper, if installed, also
    # routes through the elite agent. This catches the case where the
    # wrapper exists but points at the wrong agent file (e.g. after a
    # repo move).
    if [ -x "$HOME/.local/bin/kimi-elite" ]; then
        echo "    Also probing the kimi-elite wrapper ..."
        WRAPPER_OUT="$(echo "respond with exactly one word: WRAPPED" | \
            "$HOME/.local/bin/kimi-elite" --print --quiet --input-format text 2>&1 | \
            head -3 || true)"
        if printf '%s' "$WRAPPER_OUT" | grep -q "WRAPPED"; then
            ok "Wrapper responded: WRAPPED — alias path is live."
        else
            warn "Wrapper probe did not return WRAPPED. Output was:"
            printf '%s\n' "$WRAPPER_OUT" | sed 's/^/      /'
        fi
    fi
fi

# ── done ─────────────────────────────────────────────────────────────

step "Done"
bold "Elite Role Constitution installed."
cat <<EOF

Next steps:

  • Daily use (if you accepted the alias step):
      kimi                       # plain command — doctrine active via alias
      kimi-elite                 # same, for scripts/non-interactive contexts

  • Manual launch (no alias):
      kimi --agent-file $REPO_ROOT/agent/elite.yaml

  • Useful in-session commands:
      /skill:elite-role          load full doctrine
      /flow:audit-mode           multi-turn audit ritual
      /flow:challenge-grade x    full 6-Lens challenge of x
      /flow:save-state           write memory/RESUME.md + CONTEXT.md
      plan only                  trigger PEV PLAN gate
      [APPROVED]                 release the PEV gate

  • Verify the alias took effect (after opening a new shell):
      tail -1 ~/.kimi/logs/kimi.*.log
      # should show: Loading agent: $REPO_ROOT/agent/elite.yaml

  • To uninstall:
      ~/.kimi/config.toml backup is at \$HOME/.kimi/config.toml.bak.*
      Symlinks:  rm ~/.kimi/skills/{elite-role,audit-mode,challenge-grade,save-state}
      Wrapper:   rm ~/.local/bin/kimi-elite
      Alias:     remove the 'Elite Role Constitution alias' block from ~/.bashrc + ~/.zshrc
EOF
