#!/usr/bin/env bash
# generate.sh — thin wrapper around _generate.py
#
# Why split: `bash generate.sh` and `./generate.sh` should both work even
# if the actual implementation is python. Embedding python source under a
# .sh extension breaks `bash generate.sh`. So `.sh` is bash, calls python.
#
# Usage:
#   bash generate.sh           # regenerate; write changes
#   bash generate.sh --check   # report drift without writing (CI mode)

set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 _generate.py "$@"
