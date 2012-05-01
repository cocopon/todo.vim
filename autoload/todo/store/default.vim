" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! todo#store#default#new(path)
	let store = {}
	let store.path = expand(a:path)
	let store.data_loaded = 0

	let method_names = [
				\ 	'add_task',
				\ 	'all_tasks',
				\ 	'cleanup',
				\ 	'gc',
				\ 	'load',
				\ 	'remove_task',
				\ 	'reset',
				\ 	'save',
				\ 	'setup',
				\ 	'tasks',
				\ 	'update_task',
				\ ]
	for method_name in method_names
		let store[method_name] = function('todo#store#default#store_' . method_name)
	endfor

	call store.setup()

	return store
endfunction


" Load/Save {{{
function! todo#store#default#store_save() dict
	let data_string = string(self.data)
	let data_list = split(data_string, "\<NL>")
	call writefile(data_list, self.path)
endfunction

function! todo#store#default#store_load(forced) dict
	if self.data_loaded && !a:forced
		return
	elseif !filereadable(self.path)
		return
	endif

	let data_list = readfile(self.path)
	let data_string = join(data_list, "\<NL>")
	let self.data = eval(data_string)
	let self.data_loaded = 1

	let g:hoge = self.data
endfunction
" }}}


function! todo#store#default#store_setup() dict
	let self.data = {}
	let self.data.tasks = {}
	let self.data.next_id = 0
endfunction


function! todo#store#default#store_reset() dict
	call self.setup()
	call self.save()
endfunction


function! todo#store#default#store_cleanup() dict
	let tasks = self.all_tasks()
	for task in tasks
		if task.completed
			call self.remove_task(task)
		endif
	endfor
endfunction


" Tasks {{{
function! todo#store#default#store_tasks(date) dict
	call self.load(0)

	if empty(a:date)
		" TODO: Throw appropriate exception
		throw 'Error'
	endif

	let date_str = todo#date#encode(a:date)
	let tasks = get(self.data.tasks, date_str, [])

	if len(tasks) == 0
		let self.data.tasks[date_str] = tasks
	endif

	return tasks
endfunction

function! todo#store#default#store_all_tasks() dict
	call self.load(0)

	let result = []

	for tasks in values(self.data.tasks)
		call extend(result, tasks)
	endfor

	return result
endfunction

function! todo#store#default#store_add_task(task) dict
	let a:task.id = self.data.next_id
	let self.data.next_id += 1
	call self.gc(0)

	let tasks = self.tasks(a:task.date)
	call add(tasks, a:task)
	call self.save()
endfunction

function! todo#store#default#store_remove_task(task) dict
	let tasks = self.tasks(a:task.date)
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

	call self.save()
	return removed
endfunction

function! todo#store#default#store_update_task(task) dict
	let tasks = self.tasks(a:task.date)
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

		call self.save()
	endif

	return found
endfunction

function! todo#store#default#store_gc(forced) dict
	if self.data.next_id < 0x7fffffff && !a:forced
		return
	endif

	let tasks = self.all_tasks()
	if len(tasks) == 0x7fffffff
		throw 'TaskLimitExceeded'
	endif

	" Compact tasks' id and recalculate the next id
	let self.data.next_id = 0
	for task in tasks
		let task.id = self.data.next_id
		let self.data.next_id += 1
	endfor

	call self.save()
endfunction
" }}}


let &cpo = s:save_cpo


 " vim: set foldmethod=marker:
