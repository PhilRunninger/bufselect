" vim: foldmethod=marker
"
" BufSelect - a Vim buffer selection and deletion utility

let s:showingHelp = 0

function! bufselect#RefreshBufferList(currentLine)   " {{{1
    call s:DisplayBuffers()
    call s:SortBufferList()
    call s:SetPosition(a:currentLine)
    call s:SetupCommands()
endfunction

function! s:ExitBufSelect()   "{{{1
    if exists('s:bufSelectWindow')
        call nvim_win_hide(s:bufSelectWindow)
    endif
    unlet! s:bufSelectWindow
endfunction

function! s:SwitchBuffers(windowCmd, preview)   " {{{1
    let bufNum = s:GetSelectedBuffer()
    let currentLine = line('.')
    call s:ExitBufSelect()
    if bufexists(bufNum)
        execute a:windowCmd . bufNum
    endif
    if a:preview
        call bufselect#RefreshBufferList(currentLine)
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
    call s:ExitBufSelect()
    let hostWidth = nvim_win_get_width(0)
    let hostHeight = nvim_win_get_height(0)
    let config = {'relative':'win', 'row':(hostHeight-a:height)/2, 'col':(hostWidth-a:width)/2,
                \ 'height':a:height, 'width':a:width,
                \ 'border':'double', 'noautocmd':1, 'style':'minimal'}
    let s:bufSelectWindow = nvim_open_win(nvim_create_buf(0,1),1,config)
    setlocal syntax=bufselect nowrap bufhidden=wipe cursorline scrolloff=20
    let s:bufnrSearch = 0
endfunction

function! s:DisplayBuffers()   " {{{1
    let bufferList = s:GetBufferList()
    let footer = s:Footer()
    let width = max(map(copy(bufferList),{_,l -> strchars(l)}))+1
    let width = max([footer.width+1, width])
    let height = len(bufferList)+len(footer.text)
    call s:OpenBufSelectWindow(width, height)
    setlocal modifiable
    silent %delete _
    call setline(1, bufferList)
    call append(line('$'), footer.text)
    setlocal nomodifiable
endfunction

function! s:SortBufferList()   " {{{1
    setlocal modifiable
    1,/^[▀▔]\+$/-1sort n
    if g:BufSelectSortOrder != "Num"
        execute '1,/^[▀▔]\+$/-1sort /^.\{' . (s:filenameColumn-1) . '}/'
    endif
    if g:BufSelectSortOrder == "Status"
        execute '1,/^[▀▔]\+$/-1sort! /^\s*\d\+:..\zs.\ze/ r'
    elseif g:BufSelectSortOrder == "Extension"
        execute '1,/^[▀▔]\+$/-1sort /^.\{' . (s:extensionColumn-1) . '}/'
    elseif g:BufSelectSortOrder == "Path"
        execute '1,/^[▀▔]\+$/-1sort /^.\{' . (s:pathColumn-1) . '}/'
    endif
    setlocal nomodifiable
endfunction

function! s:Footer()   " {{{1
    let footerText = [
        \ printf('%s▔▔▔%s▔▔▔%s▔▔%s▔▔%s',
            \ repeat(g:BufSelectSortOrder == "Num"       ? '▀' : '▔', 5),
            \ repeat(g:BufSelectSortOrder == "Status"    ? '▀' : '▔', 1),
            \ repeat(g:BufSelectSortOrder == "Name"      ? '▀' : '▔', s:extensionColumn - s:filenameColumn - 2),
            \ repeat(g:BufSelectSortOrder == "Extension" ? '▀' : '▔', s:pathColumn - s:extensionColumn - 2),
            \ repeat(g:BufSelectSortOrder == "Path"      ? '▀' : '▔', 300)),
        \ printf('? for help  Sort: %-9s  CWD: %s', g:BufSelectSortOrder, fnamemodify(getcwd(),':~')) ]
    if !s:showingHelp
        return #{text:footerText, width:strchars(footerText[1])}
    else
        let helpText = [
            \ repeat("▁", 300),
            \ printf(" <CR> %3s ▏Open buffer in the current window.",                   g:BufSelectKeyOpen),
            \ printf("      %3s ▏Open buffer in a new horizontal split.",               g:BufSelectKeySplit),
            \ printf("      %3s ▏Open buffer in a new vertical split.",                 g:BufSelectKeyVSplit),
            \ printf("      %3s ▏Open buffer in a new tab.",                            g:BufSelectKeyTab),
            \ printf("g<CR> %3s ▏Preview buffer in the current window.",                g:BufSelectKeyPreviewOpen),
            \ printf("      %3s ▏Preview buffer in a new horizontal split.",            g:BufSelectKeyPreviewSplit),
            \ printf("      %3s ▏Preview buffer in a new vertical split.",              g:BufSelectKeyPreviewVSplit),
            \ printf("      %3s ▏Preview buffer in a new tab.",                         g:BufSelectKeyPreviewTab),
            \ printf("      %3s ▏Close the selected buffer using :bwipeout.",           g:BufSelectKeyDeleteBuffer),
            \ printf("      %3s ▏Change the sort order.",                               g:BufSelectKeySort),
            \ printf("      %3s ▏Change working directory to selected buffer's folder.",g:BufSelectKeyChDir),
            \ printf("      %3s ▏Change working directory up one level from current.",  g:BufSelectKeyChDirUp),
            \ printf("      %3s ▏Move cursor to the next open buffer.",                 g:BufSelectKeySelectOpen),
            \ printf("      0-9 ▏Move cursor to the next buffer by buffer number."),
            \ printf("<Esc> %3s ▏Exit the buffer list.",                                   g:BufSelectKeyExit)
            \ ]
        return #{text:footerText + helpText, width:max(map(footerText[1:]+helpText[1:], {_,v->strchars(v)}))}
    endif
endfunction

function! s:UpdateFooter()   " {{{1
    setlocal modifiable
    silent /^[▀▔]\+$/,$delete
    call append('$', s:Footer().text)
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
    execute printf("nnoremap <buffer> <silent> %s :call <SID>ExitBufSelect()<CR>",                      '<Esc>')
    execute printf("nnoremap <buffer> <silent> %s :call <SID>ExitBufSelect()<CR>",                      g:BufSelectKeyExit)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('buffer', 0)<CR>",           '<CR>')
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('buffer', 0)<CR>",           g:BufSelectKeyOpen)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('sbuffer', 0)<CR>",          g:BufSelectKeySplit)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('vertical sbuffer', 0)<CR>", g:BufSelectKeyVSplit)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('tab sbuffer', 0)<CR>",      g:BufSelectKeyTab)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('buffer', 1)<CR>",           'g<CR>')
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('buffer', 1)<CR>",           g:BufSelectKeyPreviewOpen)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('sbuffer', 1)<CR>",          g:BufSelectKeyPreviewSplit)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('vertical sbuffer', 1)<CR>", g:BufSelectKeyPreviewVSplit)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SwitchBuffers('tab sbuffer', 1)<CR>",      g:BufSelectKeyPreviewTab)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>CloseBuffer()<CR>",                        g:BufSelectKeyDeleteBuffer)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>ChangeSort()<CR>",                         g:BufSelectKeySort)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>ChangeDir()<CR>",                          g:BufSelectKeyChDir)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>ChangeDirUp()<CR>",                        g:BufSelectKeyChDirUp)
    execute printf("nnoremap <buffer> <silent> %s :call <SID>SelectOpenBuffers()<CR>",                  g:BufSelectKeySelectOpen)

    for i in range(10)
        execute printf("nnoremap <buffer> <silent> %d call <SID>SelectByNumber(%d)<CR>", i, i)
    endfor

    nnoremap <buffer> <silent> ? <Cmd>call <SID>ToggleHelp()<CR>
    augroup BufSelectAuGroup
        autocmd!
        autocmd CursorMoved <buffer> if line('.') > line('$')-len(<SID>Footer().text) | execute "normal! ".(line('$')-len(<SID>Footer().text))."gg" | endif
        autocmd BufLeave <buffer> call s:ExitBufSelect()
    augroup END
endfunction

function! s:GetSelectedBuffer()   " {{{1
    let lineOfText = getline(line('.'))
    let bufNum = matchstr(lineOfText, '^\s*\zs\d\+\ze:')
    return str2nr(bufNum)
endfunction

function! s:CloseBuffer()   " {{{1
    execute 'bwipeout ' . s:GetSelectedBuffer()
    call bufselect#RefreshBufferList(line('.'))
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
    execute 'cd '.fnamemodify(bufname(s:GetSelectedBuffer()), ':p:h')
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

function! s:ToggleHelp()   " {{{1
    let s:showingHelp = !s:showingHelp
    call bufselect#RefreshBufferList(line('.'))
endfunction
