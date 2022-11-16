" BufSelect - a Vim buffer selection and deletion utility

syntax match BufSelectSort /^Sort: \S*/hs=s+5
syntax match BufSelectSort /▀\+/
syntax match BufSelectCurrent /CWD: .*/hs=s+5
syntax match BufSelectCurrent /^\s*\d\+: %.*/
syntax match BufSelectAlt /^\s*\d\+: #.*/
syntax match BufSelectUnsaved /^\s*\d\+: ...+.*/

function! s:SetHighlight(group, setting)
    execute printf('highlight %s %s %s', (a:setting =~ '=' ? '' : 'link '), a:group, a:setting)
endfunction

call s:SetHighlight('BufSelectSort',      g:BufSelectHighlightSort)
call s:SetHighlight('BufSelectCurrent',   g:BufSelectHighlightCurrent)
call s:SetHighlight('BufSelectAlt',       g:BufSelectHighlightAlt)
call s:SetHighlight('BufSelectUnsaved',   g:BufSelectHighlightUnsaved)
