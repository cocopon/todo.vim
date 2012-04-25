" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


" Interface {{{
function! todo#load()
	call todo#store#load(1)
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
		if empty(date)
			let msg = printf('Invalid date format ''%s''. ', date_str)
			redraw
			call todo#view#echoerr(msg)
			call getchar()
		endif
	endwhile

	let task = todo#task#new(date, title)
	call todo#task#add(task)
endfunction

function! todo#reset()
	let answer = input('Do you really want to remove all tasks?: ')
	if answer =~ '^y\(es\)\?$'
		call todo#store#reset()
	endif
endfunction
" }}}


let &cpo = s:save_cpo


" vim: set foldmethod=marker:
