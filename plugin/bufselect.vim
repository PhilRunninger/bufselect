command! ShowBufferList :call ShowBufferList()

function! ShowBufferList()
    let s:originalBuffer = bufnr('%')
    call RefreshBufferList()
endfunction

function! RefreshBufferList()
    let old_ei = &eventignore
    set eventignore=all
    if bufexists(s:originalBuffer)
        execute 'keepalt buffer ' . s:originalBuffer
    endif
    let &eventignore = old_ei
    redir => tmpBuffers
    silent buffers
    redir END

    let bufferList = []
    let tmpBuffers = split(tmpBuffers, '\n')
    call filter(tmpBuffers, 'v:val !~ "\\(Location\\|Quickfix\\) List"')
    let maxLength = max(map(copy(tmpBuffers), 'strlen(fnamemodify(matchstr(v:val, "\"\\zs.*\\ze\""), ":t"))'))
    for buf in tmpBuffers
        let bufferName = matchstr(buf, '"\zs.*\ze"')
        if filereadable(fnamemodify(bufferName, ':p'))
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
    call append(line('$'), [repeat('=', 7+strlen(getcwd())), 'CWD: ' . getcwd()])
    setlocal nomodifiable
    call setpos('.', [s:bufferListNumber, 1, 1, 0])
    call setpos('.', [s:bufferListNumber, match(bufferList, '^\s*\d*:\s*%')+1, 1, 0])

    syntax match TypeDef /^CWD: .*/hs=s+5
    syntax match Tag /^=\+$/
    syntax match Identifier /^\s*\d\+: %.*/
    syntax match Label /^\s*\d\+: #.*/

    nnoremap <buffer> <silent> x :call CloseBuffer()<CR>
    nnoremap <buffer> <silent> <Esc> :call ExitBufferList()<CR>
    nnoremap <buffer> <silent> h :call ExitBufferList()<CR>
    nnoremap <buffer> <silent> l :call OpenBuffer(GetSelectedBuffer())<CR>
    nnoremap <buffer> <silent> <Enter> :call OpenBuffer(GetSelectedBuffer())<CR>
    nnoremap <buffer> <silent> s :call SplitOpenBuffer('s', GetSelectedBuffer())<CR>
    nnoremap <buffer> <silent> v :call SplitOpenBuffer('v', GetSelectedBuffer())<CR>
    nnoremap <buffer> <silent> ? :call ShowHelp()<CR>

    augroup BufferListForbiddenLines
        autocmd!
        autocmd CursorMoved -=\[Buffers\]=- if line('.') > line('$')-2 | call setpos('.', [s:bufferListNumber, line('$')-2, col('.'), 0]) | endif
    augroup END
endfunction

function! GetSelectedBuffer()
    let lineOfText = getline(line('.'))
    let bufNum = matchstr(lineOfText, '^\s*\zs\d\+\ze:')
    return str2nr(bufNum)
endfunction

function! CloseBuffer()
    execute 'bwipeout ' . GetSelectedBuffer()
    call RefreshBufferList()
endfunction

function! ExitBufferList()
    call OpenBuffer(s:originalBuffer)
endfunction

function! OpenBuffer(bufNum)
    call SwitchBuffer(a:bufNum)
    call SetAlternate(s:originalBuffer)
endfunction

function! SplitOpenBuffer(windowCmd, bufNum)
    execute 'wincmd ' . a:windowCmd
    call SwitchBuffer(a:bufNum)
    execute 'wincmd p'
    call SwitchBuffer(s:originalBuffer)
    call SetAlternate(s:originalBuffer)
    execute 'wincmd p'
endfunction

function! SwitchBuffer(bufNum)
    if bufexists(a:bufNum)
        execute 'keepalt buffer ' . a:bufNum
    else
        execute 'bprevious'
    endif
endfunction

function! SetAlternate(bufNum)
    execute 'bwipeout ' . s:bufferListNumber
    if a:bufNum != s:originalBuffer && bufexists(a:bufNum)
        let @# = bufname(a:bufNum)
    endif
endfunction

function! ShowHelp()
    echohl Special
    echomsg "j,k:Navigate   h,Esc:Exit   l,Enter:Open   s:Split-Open   v:VSplit-Open   x:Delete Buffer"
    echohl None
endfunction
