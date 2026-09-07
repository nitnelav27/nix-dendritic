# apt/ — non-Nix system software for utdt10141

utdt10141 runs Nix only as `home-manager` on top of stock Ubuntu (see
`modules/hosts/utdt10141/`). Everything under `modules/hosts/utdt10141/`
and the shared `modules/programs/` tree declares the home directory:
dotfiles, shell config, editor config, VS Code settings, terminal themes.

Desktop applications, dev toolchains and general CLI utilities are
installed with `apt` (or, where noted, snap/a vendor `.deb`) instead, so
that a proprietary vendor tool that assumes a normal FHS Ubuntu — like
FortiClient — behaves exactly like it would on any other Ubuntu box, with
no Nix involved.

This directory is the "reproduce this after a wipe" half of that split:
it does not get applied automatically by anything (there's no Nix
evaluation of it, no idempotent re-apply, no drift detection — that's the
tradeoff for not fighting Nix over apt's job). It's a snapshot you
maintain by hand and re-run after a fresh install or disk wipe.

## Files

- `packages.txt` — output of `apt-mark showmanual`, i.e. every package you
  explicitly asked apt to install (not the transitive dependency closure —
  that's what makes this list actually reproduce *intent*, not noise).
  Regenerate it with:

  ```sh
  apt-mark showmanual > apt/packages.txt
  ```

  Do this every so often, and definitely before a planned wipe/reinstall.

- `sources.list.d/` — copy of `/etc/apt/sources.list.d/*.list` (or the
  newer deb822 `*.sources` files) for every third-party repo you've added
  (FortiClient's own repo if you use one, VS Code's, Docker's, Spotify's,
  etc). Without these, `apt install <package-from-a-ppa>` just fails with
  "unable to locate package" on a fresh box, even though the name is
  right.

- `keyrings/` — copy of the matching GPG keyring files, usually from
  `/etc/apt/keyrings/` or `/usr/share/keyrings/`. Ubuntu 22.04+ refuses to
  use a repo whose signing key isn't present, so these have to travel with
  `sources.list.d/`.

- `bootstrap.sh` — replays all of the above on a fresh Ubuntu install, in
  the right order (keys → repos → apt update → packages).

## What's NOT covered here

- **Bare `.deb` installs** (`dpkg -i whatever.deb`, no repo at all) won't
  show up in `apt-mark showmanual` in a way you can `apt install` back.
  If FortiClient (or anything else) was installed this way, note the
  package name, version and download URL in this README by hand.
- **snap / flatpak** packages: `snap list` / `flatpak list
  --columns=application` — not tracked here yet. Add a `snaps.txt` /
  `flatpaks.txt` the same way if you use either.
- **Packages that only exist as a Nix build** (this repo's own dotfile
  tooling: `nil`, `pyright`, `ripgrep`, `fzf`, `nixpkgs-fmt`, `shellcheck` —
  see `modules/hosts/utdt10141/programs/nixTools.nix`). Those are the
  exception to "everything comes from apt" — they're kept in Nix because
  `nvf.nix` and this flake's own editing depend on them directly, not
  because apt can't provide them.

## Caveats on the "just move this to apt" list

These packages used to be installed via Nix in
`modules/hosts/utdt10141/programs/homePkgsUtdt10141.nix` and
`modules/programs/homeBasePkgs.nix`. Moving them to apt is not uniformly a
one-line `apt install <name>` — verify each of these on the actual machine
(`apt-cache policy <name>`) before relying on it:

| Was (Nix package)         | apt/snap/other                                              | Caveat |
|---|---|---|
| `firefox`                 | `firefox`                                                    | Ubuntu 22.04+ ships this as a **snap** via a transitional apt package. If you want a real `.deb`, add the `ppa:mozillateam/ppa` repo and apt-pin it above the snap wrapper. |
| `thunderbird`              | `thunderbird`                                                | Same snap-wrapper situation as firefox. |
| `libreoffice-qt`           | `libreoffice`                                                | Straightforward — real deb in the main archive. |
| `zathura`                  | `zathura` (+ `zathura-pdf-poppler` or `zathura-djvu` etc.)   | Base package alone won't open PDFs — you need a `zathura-pdf-*` backend too. |
| `pandoc`                   | `pandoc`                                                     | apt's version usually lags Nix's by a fair bit. |
| `gnuplot`, `wordnet`, `p7zip` (→ `p7zip-full`), `qpdf` | same names (roughly) | Standard universe packages, low risk. |
| `gcc`, `gnumake`, `libtool`, `cmake` | `build-essential` (gcc/make/libtool) + `cmake` separately | `build-essential` is the usual meta-package for the first three; `cmake` isn't bundled in it. |
| `luajitPackages.luacheck` | `luarocks` + `luarocks install luacheck`, or check for a `lua-check`/`luacheck` apt package on your release | Not consistently apt-packaged across Ubuntu releases — verify before relying on it. |
| `spotify`                  | needs Spotify's own apt repo + key, **or** the Ubuntu snap    | Not in the default archive at all — pick one and add it to `sources.list.d/`. |
| `teams-for-linux`          | vendor `.deb`/repo (unofficial community build)               | Not in Ubuntu's archive; you were already relying on a Nix package pulling from GitHub for this. |
| `hugo`                     | `hugo`                                                        | Present, but often an older version than Nix's — check if that matters for your sites. |
| `sioyek`                   | **no apt package**                                            | Not packaged for Ubuntu. Either keep it in Nix (drop it back into `homePkgsUtdt10141.nix`), build/install their AppImage by hand, or switch PDF readers. |
| `papers` (GNOME Papers)    | check `apt-cache policy papers` on your Ubuntu version         | Recent GNOME app; may not exist yet on your Ubuntu release. Evince (`org.gnome.Evince.desktop`, already your fallback default) is the safe bet if not. |
| `languagetool`             | **no clean apt package**                                      | Normally run as a local server jar or through a browser extension/flatpak — not a simple apt install. |
| `enchant`                  | dropped entirely                                               | It's a spell-check backend library; apt-installed LibreOffice/Thunderbird/etc. pull their own automatically. |
| `uv` (astral)               | **not in Ubuntu's apt archive** (as of Ubuntu 24.04)            | Install via their official installer script or pipx instead of apt. |
| fonts (`noto-fonts`, `roboto`, `barlow`, etc.) | `fonts-noto`, `fonts-roboto`, etc.        | Base font families are fine via apt. |
| Nerd Fonts (`nerd-fonts.jetbrains-mono`, `.meslo-lg`, `.symbols-only`) | **not in Ubuntu's archive**       | The *patched* glyph-added variants aren't apt-packaged. Download the release zips from ryanoasis/nerd-fonts and drop them in `~/.local/share/fonts` by hand, or keep these three in Nix. |
| `btop`, `fastfetch`, `eza`, `tldr`, `duf`, `bat`, `fzf`\*, `fd`, `tree`, `unzip`, `zip`, `shellcheck`\*, `jq`, `sqlite` (→ `sqlite3`), `dialog`, `dig` (→ `dnsutils`), `killall` (→ `psmisc`), `iperf` (→ `iperf3`), `aspell`+dicts, `hunspell`+dicts | mostly present under the apt names shown | `bat` installs as `/usr/bin/batcat` on Debian/Ubuntu (name clash with an existing package) — alias it or symlink. `fd` installs as `fdfind` for the same reason. \*`fzf` and `shellcheck` stayed in Nix (see nixTools.nix) since nvf.nix uses them directly. |

None of this table is applied automatically — it's here so `packages.txt`
+ `bootstrap.sh` don't quietly go stale the day you actually run them.
