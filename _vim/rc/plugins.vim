" Load all the plugins automatically on startup

filetype off
filetype plugin indent off

call plug#begin('~/.vim/plugged')

Plug 'vim-scripts/Align'

Plug 'ctrlpvim/ctrlp.vim'

Plug 'vim-scripts/dbext.vim', {'for': 'sql'}

Plug 'Raimondi/delimitMate'

Plug 'mattn/emmet-vim', {'for':['html','xml','xsl','xslt','xsd','css','sass','scss','less','mustache']}
function! s:zen_html_tab()
  let line = getline('.')
  if match(line, '<.*>') < 0
    return "\<c-y>,"
  endif
  return "\<c-y>n"
endfunction
autocmd FileType xml,xsl,xslt,xsd,css,sass,scss,less,mustache imap <buffer><tab> <c-y>,
autocmd FileType html imap <buffer><expr><tab> <sid>zen_html_tab()

Plug 'tpope/vim-fugitive'

Plug 'gregsexton/gitv', {'on': 'Gitv'}
nnoremap <silent> <leader>gv :Gitv<CR>
nnoremap <silent> <leader>gV :Gitv!<CR>

Plug 'zhaocai/GoldenView.Vim'
let g:goldenview__enable_default_mapping=0
nmap <F4> <Plug>ToggleGoldenViewAutoResize

Plug 'vim-scripts/groovy.vim'

Plug 'othree/html5.vim'

Plug 'othree/javascript-libraries-syntax.vim', {'for':['javascript','coffee','ls','typescript']}

Plug 'maksimr/vim-jsbeautify', {'for':['javascript']}
nnoremap <leader>fjs :call JsBeautify()<cr>

Plug 'gregsexton/MatchTag', {'for':['html','xml']}

Plug 'Shougo/neocomplete.vim'

Plug 'scrooloose/nerdtree', {'on':['NERDTreeToggle','NERDTreeFind']}
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=0
let NERDTreeShowLineNumbers=1
let NERDTreeChDirMode=0
let NERDTreeShowBookmarks=1
let NERDTreeIgnore=['\.git','\.hg']
nnoremap <F2> :NERDTreeToggle<CR>
nnoremap <F3> :NERDTreeFind<CR>

Plug 'OmniSharp/omnisharp-vim', {'for': 'cs'}
let g:OmniSharp_host = "http://localhost:2000"
set noshowmatch

"Super tab settings - uncomment the next 4 lines
let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = "<c-x><c-o>"
let g:SuperTabDefaultCompletionTypeDiscovery = ["&omnifunc:<c-x><c-o>","&completefunc:<c-x><c-n>"]
let g:SuperTabClosePreviewOnPopupClose = 1

"don't autoselect first item in omnicomplete, show if only one item (for preview)
"remove preview if you don't want to see any documentation whatsoever.
set completeopt=longest,menuone,preview
" Fetch full documentation during omnicomplete requests. 
" There is a performance penalty with this (especially on Mono)
" By default, only Type/Method signatures are fetched. Full documentation can still be fetched when
" you need it with the :OmniSharpDocumentation command.
" let g:omnicomplete_fetch_documentation=1

"Move the preview window (code documentation) to the bottom of the screen, so it doesn't move the code!
"You might also want to look at the echodoc plugin
set splitbelow

" Get Code Issues and syntax errors
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']

augroup omnisharp_commands
    autocmd!

    "Set autocomplete function to OmniSharp (if not using YouCompleteMe completion plugin)
    autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

    " Synchronous build (blocks Vim)
    "autocmd FileType cs nnoremap <F5> :wa!<cr>:OmniSharpBuild<cr>
    " Builds can also run asynchronously with vim-dispatch installed
    autocmd FileType cs nnoremap <leader>b :wa!<cr>:OmniSharpBuildAsync<cr>
    " automatic syntax check on events (TextChanged requires Vim 7.4)
    autocmd BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck

    " Automatically add new cs files to the nearest project on save
    " autocmd BufWritePost *.cs call OmniSharp#AddToProject()

    "show type information automatically when the cursor stops moving
    autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()

    "The following commands are contextual, based on the current cursor position.

    autocmd FileType cs nnoremap gd :OmniSharpGotoDefinition<cr>
    autocmd FileType cs nnoremap <leader>fi :OmniSharpFindImplementations<cr>
    autocmd FileType cs nnoremap <leader>ft :OmniSharpFindType<cr>
    autocmd FileType cs nnoremap <leader>fs :OmniSharpFindSymbol<cr>
    autocmd FileType cs nnoremap <leader>fu :OmniSharpFindUsages<cr>
    autocmd FileType cs nnoremap <leader>fm :OmniSharpFindMembers<cr> "finds members in the current buffer
    " cursor can be anywhere on the line containing an issue 
    autocmd FileType cs nnoremap <leader>x  :OmniSharpFixIssue<cr>  
    autocmd FileType cs nnoremap <leader>fx :OmniSharpFixUsings<cr>
    autocmd FileType cs nnoremap <leader>tt :OmniSharpTypeLookup<cr>
    autocmd FileType cs nnoremap <leader>dc :OmniSharpDocumentation<cr>
    autocmd FileType cs nnoremap <C-K> :OmniSharpNavigateUp<cr> "navigate up by method/property/field
    autocmd FileType cs nnoremap <C-J> :OmniSharpNavigateDown<cr> "navigate down by method/property/field

augroup END


" this setting controls how long to wait (in ms) before fetching type / symbol information.
set updatetime=500
" Remove 'Press Enter to continue' message when type information is longer than one line.
set cmdheight=2

" Contextual code actions (requires CtrlP)
nnoremap <leader><space> :OmniSharpGetCodeActions<cr>
" Run code actions with text selected in visual mode to extract method
vnoremap <leader><space> :call OmniSharp#GetCodeActions('visual')<cr>

" rename with dialog
nnoremap <leader>nm :OmniSharpRename<cr>
" nnoremap <F2> :OmniSharpRename<cr>      
" rename without dialog - with cursor on the symbol to rename... ':Rename newname'
command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")

" Force OmniSharp to reload the solution. Useful when switching branches etc.
nnoremap <leader>rl :OmniSharpReloadSolution<cr>
nnoremap <leader>cf :OmniSharpCodeFormat<cr>
" Load the current .cs file to the nearest project
nnoremap <leader>tp :OmniSharpAddToProject<cr>

" (Experimental - uses vim-dispatch or vimproc plugin) - Start the omnisharp server for the current solution
nnoremap <leader>ss :OmniSharpStartServer<cr>
nnoremap <leader>sp :OmniSharpStopServer<cr>

" Add syntax highlighting for types and interfaces
nnoremap <leader>th :OmniSharpHighlightTypes<cr>
"Don't ask to save when changing buffers (i.e. when jumping to a type definition)
set hidden


Plug 'exu/pgsql.vim', {'for':['pgsql']}

Plug 'cakebaker/scss-syntax.vim', {'for':['scss','sass']}

Plug 'vim-scripts/sql.vim--Stinson'

Plug 'vim-scripts/SQLUtilities', {'for':['sql', 'pgsql']}
vmap <silent>sf	<Plug><,>SQLU_Formatter<CR> 
let g:sqlutil_keyword_case = '\U'

Plug 'ervandew/supertab'
" Helps with YCM + ultisnips integration
let g:SuperTabDefaultCompletionType = '<C-n>'

Plug 'scrooloose/syntastic' 
let g:syntastic_error_symbol = '✗'
let g:syntastic_style_error_symbol = '✠'
let g:syntastic_warning_symbol = '∆'
let g:syntastic_style_warning_symbol = '≈'

Plug 'majutsushi/tagbar', {'on':'TagbarToggle'}
nnoremap <silent> <F9> :TagbarToggle<CR>

Plug 'marijnh/tern_for_vim', {'for': ['javascript'], 'do': 'npm install' }

Plug 'edkolev/tmuxline.vim'

Plug 'leafgarland/typescript-vim', {'for':['typescript']}

Plug 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetsDir='~/.vim/snippets'

Plug 'vim-scripts/unibasic.vim'

Plug 'Shougo/unite.vim'
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable=1
let g:unite_source_rec_max_cache_files=5000
let g:unite_prompt='» '
let g:unite_source_grep_command = 'pt'
let g:unite_source_grep_default_opts = '--nogroup --nocolor'
let g:unite_source_grep_recursive_opt = ''
let g:unite_source_grep_encoding = 'utf-8'
function! s:unite_settings()
  nmap <buffer> Q <plug>(unite_exit)
  nmap <buffer> <esc> <plug>(unite_exit)
  imap <buffer> <esc> <plug>(unite_exit)
endfunction
autocmd FileType unite call s:unite_settings()
nmap <space> [unite]
nnoremap [unite] <nop>
nnoremap <silent> [unite]<space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async:! buffer file_mru bookmark<cr><c-u>
nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec<cr><c-u>
nnoremap <silent> [unite]e :<C-u>Unite -buffer-name=recent file_mru<cr>
nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
nnoremap <silent> [unite]l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
nnoremap <silent> [unite]b :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
nnoremap <silent> [unite]/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
nnoremap <silent> [unite]m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
nnoremap <silent> [unite]s :<C-u>Unite -quick-match buffer<cr>

" Additional useful unite plugins
"Plug 'Shougo/neomru.vim', {'autoload':{'unite_sources':'file_mru'}}
"Plug 'osyo-manga/unite-airline_themes', {'autoload':{'unite_sources':'airline_themes'}}
nnoremap <silent> [unite]a :<C-u>Unite -winheight=10 -auto-preview -buffer-name=airline_themes airline_themes<cr>

"Plug 'ujihisa/unite-colorscheme', {'autoload':{'unite_sources':'colorscheme'}}
"nnoremap <silent> [unite]c :<C-u>Unite -winheight=10 -auto-preview -buffer-name=colorschemes colorscheme<cr>

"Plug 'tsukkee/unite-tag', {'autoload':{'unite_sources':['tag','tag/file']}}
"nnoremap <silent> [unite]t :<C-u>Unite -auto-resize -buffer-name=tag tag tag/file<cr>

"Plug 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}} 
"nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>

"Plug 'Shougo/unite-help', {'autoload':{'unite_sources':'help'}} 
"nnoremap <silent> [unite]h :<C-u>Unite -auto-resize -buffer-name=help help<cr>

Plug 'tpope/vim-abolish'

Plug 'bling/vim-airline'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0
let g:airline_powerline_fonts = 1

Plug 'kchmck/vim-coffee-script', {'for':['coffee']}

Plug 'altercation/vim-colors-solarized'

Plug 'ap/vim-css-color', {'for':['css','scss','sass','less','styl']}

Plug 'hail2u/vim-css3-syntax', {'for':['css','scss','sass']}

Plug 'tpope/vim-dispatch'

Plug 'tpope/vim-fugitive'
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gb :Gblame<CR>
nnoremap <silent> <leader>gl :Glog<CR>
nnoremap <silent> <leader>gp :Git push<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gr :Gremove<CR>
autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>
autocmd BufReadPost fugitive://* set bufhidden=delete

Plug 'fatih/vim-go', {'for':['go']}
let g:go_bin_path = expand("~/go/bin")
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>i <Plug>(go-info)

Plug 'tfnico/vim-gradle', {'for':['gradle']}

Plug 'pangloss/vim-javascript', {'for':['javascript']}

Plug 'maksimr/vim-jsbeautify', {'for':['javascript','html','css']}

Plug 'elzr/vim-json', {'for':['javascript','json']}

Plug 'groenewege/vim-less', {'for':['less']}

Plug 'plasticboy/vim-markdown', {'for':['markdown']}

Plug 'mmalecki/vim-node.js', {'for':['javascript']}

Plug 'tpope/vim-repeat'

Plug 'christoomey/vim-tmux-navigator'

Plug 'tpope/vim-unimpaired'

Plug 'Shougo/vimproc.vim', {'do': 'make -f make_mac.mak'}

call plug#end()

filetype plugin indent on
syntax on
