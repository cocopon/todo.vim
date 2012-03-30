let s:empty_date = {}


" Create {{{
""
" Creates and returns a new date
" @param year
" @param month
" @param day
" @return
" Created date
function! todo#date#new(year, month, day)
	return {
				\   'year': a:year,
				\   'month': a:month,
				\   'day': a:day
				\ }
endfunction

function! todo#date#today()
	let total_sec = localtime()
	return todo#date#decode(strftime('%Y%m%d'))
endfunction
" }}}


""
" Returns comparison result between two dates
" @param date1
" @param date2
" @return
" Positive value if date1 is greater than date2.
" Negative value if date1 is less than date1.
" Zero if date1 equals to date2.
function! todo#date#compare(date1, date2)
	let keys = ['year', 'month', 'day']

	for key in keys
		let d = a:date1[key] - a:date2[key]
		if d > 0
			return +1
		elseif d < 0
			return -1
		endif
	endfor

	return 0
endfunction

" Format {{{
function! s:parse_date_symbol(str)
	if match(a:str, 'tod\(ay\)\?') >= 0
		return todo#date#today()
	else
		return s:empty_date
	endif
endfunction
function! s:parse_yyyymmdd(str)
	let separators = ['', '/']
	let pattern_fmt = '^\(\d\{4\}\)%s\(\d\{2\}\)%s\(\d\{2\}\)$'

	for separator in separators
		let pattern = printf(pattern_fmt, separator, separator)
		let comps = matchlist(a:str, pattern)
		if get(comps, 3, '') != ''
			return todo#date#new(comps[1], comps[2], comps[3])
		endif
	endfor

	return s:empty_date
endfunction

let s:date_parsers = [
			\   function('s:parse_date_symbol'),
			\   function('s:parse_yyyymmdd')
			\ ]

function! todo#date#parse(str)
	for Parser in s:date_parsers
		let result = call(Parser, [a:str])
		if !empty(result)
			return result
		endif
	endfor

	return s:empty_date
endfunction

" TODO: Add format argument
function! todo#date#format(date)
	return printf('%04d/%02d/%02d',
				\ a:date.year,
				\ a:date.month,
				\ a:date.day)
endfunction
" }}}

" Encode/Decode {{{
function! todo#date#encode(date)
	return printf('%04d%02d%02d', a:date.year, a:date.month, a:date.day)
endfunction

function! todo#date#decode(str)
	return s:parse_yyyymmdd(a:str)
endfunction
" }}}


 " vim: set foldmethod=marker:
