{ config, pkgs, lib, ... }:

# Proton (proton.me) desktop applications.
#
# Naming trap: nixpkgs also carries protonup-qt, protontricks and
# proton-ge-bin. Those are Valve's Proton, the Wine-based Steam compatibility
# layer, and have nothing to do with this company. They are deliberately not
# here; add them via the Steam config if you want them.
#
# There is no Proton VPN CLI to install. protonvpn-cli and protonvpn-cli_2
# were the old Python client and no longer resolve in nixpkgs at all, so the
# GTK app below is the whole of the supported Linux VPN client. Headless hosts
# should not use it: they want a declarative wg-quick tunnel instead (see
# hosts/proxmox/media), because the app expects a desktop session and keyring.
{
  environment.systemPackages = with pkgs; [
    # VPN. Logs in with Proton *account* credentials. The OpenVPN/IKEv2
    # username and password shown in the account portal are a separate
    # credential set, only for third-party clients, and are not used here.
    protonvpn-gui
    # Required alongside it: the app negotiates WireGuard through the kernel
    # rather than shipping a userspace implementation.
    wireguard-tools

    # Mail. The bridge exposes a local IMAP/SMTP endpoint so ordinary clients
    # can talk to an end-to-end encrypted mailbox; -gui is the tray frontend,
    # the base package is the headless binary and is what you want over SSH.
    protonmail-bridge
    protonmail-bridge-gui
    # Electron app for Mail and Calendar, independent of the bridge.
    protonmail-desktop

    # Password manager and TOTP manager.
    # proton-authenticator is unfree, so an importing host needs
    # nixpkgs.config.allowUnfree = true or evaluation will fail.
    proton-pass
    proton-authenticator
  ];

  # Proton's client is dropped by the firewall's reverse-path filter: replies
  # arrive on the tunnel interface rather than the one the kernel expects for
  # that source, and strict rp_filter discards them. This is the standard
  # NixOS requirement for the app and it will silently fail to connect
  # without it.
  # https://discourse.nixos.org/t/how-to-configure-and-use-proton-vpn-on-nixos/65837
  networking.firewall.checkReversePath = false;
}
