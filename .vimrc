scriptencoding utf-8

call plug#begin('~/.vim/plugged')

Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --go-completer --js-completer' }
Plug 'mileszs/ack.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'vim-scripts/a.vim'
Plug 'vim-scripts/FencView.vim'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'will133/vim-dirdiff'
Plug 'fatih/vim-go'
Plug 'vim-airline/vim-airline'
Plug 'rizzatti/dash.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/echofunc'
"Plug 'EasyMotion'
Plug 'sirver/UltiSnips'
Plug 'honza/vim-snippets'
"Plug 'scrooloose/syntastic'
Plug 'Valloric/ListToggle'
Plug 'orenhe/pylint.vim'
"Plug 'kien/ctrlp.vim'
"Plug 'tpope/vim-surround'
Plug 'majutsushi/tagbar'
Plug 'simplyzhao/cscope_maps.vim'
Plug 'tomasr/molokai'
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

" use GitGutterEnable
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

"Plug 'lyuts/vim-rtags'

"Plug 'nsf/gocode', {'rtp': 'vim/'}
"Plug 'davidhalter/jedi-vim'
"Plug 'mbbill/echofunc'
"Plug 'jalcine/cmake.vim'
"Plug 'guileen/vim-node-dict'
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

" non github reposo
" 非github的插件，可以直接使用其git地址
" Plug 'git://git.wincent.com/command-t.git'
" ...

" YouCompleteMe 配置
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py'
nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR>
let g:ycm_key_list_select_completion = ['<c-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<c-p>', '<Up>']
let g:ycm_confirm_extra_conf = 0
let g:ycm_python_binary_path = '/usr/local/bin/python3'
"let g:ycm_collect_identifiers_from_tags_files = 1

" ale
let g:ale_cpp_clang_options = '-std=c++14 -Wall -isystem /Users/admin/wbl/ -system /Users/admin/gnp/src/api/'
let g:ale_cpp_gcc_options = '-std=c++14 -Wall -I/Users/admin/wbl/ -I/Users/admin/gnp/src/api/'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
nmap <F9> <Plug>(ale_fix)

" clang-format
map <C-K> :pyf /usr/local/Cellar/llvm/5.0.0/share/clang/clang-format.py<cr>
imap <C-K> <c-o>:pyf /usr/local/Cellar/llvm/5.0.0/share/clang/clang-format.py<cr>
"function! Formatonsave()
"  let l:formatdiff = 1
"  pyf ~/llvm/tools/clang/tools/clang-format/clang-format.py
"endfunction
"autocmd BufWritePre *.h,*.cc,*.cpp call Formatonsave()

" FZF
nnoremap <silent> <C-p> :FZF<CR>

" vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" CtrlP
"set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.o,*.dSYM
"let g:ctrlp_custom_ignore = {
"		   \ 'dir':  '\v[\/]\.(git|hg|svn)$',
"		   \ 'file': '\v\.(exe|so|dll|o)$',
"		   \ 'link': 'some_bad_symbolic_links',
"		   \ }
"let g:ctrlp_extensions = ['tag', 'buffertag', 'quickfix', 'dir', 'rtscript',
"			\ 'undo', 'line', 'changes', 'mixed', 'bookmarkdir']

" A
let g:alternateSearchPath = 'sfr:../source,sfr:../src,sfr:../include,sfr:../inc,sfr:../wbl,sfr:../gnp'

" fencview
"let g:fencview_autodetect=0
"map <F2> :FencView<cr>

map <leader>cd :cd %:p:h<cr>

set nocompatible
set helplang=cn
"set langmenu=zn_CN.gbk
syntax enable
set backspace=indent,eol,start
set cscopetag
set cscopetagorder=1
set helplang=cn
set number
set tabstop=4
set shiftwidth=4
set cinoptions=:0g0
set virtualedit=block
set cursorline
set wildmenu
set hlsearch
set autoindent
set smartindent
set cindent
set wrap
set incsearch
set noswapfile
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
"colorscheme elflord
colorscheme molokai
filetype plugin on

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

"autocmd FileType javascript set dictionary+=$HOME/.vim/dict/node.dict

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

