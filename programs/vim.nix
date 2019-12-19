{pkgs, hie}:
let vimCommon = 
      {
        customRC = ''
          colo gruvbox
          set number
          set termguicolors
          set clipboard=unnamedplus
          syntax on
          set background=dark
          set hlsearch
          set incsearch
          set tabstop=2
          set shiftwidth=2
          set smarttab
          set expandtab
          map <C-n> :NERDTreeToggle<CR>
          "tnoremap <Esc><Esc><Esc> <C-\><C-n>
          command! W w !tee /tmp/ff && ${pkgs.my.dmenu}/bin/dmenu -p 'Enter password: ' | sudo -S 2> /dev/null sudo mv /tmp/ff %

          inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
          inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
          set completeopt=noinsert,menuone,noselect
          autocmd BufEnter  *  call ncm2#enable_for_buffer()

          map <C-q> :GFiles<CR>
          map <C-c> :Commits<CR>
          map <C-l> :Lines<CR>
        '';
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            gruvbox
            vim-nix
            nerdtree
            ncm2
            ncm2-path 
            ncm2-bufword 

            fzfWrapper
            fzf-vim
          ];
          opt = [];
        };
      };
      overrider = pkgs.neovim.override;
      defaultPackages = vimCommon.packages.myVimPackage.start;
      hieWrapper = pkgs.writers.writeBash "hie" "${hie}/bin/hie +RTS -c -M1500M -K1G -A16M -RTS --lsp $@";
in
rec {
    default = overrider {
        withRuby = false;
        withPython = false;
        withPython3 = true;
        configure = vimCommon // {
          packages.myVimPackage.start = with pkgs.vimPlugins; [
            vim-polyglot
            ] ++ defaultPackages;
          };
        };
    vide = overrider {
        withRuby = false;
        withPython = false;
        withPython3 = true;
        configure = vimCommon // {
          customRC = ''
            source /home/banan/.vimrc
            '' + vimCommon.customRC + ''
            let g:LanguageClient_serverCommands = { 
                \ 'haskell': ['${hieWrapper}'],
                \ 'cpp': ['${pkgs.cquery}/bin/cquery'],
                \ 'c': ['${pkgs.cquery}/bin/cquery'],
                \ 'xml': ['/etc/nixos/sources/lspxml/lspxml.sh'],
                \ 'xsd': ['/etc/nixos/sources/lspxml/lspxml.sh'],
                \ 'dtd': ['/etc/nixos/sources/lspxml/lspxml.sh'],
                \}
          '';
          packages.myVimPackage.start = with pkgs.vimPlugins; [
              LanguageClient-neovim
              echodoc-vim
              nerdtree
              haskell-vim
              fugitive
              vim-polyglot
              #airline
              #undotree
            ] ++ defaultPackages;
          };
        };
    term = overrider {
        withRuby = false;
        withPython = false;
        withPython3 = false;
        configure = vimCommon // {
          customRC = ''
              set nonumber
              set laststatus=1
              set noshowmode
            '';
          packages.myVimPackage.start = [];
          };
        };
    }
