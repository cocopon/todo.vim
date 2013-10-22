" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! unite#kinds#todo#define()
	return s:kind
endfunction

let s:kind = {
			\ 	'name': 'todo',
			\ 	'default_action': 'toggle',
			\ 	'action_table': {},
			\ 	'parents': []
			\ }


" Toggle {{{
let s:kind.action_table.toggle = {
			\ 	'description': 'toggle completion',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.toggle.func(candidates)
	let task = a:candidates.action__task
	let task.completed = task.completed ? 0 : 1
	let store = todo#store#manager#get()
	call store.update_task(task)
endfunction
" }}}


" Check {{{
let s:kind.action_table.check = {
			\ 	'description': 'mark task as complete',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_selectable': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.check.func(candidates)
	call s:set_candidates_state(a:candidates, 1)
endfunction
" }}}


" Uncheck {{{
let s:kind.action_table.uncheck = {
			\ 	'description': 'mark task as incomplete'
			\ }
function! s:kind.action_table.uncheck.func(candidates)
	call s:set_candidates_state(a:candidates, 0)
endfunction
" }}}


" Delete {{{
let s:kind.action_table.delete = {
			\ 	'description': 'delete task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_selectable': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.delete.func(candidates)
	if type(a:candidates) == type([])
		let candidates = sort(a:candidates, function('s:compare_candidate_id_desc'))
	else
		let candidates = [a:candidates]
	endif

	let store = todo#store#manager#get()
	for candidate in candidates
		let task = candidate.action__task
		call store.remove_task(task)
	endfor
endfunction
" }}}


" Rename {{{
let s:kind.action_table.rename = {
			\ 	'description': 'rename task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.rename.func(candidates)
	let task = a:candidates.action__task
	let new_name = input('New name: ', task.title)
	if len(new_name) == 0
		return
	endif

	let task.title = new_name
	let store = todo#store#manager#get()
	call store.update_task(task)
endfunction
" }}}


" Reschedule {{{
let s:kind.action_table.reschedule = {
			\ 	'description': 'reschedule task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_selectable': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.reschedule.func(candidates)
	if type(a:candidates) == type([])
		let candidates = sort(a:candidates, function('s:compare_candidate_id_desc'))
	else
		let candidates = [a:candidates]
	endif

	let date_str = ''
	if len(candidates) == 1
		let task = candidates[0].action__task
		let date_str = todo#date#format('%y/%m/%d', task.date)
	endif
	let date_str = input('New date: ', date_str)
	let date = todo#date#parse(date_str)
	if empty(date)
		" TODO: Show error message
		return
	endif

	" Remove old task
	let store = todo#store#manager#get()
	for candidate in candidates
		let task = candidate.action__task
		call store.remove_task(task)
	endfor

	let candidates = sort(candidates, function('s:compare_candidate_id_asc'))

	" Add rescheduled task
	for candidate in candidates
		let task = candidate.action__task
		let task.date = date
		call store.add_task(task)
	endfor
endfunction
" }}}


" {{{
let s:kind.action_table.unite__new_candidate = {
			\ 	'description': 'new task',
			\ 	'is_invalidate_cache': 1,
			\ 	'is_selectable': 1,
			\ 	'is_quit': 0
			\ }
function! s:kind.action_table.unite__new_candidate.func(candidates)
	if type(a:candidates) == type([])
		let candidate = sort(a:candidates, function('s:compare_candidate_id_desc'))[0]
	else
		let candidate = a:candidates
	endif

	let task = candidate.action__task

	" TODO: Pass selected date parameter
	call todo#add()
endfunction
" }}}


function! s:set_candidates_state(candidates, state)
	if type(a:candidates) == type([])
		let candidates = a:candidates
	else
		let candidates = [a:candidates]
	endif

	let store = todo#store#manager#get()
	for candidate in candidates
		let task = candidate.action__task
		let task.completed = a:state
		call store.update_task(task)
	endfor
endfunction

function! s:compare_candidate_id_asc(c1, c2)
	let task1 = a:c1.action__task
	let task2 = a:c2.action__task

	return (task1.id >= task2.id) ? +1 : -1
endfunction

function! s:compare_candidate_id_desc(c1, c2)
	return s:compare_candidate_id_asc(a:c2, a:c1)
endfunction


let &cpo = s:save_cpo
