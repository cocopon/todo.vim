" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:data_loaded = 0
let s:data = {}


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
	call todo#store#save()
endfunction

function! todo#store#cleanup()
	let tasks = todo#store#all_tasks()
	for task in tasks
		if task.completed
			call todo#task#remove(task)
		endif
	endfor
endfunction


" Tasks {{{
function! todo#store#tasks(date)
	if !s:data_loaded
		call todo#store#load(0)
	endif

	if empty(a:date)
		" TODO: Throw appropriate exception
		throw 'Error'
	endif

	let date_str = todo#date#encode(a:date)
	let tasks = get(s:data, date_str, [])

	if len(tasks) == 0
		let s:data[date_str] = tasks
	endif

	return tasks
endfunction

function! todo#store#all_tasks()
	if !s:data_loaded
		call todo#store#load(0)
	endif

	let result = []

	for tasks in values(s:data)
		call extend(result, tasks)
	endfor

	return result
endfunction
" }}}


let &cpo = s:save_cpo


 " vim: set foldmethod=marker:
