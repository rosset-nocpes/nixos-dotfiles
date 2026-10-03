#!/usr/bin/env bash
# Lint scripts, parse every Nix file and evaluate the flake (no builds).
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
shellcheck scripts/*.sh
git ls-files -co --exclude-standard '*.nix' | xargs -r nix-instantiate --parse >/dev/null
nix --extra-experimental-features 'nix-command flakes' flake check "path:$PWD" --no-build
