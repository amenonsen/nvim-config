" Plugins configured in lua/plugins.lua have already been loaded from
" .local/share/nvim/site/pack/*/start by the time we reach here.

let mapleader = " "

set nocp ai hidden ruler showcmd terse writeany autowrite smarttab expandtab
set incsearch nohlsearch ignorecase smartcase nofoldenable nojs noshowmatch
set title titlestring= ttyfast vb t_Co=256 t_ti= t_te= t_vb= scrolloff=5
set tw=72 bs=1 history=1000 report=1 tags=tags background=dark t_Co=256
set mouse=a tabstop=8 shiftwidth=4 formatoptions=tcqnlj
set backupdir=~/tmp,.,~/ directory=~/tmp,.,~/
set spelllang=en_gb dictionary=/usr/share/dict/words complete=.,w,b,u,t,i,k,kspell,k~/.ispell_english
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc
"set formatlistpat="^\s*(*\d\+[.)] "
set updatetime=1000 timeoutlen=1000
set cursorline signcolumn=yes:1
set completeopt=menu,menuone,noselect

" Neovim doesn't support clipboard=autoselect; the best we can do is to
" make mouse selections yank into "* when you click+drag+release. See
" https://github.com/neovim/neovim/issues/2325 for details.
set clipboard=unnamed
if !has('nvim')
    set clipboard+=autoselect
else
    vmap <LeftRelease> "*ygv
endif

if has('termguicolors')
  set termguicolors
endif

if executable("rg")
    set grepprg=rg\ --vimgrep
endif

" We can't use splice.vim and fugitive together, but we need the former
" only if we are invoked as a git mergetool.
if v:argv[-1] == "SpliceInit"
    packadd splice.vim
else
    packadd vim-fugitive
endif

" In insert mode, correct the last spelling error with the first
" suggestion and keep going.
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

nnoremap <F9> <cmd>setlocal spell<CR>
nnoremap <C-z> :Gwrite<Cr>
nnoremap <C-d><C-d> :bd<Cr>
tnoremap <Esc> <C-\><C-n>

abbr &em- &#8239;—&thinsp;
digraph RU 8377 " ₹

map ' `

filetype plugin indent on

colorscheme antipathy

syntax enable

if !exists("autocmds_loaded")
    let autocmds_loaded = 1

    " Restore prior cursor (line) position when reopening a file.
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
                         \ exe "normal g'\"" | endif

    autocmd BufNewFile,BufRead *.post set filetype=post

    autocmd BufNewFile,BufRead */[pP]ostgre[sS]*/src/*.[chl] setlocal ts=4 sw=4 noexpandtab
    autocmd BufNewFile,BufRead */[pP]ostgre[sS]*/doc/src/* setlocal ts=4 sw=4 expandtab
    autocmd BufNewFile,BufRead */work/2ndq/*.[ch] setlocal ts=4 sw=4 noexpandtab

    autocmd FileType text setlocal textwidth=72
    autocmd FileType python setlocal textwidth=80

    autocmd FileType mail setlocal textwidth=72 comments=n:>,b:#
    autocmd FileType mail nnoremap <buffer> FF :s/^From: .*\(<.*>\)$/From: Abhijit Menon-Sen \1/<CR>
    autocmd FileType mail nnoremap <buffer> FW :s/^From: .*\(<.*>\)$/From: Abhijit Menon-Sen <abhijit@menon-sen.com>/<CR>:$s/-- ams/-- Abhijit/<CR>gg
    autocmd FileType mail nnoremap <buffer> SD :s/\(^[^:]*: \).* <\(.*@.*\)>/\1\2/<CR>
    autocmd FileType mail nnoremap <buffer> LR :s/\[[^]]*\] \([Rr][Ee]: \)* *//<CR>
    autocmd FileType mail nnoremap <buffer> TC ddpcwCck0cwTo0

    autocmd FileType html,xml setlocal nosmartindent indentexpr= indentkeys= sw=2 ts=2 sts=2 et
endif

nmap :q<CR> <cmd>echo "nope"<CR>
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
