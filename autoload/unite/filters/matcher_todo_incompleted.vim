" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! unite#filters#matcher_todo_incompleted#define()
	return s:filter
endfunction

let s:filter = {
			\ 	'name': 'matcher_todo/incompleted'
			\ }
function! s:filter.filter(candidates, context)
	let result = []

	for candidate in a:candidates
		let task = candidate.action__task
		if !task.completed
			call add(result, candidate)
		endif
	endfor

	return result
endfunction


let &cpo = s:save_cpo
