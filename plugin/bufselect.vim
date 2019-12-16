" vim: foldmethod=marker
"
" BufSelect - a Vim buffer selection and deletion utility

" Default values for settings {{{1
let g:BufSelectKeyExit         = get(g:, 'BufSelectKeyExit',         'q')
let g:BufSelectKeyOpen         = get(g:, 'BufSelectKeyOpen',         'o')
let g:BufSelectKeySplit        = get(g:, 'BufSelectKeySplit',        's')
let g:BufSelectKeyVSplit       = get(g:, 'BufSelectKeyVSplit',       'v')
let g:BufSelectKeyTab          = get(g:, 'BufSelectKeyTab',          't')
let g:BufSelectKeyDeleteBuffer = get(g:, 'BufSelectKeyDeleteBuffer', 'x')
let g:BufSelectKeySort         = get(g:, 'BufSelectKeySort',         'S')
let g:BufSelectSortOrder       = get(g:, 'BufSelectSortOrder',    'Name')
let g:BufSelectKeyChDir        = get(g:, 'BufSelectKeyChDir',       'cd')
let g:BufSelectKeyChDirUp      = get(g:, 'BufSelectKeyChDirUp',     '..')
let g:BufSelectKeySelectOpen   = get(g:, 'BufSelectKeySelectOpen',   '#')
let s:sortOptions = ["Num", "Status", "Name", "Extension", "Path"]

command! ShowBufferList :call <SID>ShowBufferList()   " {{{1

function! s:ShowBufferList()
    let s:bufnrSearch = 0
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
    let l:filenames = []
    let l:extensions = []
    for buf in l:tmpBuffers
        let buf = fnamemodify(matchstr(buf, '"\zs.*\ze"'), ':t')
        let parts = split(buf, '\.')
        if len(parts) == 1
            call add(l:filenames, buf)
            call add(l:extensions, '')
        else
            call add(l:filenames, buf[0:(-2-strlen(parts[-1]))])
            call add(l:extensions, parts[-1])
        endif
        let l:filenameMaxLength = max(map(copy(l:filenames), 'strlen(v:val)'))
        let l:extensionMaxLength = max(map(copy(l:extensions), 'strlen(v:val)'))
    endfor

    let s:filenameColumn = 12
    let s:extensionColumn = s:filenameColumn + l:filenameMaxLength + 2
    let s:pathColumn = s:extensionColumn + l:extensionMaxLength + 2
    let s:bufferList = []
    for i in range(len(l:filenames))
        let buf = l:tmpBuffers[i]
        let bufferName = matchstr(buf, '"\zs.*\ze"')
        if filereadable(fnamemodify(bufferName, ':p'))
            " Parse the bufferName into filename, extension, and path.
            let bufferName = printf( '%-' . (l:filenameMaxLength) . 's  %-' . (l:extensionMaxLength) . 's  %s',
                                   \ l:filenames[i],
                                   \ l:extensions[i],
                                   \ escape(fnamemodify(bufferName, ':.:h'), '\') )
        endif
        let buf = substitute(buf, '^\(\s*\d\+\)', '    \1:', "")  " Put spaces before, and a colon after, the buffer number.
        let buf = substitute(buf, '^\s*\(....\):', '\1:', "")     " Make buffer number column 4 digits.
        let buf = substitute(buf, '".*', bufferName, "")          " Replace quoted buffer name with parsed or unquoted buffer
        call add(s:bufferList, buf)
    endfor
endfunction

function! s:DisplayBuffers()   " {{{1
    let s:bufferListNumber = bufnr('=Buffers=', 1)
    execute 'silent buffer ' . s:bufferListNumber
    execute 'setlocal buftype=nofile noswapfile nonumber nowrap cursorline syntax=bufselect statusline='.escape("[Buffer List]  Press ? for key mappings.", " ")
    setlocal modifiable
    %delete _
    call setline(1, s:bufferList)
    call append(line('$'), ['', ''])
    call s:UpdateFooter()
    setlocal nomodifiable
endfunction

function! s:SortBufferList()   " {{{1
    setlocal modifiable
    1,$-2sort n
    if g:BufSelectSortOrder != "Num"
        execute '1,$-2sort /^' . repeat('.', s:filenameColumn-1) . '/'
    endif
    if g:BufSelectSortOrder == "Status"
        execute '1,$-2sort! /^\s*\d\+:..\zs.\ze/ r'
    elseif g:BufSelectSortOrder == "Extension"
        execute '1,$-2sort /^' . repeat('.', s:filenameColumn-1) . '.*\.\zs\S*\ze\s/ r'
    elseif g:BufSelectSortOrder == "Path"
        execute '1,$-2sort /^' . repeat('.', s:pathColumn-1) . '/'
    endif
    setlocal nomodifiable
endfunction

function! s:UpdateFooter()   " {{{1
    let l:line = (g:BufSelectSortOrder == "Num" ? '====---' : '-------').
               \ (g:BufSelectSortOrder == "Status" ? '=---' : '----').
               \ repeat(g:BufSelectSortOrder == "Name" ? '=' : '-', s:extensionColumn - s:filenameColumn - 2). '--'.
               \ repeat(g:BufSelectSortOrder == "Extension" ? '=' : '-', s:pathColumn - s:extensionColumn - 2). '--'.
               \ repeat(g:BufSelectSortOrder == "Path" ? '=' : '-', 100 - s:pathColumn)
    setlocal modifiable
    call setline(line('$')-1, l:line)
    call setline(line('$'), printf('Sort: %-9s  CWD: %s', g:BufSelectSortOrder, fnamemodify(getcwd(),':~')))
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
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyExit." :call <SID>ExitBufSelect()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyOpen." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), '')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeySplit." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'wincmd s')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyVSplit." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'wincmd v')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyTab." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'tabnew')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyDeleteBuffer." :call <SID>CloseBuffer()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeySort." :call <SID>ChangeSort()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyChDir." :call <SID>ChangeDir()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyChDirUp." :call <SID>ChangeDirUp()<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeySelectOpen." :call <SID>SelectOpenBuffers()<CR>"

    for l:i in range(10)
        execute "nnoremap <buffer> <silent> ".l:i." :call <SID>SelectByNumber(".l:i.")<CR>"
    endfor
    nnoremap <buffer> <silent> ? :call <SID>ShowHelp()<CR>

    augroup BufSelectLinesBoundary
        autocmd!
        autocmd CursorMoved =Buffers= if line('.') > line('$')-2 | execute "normal! ".(line('$')-2)."gg" | endif
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
    if !(bufexists(s:prevBuffer) && buflisted(s:prevBuffer)) &&
     \ !(bufexists(s:currBuffer) && buflisted(s:currBuffer))
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

function! s:SelectOpenBuffers()   " {{{1
    call search('^ *\d\+: [%# ][ha]', 'w')
endfunction

function! s:SelectByNumber(num)   " {{{1
    let s:bufnrSearch = 10*s:bufnrSearch + a:num
    while !search('^\s*'.s:bufnrSearch.':', 'w') && s:bufnrSearch > 0
        let s:bufnrSearch = s:bufnrSearch % float2nr(pow(10,floor(log10(s:bufnrSearch))))
    endwhile
endfunction

function! s:ShowHelp()   " {{{1
    let l:help = [
                \ [g:BufSelectKeyOpen        , "Open the selected buffer in the current window."],
                \ [g:BufSelectKeySplit       , "Split the window horizontally, and open the selected buffer there."],
                \ [g:BufSelectKeyVSplit      , "Split the window vertically, and open the selected buffer there."],
                \ [g:BufSelectKeyTab         , "Open the selected buffer in a new tab."],
                \ [g:BufSelectKeyDeleteBuffer, "Close the selected buffer using vim's :bwipeout command."],
                \ [g:BufSelectKeySort        , "Change the sort order, cycling between Number, Status, Name, Extension, and Path."],
                \ [g:BufSelectKeyChDir       , "Change the working directory to that of the selected buffer"],
                \ [g:BufSelectKeyChDirUp     , "Change the working directory up one level from current"],
                \ [g:BufSelectKeySelectOpen  , "Highlight (move cursor to) the next open buffer, those marked with h or a."],
                \ ["0-9"                     , "Highlight (move cursor to) the next buffer matching the cumulatively-typed buffer number."],
                \ [g:BufSelectKeyExit        , "Exit the buffer list."]
               \ ]
    for key in l:help
        echohl Identifier
        echon printf("%3s", key[0])
        echohl Normal
        echon "  ".key[1]
        echo ""
    endfor
    echohl None
endfunction
