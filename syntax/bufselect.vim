""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  BufSelect - a Vim buffer selection and deletion utility
"
"  Copyright 2018 Phil Runninger.
"
"  This program is free software; you can redistribute it and/or modify
"  it under the terms of the GNU General Public License as published by
"  the Free Software Foundation; either version 3 of the License, or
"  (at your option) any later version.
"
"  This program is distributed in the hope that it will be useful,
"  but WITHOUT ANY WARRANTY; without even the implied warranty of
"  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"  GNU General Public License <http://www.gnu.org/licenses/>
"  for more details."
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax match BufSelectCWD /^CWD: .*/hs=s+5
syntax match BufSelectCurrentSort /=\+/
syntax match BufSelectSeparator /^[-=]\+$/ contains=BufSelectCurrentSort
syntax match BufSelectCurrBuffer /^\s*\d\+: %.*/
syntax match BufSelectAltBuffer /^\s*\d\+: #.*/
syntax match BufSelectUnsavedBuffer /^\s*\d\+: ...+.*/

highlight link BufSelectCWD TypeDef
highlight link BufSelectCurrentSort Function
highlight link BufSelectSeparator Tag
highlight link BufSelectCurrBuffer Identifier
highlight link BufSelectAltBuffer Label
highlight link BufSelectUnsavedBuffer Error
