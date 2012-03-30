let s:save_cpo = &cpo
set cpo&vim


" Initialize {{{
call todo#unite#register()
" }}}


" Interface {{{
function! todo#load()
	call todo#store#load(1)
endfunction

function! todo#add(...)
	if a:0 == 1
		" Add new task in today
		" :Add {title}
		let task = todo#task#new(todo#date#today(), a:1)
		call todo#task#add(task)
	elseif a:0 >= 2
		" Add new task in specified date
		" :Add {date} {title}
		let args = copy(a:000)
		call remove(args, 0)
		let title = join(args)
		let date = todo#date#parse(a:1)
		let task = todo#task#new(date, title)
		call todo#task#add(task)
	else
		" Add new task step-by-step
		let date_str = input('Date: ')
		let date = todo#date#parse(date_str)
		let title = input('Title: ')
		let task = todo#task#new(date, title)
		call todo#task#add(task)
	endif
endfunction

function! todo#reset()
	let answer = input('Do you really want to remove all tasks?: ')
	if answer == 'yes'
		call todo#store#reset()
	endif
endfunction
" }}}


let &cpo = s:save_cpo


" vim: set foldmethod=marker:
