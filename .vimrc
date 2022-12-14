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
" set ignorecase
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
" set spell
" set updatetime=100 " default updatetime 4000ms is not good for async update

" set mouse=nvi
" Disable arrow keys in normal mode
nmap <Up> <Nop>
nmap <Right> <Nop>
nmap <Left> <Nop>
nmap <Down> <Nop>

autocmd FileType json setlocal equalprg=python3.10\ -m\ json.tool

let g:ale_disable_lsp = 1 " Stop ALE from interfering with coc

call plug#begin()
  " Workflow improvments
  Plug 'tpope/vim-repeat' " Help plugins do stuff with .
  Plug 'tpope/vim-surround' " Quotes and braces
  Plug 'michaeljsmith/vim-indent-object' " Indentation as text object
  Plug 'bogado/file-line', { 'branch': 'main' } " Open to line `vi file.js:10`
  Plug 'tpope/vim-commentary' " Line comments
  Plug 'tpope/vim-abolish' " Case coercion
  Plug 'tpope/vim-eunuch' " UNIX commands
  Plug 'tpope/vim-unimpaired' " Mapping pairs
  Plug 'AndrewRadev/splitjoin.vim' " Convert between single and multiline statements

  " fzf and ripgrep support
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " Intellisense engine for vim8 & neovim
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " Support for rubocop and other syntax checkers
  Plug 'dense-analysis/ale'
  Plug 'ngmy/vim-rubocop', " do I really want this?

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

  " Color code delimiters
  Plug 'luochen1990/rainbow'

  " Indicate line indentation
  Plug 'Yggdroot/indentLine'

  " Color schemes
  Plug 'chriskempson/base16-vim'

  " Language support
  Plug 'sheerun/vim-polyglot'
  Plug 'tpope/vim-rails'
  Plug 'tpope/vim-rake'
  Plug 'tpope/vim-rbenv'
  Plug 'tpope/vim-bundler'
  Plug 'itmammoth/run-rspec.vim'
  Plug 'fladson/vim-kitty'

  " Git Support
  Plug 'mhinz/vim-signify'
  if has('nvim')
    Plug 'APZelos/blamer.nvim'
  endif
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  "Plug 'shumphrey/fugitive-gitlab'
call plug#end()

set t_Co=256 " 256 colorspace support
let base16colorspace = 256 " Access colors present in 256 colorspace
colorscheme base16-tomorrow-night-eighties
highlight Comment cterm=italic
hi Search cterm=bold ctermbg=DarkGray ctermfg=White guibg=DarkGray guifg=White
hi IncSearch cterm=bold ctermbg=DarkGray ctermfg=Gray guibg=DarkGray guifg=Gray

" Set whitespace indicator to red
let g:better_whitespace_ctermcolor='1'

" indentLine config (ctermfg 18 requires 256 colorspace)
let g:indentLine_setColors = 0
hi Conceal cterm=bold ctermfg=18 guifg=DarkGray
let g:indentLine_char = '│'

" Delimiter color config
let g:rainbow_active = 1

" Stop concealing characters in certain syntaxes (b/c indentLine)
let g:vim_json_syntax_conceal = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:csv_no_conceal = 1

" Setup skeleton file templates
" if has("autocmd")
" augroup templates
"   au!
"   autocmd BufNewFile *.* silent! execute '0r $HOME/.vim/templates/skeleton.'.expand("<afile>:e")
" augroup END
" endif

" ALE Global Configuration
nmap <silent> gk <Plug>(ale_previous_wrap)
nmap <silent> gj <Plug>(ale_next_wrap)
" let g:ale_fixers = {
"   'javascript': ['prettier', 'eslint'],
" }
let g:ale_sign_error = ' '
let g:ale_sign_warning = ' '
highlight ALEError term=underline cterm=underline,bold gui=underline,bold guisp=Red
highlight ALEWarning term=underline cterm=undercurl,bold gui=undercurl,bold guisp=Yellow
highlight ALEInfo term=underline cterm=undercurl gui=undercurl guisp=Blue
highlight ALEErrorSign ctermfg=1 ctermbg=18 guifg=#2d2d2d guibg=#393939
highlight link ALEWarningSign Todo

" Airline config
let g:airline_theme='base16'
let g:airline_powerline_fonts = 1
let g:airline_skip_empty_sections = 1
let g:airline_symbols = {}
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty = '*'
let g:airline_left_alt_sep = ' '
let g:airline_right_alt_sep = ' '

let g:airline#extensions#whitespace#enabled = 0

let g:airline#extensions#clock#format = '%a, %b %d %I:%M %p'
let g:airline#extensions#clock#updatetime = 1000

let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#ale#warning_symbol = ' '
let g:airline#extensions#ale#error_symbol = ' '
let g:airline#extensions#ale#checking_symbol = ''
let g:airline#extensions#ale#open_lnum_symbol = ' :'
let g:airline#extensions#ale#close_lnum_symbol = ''

let airline#extensions#coc#warning_symbol = '  '
let airline#extensions#coc#error_symbol = '  '

" Blamer config
if has('nvim')
  let g:blamer_enabled = 1
  let g:blamer_show_in_visual_modes = 0
  let g:blamer_template = '<committer> • <summary>'
endif

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
" hi CocErrorHighlight cterm=bold ctermbg=Red ctermfg=Black guibg=Red guifg=Black
" hi CocWarningHighlight cterm=bold ctermbg=DarkYellow ctermfg=White guibg=Orange guifg=White
" hi CocInfoHighlight cterm=bold ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
" hi CocHintHighlight cterm=bold ctermbg=Blue ctermfg=Black guibg=Blue guifg=Black

" CocFadeOut seems to link to Conceal. This sets CocFadeOut explicitly so
" indentLine doesn't interfere with it
hi CocFadeOut ctermbg=Black ctermfg=Grey guibg=Black guifg=Grey

" Fix coc auto complete menu
hi CocMenuSel ctermbg=19 guibg=#0000a2
" hi link CocMenuSel Cursor

" May need for vim (not neovim) since coc.nvim calculate byte offset by count
" utf-8 byte sequence.
set encoding=utf-8
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for apply code actions at the cursor position.
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer.
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for apply refactor code actions.
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
