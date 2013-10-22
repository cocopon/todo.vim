" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:store = {}


function! todo#store#manager#get()
	if !empty(s:store)
		return s:store
	endif

	if !exists('g:todo_store_type')
		let g:todo_store_type = 'default'
	endif
	let constructor_name = printf('todo#store#%s#new', g:todo_store_type)
	let Constructor = function(constructor_name)
	let s:store = Constructor(g:todo_data_path)

	return s:store
endfunction


let &cpo = s:save_cpo
