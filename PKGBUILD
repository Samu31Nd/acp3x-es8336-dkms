# Build from a clone of this repository: makepkg -si
pkgname=acp3x-es8336-dkms
pkgver=1.2.0
pkgrel=1
pkgdesc="Speaker/headphone support for AMD ACP3x laptops with an Everest ES8336 codec (Huawei MateBook D AMD, etc.)"
arch=('any')
url="https://github.com/Samu31Nd/acp3x-es8336-dkms"
license=('GPL-2.0-only')
depends=('dkms' 'alsa-ucm-conf')
optdepends=('wireplumber: anti-click and 48 kHz rules')
install=acp3x-es8336-dkms.install

package() {
	local dest="$pkgdir/usr/src/acp3x-es8336-$pkgver"
	install -d "$dest"
	cp -r "$startdir/module" "$startdir/dkms.conf" "$dest/"
	sed -i "s/^PACKAGE_VERSION=.*/PACKAGE_VERSION=\"$pkgver\"/" "$dest/dkms.conf"

	install -Dm644 "$startdir/wireplumber/51-acp3x-es8336.conf" \
		"$pkgdir/usr/share/wireplumber/wireplumber.conf.d/51-acp3x-es8336.conf"
	install -Dm644 "$startdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
