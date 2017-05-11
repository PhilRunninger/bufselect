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
    redir => tmpBuffers
    silent buffers
    redir END

    let bufferList = []
    let tmpBuffers = split(tmpBuffers, '\n')
    let maxLength = max(map(copy(tmpBuffers), 'strlen(fnamemodify(matchstr(v:val, "\"\\zs.*\\ze\""), ":t"))'))
    for buf in tmpBuffers
        let bufferName = matchstr(buf, '"\zs.*\ze"')
        if filereadable(bufferName)
            let fileName = fnamemodify(bufferName, ':t')
            let replacement = fileName . repeat(' ', maxLength - strlen(fileName)) . '  ' . fnamemodify(bufferName, ':h')
        else
            let replacement = bufferName
        endif
        let buf = substitute(buf, '".*', replacement, "")
        call add(bufferList, substitute(buf, '^\(\s*\d\+\)', '\1:', ""))
    endfor

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
    echomsg "j,k:Navigate   h:Cancel   l:Open   d:Remove"
    echohl None
endfunction
