#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
workspace_dir=$(cd "$script_dir/.." && pwd)

chmod +x $workspace_dir/.devcontainer/*.sh

# -----------------------
# Sync workspace materials
# -----------------------

$workspace_dir/.devcontainer/sync.sh

# -----------------------
# Run synced postAttachScript
# -----------------------

exec "$workspace_dir/.devcontainer/postAttachScript.sh"
