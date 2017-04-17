command! ShowBufferList :call ShowBufferList()

function! ShowBufferList()
    let s:originalBuffer = bufnr('%')
    call RefreshBufferList()
endfunction

function! RefreshBufferList()
    let old_ei = &eventignore
    set eventignore=all
    execute 'keepalt buffer ' . s:originalBuffer
    let &eventignore = old_ei
    redir => bufferList
    silent buffers
    redir END

    let bufferList = split(bufferList, '\n')
    let bufferList = map(bufferList, 'substitute(v:val, "\\s*line.*$", "", "")')
    let bufferList = map(bufferList, 'substitute(v:val, "\"", "", "g")')
    let bufferList = map(bufferList, 'substitute(v:val, "^\\(\\s*\\d*\\)", "\\1: ", "")')

    let s:bufferListNumber = bufnr('-=[Buffers]=-', 1)
    execute 'silent keepalt buffer ' . s:bufferListNumber
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nonumber
    setlocal cursorline
    setlocal statusline=[Buffer\ List]
    setlocal modifiable
    execute '%delete'
    call setline(1, bufferList)
    setlocal nomodifiable
    call setpos('.', [s:bufferListNumber, 1, 1, 0])
    call setpos('.', [s:bufferListNumber, match(bufferList, '^\s*\d*:\s*%')+1, 1, 0])

    nnoremap <buffer> d :call CloseBuffer()<CR>
    execute 'nnoremap <buffer> h :call OpenBuffer(' . s:originalBuffer . ')<CR>'
    nnoremap <buffer> l :call OpenBuffer(GetSelectedBuffer())<CR>
    nnoremap <buffer> ? :call ShowHelp()<CR>
endfunction

function! GetSelectedBuffer()
    let lineOfText = getline(line('.'))
    let bufNum = matchstr(lineOfText, '^\s*\zs\d\+\ze:')
    return bufNum
endfunction

function! CloseBuffer()
    execute 'bwipeout ' . GetSelectedBuffer()
    call RefreshBufferList()
endfunction

function! OpenBuffer(bufNum)
    execute 'keepalt buffer ' . a:bufNum
    execute 'bwipeout ' . s:bufferListNumber
    if a:bufNum != s:originalBuffer
        let @# = bufname(s:originalBuffer)
    endif
endfunction

function! ShowHelp()
    echohl Special
    echomsg "j,k:Navigate   h:Exit list   l:Open buffer   d:Close buffer"
    echohl None
endfunction
