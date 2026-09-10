#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
mode=${1:---build}
case "$mode" in
  --build|--switch) ;;
  --help) printf 'Usage: scripts/install.sh [--build|--switch]\nBuild first (default), or build and activate Home Manager.\n'; exit 0 ;;
  *) printf 'Unknown option: %s\n' "$mode" >&2; exit 2 ;;
esac
if [[ "$mode" == --switch && -f /run/.toolboxenv ]]; then
  echo 'Activate on the target desktop, outside Toolbox. Use --build for container validation.' >&2
  exit 1
fi
command -v nix >/dev/null || { echo 'Install Nix first; see README.md.' >&2; exit 1; }
if [[ ! -f "$repo/local.nix" ]]; then
  echo 'Copy examples/local.nix to local.nix and set your username, home directory, and system.' >&2
  exit 1
fi
# path: includes the gitignored local.nix and newly created files.
nix --extra-experimental-features 'nix-command flakes' build \
  "path:$repo#homeConfigurations.default.activationPackage" --out-link "$repo/result"
if [[ "$mode" == --switch ]]; then
  "$repo/result/activate"
else
  echo 'Build ready. Run scripts/install.sh --switch to activate on the target desktop.'
fi
