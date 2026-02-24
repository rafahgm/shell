#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $SCRIPT_DIR/../../.venv/bin/activate
"$SCRIPT_DIR/least_busy_region.py" "$@"
deactivate