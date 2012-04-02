function! unite#sources#todo_today#define()
	return s:source
endfunction

let s:source = {
			\ 	'name': 'todo/today',
			\ 	'filters': ['matcher_todo/today', 'sorter_todo', 'matcher_default', 'converter_todo/separate'],
			\ 	'gather_candidates': function('todo#unite#all_tasks'),
			\ 	'hooks': todo#unite#hooks,
			\ 	'syntax': 'unite__todo',
			\ }

