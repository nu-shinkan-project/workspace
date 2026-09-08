#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
workspace_dir=$(cd "$script_dir/.." && pwd)

# -----------------------
# Sync workspace materials
# -----------------------

exec "$workspace_dir/.devcontainer/sync.sh"

# -----------------------
# Run synced postCreateScript
# -----------------------

exec "$workspace_dir/.devcontainer/postCreateScript.sh"
