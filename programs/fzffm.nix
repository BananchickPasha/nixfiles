{ file, fzf, feh, neovim, helpers, writeScriptBin, zsh }:
let
  script = helpers.scriptWriter [
    /etc/nixos/sources/fzfm/preview.sh
    /etc/nixos/sources/fzfm/run.sh
  ] [ file fzf feh neovim ];
in helpers.alias "${script}/run.sh" "fzfm"
