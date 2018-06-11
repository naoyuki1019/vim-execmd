# vim-execmd

":call execmd#Execute(...)" search file in the directory of the opened file and in every parent directory. and execute [!file.sh]


** search & execute [!file.sh] **

```
/dir/subdir/file.sh
/dir/file.sh
/file.sh
```

## How to use

```vim
:call execmd#Execute(...)
```

## Setting

### add (~/.vimrc)

#### example (command)

```vim
command! -nargs=* Execmd call execmd#Execute(<f-args>)
```

#### default

```vim
if has("win32") || has("win95") || has("win64") || has("win16")
  let g:exd_default = 'build.bat'
else
  let g:exd_default = 'build.sh'
endif
```

#### example (rst build)

```vim
if 1 == get(g:, 'enable_rstbuild', '0')

  if has("win32") || has("win95") || has("win64") || has("win16")
    let s:exd_rstbuild = 'make_html.bat'
  else
    let s:exd_rstbuild = 'make_html.sh'
  endif

  command! ExecmdRst call execmd#Execute(s:exd_rstbuild)

  " auto make_html
  augroup execmd_rst
    autocmd!
    autocmd BufWritePost *.rst call execmd#Execute(s:exd_rstbuild)
  augroup END

endif
```

