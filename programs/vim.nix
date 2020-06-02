{ pkgs, hie }:
let
  vimCommon = {
    customRC = ''
      colo gruvbox
      set termguicolors
      set number
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

      map <C-q> :GFiles<CR>
      map <C-c> :Commits<CR>
      map <C-l> :Lines<CR>
    '' + ''
      let g:neoformat_haskell_brittany = {
        \ 'exe': '${pkgs.haskellPackages.brittany}/bin/brittany',
      \ }
      let g:neoformat_nix_nixfmt = {
        \ 'exe': '${pkgs.nixfmt}/bin/nixfmt',
        \ 'stdin': 1,
      \ }
      let g:neoformat_sh_shfmt = {
        \ 'exe': '${pkgs.shfmt}/bin/shfmt',
      \ }
    '';
    packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        gruvbox
        vim-polyglot
        vim-nix
        nerdtree
        fzfWrapper
        fzf-vim

        neoformat
      ];
      opt = [ ];
    };
  };
  overrider = pkgs.neovim.override;
  defaultPackages = vimCommon.packages.myVimPackage.start;
  #hieWrapper = pkgs.writers.writeBash "hie" "${hie}/bin/hie +RTS -c -M1500M -K1G -A16M -RTS --lsp $@";
in rec {
  default = overrider {
    withRuby = false;
    withPython = false;
    withPython3 = true;
    configure = vimCommon // {
      customRC = vimCommon.customRC + ''
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
        set completeopt=noinsert,menuone,noselect
        autocmd BufEnter  *  call ncm2#enable_for_buffer()
      '';
      packages.myVimPackage.start = with pkgs.vimPlugins; [
        ncm2
        ncm2-path
        ncm2-bufword
      ] ++ defaultPackages;
    };
  };
  coc = overrider {
    withRuby = false;
    withPython = false;
    withPython3 = true;
    configure = vimCommon // {
      customRC = vimCommon.customRC + ''
        let g:coc_node_path = '${pkgs.nodejs}/bin/node'
        set signcolumn=yes
        nmap <silent> gd <Plug>(coc-definition)
        " Use K to show documentation in preview window.
        nnoremap <silent> K :call <SID>show_documentation()<CR>

        function! s:show_documentation()
          if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
          else
            call CocAction('doHover')
          endif
        endfunction

        autocmd CursorHold * silent call CocActionAsync('highlight')
      '';
      packages.myVimPackage.start = with pkgs.vimPlugins;
        [
          coc-nvim
          coc-yaml
          coc-html
          coc-rls
          coc-highlight
        ] ++ defaultPackages;
    };
  };
  justvim = overrider {
    withRuby = false;
    withPython = false;
    withPython3 = false;
    configure = { customRC = ""; };
  };
}
