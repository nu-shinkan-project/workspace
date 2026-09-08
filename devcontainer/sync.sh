
script_dir=$(cd "$(dirname "$0")" && pwd)
workspace_dir=$(cd "$script_dir/.." && pwd)

repository_url="https://github.com/nu-shinkan-project/workspace.git"
repository_ref="refs/heads/main"

# -----------------------
# Check for workspace updates
# -----------------------

latest_revision=$(
  git ls-remote "$repository_url" "$repository_ref" |
    awk 'NR == 1 { print $1 }'
)

if [ -z "$latest_revision" ]; then
  echo "Unable to resolve workspace revision." >&2
  exit 1
fi

local_revision=""
if [ -f "$script_dir/.workspace-revision" ]; then
  read -r local_revision < "$script_dir/.workspace-revision"
fi

# -----------------------
# Update workspace resources
# -----------------------

if [ "$local_revision" != "$latest_revision" ]; then
  temporary_dir=$(mktemp -d)
  trap 'rm -rf "$temporary_dir"' EXIT

  archive_url="https://github.com/nu-shinkan-project/workspace/archive/$latest_revision.zip"
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

  archive_root=$(find "$extract_dir" -mindepth 1 -maxdepth 1 -type d -print -quit)
  devcontainer_source="$archive_root/devcontainer"

  if [ ! -d "$devcontainer_source" ]; then
    echo "Downloaded bundle is missing devcontainer/." >&2
    exit 1
  fi

  # Stage on the same filesystem as the workspace so the final mv is a rename.
  next_devcontainer="$workspace_dir/.devcontainer.next"
  previous_devcontainer="$workspace_dir/.devcontainer.previous"

  # pre clean up
  rm -rf "$next_devcontainer" "$previous_devcontainer"

  # Safe replacement:
  # Downloaded           Original
  # .devcontainer.next   .devcontainer
  # .devcontainer.next   .devcontainer.previous
  # .devcontainer        .devcontainer.previous
  # .devcontainer        (deleted)
  cp -a "$devcontainer_source" "$next_devcontainer"
  echo "$latest_revision" > "$next_devcontainer/.workspace-revision"

  mv "$script_dir" "$previous_devcontainer"
  mv "$next_devcontainer" "$workspace_dir/.devcontainer"

  rm -rf "$previous_devcontainer"

  # clean up unnecessary material
  rm -f "$workspace_dir/.devcontainer/auto-clone.ps1"
fi