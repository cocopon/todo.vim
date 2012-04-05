" todo.vim - Simple to-do list working with unite.vim
"
" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


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

function! todo#date#empty()
	return s:empty_date
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
let s:special_patterns = {
			\ 	'tod\(ay\)\?': [0, 0, 0],
			\ 	'tom\(orrow\)\?': [0, 0, 1],
			\ }
function! s:parse_special_name(str)
	for pattern in keys(s:special_patterns)
		if match(a:str, pattern) >= 0
			let today = todo#date#today()
			let offset = s:special_patterns[pattern]
			return todo#date#offset(today, offset[0], offset[1], offset[2])
		endif
	endfor

	return s:empty_date
endfunction

let s:date_separators = ['', '/', '-']
function! s:parse_yyyymmdd(str)
	let pattern_fmt = '^\(\d\{4\}\)%s\(\d\{2\}\)%s\(\d\{2\}\)$'

	for separator in s:date_separators
		let pattern = printf(pattern_fmt, separator, separator)
		let comps = matchlist(a:str, pattern)
		if get(comps, 3, '') != ''
			return todo#date#new(comps[1], comps[2], comps[3])
		endif
	endfor

	return s:empty_date
endfunction

let s:weekday_patterns = {
			\ 	'sat\(\urday\)\?': 0,
			\ 	'sun\(day\)\?': 1,
			\ 	'mon\(day\)\?': 2,
			\ 	'tue\(sday\)\?': 3,
			\ 	'wed\(nesday\)\?': 4,
			\ 	'thu\(rsday\)\?': 5,
			\ 	'fri\(day\)\?': 6,
			\ }
function! s:parse_weekday(str)
	let target_weekday = -1
	for pattern in keys(s:weekday_patterns)
		if match(a:str, pattern) >= 0
			let target_weekday = s:weekday_patterns[pattern]
			break
		endif
	endfor
	if target_weekday < 0
		return todo#date#empty()
	endif

	let today = todo#date#today()
	let weekday = todo#date#weekday(today)
	let offset = target_weekday - weekday
	if offset < 0
		let offset += 7
	endif

	return todo#date#offset(today, 0, 0, offset)
endfunction

let s:date_parsers = [
			\ 	function('s:parse_special_name'),
			\ 	function('s:parse_yyyymmdd'),
			\ 	function('s:parse_weekday'),
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


" Calculate {{{
function! s:is_intercalary(year)
	if a:year % 4 == 0
		if a:year % 100 == 0
			return a:year % 400 == 0
		else
			return 1
		endif
	else
		return 0
	endif
endfunction

function! s:days(year, month)
	let offset = [1, -2, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1]
	let offset[1] += s:is_intercalary(a:year) ? +1 : 0

	return 30 + offset[a:month - 1]
endfunction

function! todo#date#offset(date, dyear, dmonth, dday)
	let date = copy(a:date)
	let date.year += a:dyear
	let date.month += a:dmonth
	let date.day += a:dday

	let date = s:normalize_month(date)
	if empty(date)
		return date
	endif

	while date.day <= 0
		let date.month -= 1
		let date = s:normalize_month(date)
		let date.day += s:days(date.year, date.month)
	endwhile

	let days = s:days(date.year, date.month)
	while date.day > days
		let date.day -= days
		let date.month += 1
		let date = s:normalize_month(date)
		let days = s:days(date.year, date.month)
	endwhile

	return date
endfunction

function! s:normalize_month(date)
	let date = copy(a:date)

	while date.month < 0
		let date.month += 12
		let date.year -= 1

		if date.year < 0
			return todo#date#empty
		endif
	endwhile

	while date.month > 12
		let date.month -= 12
		let date.year += 1

		if date.year > 9999
			return todo#date#empty
		endif
	endwhile

	return date
endfunction
" }}}


" Weekday {{{
function! todo#date#weekday(date)
	let year = a:date.year
	let m = a:date.month
	if m < 3
		let m += 12
		let year -= 1
	endif
	let y1 = year / 100
	let y2 = year % 100
	let d = a:date.day

	return (d + ((m + 1) * 26 / 10) + y2 + (y2 / 4) + (y1 / 4) + 5 * y1) % 7
endfunction
" }}}


let &cpo = s:save_cpo


 " vim: set foldmethod=marker:
