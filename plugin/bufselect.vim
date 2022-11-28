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
let g:BufSelectKeyDeleteBuffer  = get(g:,'BufSelectKeyDeleteBuffer', 'x')
let g:BufSelectKeySort          = get(g:,'BufSelectKeySort',         'S')
let g:BufSelectKeyChDir         = get(g:,'BufSelectKeyChDir',        'cd')
let g:BufSelectKeyChDirUp       = get(g:,'BufSelectKeyChDirUp',      '..')
let g:BufSelectKeySelectOpen    = get(g:,'BufSelectKeySelectOpen',   '#')
let g:BufSelectSortOrder        = get(g:,'BufSelectSortOrder',       'Name')
let g:BufSelectHighlightSort    = get(g:,'BufSelectHighlightSort',   'guibg=NONE guifg=#FF8700 ctermbg=NONE ctermfg=208')
let g:BufSelectHighlightCurrent = get(g:,'BufSelectHighlightCurrent','guibg=NONE guifg=#5F87FF ctermbg=NONE ctermfg=69')
let g:BufSelectHighlightAlt     = get(g:,'BufSelectHighlightAlt',    'guibg=NONE guifg=#5FAF00 ctermbg=NONE ctermfg=70')
let g:BufSelectHighlightUnsaved = get(g:,'BufSelectHighlightUnsaved','guibg=NONE guifg=#FF5F00 ctermbg=NONE ctermfg=202')

command! ShowBufferList :call bufselect#RefreshBufferList(-1)
