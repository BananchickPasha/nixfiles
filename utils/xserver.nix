{ config, pkgs, lib, ... }:
{
  options = with lib; {
    services.myXmonad = mkOption {
     default = false;
     type = types.bool;
    };
    services.myGnome = {
     default = false;
     type = types.bool;
    };
  };
  config = lib.mkIf (config.services.myXmonad) {
    services.autorandr.enable = true;
    services.xserver = {
     enable = true;
     synaptics.enable = true;
     #videoDrivers = ["nvidiaLegacy390"];
     displayManager.startx.enable = true;
     windowManager.xmonad = {
       enable = true;
       enableContribAndExtras = true;
       extraPackages = haskellPackages: [
         haskellPackages.split
         haskellPackages.lens
         ];
       };
     };
   };
}
