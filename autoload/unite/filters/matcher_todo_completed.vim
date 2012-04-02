function! unite#filters#matcher_todo_completed#define()
	return s:filter
endfunction

let s:filter = {
			\ 	'name': 'matcher_todo/completed'
			\ }
function! s:filter.filter(candidates, context)
	let result = []

	for candidate in a:candidates
		let task = candidate.action__task
		if task.completed
			call add(result, candidate)
		endif
	endfor

	return result
endfunction

