" BufSelect - a Vim buffer selection and deletion utility

syntax match BufSelectSort /^Sort: \S*/hs=s+5
syntax match BufSelectSort /▀\+/
syntax match BufSelectCurrent /CWD: .*/hs=s+5
syntax match BufSelectCurrent /^\s*\d\+: %.*/
syntax match BufSelectAlt /^\s*\d\+: #.*/
syntax match BufSelectUnsaved /^\s*\d\+: ...+.*/

function! s:SetHighlight(group, setting)
    let parts = split(a:setting, 'link\zs')
    if a:setting =~? '\<link\>'
        execute 'highlight link ' . a:group . ' ' . trim(substitute(a:setting, 'link', '', ''))
    else
        execute 'highlight ' . a:group . ' ' . a:setting
    endif
endfunction

call s:SetHighlight('BufSelectSort',      g:BufSelectHighlightSort)
call s:SetHighlight('BufSelectCurrent',   g:BufSelectHighlightCurrent)
call s:SetHighlight('BufSelectAlt',       g:BufSelectHighlightAlt)
call s:SetHighlight('BufSelectUnsaved',   g:BufSelectHighlightUnsaved)
