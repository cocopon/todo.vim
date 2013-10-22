" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


command! -nargs=? TodoAdd call todo#add(<f-args>)


" Initialize {{{
function! s:initialize()
	if !exists('g:todo_data_path')
		let g:todo_data_path = '~/todo-vim.txt'
	endif
endfunction

call s:initialize()
" }}}


let &cpo = s:save_cpo
