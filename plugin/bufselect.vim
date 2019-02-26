" vim: foldmethod=marker
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  BufSelect - a Vim buffer selection and deletion utility
"
"  Copyright 2018 Phil Runninger.
"
"  This program is free software; you can redistribute it and/or modify
"  it under the terms of the GNU General Public License as published by
"  the Free Software Foundation; either version 3 of the License, or
"  (at your option) any later version.
"
"  This program is distributed in the hope that it will be useful,
"  but WITHOUT ANY WARRANTY; without even the implied warranty of
"  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"  GNU General Public License <http://www.gnu.org/licenses/>
"  for more details."
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Default values for settings {{{1
let g:BufSelectKeyExit         = get(g:, 'BufSelectKeyExit',         'q')
let g:BufSelectKeyOpen         = get(g:, 'BufSelectKeyOpen',         'o')
let g:BufSelectKeySplit        = get(g:, 'BufSelectKeySplit',        's')
let g:BufSelectKeyVSplit       = get(g:, 'BufSelectKeyVSplit',       'v')
let g:BufSelectKeyDeleteBuffer = get(g:, 'BufSelectKeyDeleteBuffer', 'x')
let g:BufSelectKeySort         = get(g:, 'BufSelectKeySort',         'S')
let g:BufSelectSortOrder       = get(g:, 'BufSelectSortOrder',    'Name')
let g:BufSelectChDir           = get(g:, 'BufSelectChDir',          'cd')
let g:BufSelectChDirUp         = get(g:, 'BufSelectChDirUp',        '..')
let s:sortOptions = ["Num", "Name", "Path"]

command! ShowBufferList :call <SID>ShowBufferList()   " {{{1

function! s:ShowBufferList()
    let s:currBuffer = bufnr('%')
    let s:prevBuffer = bufnr('#')
    call s:RefreshBufferList(-1)
endfunction

function! s:RefreshBufferList(currentLine)   " {{{1
    call s:SwitchBuffers(-1, '')
    call s:FormatBufferNames()
    call s:DisplayBuffers()
    call s:SortBufferList()
    call s:SetPosition(a:currentLine)
    call s:SetupCommands()
endfunction

function! s:SwitchBuffers(nextBuffer, windowCmd)   " {{{1
    " Switch to the prev, curr, and next buffer in that order (if they exist)
    " to preserve or recalculate the # and % buffers.
    let old_ei = &eventignore
    set eventignore=all

    call s:SwitchBuffer(s:prevBuffer)

    if s:currBuffer != a:nextBuffer
        call s:SwitchBuffer(s:currBuffer)
    endif

    let &eventignore = old_ei
    execute a:windowCmd
    call s:SwitchBuffer(a:nextBuffer)
endfunction

function! s:SwitchBuffer(buffer)
    if bufexists(a:buffer)
        execute 'buffer ' . a:buffer
    endif
endfunction

function! s:CollectBufferNames()   " {{{1
    let l:tmpBuffers = split(execute('buffers'), '\n')
    return filter(l:tmpBuffers, 'v:val !~? "\\(Location\\|Quickfix\\) List"')
endfunction

function! s:FormatBufferNames()   " {{{1
    let l:tmpBuffers = s:CollectBufferNames()
    let l:filenameMaxLength = max(map(copy(l:tmpBuffers), 'strlen(fnamemodify(matchstr(v:val, "\"\\zs.*\\ze\""), ":t"))'))
    let s:filenameColumn = match(l:tmpBuffers[0], '"')
    let s:pathColumn = s:filenameColumn + l:filenameMaxLength + 2
    let s:bufferList = []
    for buf in l:tmpBuffers
        let bufferName = matchstr(buf, '"\zs.*\ze"')
        if filereadable(fnamemodify(bufferName, ':p'))
            " Parse the bufferName into filename and path.
            let bufferName = printf( '%-' . (l:filenameMaxLength) . 's  %s',
                                   \ fnamemodify(bufferName, ':t'),
                                   \ escape(fnamemodify(bufferName, ':h'), '\') )
        endif
        let buf = substitute(buf, '^\(\s*\d\+\)', '\1:', "")  " Put colon after buffer number.
        let buf = substitute(buf, '".*', bufferName, "")      " Replace quoted buffer name with parsed or unquoted buffer
        call add(s:bufferList, buf)
    endfor
endfunction

function! s:DisplayBuffers()   " {{{1
    let s:bufferListNumber = bufnr('-=[Buffers]=-', 1)
    execute 'silent buffer ' . s:bufferListNumber
    setlocal buftype=nofile noswapfile nonumber nowrap cursorline statusline=[Buffer\ List] syntax=bufselect
    setlocal modifiable
    %delete _
    call setline(1, s:bufferList)
    call append(line('$'), [repeat('-',100), 'CWD: ' . getcwd()])
    call s:UpdateFooter()
    setlocal nomodifiable
endfunction

function! s:SortBufferList()   " {{{1
    setlocal modifiable
    1,$-2sort
    if g:BufSelectSortOrder == "Name" || g:BufSelectSortOrder == "Path"
        execute '1,$-2sort /^' . repeat('.', s:filenameColumn-1) . '/'
    endif
    if g:BufSelectSortOrder == "Path"
        execute '1,$-2sort /^' . repeat('.', s:pathColumn-1) . '/'
    endif
    setlocal nomodifiable
endfunction

function! s:UpdateFooter()   " {{{1
    let l:line = repeat(g:BufSelectSortOrder == "Num" ? '=' : '-', s:filenameColumn).
               \ repeat(g:BufSelectSortOrder == "Name" ? '=' : '-', s:pathColumn - s:filenameColumn).
               \ repeat(g:BufSelectSortOrder == "Path" ? '=' : '-', 100 - s:pathColumn)
    setlocal modifiable
    call setline(line('$')-1, l:line)
    setlocal nomodifiable
endfunction

function! s:SetPosition(currentLine)   " {{{1
    normal! gg0
    if a:currentLine != -1
        execute 'normal! '.a:currentLine.'gg0'
    elseif search('^\s*\d\+:\s*%', 'w') == 0
        call search('^\s*\d\+:\s*#', 'w')
    endif
endfunction

function! s:SetupCommands()   " {{{1
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyDeleteBuffer." :call <SID>CloseBuffer()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyExit." :call <SID>ExitBufSelect()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyOpen." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), '')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeySplit." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'wincmd s')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyVSplit." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'wincmd v')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeySort." :call <SID>ChangeSort()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectChDir." :call <SID>ChangeDir()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectChDirUp." :call <SID>ChangeDirUp()<CR>"
    nnoremap <buffer> <silent> ? :call <SID>ShowHelp()<CR>

    augroup BufSelectLinesBoundary
        autocmd!
        autocmd CursorMoved -=\[Buffers\]=- if line('.') > line('$')-2 | normal! G2k0 | endif
    augroup END
endfunction

function! s:GetSelectedBuffer()   " {{{1
    let lineOfText = getline(line('.'))
    let bufNum = matchstr(lineOfText, '^\s*\zs\d\+\ze:')
    return str2nr(bufNum)
endfunction

function! s:CloseBuffer()   " {{{1
    if len(s:CollectBufferNames()) == 1
        echomsg "Not gonna do it. The last buffer stays."
    else
        execute 'bwipeout ' . s:GetSelectedBuffer()
        call s:RefreshBufferList(line('.'))
    endif
endfunction

function! s:ExitBufSelect()   "{{{1
    if !bufexists(s:prevBuffer) && !bufexists(s:currBuffer)
        let s:currBuffer = s:GetSelectedBuffer()
    endif
    call s:SwitchBuffers(-1, '')
endfunction

function! s:ChangeSort()   " {{{1
    let g:BufSelectSortOrder = s:sortOptions[(index(s:sortOptions, g:BufSelectSortOrder) + 1) % len(s:sortOptions)]
    let l:currBuffer = s:GetSelectedBuffer()
    call s:SortBufferList()
    call s:UpdateFooter()
    call s:SetPosition(search('^\s*'.l:currBuffer.':', 'w'))
endfunction

function! s:ChangeDir()   " {{{1
    let l:currBuffer = s:GetSelectedBuffer()
    execute 'cd '.fnamemodify(bufname(l:currBuffer), ':p:h')
    call s:RefreshBufferList(line('.'))
endfunction

function! s:ChangeDirUp()   " {{{1
    cd ..
    call s:RefreshBufferList(line('.'))
endfunction

function! s:ShowHelp()   " {{{1
    echohl Special
    echomsg g:BufSelectKeyOpen.":Open   ".
          \ g:BufSelectKeySplit.":Split-Open   ".
          \ g:BufSelectKeyVSplit.":VSplit-Open   ".
          \ g:BufSelectKeyDeleteBuffer.":Delete Buffer   ".
          \ g:BufSelectKeySort.":Sort   ".
          \ g:BufSelectChDir.":CD to folder   ".
          \ g:BufSelectChDirUp.":CD up once   ".
          \ g:BufSelectKeyExit.":Exit"
    echohl None
endfunction
