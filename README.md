# acp3x-es8336-dkms

Speaker and headphone support for AMD **Renoir / Lucienne / Cezanne** laptops (ACP 3.x)
that use an **Everest ES8336** codec, packaged as DKMS so it survives kernel updates.

Upstream Linux already has the machine driver (`acp3x-es83xx`), but it only binds on
models hard-coded in two DMI tables. Every other laptop gets the DMIC-only driver:
the microphone shows up, the speakers and the headphone jack don't.

## Does this apply to me?

```sh
ls /sys/bus/acpi/devices/ | grep ESSX8336      # codec declared by the BIOS
lspci -nn | grep 1022:15e2                      # AMD Audio Coprocessor (ACP3x)
aplay -l                                        # only HDMI listed → you have the problem
```

If the first two print something and `aplay -l` has no analog card, this module is for you.

## What it does

Rebuilds two kernel modules from the matching upstream sources with a small patch:

| Module | Change |
|---|---|
| `snd-acp-config` | Adds the HUAWEI MateBook D 14 AMD (`NBM-WXX9`). New parameter `es83xx_autodetect` (default **on**): any ACP3x system with an `ESSX8336` device uses the legacy ES83xx driver, even if it is not listed. |
| `snd-acp-legacy-mach` | Adds `NBM-WXX9` with internal mic + 48 MHz MCLK. New parameter `quirk` to change the clock / DMIC settings without rebuilding. Enables the amplifier **after** the codec output is up (plus `amp_delay_ms`, default 50) to remove the power-up pop. |

DKMS installs them under `updates/dkms`, which takes precedence over the stock modules and
is rebuilt automatically for every new kernel. Nothing in the kernel package is overwritten.

It also ships a WirePlumber rule that:

- keeps the output open (no suspend), which removes the **click/pop** when audio stops,
- locks the card to **48 kHz**, avoiding distorted audio from a rate the codec clock is not set up for.

## Install

**Arch / CachyOS / EndeavourOS / Manjaro**

```sh
sudo pacman -S --needed dkms linux-headers   # use the headers of your kernel, e.g. linux-cachyos-headers
git clone https://github.com/Samu31Nd/acp3x-es8336-dkms.git
cd acp3x-es8336-dkms
makepkg -si
reboot
```

**Other distros** (needs `dkms` and kernel headers):

```sh
./install.sh            # ./install.sh uninstall to remove
reboot
```

Kernels built with clang (CachyOS) are detected and built with `LLVM=1` automatically.

## Troubleshooting

**Distorted / noisy / wrong-pitch audio** means the MCLK setting doesn't match your board. Try the other clock:

```sh
# 16 = DMIC + 12.288 MHz MCLK   |   48 = DMIC + 48 MHz MCLK   |   0/32 = same without DMIC
echo "options snd_acp_legacy_mach quirk=16" | sudo tee /etc/modprobe.d/acp3x-es8336.conf
reboot
```

When you find the value that works, please open an issue with the output of
`cat /sys/class/dmi/id/{board_vendor,product_name,product_version}` so the model can be added.

**Pop when audio starts:** raise the amplifier delay (applies on the next power-up, no reboot needed):

```sh
echo 100 | sudo tee /sys/module/snd_acp_legacy_mach/parameters/amp_delay_ms
# make it permanent:
echo "options snd_acp_legacy_mach amp_delay_ms=100" | sudo tee -a /etc/modprobe.d/acp3x-es8336.conf
```

**Check what loaded:**

```sh
lsmod | grep -E 'snd_acp_legacy_mach|snd_rn_pci_acp3x'
modinfo -n snd-acp-config        # should point to .../updates/dkms/...
journalctl -k -b | grep -i es83
```

## Known models

| Vendor | Product | Version | Quirk |
|---|---|---|---|
| HUAWEI | NBM-WXX9 (MateBook D 14 AMD) | M1010 | DMIC + 48 MHz (added here; speakers and internal mic tested, 3.5 mm jack untested — reports welcome) |
| HUAWEI | BOM-WXX9, KLVL-WXX9, KLVL-WXXW, HVY-WXX9 | — | already upstream |

## Kernel compatibility

Sources are taken from Linux **v7.3.3**. They depend on internal kernel APIs, so a future
kernel may need a refresh of `module/` from the matching tag. If a build fails after a kernel
update, DKMS keeps the stock modules (audio goes back to mic-only) and the system still boots.

## Resumen en español

Hace funcionar los altavoces y la salida de audífonos en laptops AMD (Ryzen 4000/5000) con el códec
ES8336, como la Huawei MateBook D 14 AMD. Se instala con DKMS, así que se recompila sola en cada
actualización del kernel. Incluye una regla de WirePlumber que quita el "clic" al dejar de sonar y fija
el audio a 48 kHz. Si se escucha con ruido, prueba `quirk=16` como se explica arriba.

## License

GPL-2.0-only, same as the kernel sources it is derived from (`acp-config.c` is dual BSD/GPL).
