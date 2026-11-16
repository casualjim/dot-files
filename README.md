# dot-files

Everything added on top of a fresh install, driven by [mise](https://mise.jdx.dev).
It has to work on macOS and on two kinds of Linux machine: headless (Arch or CachyOS, or Ubuntu) and
with a desktop (CachyOS). The one desktop so far is `galileo`, a Minisforum AI X1 Pro 470 running
CachyOS with niri and the Noctalia shell (Wayland only). The installer's own defaults
(kernel, firmware, fprintd, snapper, limine, NetworkManager) are deliberately not repeated.

Nothing secret lives here. See [Secrets](#secrets).

## Layout

| Path | What it is |
| --- | --- |
| `mise.toml` | What works on macOS and Linux: the check tools, `set-env`, identity and helper tasks. Run from this directory. |
| `mise.linux.toml` | Any Linux (loaded automatically): TPM, YubiKey, gpg and gopass setup, podman, tailscale, polkit. |
| `mise.arch.toml` | Arch and CachyOS, headless or desktop: the pacman and aur packages, the PAM and initramfs files. |
| `mise.desktop.toml` | A machine with a desktop: apps, greetd, the keyring, Voxtype, the Chrome policy. |
| `mise.fprint.toml` | A machine with a fingerprint reader: the PAM file that tries it first. |
| `.config/mise/config.toml` | The **global** mise config shared by every OS: `[tools]`, `[env]`, and the `[dotfiles]` table that maps files here to `~`. |
| `.config/mise/config.linux.toml`, `config.desktop.toml`, `config.macos.toml` | The same split for the global config: Linux-wide, desktop-only (niri, AppImages, nirinit), macOS-only. |
| `.config/mise/miserc.toml` | Turns on `auto_env` so the per-OS files load. `arch`, `ubuntu`, `desktop` and `fprint` cannot be detected, so you choose them per machine (below). |
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
mise run set-env arch desktop    # what this machine is: arch, ubuntu, desktop, fprint (galileo: arch desktop fprint)
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
7. `mise run voxtype-parakeet`: Right Ctrl push-to-talk, the Parakeet Ultra model, and the user service.
   That is what is in use now. `voxtype-setup` is the Qwen3-ASR alternative (the last one you run wins).
   `voxtype-gpu` is an optional Vulkan backend.
8. By hand: log in to Dropbox (the tray icon needs `libayatana-appindicator`, already installed) and
   restart Noctalia with `systemctl --user restart noctalia.service`.
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
| `helix-grammars` | Build Helix's tree-sitter grammars (slow). Config is tracked; `runtime/grammars` is build output and is not. The language servers named in `languages.toml` come from mise (TypeScript uses `tsc --lsp` from TypeScript 7). |
| `hindsight-install` | First time: `npx @vectorize-io/hindsight-coding-agents install all` (detects the agents), then the pi-mimir patch. Clones or fast-forwards `~/github/casualjim/pi-mimir` first (`pi-mimir-sync`). |
| `hindsight-update` | Update an existing or rsynced Hindsight, then re-apply the patch (`hindsight-patch`; an update wipes it). |
| `claude-code-config-sync` | Clone or fast-forward `casualjim/claude-code-config` and `bun install`. The Claude hooks in `~/.claude/settings.json` run from that exact path, so do this before using Claude Code on a new machine. |
| `codebase-memory-build` | Pull and build `DeusData/codebase-memory-mcp` with the UI, stop the daemon, install the binary into `~/.local/bin`, restart the daemon. Re-run to update. |
| `codebase-memory-install` | First time only: `codebase-memory-mcp install -y --hooks` (builds first). |
| `screensaver-install` | After desktop bootstrap: build `casualjim/omarchy-screensaver` branch `niri-screensaver` into `~/.local/bin`. Re-run to update. |

## Day to day

```bash
mise bootstrap --dry-run      # preview; asks for sudo to inspect /etc
mise bootstrap                # apply
mise dot apply                # re-link dotfiles only
```

Edit files in this repo, not the copies in `~` (most are symlinks into here). A few are
copied instead, and need `mise dot apply` after a change: `btop.conf`, and the units and scripts
for the keyring, gpg-agent and yubikey-drill. Run `noctalia msg config-reload` after changing `.config/noctalia/config.toml`.

Niri starts `noctalia.service`, which restarts the shell after a crash and stops with the graphical session.
The shell runs in `session.slice`, protected by CachyOS's OOM policy. CachyOS already enables `systemd-oomd`;
keep its packaged thresholds rather than adding another OOM manager.
Noctalia holds a logind delay inhibitor to lock before sleep; no separate sleep-lock service is installed.

The desktop screensaver starts after 120 seconds idle, before the existing 300-second lock.
Noctalia stops it on activity or lock; the `screensaver.service` user unit is started on demand,
not enabled at login. Artwork lives in `.config/niri/screensaver.txt`. Run
`mise run screensaver-install`, `mise dot apply`, `systemctl --user daemon-reload`, then
`noctalia msg config-reload` after first installing it. To preview, run
`systemctl --user start screensaver.service`.

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
- **Voxtype's config is captured as tasks, not as a file.** It lives in `~/.config/voxtype/config.toml`,
  which Voxtype rewrites atomically, so a symlink would not survive. `voxtype-config` sets the hotkey
  (Right Ctrl, push to talk) and turns its own OSD off, and `voxtype-parakeet` or `voxtype-setup` set
  the engine and model. Together they reproduce every non-default setting (`voxtype config` shows the
  resolved result).
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

## Keeping copies in step

Most dotfiles are symlinks, so an edit lands in the repo by itself. Some are `copy` entries because the app that owns
the file rewrites it (Tern settings, `mimeapps.list`, the world-clock zones, systemd units). For those, `mise dot apply`
only goes repo to live. `dotfiles-sync-back.service` (a user service, from `mise.linux.toml`) watches the live files
and, when one is newer than and different from its repo source, copies it back. It changes the working copy only:
review with `jj diff` and commit. A source you edited but have not applied is newer than its live file, so it is
never overwritten. Run `dotfiles-sync-back` by hand to sync once. When you add or remove a copy entry in the
global mise config, the watcher notices (it also watches the repo directory behind that config), exits, and
systemd starts it again with the new list. (`mise dot save` is something else: a checkpoint in mise's local
history.)

## Services that run at login

Besides the desktop pieces, two user services are declared in `mise.linux.toml`:

- `codebase-memory-mcp.service` runs `codebase-memory-mcp daemon start`. The daemon has no foreground mode: it
  double-forks and writes no pidfile, so the unit is `Type=forking` and systemd finds the process by itself. It is
  skipped until the binary exists (`mise run codebase-memory-build`).
- `headroom.service` is generated by podman from the Quadlet `.config/containers/systemd/headroom.container`
  (a rootless container on `127.0.0.1:8788`, state in `~/.local/state/headroom`). Quadlet units cannot be
  enabled, so mise only keeps it running; its `[Install]` section wires it to login.

## Coding-agent config is not tracked

The settings of Claude Code, Codex, pi and omp (`~/.claude`, `~/.codex`, `~/.pi`, `~/.omp`) change too
often and carry API keys, so they are deliberately **not** in this repo. A new machine gets them by copying the
config (not the history) from another machine. What is tracked is what goes on top: the install tasks
(`hindsight-install`, `codebase-memory-install`), the hooks repo (`claude-code-config-sync`), and
`~/.hindsight/coding-agent.json`. Session history is not carried over either; Hindsight is the shared memory.

## Tern

Tern is downloaded by hand from its private server (not yet released) and kept at `~/.local/bin/tern`. It
updates itself and the components it manages: `tern` (the terminal), `omp` (the coding agent), `ovfns`
(a copy-on-write filesystem) and `abkit` (the WebKit library it embeds). **Do not install any of those
with mise or pacman**, or two updaters will fight over the same files. Only `~/.config/tern/settings.json`
is tracked here, as a copy that `dotfiles-sync-back` keeps current (see below).

## Not done yet

- The fnox secrets are readable by any process running as you. A lease-style system (fnox has
  `lease`) would limit that.
- `enroll-fido2` has unverified flags. The macOS Gitea credential helper is a TODO in
  `config.macos.toml`.
- Zed settings and the btop themes are not captured.
- Only Arch and CachyOS have package lists (`mise.arch.toml`, `mise.desktop.toml`). macOS (brew) and
  Ubuntu (apt) still need theirs, as `mise.macos.toml` and `mise.ubuntu.toml`.
