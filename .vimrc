scriptencoding utf-8

" Install vim-plug if first init
if !filereadable(expand('~/.vim/autoload/plug.vim'))
    let s:first_init = 1
endif
if exists('s:first_init')
    echom 'Plugin manager: vim-plug has not been installed. Try to install...'
    exec 'silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs '.
                \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    echom 'Installing vim-plug complete.'
endif

call plug#begin('~/.vim/plugged')

" Code completion
"if has('python3') || has('python') && v:version > 704
    "Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer `type go &> /dev/null && echo \"--go-completer\"` `type node &>/dev/null && echo \"--ts-completer\"`', 'for': ['c', 'cpp', 'objc', 'objcpp'] }
    "Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
"endif
if v:version > 704
    Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}
endif
"Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java' }

" Syntax checker & Highlight
"if has('nvim')
    "Plug 'arakashic/chromatica.nvim', { 'do': ':UpdateRemotePlugins', 'for': ['c', 'cpp', 'objc', 'objcpp'] }
"elseif v:version > 704
    "Plug 'jeaye/color_coded', { 'do': 'rm -f CMakeCache.txt && cmake . -DDOWNLOAD_CLANG=FALSE && make clean && make && make install', 'for': ['c', 'cpp', 'objc', 'objcpp'] }
"endif
Plug 'luochen1990/rainbow'
if has('python3') || has('python')
    Plug 'Valloric/MatchTagAlways'
    "Plug 'python-mode/python-mode',  { 'for': 'python' }
endif
"if v:version > 704
    "Plug 'w0rp/ale'
    "Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoUpdateBinaries' }
"endif
Plug 'Chiel92/vim-autoformat'
"Plug 'skywind3000/echofunc'
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
"Plug 'leafgarland/typescript-vim'
"Plug 'ap/vim-css-color', { 'for': 'css' }
"Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plug 'sheerun/vim-polyglot'

" Search
"Plug 'mileszs/ack.vim'
"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"Plug 'junegunn/fzf.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'dyng/ctrlsf.vim'
Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
Plug 'wsdjeg/FlyGrep.vim'
Plug 'Shougo/denite.nvim'

" Navigation
Plug 'vim-scripts/a.vim', { 'for': ['c', 'cpp', 'objc', 'objcpp'] }
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'Valloric/ListToggle'
Plug 'majutsushi/tagbar'
"Plug 'lyuts/vim-rtags', { 'for': ['c', 'cpp'] }
"Plug 'simplyzhao/cscope_maps.vim', { 'for': ['c', 'cpp', 'objc', 'objcpp'] }

" Snippets
if has('python3') || has('python')
    Plug 'sirver/UltiSnips'
    Plug 'honza/vim-snippets'
endif

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" Misc
"Plug 'vim-scripts/FencView.vim'
Plug 'will133/vim-dirdiff'
"Plug 'vim-airline/vim-airline'
Plug 'itchyny/lightline.vim'
Plug 'rizzatti/dash.vim'
Plug 'skywind3000/asyncrun.vim'
"Plug 'tpope/vim-surround'
Plug 'junegunn/vim-xmark', { 'do': 'make', 'for': 'markdown' }
Plug 'junegunn/vim-easy-align'
Plug 'godlygeek/tabular'
Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-expand-region'
"Plug 'terryma/vim-smooth-scroll'
Plug 'jpalardy/vim-slime'
if !has('nvim') && v:version > 704
    " <m-?> and <a-?> key map fix for vim
    Plug 'drmikehenry/vim-fixkey'
endif
"Plug 'liuchengxu/vim-which-key'

" 进入vim normal模式时，自动切换为英文输入法
"Plug 'CodeFalling/fcitx-vim-osx'

" ColorScheme
Plug 'tomasr/molokai'
Plug 'ajh17/Spacegray.vim'
Plug 'Valloric/vim-valloric-colorscheme'

call plug#end()

" Install all plugins
if exists('s:first_init')
    PlugInstall
endif

" vim common
let g:mapleader=' '
let g:maplocalleader=','
let g:python2_host_skip_check=1
let g:python2_host_prog='python2'
let g:python3_host_skip_check=1
let g:python3_host_prog='python3'

" rainbow
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle

" EasyMotion
"let g:EasyMotion_leader_key = '<leader>'
 
" UltiSnips
let g:UltiSnipsExpandTrigger='<tab>'
let g:UltiSnipsJumpForwardTrigger='<tab>'
let g:UltiSnipsJumpBackwardTrigger='<s-tab>'

" YouCompleteMe
"let g:ycm_global_ycm_extra_conf = '~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
"let g:ycm_key_invoke_completion = ''
"nnoremap <leader>y :YcmForceCompileAndDiagnostics<cr>
"nnoremap <leader>gt :YcmCompleter GoTo<cr>
"nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<cr>
"let g:ycm_key_list_select_completion = ['<c-n>', '<Down>']
"let g:ycm_key_list_previous_completion = ['<c-p>', '<Up>']
"let g:ycm_confirm_extra_conf = 0
"let g:ycm_python_binary_path = 'python'
""let g:ycm_collect_identifiers_from_tags_files = 1
"let g:ycm_server_python_interpreter = g:ycm_python_binary_path

" vim-javacomplete2
"augroup vimrc
"    autocmd FileType java,jsp setlocal omnifunc=javacomplete#Complete
"augroup END

" ale
"let g:ale_cpp_clang_options = '-std=c++14 -Wall -isystem ~/wbl/ -system ~/gnp/src/api/'
"let g:ale_cpp_gcc_options = '-std=c++14 -Wall -I~/admin/wbl/ -I~/admin/gnp/src/api/'
"let g:ale_linters = {
"            \ 'python': ['flake8']
"            \ }
"nmap <silent> <m-j> <Plug>(ale_next_wrap)
"nmap <silent> <m-k> <Plug>(ale_previous_wrap)
"nmap <silent> <m-f> <Plug>(ale_fix)
"nmap <silent> <leader>j <Plug>(ale_next_wrap)
"nmap <silent> <leader>k <Plug>(ale_previous_wrap)

" asyncrun
nnoremap <leader>ma :AsyncRun make<cr>

" LeaderF
"nnoremap <silent> <C-p> :FZF<cr>
nnoremap <silent> <C-p> :LeaderfFile<cr>
let g:Lf_ReverseOrder = 1

" vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" A
let g:alternateSearchPath = 'sfr:../source,sfr:../src,sfr:../include,sfr:../inc,sfr:../wbl,sfr:../gnp'
nnoremap <leader>a :A<cr>

" vim-smooth-scroll
"nnoremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<cr>
"nnoremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<cr>
"nnoremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<cr>
"nnoremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<cr>

" fencview
"let g:fencview_autodetect=0
"map <F2> :FencView<cr>

" nerdtree
nmap <F10> :NERDTreeToggle<cr>

" tagbar
nmap <F12> :TagbarToggle<cr>
let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

" ListToggle
" You can set the key mappings for toggling Vim's locationlist and quickfix windows in your vimrc file:
"let g:lt_location_list_toggle_map = '<leader>l'
"let g:lt_quickfix_list_toggle_map = '<leader>q'
let g:lt_height = 10

" color_coded
"let g:color_coded_enabled = 1
"if &diff
"    " Disable color_coded in diff mode
"    let g:color_coded_enabled = 0
"endif

" chromatica.nvim
"let g:chromatica#libclang_path='/usr/local/opt/llvm/lib'
"let g:chromatica#enable_at_startup=1

" vim-go
"let g:go_highlight_functions = 1
"let g:go_highlight_methods = 1
"let g:go_highlight_structs = 1
"let g:go_highlight_operators = 1
"let g:go_highlight_build_constraints = 1
"let g:go_fmt_command = 'goimports'

" vim-slime
let g:slime_python_ipython = 1
if has('nvim')
	let g:slime_target = 'neovim'
else
	let g:slime_target = 'vimterminal'
endif

" python-mode
"let g:pymode_options_colorcolumn = 0
"let g:pymode_rope = 0
"let g:pymode_rope_lookup_project = 0
"let g:pymode_lint = 0                         " disable lint, use ale's
"autocmd vimrc FileType python setlocal wrap   " undo python-mode change

" dash
nmap <silent> <leader>h <Plug>DashSearch

" vim-autoformat
noremap <F3> :Autoformat<CR>
" clang-format, use vim-autoformat
"map <C-L> :pyf /usr/local/Cellar/llvm/6.0.0/share/clang/clang-format.py<cr>
"imap <C-K> <c-o>:pyf /usr/local/Cellar/llvm/6.0.0/share/clang/clang-format.py<cr>

" ctrlsf
nmap <leader>s <Plug>CtrlSFPrompt
vmap <leader>s <Plug>CtrlSFVwordPath
let g:ctrlsf_regex_pattern = 1
let g:ctrlsf_ackprg = 'rg'

" vim-which-key
"nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
"nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>

" lightline.vim
let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
            \ },
            \ 'component_function': {
            \   'cocstatus': 'coc#status'
            \ },
            \ }

" coc.nvim
" Use `[c` and `]c` for navigate diagnostics
"nmap <silent> [c <Plug>(coc-diagnostic-prev)
"nmap <silent> ]c <Plug>(coc-diagnostic-next)
nmap <silent> <m-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <m-j> <Plug>(coc-diagnostic-next)
nmap <silent> <leader>k <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>j <Plug>(coc-diagnostic-next)
" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
" Remap for format selected region
"vmap <leader>f  <Plug>(coc-format-selected)
"nmap <leader>f  <Plug>(coc-format-selected)

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')
" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)
" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)
" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')
" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)


" vim
nnoremap ; :

" Keep search pattern at the center of the screen.
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g; g;zz
nnoremap <silent> g, g,zz

" 去掉上次搜索高亮
nnoremap <silent><leader>/ :nohls<cr>

" files
nnoremap <leader>qa :qa<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>wq :wq<cr>
nnoremap <leader>v :e ~/.vimrc<cr>
nnoremap <leader>cd :cd %:p:h<cr>
cmap w!! w !sudo tee >/dev/null %

"nnoremap <leader>h <c-w>h
"nnoremap <leader>l <c-w>l
"nnoremap <leader>k <c-w>k
"nnoremap <leader>j <c-w>j

nnoremap <leader>n :bn<cr>
nnoremap <leader>p :bp<cr>

" jump
noremap <c-j> 15gj
noremap <c-k> 15gk

" CTRL+A moves to start of line in command mode
cnoremap <C-a> <home>
" CTRL+E moves to end of line in command mode
cnoremap <C-e> <end>

" move current line down
noremap <silent>- :m+<CR>
" move current line up
noremap <silent><c-_> :m-2<CR>
" move visual selection down
vnoremap <silent>- :m '>+1<CR>gv=gv
" move visual selection up
vnoremap <silent><c-_> :m '<-2<CR>gv=gv

" replace word under cursor
nnoremap <leader>; :%s/\<<C-r><C-w>\>//<Left>

" switch between last two files
nnoremap <leader><Tab> <c-^>

" Correct spell
cab Qa qa
cab W w
cab Wq wq
cab Wa wa
cab X x

" No surround sound
set noerrorbells
set novisualbell
set t_vb=

" For indent
set wrap
set autoindent
set copyindent
set smartindent
set cindent
set cinoptions=:0g0
set smarttab
set shiftround

vnoremap < <gv
vnoremap > >gv

" Format
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Encoding setting
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1

" Search and Case
set gdefault            " this makes search/replace global by default
set ignorecase
set smartcase
set hlsearch
set incsearch
set fileignorecase
set showcmd

" Rule the define
set ruler
set cursorline      " highlight current line
"set cursorcolumn    " highlight current column
set number
"set relativenumber

" always show signcolumns
set signcolumn=yes

" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

" No back up files
set noswapfile
set nobackup
set nowritebackup

" Mouse
set mouse=a
set mousemodel=popup_setpos

" undo
set undolevels=1000     " use many levels of undo<Paste>
if exists('+undofile')
    set undodir=~/.undodir_vim
    set undofile
endif

" Fold
set foldmethod=indent
set foldlevel=100
nnoremap zc @=((foldclosed(line('.')) < 0) ? 'zc' :'zo')<CR>
nnoremap zo @=((foldclosed(line('.')) < 0) ? 'zc' :'zo')<CR>
nnoremap zr zR
augroup vimrc
    autocmd FileType java,c,cpp,go,json,js set foldmethod=syntax foldlevel=100
    autocmd FileType python set foldlevel=100
augroup END

" Other
set nocompatible
set helplang=cn
"set langmenu=zn_CN.gbk
set backspace=indent,eol,start
set cscopetag
set cscopetagorder=1
set virtualedit=block
set wildmenu
set showmatch
set matchtime=2
set title
set autoread
set clipboard=unnamedplus,unnamed
set history=1000        " remember more commands and search history
set shortmess=atI       " 启动的时候不显示那个援助索马里儿童的提示

filetype plugin on
syntax enable
syntax on
"colorscheme molokai
colorscheme spacegray

augroup vimrc
	autocmd FileType cpp set tags+=~/cpp_tags
    autocmd FileType vim nmap <buffer> <leader>r :source %<cr>
    autocmd FileType sh nmap <buffer> <leader>r :!bash %<cr>
    autocmd FileType zsh nmap <buffer> <leader>r :!zsh %<cr>
    autocmd FileType perl nmap <buffer> <leader>r :!perl %<cr>
    autocmd FileType markdown nmap <buffer> <leader>r :Xmark<cr>

    " vim自动打开跳到上次的光标位置
    autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
augroup END

" The alt (option) key on macs now behaves like the 'meta' key. This means we
" can now use <m-x> or similar as maps. This is buffer local, and it can easily
" be turned off when necessary (for instance, when we want to input special
" characters) with :set nomacmeta.
if has('gui_macvim') || exists('+macmeta')
    set macmeta
endif

if has('gui_running')
    set guifont=Monaco:h13   " 设置默认字体为monaco
    set guifontwide=Microsoft\ YaHei:h13
    "set go=aAce              " 去掉难看的工具栏和滑动条
    set transparency=15      " 透明背景
    set showtabline=2        " 开启自带的tab栏
	"set ambiwidth=double
endif

if has('nvim')
	set inccommand=split
	tnoremap <Esc> <C-\><C-n>
    autocmd vimrc TermOpen * setlocal statusline=%{b:terminal_job_id}\ %{b:term_title} 
else
    let &t_SI="\e[6 q" " Vertical bar in insert mode
    let &t_EI="\e[2 q" " Block in normal mode
endif

if has('termguicolors') && $TERM_PROGRAM ==# 'iTerm.app' 
    set termguicolors
elseif exists('$TMUX')
    if !has('nvim')
        set term=screen-256color
        if has('termguicolors')
            set notermguicolors
        endif
    endif
elseif exists('&guicolors')
    set guicolors
endif

" tmux
function! s:tmux_send(content, dest) range
    let l:dest = empty(a:dest) ? input('To which pane? ') : a:dest
    let l:tempfile = tempname()
    call writefile(split(a:content, "\n", 1), l:tempfile, 'b')
    call system(printf('tmux load-buffer -b vim-tmux %s \; paste-buffer -d -b vim-tmux -t %s',
                \ shellescape(l:tempfile), shellescape(l:dest)))
    call delete(l:tempfile)
endfunction

function! s:tmux_map(key, dest)
    execute printf('nnoremap <silent> %s "tyy:call <SID>tmux_send(@t, "%s")<cr>', a:key, a:dest)
    execute printf('xnoremap <silent> %s "ty:call <SID>tmux_send(@t, "%s")<cr>gv', a:key, a:dest)
endfunction

call s:tmux_map('<leader>tt', '')
call s:tmux_map('<leader>th', '.left')
call s:tmux_map('<leader>tj', '.bottom')
call s:tmux_map('<leader>tk', '.top')
call s:tmux_map('<leader>tl', '.right')
call s:tmux_map('<leader>ty', '.top-left')
call s:tmux_map('<leader>to', '.top-right')
call s:tmux_map('<leader>tn', '.bottom-left')
call s:tmux_map('<leader>t.', '.bottom-right')

" temporary fix
" https://github.com/vim/vim/issues/3117
if has('python3') && !has('nvim') && !has('patch-8.1.201')
    silent! python3 1
endif

"au BufRead,BufNewFile *.ts set filetype=typescript 


