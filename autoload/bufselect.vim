" vim: foldmethod=marker
"
" BufSelect - a Vim buffer selection and deletion utility

function! bufselect#RefreshBufferList(currentLine)   " {{{1
    call s:FormatBufferNames()
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

function! s:CollectBufferNames()   " {{{1
    return filter(split(execute('buffers'), '\n'), 'v:val !~? "\\(Location\\|Quickfix\\) List"')
endfunction

function! s:FormatBufferNames()   " {{{1
    let s:bufferList = map(s:CollectBufferNames(), {_,v -> {'origin':v, 'buffer':matchstr(v,'"\zs.*\ze"')}})
    call map(s:bufferList, {_,v -> {'origin':v.origin, 'buffer':v.buffer, 'filename':fnamemodify(v.buffer,':t')}})
    call map(s:bufferList, {_,v -> {'origin':v.origin, 'buffer':v.buffer, 'filename':v.filename, 'parts': split(v.filename, '\.')}})
    call map(s:bufferList, {_,v -> {'origin':v.origin, 'buffer':v.buffer, 'filename':len(v.parts)==1?v.filename:strcharpart(v.filename,0,strchars(v.filename)-strchars(v.parts[-1])-1), 'extension':len(v.parts)==1?'':v.parts[-1]}})

    let l:filenameMaxLength = max(map(copy(s:bufferList), {_,v -> strchars(v.filename)}))
    let l:extensionMaxLength = max(map(copy(s:bufferList), {_,v -> strchars(v.extension)}))

    let s:filenameColumn = 13
    let s:extensionColumn = s:filenameColumn + l:filenameMaxLength + 2
    let s:pathColumn = s:extensionColumn + l:extensionMaxLength + 2

    call map(s:bufferList, {_,v -> {'origin':v.origin, 'buffer':filereadable(fnamemodify(v.buffer,':p')) ?
                \ printf( '%-*s  %-*s  %s', l:filenameMaxLength, v.filename, l:extensionMaxLength, v.extension, escape(fnamemodify(v.buffer, ':.:h'), '\') ) :
                \ v.buffer}})
    call map(s:bufferList, {_,v -> substitute(substitute('    '.v.origin, '^\s*\([ 0-9]\{4}\d\)\s','\1: ',''), '".*', v.buffer, '')})
endfunction

function! s:OpenBufSelectWindow(width, height)   " {{{1
    if exists('s:bufSelectWindow')
        return
    endif

    let hostWidth = nvim_win_get_width(0)
    let hostHeight = nvim_win_get_height(0)
    let config = {'relative':'win', 'row':(hostHeight-a:height)/2, 'col':(hostWidth-a:width)/2,
                \ 'height':a:height, 'width':a:width,
                \ 'border':'rounded', 'noautocmd':1, 'style':'minimal'}
    let s:bufSelectWindow = nvim_open_win(nvim_create_buf(0,1),1,config)
    setlocal syntax=bufselect nowrap bufhidden=wipe cursorline
    let s:bufnrSearch = 0
endfunction

function! s:DisplayBuffers()   " {{{1
    let width = max(map(s:bufferList+[s:Footer()[1]],{_,l -> strchars(l)}))+1
    let height = len(s:bufferList)+2
    call s:OpenBufSelectWindow(width, height)
    setlocal modifiable
    %delete _
    call setline(1, s:bufferList)
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

    for l:i in range(10)
        execute "nnoremap <buffer> <silent> ".l:i." :call <SID>SelectByNumber(".l:i.")<CR>"
    endfor
    nnoremap <buffer> <silent> ? :call <SID>ShowHelp()<CR>

    augroup BufSelectLinesBoundary
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
    if len(s:CollectBufferNames()) == 1
        echo "Not gonna do it. The last buffer stays."
        return
    endif

    let selected = s:GetSelectedBuffer()
    let currentLine = line('.')
    call s:ExitBufSelect()
    execute 'bwipeout ' . selected
    call bufselect#RefreshBufferList(currentLine)
endfunction

function! s:ChangeSort()   " {{{1
    let sortOptions = ["Num", "Status", "Name", "Extension", "Path"]
    let g:BufSelectSortOrder = sortOptions[(index(sortOptions, g:BufSelectSortOrder) + 1) % len(sortOptions)]
    let l:currBuffer = s:GetSelectedBuffer()
    call s:SortBufferList()
    call s:UpdateFooter()
    call s:SetPosition(search('^\s*'.l:currBuffer.':', 'w'))
endfunction

function! s:ChangeDir()   " {{{1
    let l:currBuffer = s:GetSelectedBuffer()
    execute 'cd '.fnamemodify(bufname(l:currBuffer), ':p:h')
    call bufselect#RefreshBufferList(line('.'))
endfunction

function! s:ChangeDirUp()   " {{{1
    cd ..
    call bufselect#RefreshBufferList(line('.'))
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
