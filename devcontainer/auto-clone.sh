#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
workspace_dir=$(cd "$script_dir/.." && pwd)
repository_org="${WORKSPACE_REPOSITORY_ORG:-nu-shinkan-project}"
repos_file="$script_dir/repos"

# -----------------------
# Clone missing repositories
# -----------------------

while IFS= read -r entry || [ -n "$entry" ]; do
  # Accept repos files with either Unix or Windows line endings.
  entry="${entry%$'\r'}"

  # Ignore blank lines and comments.
  case "$entry" in
    "" | \#*) continue ;;
  esac

  # An entry may be a complete Git URL or a repository name in the default org.
  case "$entry" in
    https://* | http://* | git@* | ssh://*)
      repository_url="$entry"
      repository_name="${entry##*/}"
      repository_name="${repository_name%.git}"
      ;;
    *)
      repository_name="${entry%.git}"
      repository_url="https://github.com/$repository_org/$repository_name.git"
      ;;
  esac

  repository_path="$workspace_dir/$repository_name"

  # Never modify a repository—or any other path—that already exists.
  if [ -e "$repository_path" ] || [ -L "$repository_path" ]; then
    echo "Skipping existing path: $repository_path"
    continue
  fi

  git clone "$repository_url" "$repository_path"
done < "$repos_file"
