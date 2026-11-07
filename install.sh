#!/usr/bin/env bash
# Generic installer for distros without a package (needs dkms + kernel headers).
# On Arch-based distros prefer: makepkg -si
set -euo pipefail

NAME=acp3x-es8336
VER=$(sed -n 's/^PACKAGE_VERSION="\(.*\)"/\1/p' "$(dirname "$0")/dkms.conf")
ROOT=$(cd -- "$(dirname -- "$0")" && pwd)

if [[ ${1:-} == uninstall ]]; then
	sudo dkms remove "$NAME/$VER" --all || true
	sudo rm -rf "/usr/src/$NAME-$VER" /etc/wireplumber/wireplumber.conf.d/51-acp3x-es8336.conf
	echo "Removed. Reboot to go back to the stock driver."
	exit 0
fi

command -v dkms >/dev/null || { echo "Install dkms and your kernel headers first."; exit 1; }

sudo rm -rf "/usr/src/$NAME-$VER"
sudo install -d "/usr/src/$NAME-$VER"
sudo cp -r "$ROOT/module" "$ROOT/dkms.conf" "/usr/src/$NAME-$VER/"
sudo dkms install "$NAME/$VER"

sudo install -Dm644 "$ROOT/wireplumber/51-acp3x-es8336.conf" \
	/etc/wireplumber/wireplumber.conf.d/51-acp3x-es8336.conf

echo "Installed. Reboot to load the new driver."
