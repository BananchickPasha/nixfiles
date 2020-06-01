let
  hie = import (fetchTarball {
    url = "https://github.com/infinisil/all-hies/tarball/master";
  }) { };
in { config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./utils/xserver.nix
    #./utils/nextcloud.nix
    ./utils/wireguard.nix
    ./utils/zfsSender.nix
  ];

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  networking.networkmanager.enable = true;
  services.flatpak.enable = false;
  xdg.portal.enable = true;
  services.timesyncd.enable = false;

  networking.firewall = let
    nfsPorts = [ 111 1039 1047 1048 2049 3000 ];
    minecraft = 37131;
  in {
    allowedTCPPorts = [ 60990 22832 80 443 25565 minecraft ] ++ nfsPorts;
    allowedUDPPorts = [ 60990 22832 25565 443 minecraft ] ++ nfsPorts;
  };

  services.logind = {
    #lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  services.rpcbind.enable = true;
  services.nfs.server = {
    enable = true;
    mountdPort = 1048;
    lockdPort = 1039;
    statdPort = 1047;
    exports = ''
      /rust 192.168.31.99(rw,fsid=1,sync,no_root_squash,no_subtree_check)
    '';
  };

  virtualisation.docker.enable = true;
  services.mongodb.enable = false;
  users.extraUsers.banan = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
  };
  users.extraUsers.root.shell = pkgs.zsh;

  nix = {
    gc.automatic = false;
    binaryCaches = lib.mkForce [
      "https://cache.nixos.org/"
      "https://all-hies.cachix.org/"
      "https://hydra.iohk.io"
    ];
    binaryCachePublicKeys = [
      "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    trustedUsers = [ "root" "banan" ];
  };

  services.myXmonad = true;
  /* services.xserver.enable = true;
     services.xserver.displayManager.gdm.enable = true;
     #services.xserver.displayManager.gdm.wayland = false;
     services.xserver.desktopManager.gnome3.enable = true;
  */

  networking.hostName = "nixosPasha";
  networking.hostId = "b214b35a";
  services.sshd.enable = true;
  services.openssh = {
    permitRootLogin = "no";
    passwordAuthentication = false;
    ports = [ 22832 ];
    authorizedKeysFiles = [ "/etc/nixos/keys/ssh/authorized_keys" ];
  };

  time.timeZone = "Europe/Kiev";

  programs.fuse.userAllowOther = true;
  fonts = rec {
    fonts = with pkgs; [ dejavu_fonts font-awesome_5 ubuntu_font_family ];
    fontconfig.defaultFonts.monospace = [ "Ubuntu Mono" ];
    fontconfig.defaultFonts.sansSerif = [ "Ubuntu" ];
    fontconfig.defaultFonts.serif = [ "Ubuntu" ];
  };

  #I don't know why, but without $overrided all-overrides doesn't see helpers
  nixpkgs.config = let overrided = pkgs;
  in {
    allowUnfree = false;
    allowUnsupportedSystem = true;
    packageOverrides = pkgs: {
      unstable = import <unstable> { config = config.nixpkgs.config; };
      my = import ./programs/all-overrides.nix { pkgs = overrided; };
      helpers = import ./utils/helpers/helpers.nix;
      hie.hies = (hie.selection { selector = p: { inherit (p) ghc865; }; });
    };
  };
  environment.pathsToLink = [ "/share/agda" ];
  environment.systemPackages = with pkgs.my;
    [
      st
      pmenuAlias
      dmenu
      videAlias
      viAlias
      neovim
      ranger-killer
      #codeWithPackages
      emacs
      #kak
    ] ++ (with pkgs; [
      agdaPrelude
      ghc
      mpv
      dzen2
      cquery
      #pkgs.hie.hies
      neofetch
      wget
      firefox
      unstable.tdesktop
      xclip
      maim
      qbittorrent
      krita
      feh
      numix-gtk-theme
      arc-icon-theme
      gnome3.adwaita-icon-theme
      unzip
      cmus
      git
      fzf
      killall
      htop
      unstable.ytop
      sxhkd
      moreutils
      xdotool
      zip
    ]);

  system.stateVersion = "20.03";

}
