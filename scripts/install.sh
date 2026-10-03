#!/usr/bin/env bash
# Build (default) or build and activate the Home Manager configuration for the current user.
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
# Enable flakes for this script and the nix commands Home Manager runs, without
# touching the system's nix.conf.
export NIX_CONFIG="${NIX_CONFIG:+$NIX_CONFIG
}extra-experimental-features = nix-command flakes"

case ${1:---build} in
  --build) switch=false ;;
  --switch) switch=true ;;
  -h|--help)
    printf 'Usage: scripts/install.sh [--build|--switch]\n'
    printf '  --build   build the configuration without changing anything (default)\n'
    printf '  --switch  build and activate it; conflicting files are renamed to *.hm-backup\n'
    exit 0 ;;
  *) printf 'Unknown option: %s (see --help)\n' "$1" >&2; exit 2 ;;
esac

die() { printf '%s\n' "$*" >&2; exit 1; }
command -v nix >/dev/null || die 'Nix is required: https://nixos.org/download'
[[ $(id -u) -ne 0 ]] || die 'Run as the user whose home should be configured, not root.'
if $switch && [[ -f /run/.toolboxenv || -f /run/.containerenv ]]; then
  die 'Activate on the target desktop, not inside a container. Use --build here.'
fi

# Machine identity, kept out of Git. Edit it if the detected values are wrong.
if [[ ! -f $repo/local.nix ]]; then
  system=$(nix eval --impure --raw --expr builtins.currentSystem)
  cat >"$repo/local.nix" <<EOF
{
  username = "$(id -un)";
  homeDirectory = "$HOME";
  system = "$system";
}
EOF
  printf 'Created local.nix for %s (%s).\n' "$(id -un)" "$system"
fi

# path: (not git+file:) so the ignored local.nix is part of the flake.
flake="path:$repo"
if $switch; then
  nix run "$flake#home-manager" -- switch --flake "$flake#default" -b hm-backup
else
  nix build "$flake#homeConfigurations.default.activationPackage" --no-link
  echo 'Build succeeded. Run scripts/install.sh --switch to activate it.'
fi
