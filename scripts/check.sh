#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
shellcheck scripts/*.sh
while IFS= read -r -d '' file; do
  nix-instantiate --parse "$file" >/dev/null
done < <(find . -name '*.nix' -not -path './.git/*' -print0)
nix --extra-experimental-features 'nix-command flakes' flake check "path:$PWD" --no-build
