" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

" Load plugins here (pathogen or vundle)
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
" Plugin 'tpope/vim-sleuth'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'wincent/ferret'
Plugin 'jiangmiao/auto-pairs'
Plugin 'scrooloose/nerdtree'
Plugin 'Valloric/YouCompleteMe'
Plugin 'itchyny/lightline.vim'
Plugin 'flazz/vim-colorschemes'
Plugin 'bfrg/vim-c-cpp-modern'
Plugin 'ARM9/arm-syntax-vim'
Plugin 'VundleVim/Vundle.vim'
call vundle#end()

" For plugins to load correctly
filetype plugin indent on

" Pick a leader key
let mapleader = " "

" Security
set modelines=0

" Show line numbers
set number

" Show file stats
set ruler

" Blink cursor on error instead of beeping (grr)
set visualbell

" Encoding
set encoding=utf-8

" Whitespace
set wrap
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set textwidth=100

" Cursor motion
set scrolloff=3
set backspace=indent,eol,start
set matchpairs+=<:> " use % to jump between pairs
runtime! macros/matchit.vim

" Move up/down editor lines
nnoremap j gj
nnoremap k gk

" Allow hidden buffers
set hidden

" Rendering
set ttyfast

" Status bar
set laststatus=2

" Last line
set showmode
set showcmd

" Searching
nnoremap / /\v
vnoremap / /\v
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch
map <leader><space> :let @/=''<cr> " clear search

" Remap help key.
inoremap <F1> <ESC>:set invfullscreen<CR>a
nnoremap <F1> :set invfullscreen<CR>
vnoremap <F1> :set invfullscreen<CR>

" Textmate holdouts

" Formatting
map <leader>q gqip

" Visualize tabs and newlines
set listchars=tab:▸\ ,eol:¬
" Uncomment this to enable by default:
" set list " To enable by default
" Or use your leader key + l to toggle on/off
" map <leader>l :set list!<CR> " Toggle tabs and EOL
set number
set relativenumber

" Color scheme (terminal)
set t_Co=256
set background=dark
colorscheme molokai
highlight Normal ctermbg=None

" Turn on syntax highlighting
syntax on

" Other options
set mouse=a
set clipboard=unnamedplus
set statusline+=%#warningmsg#
set statusline+=%*
let g:ycm_show_diagnostics_ui = 0
let g:ycm_global_ycm_extra_conf = '/home/davidzhang/.vim/.ycm_extra_conf.py'

autocmd FileType gitcommit setlocal textwidth=80

" Use inline window for FZF
let g:fzf_layout = { 'down': '40%' }
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always ' .
  \   '--glob="*.{c,cc,cpp,h,hpp,cu,S,rs,py,go,java,sh}" ' .
  \   shellescape(<q-args>),
  \   1,
  \   {'options': '--delimiter : --nth 4..'},
  \   <bang>0
  \ )
"  \   fzf#vim#with_preview(),

nnoremap <leader>p :Files<CR>
" nnoremap <leader>g :Lines<CR>
nnoremap <leader>f :Rg<CR>
nnoremap <leader>g :Ack
nnoremap <leader>r :Acks
nnoremap <leader>n :NERDTree<CR>
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <leader>5 :vsplit<CR>
nnoremap <leader>' :split<CR>
nnoremap <C-n> :cn<CR>
nnoremap <C-b> :cp<CR>

au BufNewFile,BufRead *.s,*.S set filetype=arm " arm = armv6/7

augroup c_binary_literals
  autocmd!
  autocmd FileType c syn match cNumber "\<0[bB][01]\+\(u\=l\{0,2}\|ll\=u\)\>"
augroup END
