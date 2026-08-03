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

## State

`./dev` bind-mounts `~/workplace` and keeps four named volumes so `./dev
rebuild` does not throw away credentials or editor state:

| mount | holds |
| --- | --- |
| `~/workplace` (bind) | your code |
| `nix-dev-state` | `~/.local/state` — nvim undo/shada, zsh history |
| `nix-dev-cache` | `~/.cache` |
| `nix-dev-gh` | `gh` auth |
| `nix-dev-copilot` | Copilot auth |

Anything else lives in the container's writable layer and is recreated from the
image on rebuild.

`avante` is pointed at `http://host.docker.internal:11434` so it reaches
ollama running on the macOS host rather than looking for it inside the
container.
