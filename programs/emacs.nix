{ pkgs1 ? import <unstable> { } }:

let
  pkgs = import <unstable> { };
  myEmacs = pkgs.emacs;
  emacsWithPackages = (pkgs.emacsPackagesGen myEmacs).emacsWithPackages;
in emacsWithPackages (epkgs: (with epkgs.melpaPackages; [ vterm ]))
