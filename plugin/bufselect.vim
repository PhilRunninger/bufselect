" BufSelect - a Vim buffer selection and deletion utility

" Default values for settings
let g:BufSelectKeyExit          = get(g:,'BufSelectKeyExit',         'q')
let g:BufSelectKeyOpen          = get(g:,'BufSelectKeyOpen',         'o')
let g:BufSelectKeySplit         = get(g:,'BufSelectKeySplit',        's')
let g:BufSelectKeyVSplit        = get(g:,'BufSelectKeyVSplit',       'v')
let g:BufSelectKeyTab           = get(g:,'BufSelectKeyTab',          't')
let g:BufSelectKeyPreviewOpen   = get(g:,'BufSelectKeyPreviewOpen',  'g'.g:BufSelectKeyOpen)
let g:BufSelectKeyPreviewSplit  = get(g:,'BufSelectKeyPreviewSplit', 'g'.g:BufSelectKeySplit)
let g:BufSelectKeyPreviewVSplit = get(g:,'BufSelectKeyPreviewVSplit','g'.g:BufSelectKeyVSplit)
let g:BufSelectKeyPreviewTab    = get(g:,'BufSelectKeyPreviewTab',   'g'.g:BufSelectKeyTab)
let g:BufSelectKeyFind          = get(g:,'BufSelectKeyFind',         'f')
let g:BufSelectKeyDeleteBuffer  = get(g:,'BufSelectKeyDeleteBuffer', 'x')
let g:BufSelectKeySort          = get(g:,'BufSelectKeySort',         'S')
let g:BufSelectKeyChDir         = get(g:,'BufSelectKeyChDir',        'cd')
let g:BufSelectKeyChDirUp       = get(g:,'BufSelectKeyChDirUp',      '..')
let g:BufSelectKeySelectOpen    = get(g:,'BufSelectKeySelectOpen',   '#')
let g:BufSelectSortOrder        = get(g:,'BufSelectSortOrder',       'Name')
let g:BufSelectFloatWinConfig   = get(g:, 'BufSelectFloatWinConfig', {})

command! ShowBufferList :call bufselect#RefreshBufferList(-1)
