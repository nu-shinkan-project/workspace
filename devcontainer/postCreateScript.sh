#!/usr/bin/env bash
script_dir=$(cd "$(dirname "$0")" && pwd)
workspace_dir=$(cd "$script_dir/.." && pwd)

$workspace_dir/.devcontainer/postCreateScript.nu-shinkan.sh
