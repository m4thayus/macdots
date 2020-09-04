set number
set relativenumber
set linebreak
set showbreak=-->
set cpoptions+=n
set breakindent
set breakindentopt+=sbr
set textwidth=0
set showmatch

set hlsearch
set smartcase
set ignorecase
set incsearch

set autoindent
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=8

set ruler
set nojoinspaces

set backspace=indent,eol,start

syntax on
set title
" set updatetime=100 " default updatetime 4000ms is not good for async update
set t_Co=256 " 256 colorspace support

" set mouse=nvi
nmap <Up> <Nop>
nmap <Right> <Nop>
nmap <Left> <Nop>
nmap <Down> <Nop>

autocmd FileType json setlocal equalprg=python\ -m\ json.tool

call plug#begin()
  " Workflow improvments
  Plug 'tpope/vim-repeat' " Help plugins do stuff with .
  Plug 'tpope/vim-surround' " Quotes and braces
  Plug 'bogado/file-line' " Open to line `vi file.js:10`
  Plug 'tpope/vim-commentary' " Line comments
  Plug 'tpope/vim-abolish' " Case coercion

  " Intellisense engine for vim8 & neovim
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " Support for rubocop and other syntax checkers
  Plug 'vim-syntastic/syntastic',
  Plug 'ngmy/vim-rubocop',

  " A tree explorer
  Plug 'scrooloose/nerdTree'
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
  Plug 'Xuyuanp/nerdtree-git-plugin'

  " Airline
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'enricobacis/vim-airline-clock'

  " Icons
  Plug 'ryanoasis/vim-devicons'

  " Auto-completion
  Plug 'Raimondi/delimitMate' " Quotes/Braces
  Plug 'tpope/vim-endwise' " Ruby def/end
  Plug 'tpope/vim-ragtag' " HTML/XXML tags

  " Highlight whitespace
  Plug 'ntpeters/vim-better-whitespace'

  " Indicate line indentation
  Plug 'Yggdroot/indentLine'

  " Color schemes
  Plug 'chriskempson/base16-vim'

  " Language support
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-rails'
  Plug 'tpope/vim-rake'
  Plug 'tpope/vim-rbenv'

  " Git Support
  Plug 'mhinz/vim-signify'
  if has('nvim')
    Plug 'APZelos/blamer.nvim'
  endif
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  "Plug 'shumphrey/fugitive-gitlab'
call plug#end()

let base16colorspace = 256 " Access colors present in 256 colorspace
colorscheme base16-tomorrow-night-eighties " Uses kitty's 256 colorspace scheme
highlight Comment cterm=italic
hi Search cterm=bold ctermbg=DarkGray ctermfg=White guibg=DarkGray guifg=White
hi IncSearch cterm=bold ctermbg=DarkGray ctermfg=Gray guibg=DarkGray guifg=Gray

" indentLine config
let g:indentLine_setColors = 0
hi Conceal cterm=bold ctermfg=18 guifg=DarkGray
let g:indentLine_char = '│'

" Airline config
let g:airline#extensions#whitespace#enabled = 0
let g:airline_powerline_fonts = 1
let g:airline_skip_empty_sections = 1
let g:airline_symbols = {}
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty = '*'
let g:airline_left_alt_sep = ' '
let g:airline_right_alt_sep = ' '
let g:airline#extensions#clock#format = '%a, %b %d %I:%M %p'
let g:airline#extensions#clock#updatetime = 1000

" Blamer config
if has('nvim')
  let g:blamer_enabled = 1
  let g:blamer_show_in_visual_modes = 0
  let g:blamer_template = '<committer> • <summary>'
endif

" Close nerdTree if only window left is a nerdTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Ctrl+n toggles nerdtree
map <C-n> :NERDTreeToggle<CR>

let g:NERDTreeShowLineNumbers = 1

" Other nerdTre config
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "M",
    \ "Staged"    : "S",
    \ "Untracked" : "U",
    \ "Renamed"   : "R",
    \ "Unmerged"  : "X",
    \ "Deleted"   : "D",
    \ "Dirty"     : "*",
    \ "Clean"     : "C",
    \ 'Ignored'   : 'I',
    \ "Unknown"   : "?"
    \ }
let g:NERDTreeShowIgnoredStatus = 1
let g:webdevicons_enable_nerdtree = 1
let g:NERDTreeMinimalUI = 1

" Rubocop/Syntastic config
let g:syntastic_ruby_checkers = ['rubocop', 'mri']
let g:syntastic_coffeescript_checkers = ['coffeelint']
let g:syntastic_auto_jump = 0 " always populates location list if enabled
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let airline#extensions#syntastic#warning_symbol = '  '
let airline#extensions#syntastic#error_symbol = '  '
let airline#extensions#syntastic#stl_format_err = '%E{%e : %fe}'
let airline#extensions#syntastic#stl_format_warn = '%W{%w : %fw}'

" CoC config
let g:coc_global_extensions = [
  \"coc-eslint",
  \"coc-json",
  \"coc-tsserver",
  \"coc-html",
  \"coc-css",
  \"coc-yaml",
  \"coc-yank",
  \"coc-spell-checker"
  \]
" hi default CocErrorHighlight cterm=bold ctermbg=Red ctermfg=Black guibg=Red guifg=Black
" hi default CocWarningHighlight cterm=bold ctermbg=DarkYellow ctermfg=White guibg=Orange guifg=White
" hi default CocInfoHighlight cterm=bold ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
" hi default CocHintHighlight cterm=bold ctermbg=Blue ctermfg=Black guibg=Blue guifg=Black

let airline#extensions#coc#warning_symbol = '  '
let airline#extensions#coc#error_symbol = '  '

" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `ctrl-k` and `ctrl-j` to navigate diagnostics
nmap <silent> <c-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <c-j> <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
" coc-yank
nnoremap <silent> <space>y  :<C-u>CocList -A --normal yank<cr>
