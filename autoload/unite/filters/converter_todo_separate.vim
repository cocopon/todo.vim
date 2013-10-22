" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! unite#filters#converter_todo_separate#define()
	return s:filter
endfunction

let s:filter = {
			\ 	'name': 'converter_todo/separate'
			\ }
function! s:filter.filter(candidates, context)
	let result = []

	let date = todo#date#empty()
	for candidate in a:candidates
		let task = candidate.action__task

		if empty(date) || todo#date#compare(date, task.date) != 0
			let date = task.date
			let separator = s:separator_candidate(date)
			call add(result, separator)
		endif

		call add(result, candidate)
	endfor

	return result
endfunction


" Candidates {{{
function! s:separator_candidate(date)
	if todo#date#istbd(a:date)
		let word = '--- TBD ---'
	elseif todo#date#compare(a:date, todo#date#today()) == 0
		let word = todo#date#format('=== %y/%m/%d (%a) ===', a:date) 
	else
		let word = todo#date#format('--- %y/%m/%d (%a) ---', a:date) 
	endif

	let dummy_task = todo#task#new(a:date, '')
	return {
				\ 	'word': word,
				\ 	'source': 'todo',
				\ 	'is_dummy': 1,
				\ 	'kind': 'todo',
				\ 	'action__task': dummy_task,
				\ }
endfunction
" }}}


let &cpo = s:save_cpo
