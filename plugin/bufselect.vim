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
let s:bufferName = '=Buffers='

command! ShowBufferList :call <SID>ShowBufferList()   " {{{1

function! s:ShowBufferList()
    if bufname('%') ==# s:bufferName
        return
    endif
    let s:bufnrSearch = 0
    call s:OpenBufSelectWindow()
    call s:RefreshBufferList(-1)
endfunction

function! s:OpenBufSelectWindow()   " {{{1
    let bufferListNumber = nvim_create_buf(0,1)
    call nvim_buf_set_name(bufferListNumber, s:bufferName)
    let s:bufferWin = nvim_open_win(bufferListNumber,1,{'relative':'cursor','width':80,'height':3,'row':1,'col':0,'border':'rounded','noautocmd':1,'style':'minimal'})
    setlocal syntax=bufselect nowrap bufhidden=wipe
endfunction

function! s:ExitBufSelect()   "{{{1
    call nvim_win_hide(s:bufferWin)
endfunction

function! s:RefreshBufferList(currentLine)   " {{{1
    call s:FormatBufferNames()
    call s:DisplayBuffers()
    call s:SortBufferList()
    call s:SetPosition(a:currentLine)
    call s:SetupCommands()
endfunction

function! s:SwitchBuffers(buffer, windowCmd)   " {{{1
    call s:ExitBufSelect()
    execute a:windowCmd
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
            call add(l:filenames, strcharpart(buf,0, strchars(buf)-strchars(parts[-1])-1))
            call add(l:extensions, parts[-1])
        endif
    endfor
    let l:filenameMaxLength = max(map(copy(l:filenames), {_,v -> strlen(v)}))
    let l:extensionMaxLength = max(map(copy(l:extensions), {_,v -> strlen(v)}))

    let s:filenameColumn = 12
    let s:extensionColumn = s:filenameColumn + l:filenameMaxLength + 1
    let s:pathColumn = s:extensionColumn + l:extensionMaxLength + 1
    let s:bufferList = []
    for i in range(len(l:filenames))
        let buf = l:tmpBuffers[i]
        let bufferName = matchstr(buf, '"\zs.*\ze"')
        if filereadable(fnamemodify(bufferName, ':p'))
            let bufferName = printf( '%-' . (l:filenameMaxLength) . 's %-' . (l:extensionMaxLength) . 's %s',
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
    setlocal modifiable
    %delete _
    call setline(1, s:bufferList)
    call append(line('$'), ['', ''])
    call s:UpdateFooter()
    call nvim_win_set_width(s:bufferWin, max(map(getline(1,line('$')-2),{_,l -> strchars(l)}))+1)
    call nvim_win_set_height(s:bufferWin, line('$'))
    setlocal nomodifiable
endfunction

function! s:SortBufferList()   " {{{1
    setlocal modifiable
    1,$-2sort n
    if g:BufSelectSortOrder != "Num"
        execute '1,$-2sort /^.\{' . (s:filenameColumn-1) . '}/'
    endif
    if g:BufSelectSortOrder == "Status"
        execute '1,$-2sort! /^\s*\d\+:..\zs.\ze/ r'
    elseif g:BufSelectSortOrder == "Extension"
        execute '1,$-2sort /^.\{' . (s:extensionColumn-1) . '}/'
    elseif g:BufSelectSortOrder == "Path"
        execute '1,$-2sort /^.\{' . (s:pathColumn-1) . '}/'
    endif
    setlocal nomodifiable
endfunction

function! s:UpdateFooter()   " {{{1
    let l:line = (g:BufSelectSortOrder == "Num" ? '====---' : '-------').
               \ (g:BufSelectSortOrder == "Status" ? '=---' : '----').
               \ repeat(g:BufSelectSortOrder == "Name" ? '=' : '-', s:extensionColumn - s:filenameColumn - 1). '-'.
               \ repeat(g:BufSelectSortOrder == "Extension" ? '=' : '-', s:pathColumn - s:extensionColumn - 1). '-'.
               \ repeat(g:BufSelectSortOrder == "Path" ? '=' : '-', 300)
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
    execute "nnoremap <buffer> <silent> <CR> :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), '')\<CR>"
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
        autocmd CursorMoved <buffer> if line('.') > line('$')-2 | execute "normal! ".(line('$')-2)."gg" | endif
        autocmd WinLeave <buffer> call s:ExitBufSelect()
    augroup END
endfunction

function! s:GetSelectedBuffer()   " {{{1
    let lineOfText = getline(line('.'))
    let bufNum = matchstr(lineOfText, '^\s*\zs\d\+\ze:')
    return str2nr(bufNum)
endfunction

function! s:CloseBuffer()   " {{{1
    if len(s:CollectBufferNames()) == 1
        echo "Not gonna do it. The last buffer stays."
    else
        let selectedBuffer = s:GetSelectedBuffer()
        if empty(filter(nvim_tabpage_list_wins(0),{_,v -> v != s:bufferWin && nvim_win_get_buf(v) != selectedBuffer}))
            " The only non-floating window is the one whose buffer we're closing.
            " Close BufSelect first and let the tab die with the buffer.
            call s:ExitBufSelect()
            execute 'bwipeout ' . selectedBuffer
        else
            execute 'bwipeout ' . selectedBuffer
            call s:RefreshBufferList(line('.'))
        endif
    endif
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
    while !search('^\s*'.s:bufnrSearch.':', 'w') && s:bufnrSearch > 9
        let s:bufnrSearch = str2nr(s:bufnrSearch[1:])
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
