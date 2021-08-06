" Plugins have already been loaded and configured in plugins.lua by the
" time we reach here.

let mapleader = " "

" We can't use splice.vim and fugitive together, but we need the former
" only if we are invoked as a git mergetool.
if v:argv[-1] == "SpliceInit"
    packadd splice.vim
else
    packadd vim-fugitive
endif

" Neovim doesn't support clipboard=autoselect; the best we can do is to
" make mouse selections yank into "* when you click+drag+release. See
" https://github.com/neovim/neovim/issues/2325 for details.
set clipboard=unnamed
if !has('nvim')
    set clipboard+=autoselect
else
    vmap <LeftRelease> "*ygv
endif

" WTF?
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

nnoremap <F9> <cmd>setlocal spell<CR>
nnoremap <F5> :MundoToggle<CR>
nnoremap Tb :Telescope builtin<Cr>
nnoremap <C-f> :lua require('telescope-files').project_files()<Cr>
nnoremap <C-g> :Telescope live_grep<Cr>
nnoremap <C-b> :Telescope buffers<Cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <C-z> :Gwrite<Cr>
nnoremap <C-n> :NERDTreeToggle<Cr>
nnoremap <C-d><C-d> :bd<Cr>
nnoremap <C-t><C-t> :TagbarToggle<Cr>
nnoremap <leader>as :SourcetrailRefresh<CR>
nnoremap <leader>aa :SourcetrailActivateToken<CR>

abbr &em- &#8239;—&thinsp;
digraph .. 8230 " …
digraph v/ 10003 " ✓
digraph \/ 10007 " ✗
digraph RU 8377 " ₹

map ' `
map FF :s/^From: .*\(<.*>\)$/From: Abhijit Menon-Sen \1/
map FW :s/^From: .*\(<.*>\)$/From: Abhijit Menon-Sen <abhijit@menon-sen.com>/:$s/-- ams/-- Abhijit/gg
map LR :s/\[[^]]*\] \([Rr][Ee]: \)* *//
map SD :s/\(^[^:]*: \).* <\(.*@.*\)>/\1\2/
map TC ddpcwCck0cwTo0

filetype plugin indent on

set nocp ai hidden ruler showcmd terse writeany autowrite smarttab expandtab
set incsearch nohlsearch ignorecase smartcase nofoldenable nojs noshowmatch
set title titlestring= ttyfast vb t_Co=256 t_ti= t_te= t_vb= scrolloff=5
set tw=72 bs=1 history=1000 report=1 tags=tags background=dark t_Co=256
set mouse=a tabstop=8 shiftwidth=4 formatoptions=tcqnlj
set undofile backupdir=~/tmp,.,~/ directory=~/tmp,.,~/
set spelllang=en_gb dictionary=/usr/share/dict/words complete=.,w,b,u,t,i,k,kspell,k~/.ispell_english
set completeopt=menuone,noselect
set completeopt-=preview
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc
"set formatlistpat="^\s*(*\d\+[.)] "
set updatetime=2000

if executable("rg")
    set grepprg=rg\ --vimgrep
endif

if has('termguicolors')
  set termguicolors
endif

function! MyHighlights() abort
    highlight MatchParen ctermbg=black ctermfg=blue
    highlight Pmenu ctermbg=grey ctermfg=black guibg=#a89984
    highlight PmenuSel ctermbg=white ctermfg=black guifg=blue
    highlight NormalFloat guibg=#1f5364
    highlight FloatBorder guifg=white guibg=#1f2335
    highlight TreesitterContext guibg=#a89984
endfunction

if !exists("autocmds_loaded")
    let autocmds_loaded = 1

    " Restore prior cursor (line) position when reopening a file.
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
                         \ exe "normal g'\"" | endif

    " Override highlights with my preferences (defined above) when
    " setting a colorscheme.
    augroup colours
        autocmd!
        autocmd ColorScheme * call MyHighlights()
    augroup end

    " Format python buffers on save. Disabled because invoking Black
    " through formatter.nvim causes hangs.
    augroup FormatAutogroup
        "autocmd!
        "autocmd BufWritePost *.py FormatWrite
    augroup END

    autocmd BufNewFile,BufRead *.post set filetype=post
    autocmd BufRead */postgres/src/*.[chl] setlocal ts=4 sw=4 noexpandtab tags=tags
    autocmd BufRead */postgres/doc/src/* setlocal ts=4 sw=4 expandtab tags=tags
    autocmd BufRead */postgre[sS][qQ][lL]/src/*.[chl] setlocal ts=4 sw=4 noexpandtab tags=tags
    autocmd BufRead */postgre[sS][qQ][lL]/doc/src/* setlocal ts=4 sw=4 expandtab tags=tags
    autocmd BufRead */work/2ndq/*.[ch] setlocal ts=4 sw=4 noexpandtab

    autocmd FileType text setlocal textwidth=72
    autocmd FileType mail setlocal textwidth=72 comments=n:>,b:#
    autocmd FileType python setlocal textwidth=80

    " Tree-sitter based folding seems to work, but I don't use it much.
    " There's also an lsp-based version at 'pierreglaser/folding-nvim'.
    "
    "autocmd FileType python setlocal foldmethod=expr
    "autocmd FileType python setlocal foldexpr=nvim_treesitter#foldexpr()
endif

colorscheme low

syntax off
