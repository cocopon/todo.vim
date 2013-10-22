" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! todo#task#new(date, title)
	return {
				\ 	'title': a:title,
				\ 	'date': a:date,
				\ 	'completed': 0,
				\ 	'id': -1
				\ }
endfunction


let &cpo = s:save_cpo
