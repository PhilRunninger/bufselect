    syntax match BufSelectCWD /^CWD: .*/hs=s+5
    syntax match BufSelectCurrentSort /=\+/
    syntax match BufSelectSeparator /^[-=]\+$/ contains=CurrentSort
    syntax match BufSelectCurrBuffer /^\s*\d\+: %.*/
    syntax match BufSelectAltBuffer /^\s*\d\+: #.*/

    highlight link BufSelectCWD TypeDef
    highlight link BufSelectCurrentSort Function
    highlight link BufSelectSeparator Tag
    highlight link BufSelectCurrBuffer Identifier
    highlight link BufSelectAltBuffer Label

