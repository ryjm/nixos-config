# Configuration for the desktop environment

{ config, lib, pkgs, ... }:

let emacs = import ./emacs.nix { inherit pkgs; };
screenLock = pkgs.writeShellScriptBin "screen-lock" ''
  find ${pkgs.wallpapers} -name "*.png" | shuf -n1 | xargs i3lock -f -t -i
'';
in {
  # Configure basic X-server stuff:
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    windowManager.default = "exwm";
    layout = "us,no,ru";
    xkbOptions = "caps:super, grp:shifts_toggle, parens:swap_brackets";
    videoDrivers = [ "virtualbox" "vmware" "cirrus" "vesa" "modesetting" ];
    exportConfiguration = true;
    
    # Give EXWM permission to control the session.
    displayManager.sessionCommands = "${pkgs.xorg.xhost}/bin/xhost +SI:localuser:$USER";
  };

  # Add a shell script with random screen lock wallpaper selection
  environment.systemPackages = [ screenLock ];

    # Configure desktop environment:
  services.xserver.windowManager.session = lib.singleton {
    name = "exwm";
    start = ''
      ${emacs}/bin/emacs --daemon -f exwm-enable
      ${emacs}/bin/emacsclient -c
    '';
  };


  # Apparently when you have house guests they complain about your screen tearing!
  services.compton.enable = true;
  services.compton.backend = "xrender";


  # Configure fonts
  fonts = {
    fonts = with pkgs; [
      font-awesome-ttf
      input-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      powerline-fonts
      helvetica-neue-lt-std
    ];
  };

  # Configure random setting of wallpapers
  systemd.user.services.feh-wp = {
    description = "Randomly set wallpaper via feh";
    serviceConfig = {
      Type             = "oneshot";
      WorkingDirectory = "${pkgs.wallpapers}/share/wallpapers";

      # Manually shuffle because feh's --randomize option can't be restricted to
      # just certain file types.
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.fd}/bin/fd -atf | shuf | head -n1 | ${pkgs.findutils}/bin/xargs ${pkgs.feh}/bin/feh --bg-fill'";
    };
  };

  systemd.user.timers.feh-wp = {
    description = "Set a random wallpaper every hour";
    wantedBy    = [ "graphical-session.target" ];
    partOf      = [ "graphical-session.target" ];

    timerConfig = {
      OnActiveSec     = "1second";
      OnUnitActiveSec = "1hour";
    };
  };
}
