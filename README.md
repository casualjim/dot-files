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
mise bootstrap                   # accounts, packages, /etc files, services, dotfiles, tools
```

Then the steps that need you present. `mise tasks` lists them:

| Task | When |
| --- | --- |
| `seal-keyring` | Seal the keyring password to the TPM. Needs `~/.config/keyring-unlock.cred` (never in the repo). |
| `enroll-fido2` | Enroll a FIDO2 token as a LUKS keyslot. Interactive. **Verify the flags first** (TODO in the task). |
| `rebuild-initramfs` | After the mkinitcpio drop-in changes. |
| `resolv-stub`, `tailscale-up` | Tailscale MagicDNS and joining the tailnet. |
| `voxtype-setup` or `voxtype-parakeet` | Voxtype settings, a model, and its user service. Log out and in first (the `input` group). |
| `voxtype-gpu` | Optional Vulkan backend. |
| `git-identity` | Set your git name and email in `~/.gitconfig`, which is untracked because this repo is public. Shared settings are in `.config/git/config`. |
| `jj-identity` | Set your jj name and email. They live in an untracked `~/.config/jj/conf.d/10-user.toml`, because this repo is public. |
| `bat-cache` | After the Catppuccin bat themes change. |

Log out and back in after the first `mise bootstrap`: it adds you to the `tss` and `input` groups.

## Day to day

```bash
mise bootstrap --dry-run      # preview; asks for sudo to inspect /etc
mise bootstrap                # apply
mise dot apply                # re-link dotfiles only
```

Edit files in this repo, not the copies in `~` (most are symlinks into here). A few are
copied instead, and need `mise dot apply` after a change: `btop.conf`, the keyring unit and
script. Run `noctalia msg config-reload` after changing `.config/noctalia/config.toml`.

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
  `systemd-creds decrypt` as a normal user is refused. The packaged
  `gnome-keyring-daemon.socket/.service` are masked on purpose.
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

Never committed (see `.gitignore`): `~/.config/mise/age.txt` (age key), `*.cred`
(TPM-sealed credentials, tied to one machine's TPM), and `*.age`, `*.key`. Restore the age key
from your password manager before using anything encrypted with it. After a TPM change or a
new machine, re-seal the keyring with `mise run seal-keyring`.

## Not done yet

- `gitconfig` still needs rewriting as a per-OS template.
- Zed settings and the btop themes are not captured.
- The bootstrap section is Linux (pacman and AUR) only. macOS and Ubuntu would need their own
  `[bootstrap.packages]`, possibly as platform-specific config files.
