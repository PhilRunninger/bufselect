" vim: foldmethod=marker

function! s:InitVar(name, value)   " {{{1
    if !exists(a:name)
        execute "let ".a:name."='".a:value."'"
    endif
endfunction

call s:InitVar("g:BufSelectExit", "q")
call s:InitVar("g:BufSelectOpen", "o")
call s:InitVar("g:BufSelectSplit", "s")
call s:InitVar("g:BufSelectVSplit", "v")
call s:InitVar("g:BufSelectDeleteBuffer", "x")
call s:InitVar("g:BufSelectSort", "S")
call s:InitVar("g:BufSelectSortOrder", "Name")
let s:sortOptions = ["Num", "Name", "Path"]

command! ShowBufferList :call <SID>ShowBufferList()   " {{{1

function! s:ShowBufferList()
    let s:currBuffer = bufnr('%')
    let s:prevBuffer = bufnr('#')
    call s:RefreshBufferList(-1)
endfunction

function! s:RefreshBufferList(currentLine)   " {{{1
    call s:SwitchBuffers(-1, '')
    call s:CollectBufferNames()
    call s:DisplayBuffers()
    call s:SortBufferList()
    call s:SetPosition(a:currentLine)
    call s:SetupHighlighting()
    call s:SetupCommands()
endfunction

function! s:SwitchBuffer(buffer, windowCmd)   " {{{1
    if a:windowCmd != ''
        execute "wincmd ".a:windowCmd
    endif
    if bufexists(a:buffer)
        execute 'buffer ' . a:buffer
    endif
endfunction

function! s:SwitchBuffers(nextBuffer, windowCmd)
    " Switch to the prev, curr, and next buffer in that order (if they exist)
    " to preserve or recalculate the # and % buffers.
    let old_ei = &eventignore
    set eventignore=all
    call s:SwitchBuffer(s:prevBuffer, '')
    if s:currBuffer != a:nextBuffer | call s:SwitchBuffer(s:currBuffer, '') | endif
    let &eventignore = old_ei
    call s:SwitchBuffer(a:nextBuffer, a:windowCmd)
endfunction

function! s:CollectBufferNames()   " {{{1
    redir => l:tmpBuffers
    silent buffers
    redir END
    let s:bufferList = []
    let l:tmpBuffers = split(l:tmpBuffers, '\n')
    " call filter(l:tmpBuffers, 'v:val !~? "\\(Location\\|Quickfix\\) List"')
    let l:filenameMaxLength = max(map(copy(l:tmpBuffers), 'strlen(fnamemodify(matchstr(v:val, "\"\\zs.*\\ze\""), ":t"))'))
    let s:filenameColumn = match(l:tmpBuffers[0], '"')
    let s:pathColumn = s:filenameColumn + l:filenameMaxLength + 2
    for buf in l:tmpBuffers
        let bufferName = matchstr(buf, '"\zs.*\ze"')
        if filereadable(fnamemodify(bufferName, ':p'))
            " Parse the bufferName into filename and path.
            let bufferName = printf( '%-' . (l:filenameMaxLength+2) . 's%s',
                                   \ fnamemodify(bufferName, ':t'),
                                   \ escape(fnamemodify(bufferName, ':h'), '\') )
        endif
        let buf = substitute(buf, '^\(\s*\d\+\)', '\1:', "")  " Put colon after buffer number.
        let buf = substitute(buf, '".*', bufferName, "")      " Replace quoted buffer name with parsed or unquoted buffer
        call add(s:bufferList, buf)
    endfor
endfunction

function! s:SortBufferList()
    setlocal modifiable
    execute '1,$-2sort'
    if g:BufSelectSortOrder == "Name" || g:BufSelectSortOrder == "Path"
        execute '1,$-2sort /^' . repeat('.', s:filenameColumn-1) . '/'
    endif
    if g:BufSelectSortOrder == "Path"
        execute '1,$-2sort /^' . repeat('.', s:pathColumn-1) . '/'
    endif
    setlocal nomodifiable
endfunction

function! s:DisplayBuffers()   " {{{1
    let s:bufferListNumber = bufnr('-=[Buffers]=-', 1)
    execute 'silent buffer ' . s:bufferListNumber
    setlocal buftype=nofile noswapfile nonumber nowrap cursorline statusline=[Buffer\ List]
    setlocal modifiable
    execute '%delete'
    call setline(1, s:bufferList)
    call append(line('$'), [repeat('-',120), 'CWD: ' . getcwd()])
    call s:UpdateFooter()
    setlocal nomodifiable
endfunction

function! s:SetPosition(currentLine)   " {{{1
    call setpos('.', [s:bufferListNumber, 1, 1, 0])
    if a:currentLine != -1
        call setpos('.', [s:bufferListNumber, a:currentLine, 1, 0])
    elseif match(s:bufferList, '^\s*\d*:\s*%') > -1
        call setpos('.', [s:bufferListNumber, match(s:bufferList, '^\s*\d*:\s*%')+1, 1, 0])
    else
        call setpos('.', [s:bufferListNumber, match(s:bufferList, '^\s*\d*:\s*#')+1, 1, 0])
    endif
endfunction

function! s:UpdateFooter()
    let l:line = repeat(g:BufSelectSortOrder == "Num" ? '=' : '-', s:filenameColumn).
               \ repeat(g:BufSelectSortOrder == "Name" ? '=' : '-', s:pathColumn - s:filenameColumn).
               \ repeat(g:BufSelectSortOrder == "Path" ? '=' : '-', 120 - s:pathColumn)
    setlocal modifiable
    call setline(line('$')-1, l:line)
    setlocal nomodifiable
endfunction

function! s:SetupHighlighting()   " {{{1
    syntax match TypeDef /^CWD: .*/hs=s+5
    syntax match CurrentSort /=\+/
    syntax match Tag /^[-=]\+$/ contains=CurrentSort
    syntax match Identifier /^\s*\d\+: %.*/
    syntax match Label /^\s*\d\+: #.*/
    highlight link CurrentSort Function
endfunction

function! s:SetupCommands()   " {{{1
    execute "nnoremap <buffer> <silent> ".g:BufSelectDeleteBuffer." :call <SID>CloseBuffer()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectExit." :call <SID>SwitchBuffers(-1, '')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectOpen." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), '')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectSplit." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 's')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectVSplit." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'v')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectSort." :call <SID>ChangeSort()\<CR>"
    nnoremap <buffer> <silent> ? :call <SID>ShowHelp()<CR>

    augroup BufferListForbiddenLines
        autocmd!
        autocmd CursorMoved -=\[Buffers\]=- if line('.') > line('$')-2 | call setpos('.', [s:bufferListNumber, line('$')-2, col('.'), 0]) | endif
    augroup END
endfunction

function! s:GetSelectedBuffer()   " {{{1
    let lineOfText = getline(line('.'))
    let bufNum = matchstr(lineOfText, '^\s*\zs\d\+\ze:')
    return str2nr(bufNum)
endfunction

function! s:CloseBuffer()   " {{{1
    execute 'bwipeout ' . s:GetSelectedBuffer()
    echomsg "line = ".line('.')
    call s:RefreshBufferList(line('.'))
endfunction

function! s:ChangeSort()
    let g:BufSelectSortOrder = s:sortOptions[(index(s:sortOptions, g:BufSelectSortOrder) + 1) % len(s:sortOptions)]
    call s:SortBufferList()
    call s:UpdateFooter()
endfunction

function! s:ShowHelp()   " {{{1
    echohl Special
    echomsg "j,k:Navigate   ".
          \ g:BufSelectExit.":Exit   ".
          \ g:BufSelectOpen.":Open   ".
          \ g:BufSelectSplit.":Split-Open   ".
          \ g:BufSelectVSplit.":VSplit-Open   ".
          \ g:BufSelectDeleteBuffer.":Delete Buffer   ".
          \ g:BufSelectSort.":Sort"
    echohl None
endfunction
