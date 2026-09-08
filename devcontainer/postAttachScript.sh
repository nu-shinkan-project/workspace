#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)

# -----------------------
# Clone missing repositories
# -----------------------

exec "$script_dir/auto-clone.sh"
