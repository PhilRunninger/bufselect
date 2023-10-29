" BufSelect - a Vim buffer selection and deletion utility

syntax match BufSelectSort /Sort: \S*/hs=s+5
syntax match BufSelectSort /▀\+/
syntax match BufSelectCurrent /CWD: .*/hs=s+5
syntax match BufSelectCurrent /^\s*\d\+: %.*/
syntax match BufSelectAlt /^\s*\d\+: #.*/
syntax match BufSelectUnsaved /^\s*\d\+: ...+.*/
syntax match BufSelectHelp /^?\ze for help/
syntax match BufSelectHelp /^.*┃/he=e-1

highlight BufSelectHelp guibg=NONE guifg=#FF8700 ctermbg=NONE ctermfg=208
highlight BufSelectSort guibg=NONE guifg=#FF8700 ctermbg=NONE ctermfg=208
highlight BufSelectCurrent guibg=NONE guifg=#5F87FF ctermbg=NONE ctermfg=69
highlight BufSelectAlt guibg=NONE guifg=#5FAF00 ctermbg=NONE ctermfg=70
highlight BufSelectUnsaved guibg=NONE guifg=#FF5F00 ctermbg=NONE ctermfg=202
