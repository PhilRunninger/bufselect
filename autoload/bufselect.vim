" vim: foldmethod=marker
"
" BufSelect - a Vim buffer selection and deletion utility

let s:showingHelp = 0

" Settings Management   {{{1
let s:defaultSettings =
    \ {
        \ 'mappings': {
            \ 'open':    'o',
            \ 'split':   's',
            \ 'vsplit':  'v',
            \ 'tab':     't',
            \ 'gopen':   'go',
            \ 'gsplit':  'gs',
            \ 'gvsplit': 'gv',
            \ 'gtab':    'gt',
            \ 'exit':    'q',
            \ 'find':    'f',
            \ 'delete':  'x',
            \ 'sort':    'S',
            \ 'cd':      'cd',
            \ 'cdup':    '..',
            \ 'next':    '#'
        \ },
        \ 'sortOrder':   'Name',
        \ 'win': {
            \ 'config':  {'border': 'double'},
            \ 'hl':      ''
        \ },
    \ }
let s:settings = s:defaultSettings

" Merge two dictionaries - a recursive version of: extend(copy(expr1), expr2, 'force')
function! s:deep_extend(defaults, override) abort
    let new = copy(a:defaults)
    for [k, v] in items(a:override)
        let new[k] = (type(v) is v:t_dict && type(get(new, k)) is v:t_dict)
                    \ ? s:deep_extend(new[k], v)
                    \ : v
    endfor
    return new
endfunction

function! bufselect#settings(...)
    if a:0 && type(a:1) == v:t_dict
        let s:settings = s:deep_extend(s:defaultSettings, a:1)
    endif
    return s:settings
endfunction

function! bufselect#RefreshBufferList(currentLine)   " {{{1
    let bufferList = s:GetBufferList()
    if empty(bufferList)
        echo 'No buffers!'
        return
    endif
    call s:DisplayBuffers(bufferList)
    call s:SortBufferList()
    call s:SetPosition(a:currentLine)
    call s:SetupCommands()
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
    let config = extend({
                \ 'relative': 'win',
                \ 'row': (hostHeight - a:height) / 2,
                \ 'col': (hostWidth - a:width) / 2,
                \ 'height': a:height,
                \ 'width': a:width,
                \ 'noautocmd': 1,
                \ 'style': 'minimal',
                \ }, s:settings.win.config)
    let s:bufSelectWindow = nvim_open_win(nvim_create_buf(0,1),1,config)
    call nvim_win_set_option(s:bufSelectWindow, 'winhl', s:settings.win.hl)
    setlocal syntax=bufselect nowrap bufhidden=wipe cursorline scrolloff=20
    let s:bufnrSearch = 0
endfunction

function! s:DisplayBuffers(bufferList)   " {{{1
    let footer = s:Footer()
    let width = max([footer.width] + map(copy(a:bufferList), {_,l -> strchars(l)})) + 1
    let height = len(a:bufferList) + len(footer.text)
    call s:OpenBufSelectWindow(width, height)
    setlocal modifiable
    silent %delete _
    call setline(1, a:bufferList)
    call append(line('$'), footer.text)
    setlocal nomodifiable
endfunction

function! s:SortBufferList()   " {{{1
    setlocal modifiable
    1,/^[▀▔]\+$/-1sort n
    if s:settings.sortOrder != "Num"
        execute '1,/^[▀▔]\+$/-1sort /^.\{' . (s:filenameColumn-1) . '}/'
    endif
    if s:settings.sortOrder == "Status"
        execute '1,/^[▀▔]\+$/-1sort! /^\s*\d\+:..\zs.\ze/ r'
    elseif s:settings.sortOrder == "Extension"
        execute '1,/^[▀▔]\+$/-1sort /^.\{' . (s:extensionColumn-1) . '}/'
    elseif s:settings.sortOrder == "Path"
        execute '1,/^[▀▔]\+$/-1sort /^.\{' . (s:pathColumn-1) . '}/'
    endif
    setlocal nomodifiable
endfunction

function! s:Footer()   " {{{1
    let footerText = [
        \ printf('%s▔▔▔%s▔▔▔%s▔▔%s▔▔%s',
            \ repeat(s:settings.sortOrder == "Num"       ? '▀' : '▔', 5),
            \ repeat(s:settings.sortOrder == "Status"    ? '▀' : '▔', 1),
            \ repeat(s:settings.sortOrder == "Name"      ? '▀' : '▔', s:extensionColumn - s:filenameColumn - 2),
            \ repeat(s:settings.sortOrder == "Extension" ? '▀' : '▔', s:pathColumn - s:extensionColumn - 2),
            \ repeat(s:settings.sortOrder == "Path"      ? '▀' : '▔', 300)),
        \ printf('? for help  Sort: %-9s  CWD: %s', s:settings.sortOrder, fnamemodify(getcwd(),':~')) ]
    if !s:showingHelp
        return {'text':footerText, 'width':strchars(footerText[1])}
    endif

    let helpText = [
        \ repeat("▁", 300),
        \ printf(" <CR> %3s┃Open buffer in the current window.",                   s:settings.mappings.open),
        \ printf("      %3s┃Open buffer in a new horizontal split.",               s:settings.mappings.split),
        \ printf("      %3s┃Open buffer in a new vertical split.",                 s:settings.mappings.vsplit),
        \ printf("      %3s┃Open buffer in a new tab.",                            s:settings.mappings.tab),
        \ printf("g<CR> %3s┃Preview buffer in the current window.",                s:settings.mappings.gopen),
        \ printf("      %3s┃Preview buffer in a new horizontal split.",            s:settings.mappings.gsplit),
        \ printf("      %3s┃Preview buffer in a new vertical split.",              s:settings.mappings.gvsplit),
        \ printf("      %3s┃Preview buffer in a new tab.",                         s:settings.mappings.gtab),
        \ printf("      %3s┃Find buffer in any open window.",                      s:settings.mappings.find),
        \ printf("      %3s┃Close the selected buffer using :bwipeout.",           s:settings.mappings.delete),
        \ printf("      %3s┃Change the sort order.",                               s:settings.mappings.sort),
        \ printf("      %3s┃Change working directory to selected buffer's folder.",s:settings.mappings.cd),
        \ printf("      %3s┃Change working directory up one level from current.",  s:settings.mappings.cdup),
        \ printf("      %3s┃Move cursor to the next open buffer.",                 s:settings.mappings.next),
        \ printf("      0-9┃Move cursor to the next buffer by buffer number."),
        \ printf("<Esc> %3s┃Exit the buffer list.",                                s:settings.mappings.exit)
        \ ]
    return {'text':footerText + helpText, 'width':max(map(footerText[1:]+helpText[1:], {_,v->strchars(v)}))}
endfunction

function! s:UpdateFooter()   " {{{1
    setlocal modifiable
    silent /^[▀▔]\+$/,$delete _
    call append('$', s:Footer().text)
    setlocal nomodifiable
endfunction

function! s:SetPosition(currentLine)   " {{{1
    call cursor(1,1)
    if a:currentLine != -1
        call cursor(a:currentLine,1)
    elseif search('^\s*\d\+:\s*%', 'w') == 0
        call search('^\s*\d\+:\s*#', 'w')
    endif
endfunction

function! s:SetupCommands()   " {{{1
    execute "nnoremap <buffer> <silent>            <Esc>                :call <SID>ExitBufSelect()<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.exit   ." :call <SID>ExitBufSelect()<CR>"
    execute "nnoremap <buffer> <silent>            <CR>                 :call <SID>SwitchBuffers('buffer', 0)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.open   ." :call <SID>SwitchBuffers('buffer', 0)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.split  ." :call <SID>SwitchBuffers('sbuffer', 0)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.vsplit ." :call <SID>SwitchBuffers('vertical sbuffer', 0)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.tab    ." :call <SID>SwitchBuffers('tab sbuffer', 0)<CR>"
    execute "nnoremap <buffer> <silent>            g<CR>                :call <SID>SwitchBuffers('buffer', 1)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.gopen  ." :call <SID>SwitchBuffers('buffer', 1)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.gsplit ." :call <SID>SwitchBuffers('sbuffer', 1)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.gvsplit." :call <SID>SwitchBuffers('vertical sbuffer', 1)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.gtab   ." :call <SID>SwitchBuffers('tab sbuffer', 1)<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.find   ." :call <SID>FindInWindow()<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.delete ." :call <SID>CloseBuffer()<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.sort   ." :call <SID>ChangeSort()<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.cd     ." :call <SID>ChangeDir()<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.cdup   ." :call <SID>ChangeDirUp()<CR>"
    execute "nnoremap <buffer> <silent> ".s:settings.mappings.next   ." :call <SID>SelectOpenBuffers()<CR>"

    for i in range(10)
        execute 'nnoremap <buffer> <silent> '.i." :call <SID>SelectByNumber(".i.")<CR>"
    endfor

    nnoremap <buffer> <silent> ? <Cmd>call <SID>ToggleHelp()<CR>
    augroup BufSelectAuGroup
        autocmd!
        autocmd CursorMoved <buffer> call cursor(min([line('.'),line('$')-len(<SID>Footer().text)]),1)
        autocmd BufLeave <buffer> call s:ExitBufSelect()
    augroup END
endfunction

function! s:ExitBufSelect()   "{{{1
    if exists('s:bufSelectWindow')
        call nvim_win_hide(s:bufSelectWindow)
    endif
    unlet! s:bufSelectWindow
endfunction

function! s:GetSelectedBuffer()   " {{{1
    return str2nr(matchstr(getline(line('.')), '^\s*\zs\d\+\ze:'))
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

function! s:FindInWindow()   " {{{1
    let selected = s:GetSelectedBuffer()
    for i in range(1,tabpagenr('$'))
        let win = index(tabpagebuflist(i),selected)
        if  win > -1
            execute i . 'tabnext'
            execute (win+1) . 'wincmd w'
            return
        endif
    endfor
    echo 'Buffer ' . selected . ' is not open in any window.'
endfunction

function! s:CloseBuffer()   " {{{1
    let selected = s:GetSelectedBuffer()
    let currentLine = line('.')
    call s:ExitBufSelect()      " Must exit if wiping out the only window's buffer.
    execute 'bwipeout ' . selected
    call bufselect#RefreshBufferList(currentLine)
endfunction

function! s:ChangeSort()   " {{{1
    let sortOptions = ["Num", "Status", "Name", "Extension", "Path"]
    let s:settings.sortOrder = sortOptions[(index(sortOptions, s:settings.sortOrder) + 1) % len(sortOptions)]
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
    let currentLine = line('.')
    call cursor(1,1)

    let s:bufnrSearch = 10*s:bufnrSearch + a:num
    let found = search('^\s*'.s:bufnrSearch.':', 'cW') || search('^\s*'.s:bufnrSearch.'\d*:', 'cW')
    while !found && s:bufnrSearch > 9
        let s:bufnrSearch = str2nr(s:bufnrSearch[1:])
        let found = search('^\s*'.s:bufnrSearch.':', 'cW') || search('^\s*'.s:bufnrSearch.'\d*:', 'cW')
    endwhile
    if !found
        call cursor(currentLine,1)
    endif
endfunction

function! s:ToggleHelp()   " {{{1
    let s:showingHelp = !s:showingHelp
    call bufselect#RefreshBufferList(line('.'))
endfunction
