# Dev container host

A Docker image carrying the same environment as the darwin/NixOS hosts —
packages, zsh, tmux, btop, nixvim — minus anything that needs a GUI. Built for
the "WezTerm is the only thing installed locally" workflow: everything else
lives in the container, with `~/workplace` bind-mounted in from the host.

## Quick start

From the repo root, on a machine with Docker (Nix not required):

```sh
./dev
```

That installs the WezTerm config and a `dev` alias, builds the image if it is
missing, starts the container, and drops you into a shell. Afterwards `dev`,
`dev tmux` and `dev rebuild` are the commands you want. See `./dev help`.

## Layout

| file | what it is |
| --- | --- |
| `home.nix` | the Home Manager configuration the image is built from |
| `image.nix` | turns that generation into a Docker image |
| `clipboard.nix` | OSC 52 wiring for tmux and neovim |
| `nixos-compat.nix` | shim so the NixOS-shaped neovim mixins evaluate under HM |

Flake outputs:

```sh
nix build .#packages.x86_64-linux.devcontainer          # image tarball
docker load < result

nix build .#packages.aarch64-linux.devcontainer-stream  # streams the tarball
./result | docker load

home-manager switch --flake .#container-x86_64-linux    # the HM config alone
```

The image is only exposed for `x86_64-linux` and `aarch64-linux`. Building the
aarch64 one from an Apple Silicon Mac needs a Linux builder — either
`nix.linux-builder.enable` in the darwin config, a remote builder, or the
dockerised builder `./dev` falls back to when `nix` is not on PATH.

## What's inside

Everything from `users/modules/packages.nix` plus zsh/tmux/btop/nixvim, `nix`
itself with flakes enabled and a populated Nix database, and a home directory
materialised at build time from the Home Manager generation. Runs as root:
single-user Nix has to own `/nix`, and chowning the store would double the
image size.

Left out: wezterm, kitty, sketchybar, aerospace, ollama.

## Clipboard

There is no X11 or Wayland display in the container, so copying rides on
OSC 52 the whole way up:

```
nvim --(OSC 52)--> tmux --(OSC 52)--> WezTerm --> macOS pasteboard
```

`clipboard.nix` sets `set-clipboard on` plus the `clipboard` terminal feature
in tmux, and points neovim's `+`/`*` registers at
`vim.ui.clipboard.osc52.copy`. Yanks land on the host pasteboard, including
from inside tmux.

Paste deliberately does **not** go back through OSC 52. Reading the clipboard
means querying the terminal and waiting for an answer, and neovim blocks for
ten seconds when the terminal does not reply — WezTerm only replies with
`enable_osc52_clipboard_reading = true`. Instead `+p` reads the local register,
and Cmd-V works as normal because it arrives as a bracketed paste rather than a
clipboard query.

tmux also gets `default-terminal = tmux-256color` (Home Manager defaults to
plain `screen`, which costs italics and undercurl inside neovim) and
`escape-time 10`.

`./dev` passes the host terminal's `TERM` in as `HOST_TERM`, and `.zshenv`
adopts it only when the image has a matching terminfo entry. The image carries
ncurses' database — `wezterm`, `alacritty` and the `xterm-*` family are there,
kitty's `xterm-kitty` is not — so an unknown host `TERM` falls back to
`xterm-256color` instead of leaving tmux with a terminal it refuses to drive.

## State

`./dev rebuild` recreates the container and throws away its writable layer, so
every path holding credentials or long-lived state is a named volume. The list
lives in the `PERSIST` array at the top of `./dev`; adding one is a single
line.

| mount | holds |
| --- | --- |
| `~/workplace` (bind) | your code |
| `.aws` | config, credentials, and the SSO token cache in `.aws/sso` |
| `.azure`, `.config/gcloud` | Azure and gcloud logins |
| `.kube`, `.config/k9s`, `.config/helm` | kubeconfig, k9s config, helm repos |
| `.terraform.d` | terraform plugin cache and credentials |
| `.config/gh`, `.config/glab-cli` | GitHub and GitLab auth |
| `.config/github-copilot`, `.codex` | Copilot and Codex auth |
| `.docker` | registry logins |
| `.ssh`, `.gnupg` | keys — created `0700` in the image so the volume inherits it |
| `.m2` | maven repo |
| `.local/state`, `.local/share`, `.cache` | nvim undo/shada, zsh history, caches |

Two constraints on that list. A volume must not be mounted over a path the
image bakes (`.zshrc`, `.zshenv`, `.config/{btop,git,nvim,tmux}`): docker seeds
a fresh volume from the image once and never refreshes it, so you would be
pinned to a stale copy after every rebuild. And it must be a directory, since
docker creates a directory at the mount point — a dotfile like `~/.npmrc`
cannot be persisted this way.

## Sharing host credentials

By default each entry in `PERSIST` is a named volume private to the container,
so you authenticate once inside it and that survives rebuilds. If you would
rather the container see credentials you already hold on the host, list the
names in `DEV_HOST_SHARE` and they bind the host's real directory instead:

```sh
DEV_HOST_SHARE="aws ssh gcloud kube" ./dev
```

The host path is `$HOME/<same relative path>`, so `gcloud` binds
`~/.config/gcloud`. A name whose host directory does not exist falls back to a
volume with a warning. Changing this only takes effect when the container is
created, so `./dev rm` first.

## codex login

`codex login` runs its OAuth callback server on `127.0.0.1:1455` inside the
container and hardcodes `redirect_uri=http://localhost:1455/auth/callback`.
Docker publishes ports to the container's eth0 rather than its loopback, so a
plain `-p 1455:1455` cannot reach it — hence the `--device-auth` suggestion
codex prints when it detects a headless machine.

`./dev codex-login` works around that: it runs `socat` on port 1456 (which
docker does publish, bound to the host's loopback only) forwarding to codex's
listener, then starts the login. Open the printed URL on the host and the
`localhost:1455` redirect lands in the container.

If codex is installed on the host, the simpler route is to authenticate there
and share the directory — the token in `~/.codex/auth.json` is not machine
bound:

```sh
DEV_HOST_SHARE="codex" ./dev
```

`DEV_CODEX_PORT` changes the host-side port if 1455 is taken.

## Docker in the container

The host's docker socket is bind-mounted by default, so `docker` and `docker
compose` inside the container drive the host daemon. `DEV_DOCKER_SOCK=0` turns
it off.

Docker Desktop keeps the socket at `~/.docker/run/docker.sock` and only exposes
`/var/run/docker.sock` when *Settings → Advanced → "Allow the default Docker
socket to be used"* is enabled, so `./dev` probes for whichever exists and
warns if neither does. `DEV_DOCKER_SOCK_PATH` overrides.

The usual caveat applies: the daemon is the host's, so `-v` paths in commands
you run *inside* the container are resolved on the **host**. `docker run -v
$(pwd):/x` from `/root/workplace` silently mounts an empty host directory,
because the Mac has that tree at `/Users/<you>/workplace`. Use the host path
for volume arguments, or keep to bind-free workflows.

`avante` is pointed at `http://host.docker.internal:11434` so it reaches
ollama running on the macOS host rather than looking for it inside the
container.
