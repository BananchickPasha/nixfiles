# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

let hie = import (fetchTarball {
  url = "https://github.com/infinisil/all-hies/tarball/master";
}) {};
in
{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./Utils/xserver.nix
      #./Utils/nextcloud.nix
      ./Utils/wireguard.nix
      ./Utils/zfsSender.nix
    ];

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  services.timesyncd.enable = false;
  services.zfsSendSnapshots.sendFromToPairs = [
    {from = "system/home"; to = "shit/backups/home"; }
    {from = "system/root"; to = "shit/backups/root"; }
  ];

  networking.firewall = 
  let nfsPorts = [111 1039 1047 1048 2049]; 
  in {
    allowedTCPPorts = [60990 22832 80 443 25565] ++ nfsPorts;
    allowedUDPPorts = [60990 22832 25565 443] ++ nfsPorts;
  };


  services.logind = {
    #lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  services.rpcbind.enable = true;
  services.nfs.server = {
    enable = false;
    mountdPort = 1048;
    lockdPort = 1039;
    statdPort = 1047;
    exports = ''
      / 192.168.31.33(rw,fsid=0,sync,no_root_squash)
      /run 192.168.31.33(rw,fsid=1,sync,no_root_squash,no_subtree_check)
      /nix 192.168.31.33(ro,fsid=2,no_subtree_check)
      /home 192.168.31.33(rw,fsid=3,no_subtree_check)
      '';
  };

  virtualisation.docker.enable = true;
  services.mongodb.enable = false;
  users.extraUsers.banan = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };
  users.extraUsers.root.shell = pkgs.zsh;
  

  nix = {
    gc.automatic = false;
    binaryCaches = lib.mkForce [
      "https://cache.nixos.org/"
      "https://all-hies.cachix.org/"
    ];
    binaryCachePublicKeys = [
      "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
    ];
    trustedUsers = [ "root" "banan" ];
  };

  services.myXmonad = true;
  /*
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  */
  
  networking.hostName = "nixosPasha"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hostId = "b214b35a";
  services.sshd.enable = true;
  services.openssh = {
    permitRootLogin = "no";
    passwordAuthentication = false;
    ports = [ 22832 ];
    authorizedKeysFiles = [ "/home/banan/.nixos-configuration/keys/ssh/authorized_keys" ];
  };

  time.timeZone = "Europe/Kiev";


  fonts = rec {
    fonts = with pkgs; [
      dejavu_fonts
      font-awesome_5 
      ubuntu_font_family
    ];
    fontconfig.defaultFonts.monospace = [ "Ubuntu Mono" ];
    fontconfig.defaultFonts.sansSerif = [ "Ubuntu" ];
    fontconfig.defaultFonts.serif = [ "Ubuntu" ]; 
  };

  #I don't know why, but without $overrided all-overrides doesn't see helpers
  nixpkgs.config = let overrided = pkgs; in{
    allowUnfree = false;
    allowUnsupportedSystem = true;
    packageOverrides = pkgs: {
      unstable = import <unstable> {
        config = config.nixpkgs.config;
      };
      haskellEnv = pkgs.haskellPackages.ghcWithHoogle
                       (haskellPackages: with haskellPackages; [
                       ]);
      my = import ./Programs/all-overrides.nix {pkgs = overrided;};
      helpers = import ./Utils/helpers/helpers.nix;
      hie.hies = (hie.selection { selector = p: { inherit (p) ghc865 ; }; });
      #hie.hies = (hie.bios.selection { selector = p: { inherit (p) ghc865 ; }; });
    };
  };
  environment.systemPackages = with pkgs.my;
  [
		st
    pmenuAlias
    dmenu
    videAlias
    viAlias
    ranger-killer
    code
    dotnet
    #kak
	]
	++
  (with pkgs;
	[
    cquery
    pkgs.hie.hies
    haskellEnv
    neofetch 
    wget 
    firefox
    unstable.mono
    unstable.tdesktop
    #unstable.kakoune
    xclip
    maim
    qbittorrent
    vlc
    krita
    feh
    numix-gtk-theme
    arc-icon-theme
    gnome3.adwaita-icon-theme
    ranger
    unzip
    stow
    cmus
    git
    fzf
    killall
    htop
    sxhkd
    moreutils
    xdotool
  ]);

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
