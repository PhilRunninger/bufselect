" BufSelect - a Vim buffer selection and deletion utility

syntax match BufSelectSort /^Sort: \S*/hs=s+5
syntax match BufSelectCWD /CWD: .*/hs=s+5
syntax match BufSelectCurrentSort /▀\+/
syntax match BufSelectSeparator /^[▀▔]\+$/ contains=BufSelectCurrentSort
syntax match BufSelectCurrBuffer /^\s*\d\+: %.*/
syntax match BufSelectAltBuffer /^\s*\d\+: #.*/
syntax match BufSelectUnsavedBuffer /^\s*\d\+: ...+.*/

highlight link BufSelectSort Function
highlight link BufSelectCWD TypeDef
highlight link BufSelectCurrentSort Function
highlight link BufSelectSeparator Tag
highlight link BufSelectCurrBuffer Identifier
highlight link BufSelectAltBuffer Label
highlight link BufSelectUnsavedBuffer Error
