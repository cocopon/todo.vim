" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! todo#task#new(date, title)
	return {
				\ 	'title': a:title,
				\ 	'date': a:date,
				\ 	'completed': 0,
				\ 	'index': -1
				\ }
endfunction

function! todo#task#add(task)
	let tasks = todo#store#tasks(a:task.date)
	let a:task.index = len(tasks)
	call add(tasks, a:task)
	call todo#store#save()
endfunction

function! todo#task#remove(task)
	let tasks = todo#store#tasks(a:task.date)
	let i = a:task.index
	call remove(tasks, i)

	while i < len(tasks)
		let tasks[i].index -= 1
		let i += 1
	endwhile

	call todo#store#save()
endfunction

function! todo#task#update(task)
	let tasks = todo#store#tasks(a:task.date)
	let tasks[a:task.index] = a:task
	call todo#store#save()
endfunction


let &cpo = s:save_cpo


 " vim: set foldmethod=marker:
