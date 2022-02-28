" BufSelect - a Vim buffer selection and deletion utility

" Default values for settings
let g:BufSelectKeyExit         = get(g:, 'BufSelectKeyExit',         'q')
let g:BufSelectKeyOpen         = get(g:, 'BufSelectKeyOpen',         'o')
let g:BufSelectKeySplit        = get(g:, 'BufSelectKeySplit',        's')
let g:BufSelectKeyVSplit       = get(g:, 'BufSelectKeyVSplit',       'v')
let g:BufSelectKeyTab          = get(g:, 'BufSelectKeyTab',          't')
let g:BufSelectKeyDeleteBuffer = get(g:, 'BufSelectKeyDeleteBuffer', 'x')
let g:BufSelectKeySort         = get(g:, 'BufSelectKeySort',         'S')
let g:BufSelectSortOrder       = get(g:, 'BufSelectSortOrder',    'Name')
let g:BufSelectKeyChDir        = get(g:, 'BufSelectKeyChDir',       'cd')
let g:BufSelectKeyChDirUp      = get(g:, 'BufSelectKeyChDirUp',     '..')
let g:BufSelectKeySelectOpen   = get(g:, 'BufSelectKeySelectOpen',   '#')

command! ShowBufferList :call bufselect#RefreshBufferList(-1)
