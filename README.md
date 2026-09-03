![Omarchy 4 on an Apple Silicon MacBook: the top bar flowing around the display notch in a development session](hero.jpg)

# Omarchy Mac

Omarchy 4 on Apple Silicon, alongside macOS: the Omarchy Silicon integration is under active development for M1, M2, M3, M4, M5, M6, and future M-series generations across materially distinct MacBook Air, MacBook Pro, Mac mini, iMac, Mac Studio, and Mac Pro board families.

**Support status:** no Apple Silicon board is currently supported or qualified, and no supported clean installer or release is shipped. Hardware and setup references below describe development targets, not compatibility or installability.

[![License](https://img.shields.io/github/license/omarchy-silicon/omarchy-mac)](LICENSE) [![Stars](https://img.shields.io/github/stars/omarchy-silicon/omarchy-mac?style=social)](https://github.com/omarchy-silicon/omarchy-mac/stargazers)

Already running Omarchy 3.x? The historical upgrade notes are retained for
reference only; no supported upgrade or clean-install path is currently
shipped. See [docs/upgrade-to-quattro.md](docs/upgrade-to-quattro.md).

---

## Before you begin

- A recent backup of macOS (Time Machine or similar).
- An Apple Silicon Mac in the present or future M-series target set. No board is currently supported or qualified; see the [Asahi device-support table](https://asahilinux.org/fedora/#device-support) for upstream context only.
- At least 50 GB free on the internal SSD (100 GB recommended) if you are performing an experimental developer investigation.
- Internet access.

---

## Experimental / developer-only setup (not supported)

The commands in this section are retained for developers inspecting target-side integration. Do **not** run them on a valuable system: they download and execute remote code and may repartition, encrypt, or otherwise modify a disk. The native signed Omarchy Silicon clean installer is not shipped, and these commands provide no support, compatibility, qualification, or release-readiness guarantee.

### 1. Run the Asahi Alarm installer, from macOS Terminal

```bash
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

Choose an Asahi Alarm image only if you are deliberately testing the underlying target-side pieces. Neither `Asahi Alarm Minimal (BTRFS)` nor `Asahi Alarm Minimal` (ext4) currently has a supported Omarchy clean-install path.

### 2. Boot into Arch and get online

Log in as root (username: `root`, password: `root`) and connect first — 
everything from here starts with a download:

```bash
nmtui
```

Choose `Activate a connection` and connect to a WiFi network. Optionally 
`Set a system hostname` or set it during install below. Choose `Quit` when done 
to return to the prompt.

If `nmtui` shows an error right after activating the connection, reboot and try
again.

### 3. Native clean installer status

The signed Omarchy Silicon native clean installer is not yet shipped. The former guided adapter and its legacy conversion path are retired, deliberately disabled, and fail closed; do not run old `omarchy-mac-setup`, boot-layout conversion, or filesystem conversion commands from copied or cached instructions. There is no supported clean-install command to download yet, and this repository makes no clean-install, encryption, compatibility, or release-readiness claim.

---

### Existing target-side setup (not a clean install)

The package and runtime setup can be inspected separately, but the native clean installer is not yet available. Once a regular user with sudo exists — the minimal image ships without `git` or `sudo`, so as root first: `pacman -S --needed sudo git` — the existing setup is:

```bash
git clone --branch quattro https://github.com/omarchy-silicon/omarchy-mac.git ~/.local/share/omarchy
cd ~/.local/share/omarchy
cat version    # 4.x — if this says 3.x you are on the wrong branch
bash install.sh
```

**Mind the branch.** `quattro` is the default branch and the Omarchy 4 line. `main` still carries Omarchy 3.x, and its `install.sh` installs Omarchy 3 without saying which generation it is putting on the machine. `cat version` is how you check before committing to an experimental inspection.

This setup path is not the native signed clean-install flow and should not be treated as a release or support claim. Do not run it on a valuable system. A few packages have no ARM build and the current package tooling reports those gaps separately.

---

## Troubleshooting

The notes in this section apply only to legacy or experimental target-side
setups. They do not establish a supported installation, compatibility, or
recovery path.

### SSH stopped working after the install

Asahi Alarm ships openssh enabled — the images are built for headless boards —
and the legacy Omarchy install turned on a default-deny firewall that never
opened port 22.
Nothing is uninstalled; the machine simply stops answering, which looks exactly
like sshd having been removed. Turn it back on deliberately:

```bash
omarchy-setup-security-sshd
```

It enables `sshd`, adds `ufw limit 22/tcp`, and offers to fetch your public keys
from `https://github.com/<user>.keys`. The same thing lives in the menu under
Setup → Security → SSH.

### The machine boots to `grub rescue>`

GRUB kept its modules and kernel on the root filesystem, and the legacy conversion path is retired and fail-closed; do not attempt to repair a clean install with copied conversion commands. The native signed installer and its recovery contract are not yet shipped.

### Rolling back after a bad update

Legacy snapshot restore is blocked on Apple Silicon while the signed journaled rollback and recovery path is not yet shipped. There is no runnable supported recovery command; do not treat structural snapshot state as rollback authority.

### Mirrors are slow or failing

Run `bash fix-mirrors.sh` from the repository root and retry.

---

## Removal (uninstall)

For developers with a legacy or experimental setup only:

There is no automatic uninstaller. Removal is done from macOS by deleting the
Linux partitions and growing the macOS container back over them. Follow the
[Asahi Linux partitioning cheatsheet](https://asahilinux.org/docs/sw/partitioning-cheatsheet/)
exactly — it identifies which partitions are Asahi's and which are macOS's own,
and the wrong `diskutil` target can take macOS with it. If unsure, ask in the
[central Discussions](https://github.com/omarchy-silicon/omarchy-apple-platform/discussions)
before changing anything.

---

## Support and contributions

No Apple Silicon board is currently supported or qualified, and no supported
clean installer or release is shipped. For project communication:

- [Report a verified bug in product Issues](https://github.com/omarchy-silicon/omarchy-mac/issues).
- [Discuss ideas and cross-project work in the central Discussions](https://github.com/omarchy-silicon/omarchy-apple-platform/discussions).
- [Report a security vulnerability privately](https://github.com/omarchy-silicon/omarchy-mac/security/advisories/new).

---

## More documentation

- The Omarchy manual — [manual/](manual/)
- Legacy btrfs history (not part of clean install; native recovery unresolved) — [docs/btrfs.md](docs/btrfs.md)
- Upgrading from 3.x to Quattro — [docs/upgrade-to-quattro.md](docs/upgrade-to-quattro.md)

---

## External resources

- Asahi Linux (device support) — https://asahilinux.org/fedora/#device-support
- Asahi Alarm — https://asahi-alarm.org/
- Discord — https://discord.gg/KNQRk7dMzy

---

## Acknowledgements

This project is a downstream integration of [Omarchy](https://github.com/basecamp/omarchy). Thanks to Omarchy, Asahi Linux, and Asahi Alarm for enabling Linux on Apple Silicon.

If this guide helped you, please star the [Omarchy Silicon repository](https://github.com/omarchy-silicon/omarchy-mac) and share feedback through the contribution links above.

---

## Omarchy Mac Contributors

Partial contributor list:

- tayowrld — https://github.com/tayowrld
- Owen Singh (itsOwen) — https://github.com/itsOwen
- Matthias Millhoff (embeatz) — https://github.com/embeatz
- George Dobreff — https://github.com/georgedobreff
- Luke Van — https://github.com/lukevanlukevan
- Wésley Guimarães — https://github.com/wesguima
- Vince Picone — https://github.com/vpicone
- Oleh Khomei — https://github.com/varyform
- Mike Deufel — https://github.com/MDeufel13
- Gwynspring — https://github.com/Gwynspring
- DinMon — https://github.com/DinMon
- Aslkhon — https://github.com/Aslkhon
- Marcelo Alcantara — https://github.com/maralcbr
- Scott Jones — https://github.com/scottjones
