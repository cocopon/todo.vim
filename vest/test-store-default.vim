let s:save_cpo = &cpo
set cpo&vim


" {{{
let s:store_path = tempname()


function! s:rand(min, max)
	" http://vim-users.jp/2009/11/hack98/
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
" }}}


Context Source.run()
	It adds task
		let store = s:new_store()
		let task = s:new_task()
		let id = store.add_task(task)

		" Returned id should have a valid value
		Should id >= 0

		" Id of the original task should not be changed
		ShouldEqual task.id, -1

		" It should be obtained added task
		let obtained_task = store.task_by_id(id)
		ShouldNot empty(obtained_task)

		" Obtained task should have id
		ShouldEqual obtained_task.id, 0

		" Obtained task should not refer to the original
		let obtained_task.title = 'modified'
		ShouldNotEqual task.title, obtained_task.title
	End

	It gets tasks
		let store = s:new_store()
		let tasks = [
					\ 	s:new_task(2000, 12, 31),
					\ 	s:new_task(2000, 12, 31),
					\ 	s:new_task(2000, 12, 30),
					\ 	s:new_task(2000, 10, 31),
					\ 	s:new_task(2013, 12, 31)
					\ ]
		for task in tasks
			call store.add_task(task)
		endfor

		" It should be returned tasks only in the specified date
		let date = todo#date#new(2000, 12, 31)
		ShouldEqual len(store.tasks(date)), 2

		" Returned value should not refer to the original
		let obtained_task = store.tasks(date)[0]
		let obtained_task.title = 'modified'
		ShouldEqual len(filter(store.tasks(date), 'v:val.title == "modified"')), 0
	End

	It gets all_tasks
		let store = s:new_store()
		ShouldEqual len(store.all_tasks()), 0

		let task1 = s:new_task(2000, 1, 1)
		call store.add_task(task1)
		ShouldEqual len(store.all_tasks()), 1

		" all_tasks should contains tasks in different dates
		let task2 = s:new_task(2000, 12, 31)
		call store.add_task(task2)
		ShouldEqual len(store.all_tasks()), 2

		" Returned value should not refer to the original
		let obtained_task = store.all_tasks()[0]
		let obtained_task.title = 'modified'
		ShouldEqual len(filter(store.all_tasks(), 'v:val.title == "modified"')), 0
	End

	It gets a task by id
		let store = s:new_store()
		let task = s:new_task()
		call store.add_task(task)

		let obtained_task1 = store.all_tasks()[0]
		let obtained_task2 = store.task_by_id(obtained_task1.id)
		ShouldNot empty(obtained_task2)
		ShouldEqual obtained_task1.id, obtained_task2.id
	End

	It removes task
		let store = s:new_store()
		let task1 = s:new_task()
		let task2 = s:new_task()
		let id1 = store.add_task(task1)
		let id2 = store.add_task(task2)

		" It should be found obtained task
		let tasks = filter(store.all_tasks(), 'v:val.id == id1')
		ShouldEqual len(tasks), 1

		" It should be removed
		let obtained_task1 = store.task_by_id(id1)
		let removed = store.remove_task(obtained_task1)
		Should removed

		" It should be not found obtained task
		let tasks = filter(store.all_tasks(), 'v:val.id == id1')
		ShouldEqual len(tasks), 0
	End

	It updates task
		let store = s:new_store()
		let task = s:new_task()
		let id = store.add_task(task)

		let obtained_task1 = store.task_by_id(id)
		let obtained_task1.title = 'modified'
		let updated = store.update_task(obtained_task1)

		" It should be updated
		Should updated

		" Chainging title should be applied
		let obtained_task2 = store.task_by_id(id)
		ShouldEqual obtained_task2.title, 'modified'
	End

	call s:clean_up()
End


Fin


let &cpo = s:save_cpo
