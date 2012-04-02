" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#todo_all#define()
	return s:source
endfunction

let s:source = {
			\ 	'name': 'todo/all',
			\ 	'filters': ['sorter_todo', 'matcher_default', 'converter_todo/separate'],
			\ 	'gather_candidates': function('todo#unite#all_tasks'),
			\ 	'hooks': todo#unite#hooks,
			\ 	'syntax': 'unite__todo',
			\ }


let &cpo = s:save_cpo


" vim: set foldmethod=marker:
