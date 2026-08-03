## Overview

This repository contains NixOS configurations for various systems, including NixOS, Darwin (macOS), and WSL. It is structured around a `flake.nix` file for system management and customization across different hardware and operating systems.

## Repository Structure

- **`flake.nix`**: The central configuration file that defines inputs and outputs for the system configurations.
- **`flake.lock`**: Lock file ensuring reproducible builds by specifying exact versions of dependencies.
- **`hosts/`**: Contains subdirectories for each target system (`darwin`, `iseries`, `oryp11`, `wsl`), each with its own `configuration.nix` and, where applicable, `hardware-configuration.nix`.
- **`modules/`**: Custom modules for system configuration, including a `neovim` setup using `nixvim` split across multiple files for each plugin.
- **`users/`**: User-specific configurations, including dotfiles and package selections. This also has a `modules/` folder for shared dotfile configuration.
- **`dotfiles/`**: Raw, hand-copyable versions of configs for machines where Nix cannot be installed.
- **`dev`**: One-liner bootstrap for the dev container (see below).

## Dev container

`hosts/container/` builds a Docker image with the same environment as the other
hosts — packages, zsh, tmux, btop, nixvim — minus anything that needs a GUI. It
is meant for the "WezTerm is the only thing installed locally" workflow, with
`~/workplace` bind-mounted in from the host.

On any machine with Docker, from the repo root:

```bash
./dev
```

That installs the WezTerm config into `~/.config/wezterm`, adds a `dev` alias to
`~/.zshrc`, builds the image if it is missing, starts the container, and drops
you into a shell. After that, `dev` gets you back in, `dev tmux` attaches a
persistent tmux session, and `dev rebuild` picks up config changes. `./dev help`
lists the rest.

Nix does **not** need to be installed on the machine running `./dev`: without it
the image is built inside a throwaway `nixos/nix` container. See
[`hosts/container/README.md`](hosts/container/README.md) for details.

## Usage

### Applying Configurations

To apply a configuration to a system, use the appropriate command based on your system:

- **NixOS**:
  ```bash
  nixos-rebuild switch --flake .#<hostname>
  ```

Replace `<hostname>` with the target system name, such as `iseries`, `oryp11`, `wsl`, or `jlittle-mbp`.

### Customization

The `hosts/` directory is the starting point for customizing configurations for different machines. The `modules/` directory allows for shared customization of system behavior, including desktop environment tweaks, font management, and Neovim plugins.
