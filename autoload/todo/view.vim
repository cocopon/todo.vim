" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! todo#view#echoerr(message)
	echohl WarningMsg
	echo a:message
	echohl None
endfunction


let &cpo = s:save_cpo
