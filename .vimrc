" Fallback editor, deliberately plugin-free. neovim (aliased to `vi`) is the
" real one and owns the LSP and plugin stack. This config has to work where
" that cannot follow: sudo, another account, a machine with nothing installed.

set number
set linebreak
set showbreak=-->
set cpoptions+=n
set breakindent
set breakindentopt+=sbr
set textwidth=0
set showmatch

set hlsearch
set smartcase
set incsearch

set autoindent
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=8

set ruler
set nojoinspaces
set backspace=indent,eol,start
set encoding=utf-8

syntax on
set title
colorscheme habamax

" Enable mouse support in only visual mode
set mouse=v

" Disable arrow keys in normal mode
nmap <Up> <Nop>
nmap <Right> <Nop>
nmap <Left> <Nop>
nmap <Down> <Nop>

if has('autocmd')
  " python3 stays unversioned, so a minor-version upgrade cannot break this.
  autocmd FileType json setlocal equalprg=python3\ -m\ json.tool
endif
