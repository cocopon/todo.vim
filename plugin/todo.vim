" todo.vim - Simple to-do list working with unite.vim
"
" Author: cocopon <cocopon@me.com>
"
" Copyright (C) 2012 cocopon

command! -nargs=* TodoAdd call todo#add(<f-args>)


" Initialize {{{
call todo#unite#register()
" }}}

