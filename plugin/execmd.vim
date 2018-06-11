scriptencoding utf-8
"/**
" * @file execmd.vim
" * @author naoyuki onishi <naoyuki1019 at gmail.com>
" * @version 1.0
" */

if exists("g:loaded_execmd")
  finish
endif
let g:loaded_execmd = 1

let s:save_cpo = &cpo
set cpo&vim


if has("win32") || has("win95") || has("win64") || has("win16")
  let s:is_win = 1
  let s:ds = '\'
else
  let s:is_win = 0
  let s:ds = '/'
endif

"cmdfile ***.sh ***.bat
if !exists('g:exd_default')
  if 1 == s:is_win
    let g:exd_default = 'build.bat'
  else
    let g:exd_default = 'build.sh'
  endif
endif

let s:find_cmdfile = 0

" debug
let s:script_name = expand('<sfile>:t')
let s:debuglogfile = '~/.vim/debug-'.substitute(s:script_name, '\.vim', '', '').'.log'
if !exists('g:exd_debug')
  let s:debug = 0
else
  let s:debug = g:exd_debug
endif

function! s:search_cmdfile(dir, cmdfile)
  let l:dir = a:dir

  if 1 == s:is_win
    if 3 == strlen(l:dir)
      let l:dir = l:dir[0:1]
    endif
  else
  endif

  let l:cmdfile_path = fnamemodify(l:dir.s:ds.a:cmdfile, ':p')

  if filereadable(l:cmdfile_path)
    let s:find_cmdfile = 1
    call s:exec_command(l:dir.s:ds, a:cmdfile)
  endif

  if 1 == s:is_win
    if 2 == strlen(l:dir)
      return
    endif
  else
    if '/' == l:dir
      return
    endif
  endif

  let l:dir = fnamemodify(l:dir.s:ds.'..'.s:ds, ':p:h')

  " Network file
  if l:dir == a:dir
    return
  endif

  " 念のため
  if 1 == s:is_win
    let l:match = matchstr(l:dir, '\V..\\..\\')
  else
    let l:match = matchstr(l:dir, '\V../../')
  endif
  if '' != l:match
    return
  endif

  return s:search_cmdfile(l:dir, a:cmdfile)

endfunction

function! execmd#Execute(...)

  if 1 > a:0
    let l:cmdfile = g:exd_default
  else
    let l:cmdfile = a:000[0]
  endif

  let l:dir = expand('%:p:h')

  if 1 == s:is_remote(l:dir)
    return
  endif

  let s:find_cmdfile = 0
  call s:search_cmdfile(l:dir, l:cmdfile)

  if 0 == s:find_cmdfile
    call confirm('note: not found ['.l:cmdfile.']')
  endif

endfunction

function! s:exec_command(dir, cmdfile)

  let l:cmdfile_path = fnamemodify(a:dir.a:cmdfile, ':p')

  if 1 == s:is_win
    let l:drive = a:dir[:stridx(a:dir, ':')]
    let l:execute = '!'.l:drive.' & cd '.shellescape(a:dir).' & '.shellescape(l:cmdfile_path)
  else
    let l:execute = '!cd '.shellescape(a:dir).'; '.shellescape(l:cmdfile_path)
  endif

  silent execute l:execute

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

function! s:is_remote(path)
  let l:pt = '\v(ftp:\/\/.*|rcp:\/\/.*|ssh:\/\/.*|scp:\/\/.*|http:\/\/.*|file:\/\/.*|https:\/\/.*|dav:\/\/.*|davs:\/\/.*|rsync:\/\/.*|sftp:\/\/.*)'
  let l:match = matchstr(a:path, l:pt)
  if '' != l:match
    call s:debuglog('is_remote l:match', l:match)
    return 1
  else
    call s:debuglog('is_not_remote a:path', a:path)
    return 0
  endif
endfunction

function! s:debuglog(title, msg)
  if 1 != s:debug
    return
  endif
  silent execute ":redir! >> " . s:debuglogfile
  silent! echon strftime("%Y-%m-%d %H:%M:%S")
        \.' | '.a:title.':'.a:msg."\n"
  redir END
endfunction

