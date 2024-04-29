" BufSelect - a Vim buffer selection and deletion utility

" Show depcrecation warning.
if max(map(['KeyOpen',     'KeyPreviewOpen',   'KeyChDir',   'KeyDeleteBuffer',
        \ 'KeySplit',      'KeyPreviewSplit',  'KeyChDirUp', 'KeySelectOpen',
        \ 'KeyVSplit',     'KeyPreviewVSplit', 'KeyFind',    'KeyTab',
        \ 'KeyPreviewTab', 'KeyExit',          'KeySort',
        \ 'SortOrder',     'FloatWinConfig',   'Setup'],
        \ {_,v -> exists('g:BufSelect'.v)})) == 1
    echohl WarningMsg
    echomsg 'BufSelect: Deprecated settings were detected. Use `call bufselect#settings(...)` instead.'
    echohl None
endif

command! ShowBufferList :call bufselect#RefreshBufferList(-1)
