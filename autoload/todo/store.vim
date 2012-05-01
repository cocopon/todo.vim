" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


" Load/Save {{{
function! todo#store#save()
	let data_string = string(s:data)
	let data_list = split(data_string, "\<NL>")
	call writefile(data_list, expand(g:todo_data_path))
endfunction

function! todo#store#load(force_reload)
	let path = expand(g:todo_data_path)
	if s:data_loaded && !a:force_reload
		return
	elseif !filereadable(path)
		return
	endif

	let data_list = readfile(path)
	let data_string = join(data_list, "\<NL>")
	let s:data = eval(data_string)
	let s:data_loaded = 1
endfunction
" }}}


function! todo#store#reset()
	let s:data = {}
	let s:data.tasks = {}
	let s:data.next_id = 0
	call todo#store#save()
endfunction

function! todo#store#cleanup()
	let tasks = todo#store#all_tasks()
	for task in tasks
		if task.completed
			call todo#store#remove_task(task)
		endif
	endfor
endfunction


" Tasks {{{
function! todo#store#tasks(date)
	call todo#store#load(0)

	if empty(a:date)
		" TODO: Throw appropriate exception
		throw 'Error'
	endif

	let date_str = todo#date#encode(a:date)
	let tasks = get(s:data.tasks, date_str, [])

	if len(tasks) == 0
		let s:data.tasks[date_str] = tasks
	endif

	return tasks
endfunction

function! todo#store#all_tasks()
	call todo#store#load(0)

	let result = []

	for tasks in values(s:data.tasks)
		call extend(result, tasks)
	endfor

	return result
endfunction

function! todo#store#add_task(task)
	let a:task.id = s:data.next_id
	let s:data.next_id += 1
	call todo#store#gc(0)

	let tasks = todo#store#tasks(a:task.date)
	call add(tasks, a:task)
	call todo#store#save()
endfunction

function! todo#store#remove_task(task)
	let tasks = todo#store#tasks(a:task.date)
	let removed = 0

	let i = 0
	for task in tasks
		if task.id == a:task.id
			call remove(tasks, i)
			let removed = 1
			break
		endif
		let i += 1
	endfor

	call todo#store#save()
	return removed
endfunction

function! todo#store#update_task(task)
	let tasks = todo#store#tasks(a:task.date)
	let found = 0

	let i = 0
	for task in tasks
		if task.id == a:task.id
			let found = 1
			break
		endif
		let i += 1
	endfor

	if found
		let a:task.id = task.id
		let task.id = -1
		let tasks[i] = a:task

		call todo#store#save()
	endif

	return found
endfunction

function! todo#store#gc(forced)
	if s:data.next_id < 0x7fffffff && !a:forced
		return
	endif

	let tasks = todo#store#all_tasks()
	if len(tasks) == 0x7fffffff
		throw 'TaskLimitExceeded'
	endif

	" Compact tasks' id and recalculate the next id
	let s:data.next_id = 0
	for task in tasks
		let task.id = s:data.next_id
		let s:data.next_id += 1
	endfor

	call todo#store#save()
endfunction
" }}}


" Initialize {{{
let s:data_loaded = 0
call todo#store#reset()
" }}}


let &cpo = s:save_cpo


 " vim: set foldmethod=marker:
