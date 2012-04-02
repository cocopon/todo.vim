function! unite#sources#todo#define()
	return s:source
endfunction

let s:source = {
			\ 	'name': 'todo',
			\ 	'filters': ['matcher_todo/incompleted', 'sorter_todo', 'matcher_default', 'converter_todo/separate'],
			\ 	'gather_candidates': function('todo#unite#all_tasks'),
			\ 	'hooks': todo#unite#hooks,
			\ 	'syntax': 'unite__todo',
			\ }
