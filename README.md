## Overview

This repository contains NixOS configurations for various systems, including NixOS, Darwin (macOS), and WSL. It is structured around a `flake.nix` file for system management and customization across different hardware and operating systems.

## Repository Structure

- **`flake.nix`**: The central configuration file that defines inputs and outputs for the system configurations.
- **`flake.lock`**: Lock file ensuring reproducible builds by specifying exact versions of dependencies.
- **`hosts/`**: Contains subdirectories for each target system (`darwin`, `iseries`, `oryp11`, `wsl`), each with its own `configuration.nix` and, where applicable, `hardware-configuration.nix`.
- **`modules/`**: Custom modules for system configuration, including a `neovim` setup using `nixvim` split across multiple files for each plugin.
- **`users/`**: User-specific configurations, including dotfiles and package selections. This also has a `modules/` folder for shared dotfile configuration.

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
