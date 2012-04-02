" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! unite#filters#matcher_todo_today#define()
	return s:filter
endfunction

let s:filter = {
			\ 	'name': 'matcher_todo/today'
			\ }
function! s:filter.filter(candidates, context)
	let today = todo#date#today()
	let result = []

	for candidate in a:candidates
		let task = candidate.action__task

		if todo#date#compare(task.date, today) == 0
			call add(result, candidate)
		endif
	endfor

	return result
endfunction


let &cpo = s:save_cpo


" vim: set foldmethod=marker:
