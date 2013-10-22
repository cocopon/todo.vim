" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#todo_today#define()
	return s:source
endfunction

let s:source = {
			\ 	'name': 'todo/today',
			\ 	'description': 'candidates from today''s todo',
			\ 	'filters': ['matcher_todo/today', 'sorter_todo', 'matcher_default', 'converter_todo/separate'],
			\ 	'gather_candidates': function('todo#unite#all_tasks'),
			\ 	'hooks': todo#unite#hooks,
			\ 	'syntax': 'unite__todo',
			\ }


let &cpo = s:save_cpo
