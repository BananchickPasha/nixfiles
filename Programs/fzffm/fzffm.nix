{file, fzf, feh, neovim, helpers, writeScriptBin, zsh}:
let script = helpers.scriptWriter [./preview.sh ./run.sh] [file fzf feh neovim];
in
  helpers.alias "${script}/run.sh" "fzfm"
