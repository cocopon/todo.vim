" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License

command! -nargs=* TodoAdd call todo#add(<f-args>)

