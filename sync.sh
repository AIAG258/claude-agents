#!/usr/bin/env bash
# AI R&D Squad — sync (git pull + setup) for Linux/macOS

set -euo pipefail

SQUAD_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${1:-}" != "--no-pull" ]]; then
    echo "git pull..."
    (cd "$SQUAD_HOME" && git pull)
fi

bash "$SQUAD_HOME/setup.sh"
