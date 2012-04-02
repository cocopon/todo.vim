" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! unite#filters#sorter_todo#define()
	return s:filter
endfunction

let s:filter = {
			\ 	'name': 'sorter_todo'
			\ }
function! s:filter.filter(candidates, context)
	let result = copy(a:candidates)
	return sort(result, 's:compare_candidate')
endfunction

function! s:compare_candidate(c1, c2)
	let task1 = a:c1.action__task
	let task2 = a:c2.action__task

	let result = todo#date#compare(task1.date, task2.date)
	if result != 0
		return result
	elseif task1.completed != task2.completed
		return task1.completed ? +1 : -1
	endif

	return +1
endfunction


let &cpo = s:save_cpo


" vim: set foldmethod=marker:
