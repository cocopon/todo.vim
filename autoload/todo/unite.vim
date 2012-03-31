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

let s:filter_sort = {
			\ 	'name': 'sorter_todo'
			\ }
function! s:filter_sort.filter(candidates, context)
	let result = copy(a:candidates)
	return sort(result, 's:compare_candidate')
endfunction

let s:filter_today = {
			\ 	'name': 'matcher_todo/today'
			\ }
function! s:filter_today.filter(candidates, context)
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

let s:filter_completed = {
			\ 	'name': 'matcher_todo/completed'
			\ }
function! s:filter_completed.filter(candidates, context)
	let result = []

	for candidate in a:candidates
		let task = candidate.action__task
		if task.completed
			call add(result, candidate)
		endif
	endfor

	return result
endfunction

let s:filter_incompleted = {
			\ 	'name': 'matcher_todo/incompleted'
			\ }
function! s:filter_incompleted.filter(candidates, context)
	let result = []

	for candidate in a:candidates
		let task = candidate.action__task
		if !task.completed
			call add(result, candidate)
		endif
	endfor

	return result
endfunction

let s:filter_separate = {
			\ 	'name': 'converter_todo/separate'
			\ }
function! s:filter_separate.filter(candidates, context)
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
let s:source_default = {
			\ 	'name': 'todo',
			\ 	'filters': ['matcher_todo/incompleted', 'sorter_todo', 'matcher_default', 'converter_todo/separate'],
			\ 	'gather_candidates': function('todo#unite#all_tasks')
			\ }
let s:source_all = {
			\ 	'name': 'todo/all',
			\ 	'filters': ['sorter_todo', 'matcher_default', 'converter_todo/separate'],
			\ 	'gather_candidates': function('todo#unite#all_tasks')
			\ }
let s:source_today = {
			\ 	'name': 'todo/today',
			\ 	'filters': ['matcher_todo/today', 'sorter_todo', 'matcher_default', 'converter_todo/separate'],
			\ 	'gather_candidates': function('todo#unite#all_tasks')
			\ }
" }}}


" Kind {{{
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
	call unite#define_kind(s:kind)

	call unite#define_filter(s:filter_sort)
	call unite#define_filter(s:filter_completed)
	call unite#define_filter(s:filter_incompleted)
	call unite#define_filter(s:filter_today)
	call unite#define_filter(s:filter_separate)

	call unite#define_source(s:source_all)
	call unite#define_source(s:source_default)
	call unite#define_source(s:source_today)
endfunction
" }}}


" vim: set foldmethod=marker:
