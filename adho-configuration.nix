# Local configuration 
{ config, pkgs, ...}:

{
  
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
  };

  boot.growPartition = true;
  boot.loader.grub.device = "/dev/sda";

  virtualisation.virtualbox.guest.enable = true;
  # Office printer configuration
  services.printing.enable  = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.avahi.enable     = true;
  services.avahi.nssmdns    = true;

  networking = {
    hostName = "demo";
    wireless.enable = false;
    wireless.userControlled.enable = true;

    # wireless.networks = {
    #   # # Welcome to roast club!
    #   # "plasticbag_5GHz" = {
    #   #   psk = "washyourface";
    #   # };

    #   # # On the go!
    #   # "Rumpetroll" = {
    #   #   psk = "fisk1234";
    #   #   # If this network exists, chances are that I want it:
    #   #   priority = 10;
    #   # };
  };

  hardware.bluetooth.enable = true;
}
