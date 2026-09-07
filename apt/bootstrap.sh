#!/usr/bin/env bash
# Replays apt/ onto a fresh Ubuntu install (utdt10141 rebuild-from-scratch).
#
# Order matters: keyrings and repos have to exist before `apt install` can
# see packages that only live in a third-party repo (FortiClient, Spotify,
# etc, whichever ones you've added under sources.list.d/).
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing keyrings"
sudo install -d -m 0755 /etc/apt/keyrings
if compgen -G "$script_dir/keyrings/*" > /dev/null; then
  sudo cp "$script_dir"/keyrings/* /etc/apt/keyrings/
fi

echo "==> Installing third-party apt sources"
if compgen -G "$script_dir/sources.list.d/*" > /dev/null; then
  sudo cp "$script_dir"/sources.list.d/* /etc/apt/sources.list.d/
fi

echo "==> apt update"
sudo apt update

echo "==> Installing packages from packages.txt"
# xargs, not `apt install $(cat ...)`: keeps argv sane if the list is huge,
# and -a reads the file directly instead of needing a subshell substitution.
grep -v '^#' "$script_dir/packages.txt" | xargs -r -a - sudo apt install -y

echo "==> Done. Remaining manual steps (not automated here):"
echo "    - snap/flatpak packages, if any (not tracked in this directory yet)"
echo "    - any bare .deb installs noted in apt/README.md (e.g. FortiClient"
echo "      itself, if it wasn't installed via a repo)"
echo "    - clone this repo and run 'home-manager switch --flake .#utdt10141Home'"
echo "      to restore the home directory"
