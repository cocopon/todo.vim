let s:save_cpo = &cpo
set cpo&vim


" TODO: Temporary file path
let s:store_path = expand('~/Desktop/todo')


" {{{
function! s:rand(min, max)
	let match_end = matchend(reltimestr(reltime()), '\d\+\.') + 1
	return a:min + reltimestr(reltime())[l:match_end : ] % ((a:max - a:min) + 1)
endfunction


function! s:clean_up()
	call delete(s:store_path)
endfunction


function! s:new_store()
	call s:clean_up()
	return todo#store#default#new(s:store_path)
endfunction
" }}}


function! s:new_task(...)
	if a:0 == 3
		let year = a:1
		let month = a:2
		let day = a:3
	else
		let year = s:rand(1900, 2100)
		let month = s:rand(1, 12)
		let day = s:rand(1, 28)
	endif

	let date = todo#date#new(year, month, day)
	let title = 'title'
	return todo#task#new(date, title)
endfunction


Context Source.run()
	It adds task
		let store = s:new_store()
		let task = s:new_task()
		call store.add_task(task)

		" Id of the original task should not be changed
		ShouldEqual task.id, -1

		" It should be obtained added task
		let obtained_tasks = store.tasks(task.date)
		ShouldEqual len(obtained_tasks), 1

		" Obtained task should have id
		Should obtained_tasks[0].id == 0
	End

	It checks all_tasks
		let store = s:new_store()
		ShouldEqual len(store.all_tasks()), 0

		let task1 = s:new_task(2000, 1, 1)
		call store.add_task(task1)
		ShouldEqual len(store.all_tasks()), 1

		" all_tasks should contains tasks in different dates
		let task2 = s:new_task(2000, 12, 31)
		call store.add_task(task2)
		ShouldEqual len(store.all_tasks()), 2
	End

	It gets a task by id
		let store = s:new_store()
		let task = s:new_task()
		call store.add_task(task)

		let obtained_task1 = store.all_tasks()[0]
		let obtained_task2 = store.task_by_id(obtained_task1.id)
		Should !empty(obtained_task2)
		ShouldEqual obtained_task1.id, obtained_task2.id
	End

	It removes task
		let store = s:new_store()
		let task1 = s:new_task()
		let task2 = s:new_task()
		call store.add_task(task1)
		call store.add_task(task2)

		" It should be found obtained task
		let tasks = filter(store.all_tasks(), 'v:val.id == task1.id')
		ShouldEqual len(tasks), 1

		" It should be not found obtained task
		call store.remove_task(task1)
		let tasks = filter(store.all_tasks(), 'v:val.id == task1.id')
		ShouldEqual len(tasks), 0
	End

	call s:clean_up()
End


Fin


let &cpo = s:save_cpo
