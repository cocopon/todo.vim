" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


" Interface {{{
function! todo#load()
	let store = todo#store#manager#get()
	call store.load(1)
endfunction

function! todo#add(...)
	if a:0 == 0
		let title = input('Title: ')
	elseif a:0 == 1
		let title = a:1
	endif
	if len(title) == 0
		redraw
		echo 'Cancelled.'
		return
	endif

	while 1
		let date_str = input('Date: ', 'today')
		if len(date_str) == 0
			redraw
			echo 'Cancelled.'
			return
		endif

		let date = todo#date#parse(date_str)
		if !empty(date)
			break
		endif

		let msg = printf('Invalid date format ''%s''. ', date_str)
		redraw
		call todo#view#echoerr(msg)
		call getchar()
	endwhile

	let task = todo#task#new(date, title)
	let store = todo#store#manager#get()
	call store.add_task(task)

	let date_str = todo#date#format('%y/%m/%d', task.date)
	let msg = printf('Added ''%s'', %s.',
				\ 	task.title,
				\ 	date_str)
	redraw
	echo msg
endfunction

function! todo#reset()
	let answer = input('Do you really want to remove all tasks?: ')
	if answer =~ '^y\(es\)\?$'
		let store = todo#store#manager#get()
		let store.reset()
	endif
endfunction
" }}}


let &cpo = s:save_cpo
