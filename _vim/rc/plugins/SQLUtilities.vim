NeoBundleLazy 'vim-scripts/SQLUtilities', {'autoload':{'filetypes':['sql', 'pgsql']}}
vmap <silent>sf	<Plug><,>SQLU_Formatter<CR> 
let g:sqlutil_keyword_case = '\U'
