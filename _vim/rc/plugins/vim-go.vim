NeoBundleLazy 'fatih/vim-go', {'autoload':{'filetypes':['go']}}
let g:go_bin_path = expand("~/go/bin")
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap gd <Plug>(go-def)
au FileType go nmap <Leader>i <Plug>(go-info)
