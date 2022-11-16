" vim: foldmethod=marker
"
" BufSelect - a Vim buffer selection and deletion utility

function! bufselect#RefreshBufferList(currentLine)   " {{{1
    if exists('s:bufSelectWindow')
        return
    endif

    call s:DisplayBuffers()
    call s:SortBufferList()
    call s:SetPosition(a:currentLine)
    call s:SetupCommands()
endfunction

function! s:ExitBufSelect()   "{{{1
    call nvim_win_hide(s:bufSelectWindow)
    unlet! s:bufSelectWindow
endfunction

function! s:SwitchBuffers(buffer, windowCmd)   " {{{1
    call s:ExitBufSelect()
    if bufexists(a:buffer)
        execute a:windowCmd . a:buffer
    endif
endfunction

function! s:GetBufferList()   " {{{1
    let bufferList = filter(split(execute('buffers'),'\n'), {_,v -> v !~? '\(Location\|Quickfix\) List'})
    let Parse = {t -> matchlist(t, '^\s*\zs\(\d\+\)\(.\{-}\)"\(.*\)"')}
    call map(bufferList, {_,v -> {'bufNr':Parse(v)[1], 'bufAttr':Parse(v)[2], 'bufName':Parse(v)[3]}})
    call map(bufferList, {_,v -> extend(v, {'onDisk':filereadable(fnamemodify(v.bufName,':p')),
                                          \ 'path':fnamemodify(v.bufName,':.:h'),
                                          \ 'filename':fnamemodify(v.bufName,':t:r'),
                                          \ 'extension':fnamemodify(v.bufName,':t:e')}, 'force')})
    let filenameWidth = max(map(copy(bufferList), {_,v -> strchars(v.filename)}))
    let extensionWidth = max(map(copy(bufferList), {_,v -> strchars(v.extension)}))
    let s:filenameColumn = 13
    let s:extensionColumn = s:filenameColumn + filenameWidth + 2
    let s:pathColumn = s:extensionColumn + extensionWidth + 2

    return map(bufferList, {_,v -> v.onDisk ?
                \ printf('%5d:%s%-*s  %-*s  %s', v.bufNr, v.bufAttr, filenameWidth, v.filename, extensionWidth, v.extension, v.path) :
                \ printf('%5d:%s%s', v.bufNr, v.bufAttr, v.bufName)})
endfunction

function! s:OpenBufSelectWindow(width, height)   " {{{1
    let hostWidth = nvim_win_get_width(0)
    let hostHeight = nvim_win_get_height(0)
    let config = {'relative':'win', 'row':(hostHeight-a:height)/2, 'col':(hostWidth-a:width)/2,
                \ 'height':a:height, 'width':a:width,
                \ 'border':'double', 'noautocmd':1, 'style':'minimal'}
    let s:bufSelectWindow = nvim_open_win(nvim_create_buf(0,1),1,config)
    setlocal syntax=bufselect nowrap bufhidden=wipe cursorline
    let s:bufnrSearch = 0
endfunction

function! s:DisplayBuffers()   " {{{1
    let bufferList = s:GetBufferList()
    let width = max(map(bufferList+[s:Footer()[1]],{_,l -> strchars(l)}))+1
    let height = len(bufferList)+2
    call s:OpenBufSelectWindow(width, height)
    setlocal modifiable
    %delete _
    call setline(1, bufferList)
    call append(line('$'), s:Footer())
    call nvim_win_set_width(s:bufSelectWindow, width)
    call nvim_win_set_height(s:bufSelectWindow, height)
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

function! s:Footer()   " {{{1
    return [ printf('%s▔▔▔%s▔▔▔%s▔▔%s▔▔%s',
                \ repeat(g:BufSelectSortOrder == "Num"       ? '▀' : '▔', 5),
                \ repeat(g:BufSelectSortOrder == "Status"    ? '▀' : '▔', 1),
                \ repeat(g:BufSelectSortOrder == "Name"      ? '▀' : '▔', s:extensionColumn - s:filenameColumn - 2),
                \ repeat(g:BufSelectSortOrder == "Extension" ? '▀' : '▔', s:pathColumn - s:extensionColumn - 2),
                \ repeat(g:BufSelectSortOrder == "Path"      ? '▀' : '▔', 300)),
           \ printf('Sort: %-9s  CWD: %s', g:BufSelectSortOrder, fnamemodify(getcwd(),':~')) ]
endfunction

function! s:UpdateFooter()   " {{{1
    setlocal modifiable
    call setline(line('$')-1, s:Footer()[0])
    call setline(line('$'), s:Footer()[1])
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
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyOpen." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'buffer')\<CR>"
    execute "nnoremap <buffer> <silent> <CR> :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'buffer')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeySplit." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'sbuffer')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyVSplit." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'vertical sbuffer')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyTab." :call <SID>SwitchBuffers(<SID>GetSelectedBuffer(), 'tab sbuffer')\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyDeleteBuffer." :call <SID>CloseBuffer()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeySort." :call <SID>ChangeSort()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyChDir." :call <SID>ChangeDir()\<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeyChDirUp." :call <SID>ChangeDirUp()<CR>"
    execute "nnoremap <buffer> <silent> ".g:BufSelectKeySelectOpen." :call <SID>SelectOpenBuffers()<CR>"

    for i in range(10)
        execute "nnoremap <buffer> <silent> ".i." :call <SID>SelectByNumber(".i.")<CR>"
    endfor
    nnoremap <buffer> <silent> ? :call <SID>ShowHelp()<CR>

    augroup BufSelectAuGroup
        autocmd!
        autocmd CursorMoved <buffer> if line('.') > line('$')-2 | execute "normal! ".(line('$')-2)."gg" | endif
        autocmd BufLeave <buffer> call s:ExitBufSelect()
    augroup END
endfunction

function! s:GetSelectedBuffer()   " {{{1
    let lineOfText = getline(line('.'))
    let bufNum = matchstr(lineOfText, '^\s*\zs\d\+\ze:')
    return str2nr(bufNum)
endfunction

function! s:CloseBuffer()   " {{{1
    let selected = s:GetSelectedBuffer()
    let currentLine = line('.')
    call s:ExitBufSelect()
    execute 'bwipeout ' . selected
    call bufselect#RefreshBufferList(currentLine)
endfunction

function! s:ChangeSort()   " {{{1
    let sortOptions = ["Num", "Status", "Name", "Extension", "Path"]
    let g:BufSelectSortOrder = sortOptions[(index(sortOptions, g:BufSelectSortOrder) + 1) % len(sortOptions)]
    let currBuffer = s:GetSelectedBuffer()
    call s:SortBufferList()
    call s:UpdateFooter()
    call s:SetPosition(search('^\s*'.currBuffer.':', 'w'))
endfunction

function! s:ChangeDir()   " {{{1
    let currBuffer = s:GetSelectedBuffer()
    execute 'cd '.fnamemodify(bufname(currBuffer), ':p:h')
    let currentLine = line('.')
    call s:ExitBufSelect()
    call bufselect#RefreshBufferList(currentLine)
endfunction

function! s:ChangeDirUp()   " {{{1
    let currentLine = line('.')
    call s:ExitBufSelect()
    cd ..
    call bufselect#RefreshBufferList(currentLine)
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
    let helpText = [
                \ [g:BufSelectKeyOpen        , "Open the selected buffer in the current window."],
                \ [g:BufSelectKeySplit       , "Split the window horizontally, and open the selected buffer in the new window."],
                \ [g:BufSelectKeyVSplit      , "Split the window vertically, and open the selected buffer in the new window."],
                \ [g:BufSelectKeyTab         , "Open the selected buffer in a new tab."],
                \ [g:BufSelectKeyDeleteBuffer, "Close the selected buffer using vim's :bwipeout command."],
                \ [g:BufSelectKeySort        , "Change the sort order: Number, Status, Name, Extension, or Path."],
                \ [g:BufSelectKeyChDir       , "Change working directory to match the selected buffer's"],
                \ [g:BufSelectKeyChDirUp     , "Change working directory up one level from current"],
                \ [g:BufSelectKeySelectOpen  , "Move cursor to the next open buffer, those marked with h or a."],
                \ ["0-9"                     , "Move cursor to the next buffer matching the cumulatively-typed buffer number."],
                \ [g:BufSelectKeyExit        , "Exit the buffer list."]
               \ ]
    for key in helpText
        echohl Identifier
        echon printf("%3s", key[0])
        echohl Normal
        echon "  ".key[1]
        echo ""
    endfor
    echohl None
endfunction
