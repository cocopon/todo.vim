" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! todo#store#default#new(path)
	let store = {}
	let store.path = expand(a:path)
	let store.data_loaded = 0

	let method_names = [
				\ 	'_raw_tasks',
				\ 	'add_task',
				\ 	'all_tasks',
				\ 	'cleanup',
				\ 	'gc',
				\ 	'load',
				\ 	'remove_task',
				\ 	'reset',
				\ 	'save',
				\ 	'setup',
				\ 	'task_by_id',
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
function! todo#store#default#store__raw_tasks(date) dict
	call self.load(0)

	if empty(a:date)
		" TODO: Throw appropriate exception
		throw 'date is empty'
	endif

	let date_str = todo#date#encode(a:date)
	let tasks = get(self.data.tasks, date_str, [])

	if empty(tasks)
		let self.data.tasks[date_str] = tasks
	endif

	return tasks
endfunction

function! todo#store#default#store_tasks(date) dict
	return deepcopy(self._raw_tasks(a:date))
endfunction

function! todo#store#default#store_all_tasks() dict
	call self.load(0)

	let result = []

	for tasks in values(self.data.tasks)
		call extend(result, deepcopy(tasks))
	endfor

	return result
endfunction

function! todo#store#default#store_task_by_id(id) dict
	let tasks = filter(self.all_tasks(), 'v:val.id == a:id')
	if empty(tasks)
		return {}
	endif

	if len(tasks) > 1
		" TODO: Throw appropriate exception
		throw printf('conflicted task id found: %d', a:id)
	endif

	return tasks[0]
endfunction

function! todo#store#default#store_add_task(task) dict
	let task = deepcopy(a:task)
	let task.id = self.data.next_id
	let self.data.next_id += 1
	call self.gc(0)

	let tasks = self._raw_tasks(task.date)
	call add(tasks, task)
	call self.save()

	return task.id
endfunction

function! todo#store#default#store_remove_task(task) dict
	let tasks = self._raw_tasks(a:task.date)
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
	let tasks = self._raw_tasks(a:task.date)
	let i = 0
	for task in tasks
		if task.id == a:task.id
			let found = 1
			break
		endif

		let i += 1
	endfor

	if !found
		return 0
	endif

	let tasks[i] = deepcopy(a:task)
	call self.save()

	return 1
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
