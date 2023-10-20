" BufSelect - a Vim buffer selection and deletion utility

" Show depcrecation warning.
if max(map([
        \ 'KeyOpen',        'KeySplit',        'KeyVSplit',        'KeyTab',
        \ 'KeyPreviewOpen', 'KeyPreviewSplit', 'KeyPreviewVSplit', 'KeyPreviewTab',
        \ 'KeyExit',        'KeyFind',         'KeyDeleteBuffer',  'KeySort',
        \ 'KeyChDir',       'KeyChDirUp',      'KeySelectOpen',    'SortOrder',     'FloatWinConfig'],
        \ {_,v -> exists('g:BufSelect'.v)})) == 1
    echohl WarningMsg
    echomsg 'BufSelect: Deprecated settings were detected. Use g:BufSelectSetup instead.'
    echohl None
endif

" Merge two dictionaries - a recursive version of: extend(copy(expr1), expr2, 'force')
function! s:deep_extend(defaults, override) abort
    let new = copy(a:defaults)
    for [k, v] in items(a:override)
        let new[k] = (type(v) is v:t_dict && type(get(new, k)) is v:t_dict)
                    \ ? s:deep_extend(new[k], v)
                    \ : v
    endfor
    return new
endfunction

" Default values for settings, allowing for deprecated settings.
let g:BufSelectSetup = s:deep_extend(
    \ {
        \ 'mappings': {
            \ 'open':    get(g:,'BufSelectKeyOpen',          'o'),
            \ 'split':   get(g:,'BufSelectKeySplit',         's'),
            \ 'vsplit':  get(g:,'BufSelectKeyVSplit',        'v'),
            \ 'tab':     get(g:,'BufSelectKeyTab',           't'),
            \ 'gopen':   get(g:,'BufSelectKeyPreviewOpen',   'g'.get(g:,'BufSelectKeyOpen',   'o')),
            \ 'gsplit':  get(g:,'BufSelectKeyPreviewSplit',  'g'.get(g:,'BufSelectKeySplit',  's')),
            \ 'gvsplit': get(g:,'BufSelectKeyPreviewVSplit', 'g'.get(g:,'BufSelectKeyVSplit', 'v')),
            \ 'gtab':    get(g:,'BufSelectKeyPreviewTab',    'g'.get(g:,'BufSelectKeyTab',    't')),
            \ 'exit':    get(g:,'BufSelectKeyExit',          'q'),
            \ 'find':    get(g:,'BufSelectKeyFind',          'f'),
            \ 'delete':  get(g:,'BufSelectKeyDeleteBuffer',  'x'),
            \ 'sort':    get(g:,'BufSelectKeySort',          'S'),
            \ 'cd':      get(g:,'BufSelectKeyChDir',         'cd'),
            \ 'cdup':    get(g:,'BufSelectKeyChDirUp',       '..'),
            \ 'next':    get(g:,'BufSelectKeySelectOpen',    '#')
        \ },
        \ 'sortOrder':   get(g:,'BufSelectSortOrder',        'Name'),
        \ 'win': {
            \ 'config':  get(g:,'BufSelectFloatWinConfig',   {}),
            \ 'hl':      ''
        \ },
    \ },
    \ get(g:, 'BufSelectSetup', {}))

command! ShowBufferList :call bufselect#RefreshBufferList(-1)
