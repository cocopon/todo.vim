" Filter {{{
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

let s:unite_sorter = {
			\ 	'name': 'todo/sorter'
			\ }
function! s:unite_sorter.filter(candidates, context)
	let result = copy(a:candidates)
	return sort(result, 's:compare_candidate')
endfunction

let s:unite_filter_today = {
			\ 	'name': 'today'
			\ }
function! s:unite_filter_today.filter(candidates, context)
	let today = todo#date#today()
	let result = []

	for candidate in a:candidates
		let task = candidate.action__task
		if todo#dat#compare(task.date, today) == 0
			call add(result, candidate)
		endif
	endfor

	return result
endfunction

let s:unite_filter_completed = {
			\ 	'name': 'completed'
			\ }
function! s:unite_filter_completed.filter(candidates, context)
	let result = []

	for candidate in a:candidates
		let task = candidate.action__task
		if task.completed
			call add(result, candidate)
		endif
	endfor

	return result
endfunction

let s:unite_filter_incompleted = {
			\ 	'name': 'incompleted'
			\ }
function! s:unite_filter_incompleted.filter(candidates, context)
	let result = []

	for candidate in a:candidates
		let task = candidate.action__task
		if !task.completed
			call add(result, candidate)
		endif
	endfor

	return result
endfunction

let s:unite_filter_separator = {
			\ 	'name': 'todo/separator'
			\ }
function! s:unite_filter_separator.filter(candidates, context)
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
" }}}


" Source {{{
let s:unite_source_default = {
			\ 	'name': 'todo',
			\ 	'filters': ['incompleted', 'todo/sorter', 'todo/separator'],
			\ 	'gather_candidates': function('todo#unite#all_tasks')
			\ }
let s:unite_source_all = {
			\ 	'name': 'todo/all',
			\ 	'filters': ['todo/sorter', 'todo/separator'],
			\ 	'gather_candidates': function('todo#unite#all_tasks')
			\ }
let s:unite_source_today = {
			\ 	'name': 'todo/today',
			\ 	'filters': ['today', 'todo/sorter', 'todo/separator'],
			\ 	'gather_candidates': function('todo#unite#all_tasks')
			\ }
" }}}


" Kind {{{
let s:unite_kind = {
			\ 	'name': 'todo',
			\ 	'default_action': 'toggle',
			\ 	'action_table': {},
			\ 	'parents': []
			\ }

let s:unite_kind.action_table.toggle = {
			\ 	'description': 'toggle completion',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_quit': 0
			\ }
function! s:unite_kind.action_table.toggle.func(candidates)
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

let s:unite_kind.action_table.check = {
			\ 	'description': 'mark task as complete',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_selectable': 1,
			\ 	'is_quit': 0
			\ }
function! s:unite_kind.action_table.check.func(candidates)
	call s:set_candidates_state(a:candidates, 1)
endfunction

let s:unite_kind.action_table.uncheck = {
			\ 	'description': 'mark task as incomplete'
			\ }
function! s:unite_kind.action_table.uncheck.func(candidates)
	call s:set_candidates_state(a:candidates, 0)
endfunction

let s:unite_kind.action_table.remove = {
			\ 	'description': 'remove task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_selectable': 1,
			\ 	'is_quit': 0
			\ }
function! s:unite_kind.action_table.remove.func(candidates)
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

let s:unite_kind.action_table.rename = {
			\ 	'description': 'rename task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_quit': 0
			\ }
function! s:unite_kind.action_table.rename.func(candidates)
	let task = a:candidates.action__task
	let new_name = input('New name: ', task.title)
	let task.title = new_name
	call todo#task#update(task)
endfunction

let s:unite_kind.action_table.reschedule = {
			\ 	'description': 'reschedule task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_quit': 0
			\ }
function! s:unite_kind.action_table.reschedule.func(candidates)
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
" }}}


" Public {{{
function! todo#unite#all_tasks(args, context)
	if len(a:args) == 0
		let tasks = todo#store#all_tasks()
	else
		let date = todo#date#parse(a:args[0])
		let tasks = todo#store#tasks(date)
	endif
	let candidates = []

	for task in tasks
		let date_str = todo#date#format(task.date)
		let candidate = {
					\ 	'word': printf('[%s] %s %s', (task.completed ? 'v' : '-'), date_str, task.title),
					\ 	'source': 'todo',
					\ 	'kind': 'todo',
					\ 	'action__task': task,
					\ }
		call add(candidates, candidate)
	endfor

	return candidates
endfunction

function! todo#unite#register()
	call unite#define_kind(s:unite_kind)

	call unite#define_filter(s:unite_sorter)
	call unite#define_filter(s:unite_filter_completed)
	call unite#define_filter(s:unite_filter_incompleted)
	call unite#define_filter(s:unite_filter_today)
	call unite#define_filter(s:unite_filter_separator)

	call unite#define_source(s:unite_source_all)
	call unite#define_source(s:unite_source_default)
	call unite#define_source(s:unite_source_today)
endfunction
" }}}


" vim: set foldmethod=marker:
