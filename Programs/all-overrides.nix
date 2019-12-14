{pkgs, ...}:
with pkgs;
let alias = helpers.alias;
in rec {
    st = 
      pkgs.st.overrideAttrs (oldAttrs: {
        name = "pahan-st";
        src = /home/banan/MySourceProgramms/st-0.8.2;
      });
    pmenu =
      pkgs.dmenu.overrideAttrs (oldAttrs: {
        name = "pahan-dmenu";
        src = /home/banan/MySourceProgramms/dmenu-4.9;
      });
    dmenu =
      pkgs.dmenu.overrideAttrs (oldAttrs: {
        name = "pahan-dmenu";
        src = /home/banan/MySourceProgramms/dmenu-def/dmenu-4.9;
      });
    code = pkgs.vscodium.overrideDerivation (old: {
      postFixup = ''
        wrapProgram $out/bin/codium --prefix PATH : ${lib.makeBinPath [hie.hies]}
      '';
    });
    #code = import ./vscode.nix;
    dotnet = callPackage /home/banan/NixOsChannel/dotnet/dotnet.nix {};
    #zsh = callPackage /home/banan/NixOsChannel/athame/zsh.nix {vim = vims.default; isNeovim = true;};
    zsh = callPackage /home/banan/NixOsChannel/athame/zsh.nix {};
    pmenuAlias = alias "${pmenu}/bin/dmenu" "pmenu";
    ranger-killer = callPackage ./fzffm/fzffm.nix {neovim = vims.default;};
    kak = with pkgs.unstable; let masterKak = kakoune-unwrapped.overrideAttrs ( oldAttrs:
    {
 src = fetchGit {
   url = "https://github.com/mawww/kakoune";
  };
    }); in
    masterKak.overrideAttrs (oldAttrs: {
      getPlugins = [
        #kakounePlugins.kak-powerline
        #kakounePlugins.kak-fzf
        kak-lsp
      ];
    });
    mysox = 
      sox.overrideAttrs (oldAttrs: {
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
    vims = import ./vim.nix {inherit pkgs; hie = pkgs.hie.hies;};
    viAlias    = alias "${vims.default}/bin/nvim" "vi";
    videAlias  = alias "${vims.vide}/bin/nvim"    "vide";
    cocAlias   = alias "${vims.coc}/bin/nvim"    "coc";
    }
