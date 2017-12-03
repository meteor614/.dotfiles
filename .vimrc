scriptencoding utf-8

call plug#begin('~/.vim/plugged')

Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --go-completer --js-completer' }
Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java'}
Plug 'mileszs/ack.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'vim-scripts/a.vim'
Plug 'vim-scripts/FencView.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'will133/vim-dirdiff'
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'vim-airline/vim-airline'
Plug 'rizzatti/dash.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/echofunc'
Plug 'sirver/UltiSnips'
Plug 'honza/vim-snippets'
"Plug 'scrooloose/syntastic'
Plug 'Valloric/ListToggle'
Plug 'orenhe/pylint.vim', { 'for': 'python' }
"Plug 'kien/ctrlp.vim'
"Plug 'tpope/vim-surround'
Plug 'majutsushi/tagbar'
Plug 'simplyzhao/cscope_maps.vim'
Plug 'tomasr/molokai'
Plug 'ajh17/Spacegray.vim'
"Plug 'tenfyzhong/CompleteParameter.vim'
"Plug 'gilligan/vim-lldb'
Plug 'junegunn/vim-xmark', { 'do': 'make' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'rking/ag.vim'
Plug 'w0rp/ale'
Plug 'godlygeek/tabular'
Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-smooth-scroll'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'jpalardy/vim-slime'
"Plug 'neomake/neomake'

" 进入vim normal模式时，自动切换为英文输入法
Plug 'CodeFalling/fcitx-vim-osx'

"Plug 'lyuts/vim-rtags'
"Plug 'nsf/gocode', {'rtp': 'vim/'}
"Plug 'davidhalter/jedi-vim'
"Plug 'mbbill/echofunc'
"Plug 'jalcine/cmake.vim'
"Plug 'guileen/vim-node-dict'

"if has('nvim')
	"Plug 'frankier/neovim-colors-solarized-truecolor-only'
	"Plug 'c0r73x/neotags.nvim'
"endif

call plug#end()

" EasyMotion
"let g:EasyMotion_leader_key = '<Leader>'

" UltiSnips
let g:UltiSnipsExpandTrigger='<tab>'
let g:UltiSnipsJumpForwardTrigger='<tab>'
let g:UltiSnipsJumpBackwardTrigger='<s-tab>'
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-b>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py'
nnoremap <leader>y :YcmForceCompileAndDiagnostics<cr>
nnoremap <leader>g :YcmCompleter GoTo<CR>
nnoremap <leader>pd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>pc :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR>
let g:ycm_key_list_select_completion = ['<c-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<c-p>', '<Up>']
let g:ycm_confirm_extra_conf = 0
let g:ycm_python_binary_path = '/usr/local/bin/python3'
"let g:ycm_collect_identifiers_from_tags_files = 1

" vim-javacomplete2
augroup vimrc
    autocmd FileType java setlocal omnifunc=javacomplete#Complete
augroup END

" ale
let g:ale_cpp_clang_options = '-std=c++14 -Wall -isystem /Users/admin/wbl/ -system /Users/admin/gnp/src/api/'
let g:ale_cpp_gcc_options = '-std=c++14 -Wall -I/Users/admin/wbl/ -I/Users/admin/gnp/src/api/'
nmap <silent> <F9> <Plug>(ale_previous_wrap)
nmap <silent> <F10> <Plug>(ale_next_wrap)
nmap <silent> <F11> <Plug>(ale_fix)
"nmap <silent> <Leader>j <Plug>(ale_next_wrap)
"nmap <silent> <Leader>k <Plug>(ale_previous_wrap)
"nmap <silent> <Leader>f <Plug>(ale_fix)

" clang-format
map <C-K> :pyf /usr/local/Cellar/llvm/5.0.0/share/clang/clang-format.py<cr>
imap <C-K> <c-o>:pyf /usr/local/Cellar/llvm/5.0.0/share/clang/clang-format.py<cr>

" FZF
nnoremap <silent> <C-p> :FZF<CR>

" vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" A
let g:alternateSearchPath = 'sfr:../source,sfr:../src,sfr:../include,sfr:../inc,sfr:../wbl,sfr:../gnp'

" vim-smooth-scroll
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

" fencview
"let g:fencview_autodetect=0
"map <F2> :FencView<cr>

" tagbar
nmap <F8> :TagbarToggle<CR>
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

" vim
let mapleader=' '
let maplocalleader='-'
map <leader>cd :cd %:p:h<cr>

" Format Jump
nnoremap <silent> g; g;zz
nnoremap <silent> g, g,zz
noremap <Leader>qa :qa<cr>

"noremap <leader>h <c-w>h
"noremap <leader>l <c-w>l
"noremap <leader>k <c-w>k
"noremap <leader>j <c-w>j

noremap <leader>a :A<CR>
noremap <leader>n :bn<CR>
noremap <leader>p :bp<CR>

noremap <c-j> 15gj
noremap <c-k> 15gk

vnoremap < <gv
vnoremap > >gv

set nocompatible
set noerrorbells
set helplang=cn
"set langmenu=zn_CN.gbk
set backspace=indent,eol,start
set cscopetag
set cscopetagorder=1
set number
set ignorecase
set smartcase
"set relativenumber
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set cinoptions=:0g0
set virtualedit=block
set cursorline
set wildmenu
set hlsearch
set autoindent
set copyindent
set smartindent
set cindent
set smarttab
set wrap
set incsearch
set noswapfile
set autoread
set mouse=a
set mousemodel=popup_setpos
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1

filetype plugin on
syntax enable
"colorscheme molokai
colorscheme spacegray

let g:python2_host_prog='/usr/local/bin/python2'
let g:python3_host_prog='/usr/local/bin/python3'

augroup vimrc
	autocmd FileType c set tags+=~/cpp_tags
	autocmd FileType cpp set tags+=~/cpp_tags

	autocmd FileType java set foldmethod=syntax
	autocmd FileType java set foldlevel=100

	autocmd FileType c set foldmethod=syntax
	autocmd FileType c set foldlevel=100

	autocmd FileType cpp set foldmethod=syntax
	autocmd FileType cpp set foldlevel=100

	autocmd FileType go set foldmethod=syntax
	autocmd FileType go set foldlevel=100
augroup END

set guifont=Monaco:h13   " 设置默认字体为monaco
"set guifontwide=方正准圆简体:h13
"set guifontwide=幼圆:h13
if has('gui_running')
    "set go=aAce              " 去掉难看的工具栏和滑动条
    set transparency=15      " 透明背景
    set showtabline=2        " 开启自带的tab栏
	"set ambiwidth=double
    "set columns=140          " 设置宽
    "set lines=40             " 设置长
endif

if has('nvim')
	set inccommand=split
	tnoremap <Esc> <C-\><C-n>
    autocmd vimrc TermOpen * setlocal statusline=%{b:terminal_job_id}\ %{b:term_title} 
    "autocmd VimEnter term://* nested setlocal statusline=%{b:terminal_job_id}\ %{b:term_title} 
    "autocmd BufReadCmd term://* setlocal statusline=%{b:terminal_job_id}\ %{b:term_title} 
	"set termguicolors
	"set background=dark
endif
