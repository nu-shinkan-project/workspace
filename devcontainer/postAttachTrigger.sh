#!/usr/bin/env bash
set -euo pipefail

# -----------------------
# Sync workspace materials
# -----------------------

exec "$workspace_dir/.devcontainer/sync.sh"

# -----------------------
# Run synced postAttachScript
# -----------------------

exec "$workspace_dir/.devcontainer/postAttachScript.sh"
