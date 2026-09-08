#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
workspace_dir=$(cd "$script_dir/.." && pwd)

# -----------------------
# Clone missing repositories
# -----------------------

$script_dir/auto-clone.sh
