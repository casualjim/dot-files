# dot-files

Everything added on top of a fresh install, driven by [mise](https://mise.jdx.dev).
Currently built around one machine: `galileo`, a Minisforum AI X1 Pro 470 running
CachyOS with niri and the Noctalia shell (Wayland only). The installer's own defaults
(kernel, firmware, fprintd, snapper, limine, NetworkManager) are deliberately not repeated.

Nothing secret lives here. See [Secrets](#secrets).

## Layout

| Path | What it is |
| --- | --- |
| `mise.toml` | Machine bootstrap: packages, system files, services, users, and one-off tasks. Run from this directory. |
| `.config/mise/config.toml` | The **global** mise config: `[tools]`, `[env]`, and the `[dotfiles]` table that maps files here to `~`. |
| `.config/mise/config.linux.toml` | Linux-only global config (`DOCKER_HOST` for rootless podman). Loaded via `auto_env`. |
| `.config/mise/miserc.toml` | Turns on `auto_env` so the per-OS file loads. |
| `.config/` and `.local/` | Dotfiles, symlinked or copied into `~` by `mise dot apply`. |
| `.zshrc`, `.zsh_plugins.txt`, `.p10k.zsh` | Shell (zsh, antidote, powerlevel10k). The same files are used on macOS. |
| `system/` | Files that belong under `/etc`, copied there by `mise bootstrap`. |
| `hk.pkl` | Checks and git hooks ([hk](https://hk.jdx.dev)). Run them with `mise run check`. |

## New machine

mise cannot deploy the config that declares its own `[dotfiles]` table, and bootstrap needs
a few things in a particular order. In this order:

```bash
git clone <this repo> ~/github/casualjim/dot-files    # the path is set in .config/mise/config.toml
cd ~/github/casualjim/dot-files
mise trust
mise run link-global-config      # links ~/.config/mise/config.toml to this repo's copy
mise install                     # tools first: zage-install below needs the zage binary
mise run zage-install            # services in mise.toml expect zage's units to exist
mise dot apply                   # BEFORE bootstrap: several user units are dotfiles (see below)
mise bootstrap                   # accounts, packages, /etc files, services, dotfiles, tools
```

`mise dot apply` comes first because bootstrap enables services before it applies dotfiles, and
`keyring-unlock.service`, `gpg-agent-pass.service` and `yubikey-drill.timer` are dotfiles. Without
it the services step stops on a unit that does not exist yet. `mise dot apply` will not overwrite
an existing regular file; remove the old one (or pass `--force`).

Then the steps that need you present, in this order. **Log out and back in first**: bootstrap adds
you to the `tss` and `input` groups, and the TPM and Voxtype need them.

1. `mise run git-identity` and `mise run jj-identity`: your name and email, kept out of this public repo.
2. `mise run seal-keyring`: seal the login keyring password to this TPM. Needs the keyring password.
3. **GPG.** Copy `~/.gnupg` from a machine that has your keys, remove the lock files and sockets
   that came with it (see [GPG and gopass](#gpg-and-gopass)), then `mise run seal-gpg`.
4. **YubiKeys.** `mise run register-u2f` (touch each key in turn; any one registered key then
   satisfies a polkit prompt). `yubikey-drill` runs the monthly check by hand; do it once now.
5. **fnox.** `~/.config/fnox/config.toml` is not in this repo; restore it from another machine.
   Then create this machine's TPM key (`age-plugin-tpm --generate -o ~/.config/fnox/tpm.txt`),
   add its recipient to the config, and run `fnox reencrypt -p age` **on a machine that can already
   decrypt**. Recreate `~/.config/fnox/yubikey.txt` from the YubiKey's identity
   (`age-plugin-yubikey --identity`, add `--serial N` if several are plugged in). See
   [fnox keys](#fnox-keys-age-hardware-backed).
6. `mise run resolv-stub` and `mise run tailscale-up`: Tailscale MagicDNS and joining the tailnet.
7. `mise run voxtype-setup` (or `voxtype-parakeet`): settings, a model, and the user service.
   `voxtype-gpu` is an optional Vulkan backend.
8. By hand: log in to Dropbox (the tray icon needs `libayatana-appindicator`, already installed) and
   restart Noctalia through niri (`niri msg action spawn -- noctalia`), not from a terminal.
9. Optional: `enroll-fido2` (a LUKS keyslot; **verify the flags first**, TODO in the task), then
   `rebuild-initramfs` after touching the mkinitcpio drop-in.

`mise tasks` lists every task. The ones not in the sequence above:

| Task | When |
| --- | --- |
| `bat-cache` | After the Catppuccin bat themes change. |
| `check`, `hooks` | The repo's checks and the git pre-commit hook; see [Checks](#checks). |
| `rebuild-initramfs` | After the mkinitcpio drop-in changes. |
| `seal-keyring`, `seal-gpg` | Re-run after changing the keyring or GPG passphrase. |
| `register-u2f` | Re-run to change which YubiKeys are registered. It rewrites the whole file. |
| `docker-credential-gopass` | Build the Docker credential helper from the fork (branch `mine`) into `~/.local/bin`. Run after bootstrap; it needs Go from mise and the gopass store (`gopass clone https://github.com/casualjim/gopass`). |

## Day to day

```bash
mise bootstrap --dry-run      # preview; asks for sudo to inspect /etc
mise bootstrap                # apply
mise dot apply                # re-link dotfiles only
```

Edit files in this repo, not the copies in `~` (most are symlinks into here). A few are
copied instead, and need `mise dot apply` after a change: `btop.conf`, and the units and scripts
for the keyring, gpg-agent and yubikey-drill. Run `noctalia msg config-reload` after changing `.config/noctalia/config.toml`.

## Checks

`hk.pkl` runs these on the repo's own files: `taplo` (TOML), `shellcheck` (the scripts), `zsh -n`
(`.zshrc`, `.p10k.zsh`), `rumdl` (Markdown), `xmllint` (fontconfig and the bat themes),
`niri validate` (KDL), the git and Ghostty config validators, `oxlint` (JavaScript, including the
polkit rule), and `betterleaks` plus `detect-private-key` for secrets, since this repo is public.
They only report; nothing rewrites your files.

```bash
mise run check    # every check on every file
mise run hooks    # install the git pre-commit hook in this clone
```

jj does not run git hooks, so `jj commit` skips the pre-commit hook. Run `mise run check` before
committing with jj. The tools are declared in `mise.toml`, so they are only active inside this repo.

## Things that will bite you

- **greetd is never restarted by bootstrap** (`on_change = "none"`). It runs your live session.
- **mkinitcpio drop-in ordering.** The drop-in is `05-fido2-luks.conf` so it sorts before
  `10-limine-snapper-sync.conf`, which appends `sd-btrfs-overlayfs` to `HOOKS`. A later name
  would overwrite that.
- **`fontfeatures` in fontconfig hangs Pango apps.** `fonts.conf` must not append `fontfeatures`
  for the Mona Sans or Monaspace families. Ghostty hung at 100% CPU, and niri hung at login so
  the compositor was killed. Set stylistic sets in the app instead. This once needed a rescue boot.
- **Services order.** `mise bootstrap` applies services before installing tools. A service whose
  unit does not exist yet (zage) aborts the whole services step, which is why `zage-install`
  comes first.
- **The keyring unit needs the polkit rule** in `system/etc/polkit-1/`, or
  `systemd-creds decrypt` as a normal user is refused. The rule also allows `encrypt`, which the
  `seal-*` tasks need. The packaged `gnome-keyring-daemon.socket/.service` are masked on purpose.
- **polkit prompts take a fingerprint or a YubiKey touch**, then the password
  (`system/etc/pam.d/polkit-1`). `pam_faillock` locks the account for 10 minutes after 3 failed
  passwords, and the Noctalia prompt can count one typed password twice. Do not keep typing into a
  rejected prompt. `faillock --user ivan` shows the failures. `fprintd` also crashes now and then
  (`free(): invalid pointer`, not fixed upstream as far as we know); the 5 s fingerprint timeout
  keeps it from blocking the prompt.
- **What lives in `.zshrc` and what in mise.** Environment variables, PATH entries and most
  aliases are in `.config/mise/config.toml` (Linux-only ones in `config.linux.toml`). They
  apply once the oh-my-zsh `mise` plugin has activated mise, partway through `antidote load`,
  so anything needed earlier stays in `.zshrc` (`TERM`, history, `ZSH_CACHE_DIR`, the macOS
  Homebrew PATH). The `eza` aliases also stay there: the oh-my-zsh `eza` plugin loads after
  `mise` and would override `ls`, `ll` and `la`.
- **Voxtype's config is not tracked.** It lives in `~/.config/voxtype/config.toml`, which
  Voxtype rewrites atomically. `voxtype-config` applies our settings with `voxtype config set`.
- **`airpods` Noctalia plugin** needs a patched librepods fork. The CachyOS package is upstream
  and is not enough, so it is not installed.

## Secrets

Never committed (see `.gitignore`): `*.cred` (TPM-sealed credentials, tied to one machine's
TPM) and `*.age`, `*.key`. After a TPM change or a new machine, re-seal with
`mise run seal-keyring` and `mise run seal-gpg`. The fnox, YubiKey and U2F files live under
`~/.config/fnox` and `~/.config/Yubico`, outside this repo.

### fnox keys (age, hardware-backed)

fnox's age provider encrypts to several recipients. None of the private keys is a plain file:

- **TPM** (`~/.config/fnox/tpm.txt`, `age1tag1…`): the everyday key. Bound to this machine's TPM,
  unlocks without a prompt. Create it with `age-plugin-tpm --generate -o ~/.config/fnox/tpm.txt`.
  `age-plugin-tag` (from the `age` release tarball, in mise) is needed to encrypt to it.
- **YubiKey** (`~/.config/fnox/yubikey.txt`, `age1yubikey1…`): the recovery key. A PIN once per
  session and a touch every time. Create it with
  `age-plugin-yubikey --generate --name fnox-recovery --pin-policy once --touch-policy always`
  (add `--serial N` if several keys are plugged in) and save the identity it prints.
- The other recipients belong to other machines. After changing the list, run
  `fnox reencrypt -p age`.

The identity files are untracked: they name a serial and a slot, or hold a key blob wrapped by one
machine's TPM. A TPM key is useless on another machine, so keep the YubiKey recipient in the list.

Because the PIN is long and rarely typed, `yubikey-drill` (a user timer, `yubikey-drill.timer`)
opens a terminal once a drill is more than 25 days old and keeps asking daily until it is done.
It decrypts a canary file with the YubiKey: one PIN attempt, one touch. Run it by hand any time
with `yubikey-drill`. Three wrong PINs block the PIN, so stop after one miss.

### GPG and gopass

gpg-agent is unlocked at login the same way as the keyring, from a TPM-sealed credential:

1. Copy `~/.gnupg` from a machine that has the keys (`rsync -aHz host:.gnupg ~`). Then delete the
   lock files and socket stubs that came with it (`public-keys.d/.#lk*`, `pubring.db.lock`,
   `S.*`), or `gpg` waits forever on a lock held by a process on the other machine.
2. `mise dot apply`, then `mise bootstrap` (enables `gpg-agent-pass.service`).
3. `mise run seal-gpg` asks for the passphrase once and seals it to this TPM.

At login `gpg-agent-pass` presets the passphrase for the encryption subkey only. gopass can then
decrypt without a prompt, and nothing can sign with the key. `gpg-agent.conf` allows presetting and
caches for a day (a week at most); `systemctl --user restart gpg-agent-pass` after that.

## Not done yet

- gopass is installed but not set up (which store, and where it comes from). Git credentials
  still use the OS keychain and `gh`; the plan is to move them to gopass.
- The fnox secrets are readable by any process running as you. A lease-style system (fnox has
  `lease`) would limit that.
- `enroll-fido2` has unverified flags. The macOS Gitea credential helper is a TODO in
  `config.macos.toml`.
- Zed settings and the btop themes are not captured.
- The bootstrap section is Linux (pacman and AUR) only. macOS and Ubuntu would need their own
  `[bootstrap.packages]`, possibly as platform-specific config files.
