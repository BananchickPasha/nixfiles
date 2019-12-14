# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ahci" "firewire_ohci" "usb_storage" "usbhid" "usb_uhci" "usb_ohci" "sdhci_pci" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.kernelParams = ["root=ZFS=system/root"];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  boot.tmpOnTmpfs = true;
  services.zfs.autoScrub.enable = true;
  boot.zfs.enableUnstable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8; # keep the latest eight 15-minute snapshots (instead of four)
    monthly = 12;  # keep only one monthly snapshot (instead of twelve)
  };


  fileSystems."/" =
    { device = "system/root";
      fsType = "zfs";
    };
  fileSystems."/nix" =
    { device = "system/nix";
      fsType = "zfs";
    };
  fileSystems."/etc/nixos" =
    { device = "system/root/nixos";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "system/home";
      fsType = "zfs";
    };

  fileSystems."/LocalDiskF" =
    { device = "shit/shit";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/sda1";
      fsType = "vfat";
    };


  swapDevices =
    [ { device = "/dev/disk/by-id/ata-GOODRAM_A45A0775118600020829-part2"; }
    ];

  nix.maxJobs = lib.mkDefault 4;
}