function! VimPlugGuard(plug, plugged)
  if empty(glob(a:plug))
    silent execute '!curl -fLo ' . shellescape(a:plug) . ' --create-dirs 
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
  call plug#begin(a:plugged)
endfunction

if has('nvim')
  call VimPlugGuard($HOME . '/.local/share/nvim/site/autoload/plug.vim',
        \ $HOME . '/.local/share/nvim/site/plugged')
else
  call VimPlugGuard($HOME . '/.vim/autoload/plug.vim', $HOME . '/.vim/plugged')
endif

Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'shinchu/lightline-gruvbox.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'ojroques/vim-oscyank'
Plug 'fatih/vim-go', { 'tag': '*' }
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }
Plug 'shougo/unite.vim'
Plug 'majutsushi/tagbar'
Plug 'jiangmiao/auto-pairs'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'voldikss/vim-translator'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tweekmonster/startuptime.vim'
Plug 'justinmk/vim-sneak'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'andymass/vim-matchup'
if has('nvim')
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
else
  Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
endif

"Plug 'lifepillar/vim-gruvbox8'
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
"Plug 'ervandew/supertab'
call plug#end()

let mapleader=","
set encoding=utf-8
set hidden
set tabstop=8
set shiftwidth=2
set softtabstop=2
set autoindent
set expandtab       " Expand TABs to spaces
set cmdheight=1     " Give more space for displaying messages
set updatetime=300  " Default 4000ms leads to noticeable delays
set shortmess+=c    " Don't pass messages to |ins-completion-menu|
set hlsearch
set relativenumber
set colorcolumn=80
set signcolumn=yes
set cursorline
set laststatus=2
set list
set t_u7= " https://github.com/vim/vim/issues/390#issuecomment-531477332
set t_RV= " https://stackoverflow.com/questions/21618614/vim-shows-garbage-characters
if !has('gui_running')
  set t_Co=256
endif

" backup/swap/info/undo settings
set nobackup
set nowritebackup
set undofile
set swapfile
if has('nvim')
  set backupdir  -=.
  set shada       ='100
else
  let $v = $HOME . '/.vim'
  set backupdir   =$v/files/backup
  set directory   =$v/files/swap//
  set undodir     =$v/files/undo
  set viewdir     =$v/files/view
  set viminfo     ='100,n$v/files/info/viminfo
  if empty(glob($v . '/files'))
    silent !mkdir -p $v/files/{backup,swap,undo,view,info}
  endif
endif

if has('multi_byte') && &encoding ==# 'utf-8'
  let &listchars = 'tab:▸ ,extends:❯,precedes:❮,nbsp:±,trail:·'
  let &fillchars = 'vert: ,diff: '  " ⣿
  let &showbreak = '↪ '
  highlight VertSplit ctermfg=242
else
  let &listchars = 'tab:> ,extends:>,precedes:<,nbsp:.'
  let &fillchars = 'vert: ,stlnc:#'
  let &showbreak = '-> '
  augroup vimrc
    autocmd InsertEnter * set listchars-=trail:.
    autocmd InsertLeave * set listchars+=trail:.
  augroup END
endif

syntax on
filetype plugin indent on

" color scheme
colorscheme gruvbox
set bg=dark
if has('termguicolors')
  set termguicolors
endif
let g:lightline = {}
let g:lightline.colorscheme = 'gruvbox'
hi Normal guibg=NONE ctermbg=NONE

" Jump to the last position when reopening a file
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \ | exe "normal! g'\"" | endif

" Window jump
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <silent> <space>l :noh<cr> " clear hlsearch

" gitgutter
nmap <silent> ]h <Plug>(GitGutterNextHunk)
    \ :call repeat#set("\<Plug>(GitGutterNextHunk)")<CR>
nmap <silent> [h <Plug>(GitGutterPrevHunk)
    \ :call repeat#set("\<Plug>(GitGutterPrevHunk)")<CR>
nmap <silent> \h :call GitGutterNextHunkCycle()<CR>
    \ :call repeat#set("\\h")<CR>

function! GitGutterNextHunkCycle()
  let line = line('.')
  GitGutterNextHunk
  if line('.') == line
    1
    GitGutterNextHunk
  endif
endfunction

" vim-translator
nmap <silent> <leader>t <Plug>Translate

" tagbar
nmap <F8> :TagbarToggle<CR>

" Tmux navigator
nnoremap <silent><c-h>  :<c-u>call Tmux_navigate('h')<cr>
nnoremap <silent><c-j>  :<c-u>call Tmux_navigate('j')<cr>
nnoremap <silent><c-k>  :<c-u>call Tmux_navigate('k')<cr>
nnoremap <silent><c-l>  :<c-u>call Tmux_navigate('l')<cr>

function! Tmux_navigate(direction) abort
  let oldwin = winnr()
  execute 'wincmd' a:direction
  if !empty($TMUX) && winnr() == oldwin
    let sock = split($TMUX, ',')[0]
    let direction = tr(a:direction, 'hjkl', 'LDUR')
    silent execute printf('!tmux -S %s select-pane -%s', sock, direction)
  endif
endfunction

" systemtap script ft
autocmd BufRead,BufNewFile *.stp set filetype=stp

" vim-commentary
autocmd FileType c,cpp,cs,java setlocal commentstring=//\ %s
noremap <leader>/ :Commentary<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" coc.nvim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocomplete
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" highlight uses on hover
autocmd CursorHold * silent call CocActionAsync('highlight')

" navigation
nmap <silent> [g <Plug>(coc-diagnostic-prev)
    \ :call repeat#set("\<Plug>(coc-diagnostic-prev)")<CR>
nmap <silent> ]g <Plug>(coc-diagnostic-next)
    \ :call repeat#set("\<Plug>(coc-diagnostic-next)")<CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)

" show docs
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" scroll popup
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" file manager
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
" nnoremap <C-f> :NERDTreeFine<CR>
" Start NERDTree and leave the cursor in it
autocmd VimEnter * NERDTree | wincmd p
" Exit Vim if NERDTree is the only window remaining in the only tab
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 &&
    \ exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fzf.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let $FZF_DEFAULT_OPTS="--bind \"ctrl-n:preview-down,ctrl-p:preview-up\" --layout=reverse"
let $BAT_THEME='1337'
" completion
imap <c-x><c-l> <plug>(fzf-complete-line)
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')
inoremap <expr> <c-x><c-k> fzf#vim#complete('cat /usr/share/dict/words')
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case --follow -- '.shellescape(<q-args>), 1,
    \   fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Rgs
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case --follow --sort-files -- '.shellescape(<q-args>), 1,
    \   fzf#vim#with_preview(), <bang>0)

nnoremap <silent> <leader>p  :<C-u>Files<CR>
nnoremap <silent> <leader>gf :<C-u>GFiles<CR>
nnoremap <silent> <leader>gs :<C-u>GFiles?<CR>
nnoremap <silent> <leader>gc :<C-u>Commits<CR>
nnoremap <silent> <leader>f  :<C-u>let cmd = 'Rg<Space><C-r>"' <bar> call histadd("cmd", cmd) <bar> execute cmd<CR>
nnoremap <silent> <leader>F  :<C-u>let cmd = 'Rg!<Space><C-r>"' <bar> call histadd("cmd", cmd) <bar> execute cmd<CR>
nnoremap          <leader>r  :<C-u>Rg<Space>
nnoremap          <leader>R  :<C-u>Rg!<Space>
nnoremap <silent> <leader>h  :<C-u>History:<CR>
nnoremap <silent> <leader>s  :<C-u>History/<CR>
nnoremap <silent> <leader>b  :<C-u>Buffers<CR>
nnoremap <silent> <leader>l  :<C-u>Lines<CR>
nnoremap <silent> <c-x><c-f> :<C-u>BLines!<CR>
nnoremap <silent> <c-x><c-j> :<C-u>Marks<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-oscyank
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | OSCYankReg " | endif
vnoremap <leader>c :OSCYank<CR>
nnoremap <silent> <leader>e :call GetFnLn()<CR>
nnoremap <silent> <leader>w :echo expand("%:p") . ':' . line(".")<CR>

" Copy remote server vim fn:ln to local system's clipboard
function! GetFnLn()
  let fnln = expand("%:h") . '/' . expand("%:t") . ':' . line(".")
  call setreg('z', fnln) " set fn:ln to reg z
  OSCYankReg z           " yank fn:ln at reg z by OSC
  call setreg('z', @_)   " clear reg z
endfunction
