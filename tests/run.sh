#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")" && git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

PLENARY_OPTIONS="{ minimal_init = './tests/init.lua', sequential = true }"
nvim --headless -u ./tests/init.lua -c "PlenaryBustedDirectory ./tests/specs/ $PLENARY_OPTIONS"
