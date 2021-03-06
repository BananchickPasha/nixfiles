{ pkgs, ... }:
with pkgs;
let
  alias = helpers.alias;
  aliasPath = helpers.aliasPath;
in rec {
  st = pkgs.st.overrideAttrs (oldAttrs: {
    name = "pahan-st";
    src = /etc/nixos/sources/st-0.8.2;
  });
  pmenu = pkgs.dmenu.overrideAttrs (oldAttrs: {
    name = "pahan-dmenu";
    src = /etc/nixos/sources/dmenu-4.9;
  });
  dmenu = pkgs.dmenu.overrideAttrs (oldAttrs: {
    name = "pahan-dmenu";
    src = /etc/nixos/sources/dmenu-def/dmenu-4.9;
  });
  code = pkgs.unstable.vscodium.overrideDerivation (old: {
    postFixup = ''
      wrapProgram $out/bin/codium --prefix PATH : ${
        lib.makeBinPath [ hie.hies ]
      }
    '';
  });
  codeWithPackages = pkgs.buildFHSUserEnv {
    name = "vscodium";
    targetPkgs = pkgs: [ ];
    multiPkgs = pkgs: [ code icu openssl ];
    runScript = "codium";
  };
  emacs = callPackage ./emacs.nix { };
  pmenuAlias = alias "${pmenu}/bin/dmenu" "pmenu";
  ranger-killer = callPackage ./fzffm.nix { neovim = vims.default; };
  kak = with pkgs.unstable;
    let
      masterKak = kakoune-unwrapped.overrideAttrs (oldAttrs: {
        src = fetchGit { url = "https://github.com/mawww/kakoune"; };
      });
    in masterKak.overrideAttrs (oldAttrs: {
      getPlugins = [
        #kakounePlugins.kak-powerline
        #kakounePlugins.kak-fzf
        kak-lsp
      ];
    });
  mysox = sox.overrideAttrs (oldAttrs: {
    buildInputs = [
      lame
      alsaLib
      libao
      flac
      libmad
      libogg
      libvorbis
      libpng
      libsndfile
      libpulseaudio
      libav
    ];
  });
  vims = import ./vim.nix {
    pkgs = pkgs;
    hie = pkgs.hie.hies;
  };
  viAlias = alias "${vims.default}/bin/nvim" "vi";
  videAlias = aliasPath "${vims.coc}/bin/nvim" "vide"
    (with pkgs; [ haskellPackages.ghcide rustup ]);
  neovim = alias "${vims.justvim}/bin/nvim" "jvim";
}
