function! unite#kinds#todo#define()
	return s:kind
endfunction

let s:kind = {
			\ 	'name': 'todo',
			\ 	'default_action': 'toggle',
			\ 	'action_table': {},
			\ 	'parents': []
			\ }

let s:kind.action_table.toggle = {
			\ 	'description': 'toggle completion',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.toggle.func(candidates)
	let task = a:candidates.action__task
	let task.completed = task.completed ? 0 : 1
	call todo#task#update(task)
endfunction

function! s:set_candidates_state(candidates, state)
	if type(a:candidates) == type([])
		let candidates = a:candidates
	else
		let candidates = [a:candidates]
	endif

	for candidate in candidates
		let task = candidate.action__task
		let task.completed = a:state
		call todo#task#update(task)
	endfor
endfunction

let s:kind.action_table.check = {
			\ 	'description': 'mark task as complete',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_selectable': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.check.func(candidates)
	call s:set_candidates_state(a:candidates, 1)
endfunction

let s:kind.action_table.uncheck = {
			\ 	'description': 'mark task as incomplete'
			\ }
function! s:kind.action_table.uncheck.func(candidates)
	call s:set_candidates_state(a:candidates, 0)
endfunction

let s:kind.action_table.remove = {
			\ 	'description': 'remove task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_selectable': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.remove.func(candidates)
	if type(a:candidates) == type([])
		let candidates = a:candidates
	else
		let candidates = [a:candidates]
	endif

	for candidate in candidates
		let task = candidate.action__task
		call todo#task#remove(task)
	endfor
endfunction

let s:kind.action_table.rename = {
			\ 	'description': 'rename task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.rename.func(candidates)
	let task = a:candidates.action__task
	let new_name = input('New name: ', task.title)
	let task.title = new_name
	call todo#task#update(task)
endfunction

let s:kind.action_table.reschedule = {
			\ 	'description': 'reschedule task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.reschedule.func(candidates)
	let candidates = (type(a:candidates) == type([])) ? a:candidates : [a:candidates]

	let date_str = ''
	if len(candidates) == 1
		let task = candidates[0].action__task
		let date_str = todo#date#format(task.date)
	endif
	let date_str = input('New date: ', date_str)
	let date = todo#date#parse(date_str)
	if empty(date)
		" TODO: Show error message
		return
	endif

	for candidate in candidates
		" Remove old task
		let task = candidate.action__task
		call todo#task#remove(task)

		" Add rescheduled task
		let task.date = date
		call todo#task#add(task)
	endfor
endfunction

