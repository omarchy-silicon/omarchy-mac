![Omarchy 4 on an Apple Silicon MacBook: the top bar flowing around the display notch on a fresh install](hero.jpg)

# Omarchy Mac

Omarchy 4 on Apple Silicon, alongside macOS: the Omarchy Silicon integration is under active development.

[![License](https://img.shields.io/github/license/omarchy-mac/omarchy-mac)](LICENSE) [![Stars](https://img.shields.io/github/stars/omarchy-mac/omarchy-mac?style=social)](https://github.com/omarchy-mac/omarchy-mac/stargazers)

Already running Omarchy 3.x? This page is the fresh install — to upgrade in
place, see [docs/upgrade-to-quattro.md](docs/upgrade-to-quattro.md).

---

## Before you begin

- A recent backup of macOS (Time Machine or similar).
- An Apple Silicon Mac (M1/M2 family). Verify compatibility: https://asahilinux.org/fedora/#device-support
- At least 50 GB free on the internal SSD (100 GB recommended).
- Internet access.

---

## Install

### 1. Run the Asahi Alarm installer, from macOS Terminal

```bash
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

Choose `Asahi Alarm Minimal (BTRFS)` and allocate at least 50 GB for Linux.
The plain `Asahi Alarm Minimal` (ext4) works too — the setup below converts
it — but the BTRFS image already has the right shape.

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

The signed Omarchy Silicon native clean installer is not yet shipped. The former guided adapter and its legacy conversion path are deliberately disabled and fail closed; do not run old `omarchy-mac-setup`, boot-layout conversion, or filesystem conversion commands from copied or cached instructions. There is no supported clean-install command to download yet, and this repository makes no clean-install, encryption, compatibility, or release-readiness claim.

---

## By hand

The package and runtime setup can be inspected separately, but the native clean installer is not yet available. Once a regular user with sudo exists — the minimal image ships without `git` or `sudo`, so as root first: `pacman -S --needed sudo git` — the existing setup is:

```bash
git clone https://github.com/omarchy-mac/omarchy-mac.git ~/.local/share/omarchy
cd ~/.local/share/omarchy
cat version    # 4.x — if this says 3.x you are on the wrong branch
bash install.sh
```

**Mind the branch.** A plain clone gets `quattro`, the default branch and the
Omarchy 4 line. `main` still carries Omarchy 3.x, and its `install.sh` installs
Omarchy 3 without saying which generation it is putting on the machine — an
easy hour to lose. `cat version` is how you check before committing to it.

This setup path is not the native signed clean-install flow and should not be treated as a release or support claim. A few packages have no ARM build and the current package tooling reports those gaps separately.

---

## Troubleshooting

### SSH stopped working after the install

Asahi Alarm ships openssh enabled — the images are built for headless boards —
and Omarchy's install turns on a default-deny firewall that never opens port 22.
Nothing is uninstalled; the machine simply stops answering, which looks exactly
like sshd having been removed. Turn it back on deliberately:

```bash
omarchy-setup-security-sshd
```

It enables `sshd`, adds `ufw limit 22/tcp`, and offers to fetch your public keys
from `https://github.com/<user>.keys`. The same thing lives in the menu under
Setup → Security → SSH.

### The machine boots to `grub rescue>`

GRUB kept its modules and kernel on the root filesystem, and the legacy conversion path is disabled and quarantined pending P-07; do not attempt to repair a clean install with copied conversion commands. The native signed installer and its recovery contract are not yet shipped.

### Rolling back after a bad update

`omarchy snapshot restore` works on Apple Silicon. It offers snapper's
snapshots alongside `@fresh` — the system before Omarchy was installed — and
`@factory`, the installed system before it was yours, and says what you are
about to restore before doing anything. `/boot` is the EFI partition and sits
outside every snapshot; the tool warns when the restored root has no modules
for the running kernel.

### Mirrors are slow or failing

Run `bash fix-mirrors.sh` from the repository root and retry.

---

## Removal (uninstall)

There is no automatic uninstaller. Removal is done from macOS by deleting the
Linux partitions and growing the macOS container back over them. Follow the
[Asahi Linux partitioning cheatsheet](https://asahilinux.org/docs/sw/partitioning-cheatsheet/)
exactly — it identifies which partitions are Asahi's and which are macOS's own,
and the wrong `diskutil` target can take macOS with it. If unsure, open an
issue.

---

## Support

Consider supporting the project: [![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/malik2015no)

---

## More documentation

- The Omarchy manual — [manual/](manual/)
- Legacy btrfs reference (not part of clean install; P-07 unresolved) — [docs/btrfs.md](docs/btrfs.md)
- Upgrading from 3.x to Quattro — [docs/upgrade-to-quattro.md](docs/upgrade-to-quattro.md)

---

## External resources

- Asahi Linux (device support) — https://asahilinux.org/fedora/#device-support
- Asahi Alarm — https://asahi-alarm.org/
- Discord — https://discord.gg/KNQRk7dMzy

---

## Acknowledgements

Thanks to Asahi Linux and Asahi Alarm for enabling Linux on Apple Silicon, and to DHH for creating Omarchy.

If this guide helped you, please star the repository and share feedback in issues or discussions. If you enjoy Omarchy Mac, please share your experience on Twitter/X by tagging [@OmarchyMac](https://x.com/OmarchyMac).

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
