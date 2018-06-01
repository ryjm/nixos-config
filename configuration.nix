# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
    ./hardware-configuration.nix
    ./local-configuration.nix
    ./packages.nix
    ./desktop.nix
    ./dotfiles.nix
    ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;
  hardware.pulseaudio.enable = true;
  time.timeZone = "America/New_York";

  # Configure audio setup for JACK + Overtone
  boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Update Intel microcode on boot (both machines have Intel CPUs):
  hardware.cpu.intel.updateMicrocode = true;

  networking = {
    # Don't use ISP's DNS servers:
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    # Open Chromecast-related ports
    firewall.allowedTCPPorts = [ 5556 5558 ];
  };

  # Generate an immutable /etc/resolv.conf from the nameserver settings
  # above (otherwise DHCP overwrites it):
  environment.etc."resolv.conf" = with lib; with pkgs; {
    source = writeText "resolv.conf" ''
      ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
      options edns0
    '';
  };

  # Configure emacs:
  # (actually, that's a lie, this only installs emacs!)
  services.emacs = {
    install = true;
    defaultEditor = true;
    package = import ./emacs.nix { inherit pkgs; };
  };

  services.openssh.enable = true;

  # Enable GNOME keyring (required for Evolution)
  services.gnome3.gnome-keyring.enable = true;

  # Enable OfflineIMAP (configuration itself is user-data)
  services.offlineimap = {
    install = true;
    path    = with pkgs; [ pass notmuch ];
  };

  virtualisation = {
    # Configure Docker (with socket activation):
    # Side note: ... why is this in virtualisation? ...
    docker.enable = true;
    docker.autoPrune.enable = true;
  };

  # Configure various other applications:
  programs = {
    java.enable = true;
    java.package = pkgs.openjdk;

    fish.enable = true;
    ssh.startAgent = true;
  };

  services.postgresql.enable = true;
  users.defaultUserShell = pkgs.fish;
  
  # Configure user account
  users.extraUsers.jake = {
    extraGroups = [ "wheel" "docker" ];
    isNormalUser = true;
    uid = 1001;
    shell = pkgs.fish;
    initialHashedPassword = "";
  };
  

  security.sudo = {
    enable = true;
    extraConfig = "wheel ALL=(ALL:ALL) SETENV: ALL";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
