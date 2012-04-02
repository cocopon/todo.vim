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

function! s:separator_candidate(date)
	let date_str = todo#date#format(a:date)
	let dummy_task = todo#task#new(a:date, '')
	return {
				\ 	'word': printf('--- %s ---', date_str),
				\ 	'source': 'todo',
				\ 	'is_dummy': 1,
				\ 	'kind': 'todo',
				\ 	'action__task': dummy_task,
				\ }
endfunction
