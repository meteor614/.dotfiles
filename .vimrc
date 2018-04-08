scriptencoding utf-8

call plug#begin('~/.vim/plugged')

Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --go-completer --js-completer' }
if has('gui_macvim')
    Plug 'jeaye/color_coded', { 'do': 'rm -f CMakeCache.txt && cmake . -DDOWNLOAD_CLANG=FALSE && make clean && make && make install', 'for': ['c', 'cpp', 'objc', 'objcpp'] }
endif
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
Plug 'python-mode/python-mode', { 'for': 'python' }
Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java' }
Plug 'mileszs/ack.vim'
"Plug 'vim-scripts/taglist.vim'
Plug 'vim-scripts/a.vim', { 'for': ['c', 'cpp'] }
Plug 'vim-scripts/FencView.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'will133/vim-dirdiff'
Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoInstallBinaries' }
Plug 'vim-airline/vim-airline'
Plug 'rizzatti/dash.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/echofunc'
Plug 'sirver/UltiSnips'
Plug 'honza/vim-snippets'
Plug 'Valloric/ListToggle'
"Plug 'tpope/vim-surround'
Plug 'majutsushi/tagbar'
Plug 'simplyzhao/cscope_maps.vim', { 'for': ['c', 'cpp', 'objc', 'objcpp'] }
"Plug 'tenfyzhong/CompleteParameter.vim'
"Plug 'gilligan/vim-lldb'
Plug 'junegunn/vim-xmark', { 'do': 'make', 'for': 'markdown' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'jremmen/vim-ripgrep'
Plug 'w0rp/ale'
Plug 'godlygeek/tabular'
Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-expand-region'
"Plug 'terryma/vim-smooth-scroll'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'jpalardy/vim-slime'
Plug 'Valloric/MatchTagAlways'
"Plug 'neomake/neomake'
Plug 'luochen1990/rainbow'

" 进入vim normal模式时，自动切换为英文输入法
"Plug 'CodeFalling/fcitx-vim-osx'

" 配色方案
Plug 'tomasr/molokai'
Plug 'ajh17/Spacegray.vim'
Plug 'Valloric/vim-valloric-colorscheme'

"Plug 'lyuts/vim-rtags', { 'for': ['c', 'cpp'] }
"Plug 'nsf/gocode', {'rtp': 'vim/'}
"Plug 'jalcine/cmake.vim'

"if has('nvim')
	"Plug 'frankier/neovim-colors-solarized-truecolor-only'
	"Plug 'c0r73x/neotags.nvim'
"endif

call plug#end()

" vim common
let g:mapleader=' '
let g:maplocalleader='-'
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
let g:ycm_global_ycm_extra_conf = '~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
let g:ycm_key_invoke_completion = ''
nnoremap <leader>y :YcmForceCompileAndDiagnostics<cr>
nnoremap <leader>gt :YcmCompleter GoTo<cr>
nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<cr>
let g:ycm_key_list_select_completion = ['<c-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<c-p>', '<Up>']
let g:ycm_confirm_extra_conf = 0
"let g:ycm_python_binary_path = 'python'
let g:ycm_python_binary_path = g:python3_host_prog
"let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_server_python_interpreter = g:ycm_python_binary_path

" vim-javacomplete2
augroup vimrc
    autocmd FileType java,jsp setlocal omnifunc=javacomplete#Complete
augroup END

" ale
"let g:ale_cpp_clang_options = '-std=c++14 -Wall -isystem /Users/admin/wbl/ -system /Users/admin/gnp/src/api/'
"let g:ale_cpp_gcc_options = '-std=c++14 -Wall -I/Users/admin/wbl/ -I/Users/admin/gnp/src/api/'
let g:ale_cpp_clang_options = '-std=c++14 -Wall -isystem ~/wbl/ -system ~/gnp/src/api/'
let g:ale_cpp_gcc_options = '-std=c++14 -Wall -I~/admin/wbl/ -I~/admin/gnp/src/api/'
let g:ale_linters = {
            \ 'python': ['flake8']
            \ }
nmap <silent> <leader>j <Plug>(ale_next_wrap)
nmap <silent> <leader>k <Plug>(ale_previous_wrap)
nmap <silent> <leader>f <Plug>(ale_fix)

" clang-format
map <C-L> :pyf /usr/local/Cellar/llvm/6.0.0/share/clang/clang-format.py<cr>
"imap <C-K> <c-o>:pyf /usr/local/Cellar/llvm/6.0.0/share/clang/clang-format.py<cr>

" asyncrun
nnoremap <leader>ma :AsyncRun make<cr>

" FZF
nnoremap <silent> <C-p> :FZF<cr>

" vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" A
let g:alternateSearchPath = 'sfr:../source,sfr:../src,sfr:../include,sfr:../inc,sfr:../wbl,sfr:../gnp'
"iunmap <leader>ih
"iunmap <leader>is
"iunmap <leader>ihn

" vim-smooth-scroll
"nnoremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<cr>
"nnoremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<cr>
"nnoremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<cr>
"nnoremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<cr>

" fencview
"let g:fencview_autodetect=0
"map <F2> :FencView<cr>

" nerdtree
nmap <F11> :NERDTreeToggle<cr>

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

" color_coded
let g:color_coded_enabled = 1

" vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = 'goimports'
"let g:go_fmt_autosave = 1

" vim-slime
let g:slime_python_ipython = 1
if has('nvim')
	let g:slime_target = 'neovim'
else
	let g:slime_target = 'vimterminal'
endif

" python-mode
let g:pymode_options_colorcolumn = 0
let g:pymode_rope = 0
let g:pymode_rope_lookup_project = 0
let g:pymode_lint = 0                         " disable lint, use ale's
autocmd vimrc FileType python setlocal wrap   " undo python-mode change

" dash
nmap <silent> <leader>h <Plug>DashSearch

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

nnoremap <leader>qa :qa<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>wq :wq<cr>
nnoremap <leader>v :e ~/.vimrc<cr>
nnoremap <leader>cd :cd %:p:h<cr>
cmap w!! w !sudo tee >/dev/null %

" 去掉上次搜索高亮
nnoremap <silent><leader>/ :nohls<cr>

"nnoremap <leader>h <c-w>h
"nnoremap <leader>l <c-w>l
"nnoremap <leader>k <c-w>k
"nnoremap <leader>j <c-w>j

nnoremap <leader>a :A<cr>
nnoremap <leader>n :bn<cr>
nnoremap <leader>p :bp<cr>

noremap <c-j> 15gj
noremap <c-k> 15gk
noremap <m-j> 15gj
noremap <m-k> 15gk

vnoremap < <gv
vnoremap > >gv

" Set as toggle foldcomment
nnoremap zc @=((foldclosed(line('.')) < 0) ? 'zc' :'zo')<CR>
nnoremap zo @=((foldclosed(line('.')) < 0) ? 'zc' :'zo')<CR>
nnoremap zr zR

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
set cursorline
set number
"set relativenumber

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
    set undofile
endif

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
set foldmethod=indent
set foldlevel=100

filetype plugin on
syntax enable
"colorscheme molokai
colorscheme spacegray

augroup vimrc
	autocmd FileType cpp set tags+=~/cpp_tags
    autocmd FileType vim nmap <buffer> <leader>r :source %<cr>

	autocmd FileType java,c,cpp,go,json,js set foldmethod=syntax foldlevel=100
	autocmd FileType python set foldlevel=100
	"autocmd FileType python set foldmethod=indent
	"autocmd FileType java,c,cpp,go,python set foldlevel=100
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
    "set columns=140          " 设置宽
    "set lines=40             " 设置长
    "colorscheme valloric
endif

if has('nvim')
	set inccommand=split
	tnoremap <Esc> <C-\><C-n>
    autocmd vimrc TermOpen * setlocal statusline=%{b:terminal_job_id}\ %{b:term_title} 
    "autocmd VimEnter term://* nested setlocal statusline=%{b:terminal_job_id}\ %{b:term_title} 
    "autocmd BufReadCmd term://* setlocal statusline=%{b:terminal_job_id}\ %{b:term_title} 
	"set background=dark
endif

if has('termguicolors') && $TERM_PROGRAM ==# 'iTerm.app' 
    if has('nvim')
        "set t_8f=^[[38;2;%lu;%lu;%lum
        "set t_8b=^[[48;2;%lu;%lu;%lum
    endif
    set termguicolors
elseif exists('$TMUX')
    if !has('nvim')
        set term=screen-256color
        set notermguicolors
    endif
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

