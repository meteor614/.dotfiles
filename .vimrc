scriptencoding utf-8

" Install vim-plug if first init
if !filereadable(expand('~/.vim/autoload/plug.vim'))
    let s:first_init = 1
endif
if exists('s:first_init')
    echom 'Plugin manager: vim-plug has not been installed. Try to install...'
    exec 'silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    echom 'Installing vim-plug complete.'
endif

" more plugins: https://zhuanlan.zhihu.com/p/58816186、https://www.zhihu.com/question/23590572
call plug#begin('~/.vim/plugged')

" Code completion
if v:version > 704
    "Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif

" Syntax checker & Highlight
Plug 'luochen1990/rainbow'
if has('python3') || has('python')
    Plug 'Valloric/MatchTagAlways'
endif
Plug 'sbdchd/neoformat'
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
if v:version > 704
    Plug 'sheerun/vim-polyglot'
endif

" Search & Replace
Plug 'mileszs/ack.vim'
"Plug 'jremmen/vim-ripgrep'
if v:version > 704
    Plug 'dyng/ctrlsf.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
endif
"if has('python3') || has('python')
"    Plug 'Yggdroot/LeaderF', { 'do': ':/install.sh' }
"else
"    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"    Plug 'junegunn/fzf.vim'
"endif
"Plug 'wsdjeg/FlyGrep.vim'
Plug 'Shougo/denite.nvim'
Plug 'brooth/far.vim'

" Navigation
Plug 'vim-scripts/a.vim', { 'for': ['c', 'cpp', 'objc', 'objcpp'] }
Plug 'Valloric/ListToggle'
Plug 'majutsushi/tagbar'

" Snippets
"if has('python3') || has('python')
if v:version > 704
    Plug 'honza/vim-snippets'
endif

" Git
"Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" Misc
"Plug 'vim-scripts/FencView.vim'
Plug 'will133/vim-dirdiff'
"Plug 'itchyny/lightline.vim'
if has('nvim') 
    Plug 'hardcoreplayers/spaceline.vim'
elseif v:version > 704
    Plug 'itchyny/lightline.vim'
endif
if has('mac')
    Plug 'rizzatti/dash.vim'
endif
Plug 'skywind3000/asyncrun.vim'
"Plug 'tpope/vim-surround'
Plug 'junegunn/vim-xmark', { 'do': 'make', 'for': 'markdown' }
Plug 'junegunn/vim-easy-align'
Plug 'godlygeek/tabular'
Plug 'terryma/vim-expand-region'
"Plug 'metakirby5/codi.vim'
"Plug 'sillybun/vim-repl'
"Plug 'jpalardy/vim-slime'
if !has('nvim') && v:version > 704
    " <m-?> and <a-?> key map fix for vim
    Plug 'drmikehenry/vim-fixkey'
endif
Plug 'easymotion/vim-easymotion'
"Plug 'terryma/vim-multiple-cursors'
if v:version > 704
    Plug 'mg979/vim-visual-multi'
    Plug 'liuchengxu/vim-which-key'
    Plug 'ryanoasis/vim-devicons'
endif

" 进入vim normal模式时，自动切换为英文输入法
"Plug 'CodeFalling/fcitx-vim-osx'

" ColorScheme
"Plug 'tomasr/molokai'
"Plug 'ajh17/Spacegray.vim'
Plug 'ignu/Spacegray.vim'
"Plug 'Valloric/vim-valloric-colorscheme'
"Plug 'joshdick/onedark.vim'

call plug#end()

" Install all plugins
if exists('s:first_init')
    PlugInstall
    if v:version > 704
        " install coc.nvim extensions
        CocInstall coc-css coc-eslint coc-gocode coc-html coc-java coc-json coc-python coc-tslint coc-tsserver coc-wxml coc-yaml coc-svg coc-vimlsp coc-sh coc-sql coc-markdownlint coc-cmake coc-perl coc-xml coc-lua
        CocInstall coc-highlight coc-prettier coc-explorer coc-marketplace coc-lists coc-git
        CocInstall coc-tabnine coc-snippets coc-ultisnips coc-neosnippet coc-pairs coc-tag coc-yank coc-fzf-preview
    endif
endif

" vim common
let g:mapleader = ' '
let g:maplocalleader = ','
let g:python3_host_skip_check = 1
if v:version > 704
    let g:python3_host_prog = exepath('python3')
    let g:python_host_prog = g:python3_host_prog
    let g:python_host_skip_check = 1
    if g:python_host_prog == ""
        let g:python_host_prog = exepath('python2')
        if g:python_host_prog == ""
            let g:python_host_prog = exepath('python2.7')
        endif
    endif
    let g:ruby_host_prog = exepath('neovim-ruby-host')
    let g:node_host_prog = exepath('neovim-node-host')
endif

"===================
" rainbow
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
 
"===================
" asyncrun
nnoremap <leader>ma :AsyncRun make<cr>

"===================
" vim-ripgrep
let g:rg_highlight = 1

"===================
" ack.vim
if executable('rg')
    let g:ackprg = 'rg --vimgrep'
elseif executable('ag')
	let g:ackprg = 'ag --vimgrep'
endif

"if has('python3') || has('python')
    " LeaderF
"    nnoremap <silent> <C-p> :LeaderfFile<cr>
"    let g:Lf_ReverseOrder = 1
"else
    " FZF
"    nnoremap <silent> <C-p> :FZF<cr>
"endif

"===================
" ctrlsf
if v:version > 704
    nmap <leader>s <Plug>CtrlSFPrompt
    vmap <leader>s <Plug>CtrlSFVwordPath
    let g:ctrlsf_regex_pattern = 1
    if executable('rg')
        let g:ctrlsf_ackprg = 'rg'
    endif
endif

"===================
" vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

"===================
" A
let g:alternateSearchPath = 'sfr:../source,sfr:../src,sfr:../include,sfr:../inc,sfr:../wbl,sfr:../gnp'
nnoremap <leader>a :A<cr>

"===================
" tagbar
nmap <leader>i :TagbarToggle<cr>
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

"===================
" ListToggle
" You can set the key mappings for toggling Vim's locationlist and quickfix windows in your vimrc file:
"let g:lt_location_list_toggle_map = '<leader>l'
let g:lt_quickfix_list_toggle_map = '<leader>qq'
let g:lt_height = 10

"===================
" dash
nmap <silent> <leader>h <Plug>DashSearch

"===================
" vim-which-key
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
set timeoutlen=2000

"===================
" lightline.vim
let g:lightline = {
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
            \ },
            \ 'component_function': {
            \   'cocstatus': 'coc#status'
            \ },
            \ }

"===================
" coc.nvim
if v:version > 704
    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)
    "nmap <silent> <m-k> <Plug>(coc-diagnostic-prev)
    "nmap <silent> <m-j> <Plug>(coc-diagnostic-next)
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
    "nnoremap <silent><nowait> <leader>a  :<C-u>CocList diagnostics<cr>

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

    " Use CTRL-S for selections ranges.
    " Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
    "nmap <silent> <C-s> <Plug>(coc-range-select)
    "xmap <silent> <C-s> <Plug>(coc-range-select)

    " Use `:Format` for format current buffer
    command! -nargs=0 Format :call CocAction('format')
    " Use `:Fold` for fold current buffer
    command! -nargs=? Fold :call CocAction('fold', <f-args>)

    " Add `:OR` command for organize imports of the current buffer.
    command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

    "===================
    " coc-snippets
    inoremap <silent><expr> <TAB>
                \ pumvisible() ? coc#_select_confirm() :
                \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ coc#refresh()

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    let g:coc_snippet_next = '<tab>'

    "===================
    " coc-lists grep
    command! -nargs=+ -complete=custom,s:GrepArgs Rg exe 'CocList grep '.<q-args>

    function! s:GrepArgs(...)
        let list = ['-S', '-smartcase', '-i', '-ignorecase', '-w', '-word',
                \ '-e', '-regex', '-u', '-skip-vcs-ignores', '-t', '-extension']
        return join(list, "\n")
    endfunction

    " Keymapping for grep word under cursor with interactive mode
    nnoremap <silent> <Leader>g :exe 'CocList -I --input='.expand('<cword>').' grep'<CR>
    nnoremap <silent> <leader>y :<C-u>CocList -A --normal yank<cr>

    " Show all diagnostics.
    nnoremap <silent><nowait> <leader>d  :<C-u>CocList diagnostics<cr>
    " Find symbol of current document.
    nnoremap <silent><nowait> <leader>o  :<C-u>CocList outline<cr>
    " Resume latest coc list.
    nnoremap <silent><nowait> <leader>l  :<C-u>CocListResume<CR>

    "===================
    " coc-command
    nmap <F10> :CocCommand explorer<CR>
    nmap <leader>e :CocCommand explorer<CR>
    " :CocCommand java.clean.workspace

    "===================
    " coc-fzf-preview
    let g:fzf_preview_use_dev_icons = 1

    nnoremap <silent> <C-p> :<C-u>CocCommand fzf-preview.ProjectFiles<CR>
    nnoremap <silent> <Leader>ff     :<C-u>CocCommand fzf-preview.ProjectFiles<CR>
    nnoremap <silent> <Leader>fp     :<C-u>CocCommand fzf-preview.FromResources project_mru git<CR>
    nnoremap <silent> <Leader>fgs    :<C-u>CocCommand fzf-preview.GitStatus<CR>
    nnoremap <silent> <Leader>fga    :<C-u>CocCommand fzf-preview.GitActions<CR>
    nnoremap <silent> <Leader>fb     :<C-u>CocCommand fzf-preview.Buffers<CR>
    nnoremap <silent> <Leader>fB     :<C-u>CocCommand fzf-preview.AllBuffers<CR>
    nnoremap <silent> <Leader>fo     :<C-u>CocCommand fzf-preview.FromResources buffer project_mru<CR>
    nnoremap <silent> <Leader>f<C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
    nnoremap <silent> <Leader>fg;    :<C-u>CocCommand fzf-preview.Changes<CR>
    nnoremap <silent> <Leader>fc     :<C-u>CocCommand fzf-preview.Changes<CR>
    nnoremap <silent> <Leader>f/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
    nnoremap <silent> <Leader>f*     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
    nnoremap          <Leader>fgr    :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
    xnoremap          <Leader>fgr    "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
    nnoremap          <Leader>fr     :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
    xnoremap          <Leader>fr     "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
    nnoremap <silent> <Leader>ft     :<C-u>CocCommand fzf-preview.BufferTags<CR>
    nnoremap <silent> <Leader>fq     :<C-u>CocCommand fzf-preview.QuickFix<CR>
    nnoremap <silent> <Leader>fl     :<C-u>CocCommand fzf-preview.LocationList<CR>
    nnoremap <silent> <Leader>fd     :<C-u>CocCommand fzf-preview.DirectoryFiles<CR>
    nnoremap <silent> <Leader>fm     :<C-u>CocCommand fzf-preview.MruFiles<CR>
    "CocCommand fzf-preview.Ctags
endif


"===================
" vim
nnoremap ; :
" 中文字符
"nnoremap ； :
nnoremap ： :
nnoremap 、 /
nnoremap ？ ?
nnoremap 。 .
nnoremap 】】 ]]
nnoremap 【【 [[

" Keep search pattern at the center of the screen.
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g; g;zz
nnoremap <silent> g, g,zz

" 去掉上次搜索高亮
nnoremap <silent><leader>h :nohls<cr>

" files
inoremap <C-s> <C-O>:update<cr>
nnoremap <C-s> :update<cr>
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

" Movement in insert mode
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>l
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-^> <C-o><C-^>

" Make Y behave like other capitals
"nnoremap Y y$

" jump
noremap <c-j> 15gj
noremap <c-k> 15gk

" Quickfix
nnoremap ]q :cnext<cr>zz
nnoremap [q :cprev<cr>zz
nnoremap ]l :lnext<cr>zz
nnoremap [l :lprev<cr>zz

" Buffers
nnoremap ]b :bnext<cr>
nnoremap [b :bprev<cr>

" Tabs
nnoremap ]t :tabn<cr>
nnoremap [t :tabp<cr>

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

vnoremap p "0p
vnoremap P "0P

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
if v:version > 704
    set fileignorecase
endif
set showcmd

" Rule the define
set ruler
set cursorline      " highlight current line
"set cursorcolumn    " highlight current column
set number
"set relativenumber

" always show signcolumns
if v:version > 704
    set signcolumn=yes
endif

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
"if exists('+undofile')
if has('nvim')
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
    autocmd FileType java,c,cpp,objc,objcpp,go,json,js,xml set foldmethod=syntax foldlevel=100
    "autocmd FileType python set foldlevel=100
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
set maxmempattern=2000000

filetype plugin on
syntax enable
syntax on
"colorscheme molokai
colorscheme spacegray
"colorscheme onedark

augroup vimrc
	autocmd FileType cpp set tags+=~/cpp_tags
    autocmd FileType vim nmap <buffer> <leader>r :source %<cr>
    autocmd FileType sh nmap <buffer> <leader>r :!bash %<cr>
    autocmd FileType zsh nmap <buffer> <leader>r :!zsh %<cr>
    autocmd FileType perl nmap <buffer> <leader>r :!perl %<cr>
    autocmd FileType java nmap <buffer> <leader>r :!echo %:r\|awk -F'src/main/java/' '{print "echo launch java "$2"...\n java -cp "$1"target/classes "$2}'\|bash<cr>
    "autocmd FileType java nmap <buffer> <leader>r :AsyncRun echo %:r\|awk -F'src/main/java/' '{print "echo launch java "$2"...\n java -cp "$1"target/classes "$2}'\|bash<cr><leader>qq
    autocmd FileType python nmap <buffer> <leader>r :!python3 %<cr>
    autocmd FileType ruby nmap <buffer> <leader>r :!ruby %<cr>
    autocmd FileType javascript nmap <buffer> <leader>r :!node %<cr>
    autocmd FileType markdown nmap <buffer> <leader>r :Xmark<cr>

    " vim自动打开跳到上次的光标位置
    " autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
    autocmd BufReadPost * if line(".") <= 1 && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

" The alt (option) key on macs now behaves like the 'meta' key. This means we
" can now use <m-x> or similar as maps. This is buffer local, and it can easily
" be turned off when necessary (for instance, when we want to input special
" characters) with :set nomacmeta.
if has('gui_macvim') || exists('+macmeta')
    set macmeta
endif

if has('gui_running')
    " 须安装相应的字体，否则可能会提示错误
    set guifont=Hack\ Nerd\ Font:h13   " 设置默认字体为Nerd Font
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
        set term=xterm-256color
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

au BufRead,BufNewFile *.bcm set filetype=json
