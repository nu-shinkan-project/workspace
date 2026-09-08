#!/usr/bin/env bash
set -euo pipefail

workspace_dir="${WORKSPACE_DIRECTORY:-nu-shinkan-workspace}"
repository_url="${WORKSPACE_REPOSITORY_URL:-https://github.com/nu-shinkan-project/workspace.git}"
repository_ref="${WORKSPACE_REPOSITORY_REF:-refs/heads/main}"

# -----------------------
# Create workspace
# -----------------------

mkdir -p "$workspace_dir"
workspace_dir=$(cd "$workspace_dir" && pwd)

# -----------------------
# Resolve latest revision
# -----------------------

revision=$(
  git ls-remote "$repository_url" "$repository_ref" |
    awk 'NR == 1 { print $1 }'
)

if [ -z "$revision" ]; then
  echo "Unable to resolve workspace revision." >&2
  exit 1
fi

# -----------------------
# Download workspace archive
# -----------------------

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' EXIT

archive_url="https://github.com/nu-shinkan-project/workspace/archive/$revision.zip"
archive_path="$temporary_dir/workspace.zip"
extract_dir="$temporary_dir/extracted"

curl \
  --fail \
  --location \
  --silent \
  --show-error \
  "$archive_url" \
  --output "$archive_path"

unzip -q "$archive_path" -d "$extract_dir"

# -----------------------
# Install devcontainer
# -----------------------

archive_root=$(find "$extract_dir" -mindepth 1 -maxdepth 1 -type d -print -quit)
devcontainer_source="$archive_root/devcontainer"
devcontainer_target="$workspace_dir/.devcontainer"

if [ ! -d "$devcontainer_source" ]; then
  echo "Downloaded bundle is missing devcontainer/." >&2
  exit 1
fi

if [ -e "$devcontainer_target" ]; then
  echo "Keeping existing .devcontainer directory."
else
  cp -a "$devcontainer_source" "$devcontainer_target"
  echo "$revision" > "$devcontainer_target/.workspace-revision"
fi

# -----------------------
# Delete unnecessary material
# -----------------------

rm -f "$devcontainer_target"/*.ps1

# -----------------------
# Clone repositories
# -----------------------

bash "$devcontainer_target/auto-clone.sh"
