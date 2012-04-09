" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! todo#unite#all_tasks(args, context)
	if len(a:args) == 0
		let tasks = todo#store#all_tasks()
	else
		let date = todo#date#parse(a:args[0])
		let tasks = todo#store#tasks(date)
	endif
	let candidates = []

	for task in tasks
		let date_str = todo#date#format('%y/%m/%d', task.date)
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

let todo#unite#hooks = {
			\ }
function! todo#unite#hooks.on_syntax(args, context)
	syntax match uniteSource__Separator /--- .\+ ---/ contained containedin=unite__todo
	syntax match uniteSource__Separator /=== .\+ ===/ contained containedin=unite__todo
	syntax match uniteSource__Completed /\[v\] .\+/ contained containedin=unite__todo
	syntax match uniteSource__Date /[0-9]\{4\}\/[0-9]\{2\}\/[0-9]\{2\}/ contained containedin=unite__todo

	highlight default link uniteSource__Separator Special
	highlight default link uniteSource__Completed Comment
	highlight default link uniteSource__Date Type
endfunction


let &cpo = s:save_cpo


" vim: set foldmethod=marker:
