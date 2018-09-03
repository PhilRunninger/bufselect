# bufselect.vim

This is a much scaled-down alternative to [bufexplorer](https://github.com/jlanzarotta/bufexplorer). I wanted it to be a lot fewer lines of code, so I removed functionality I didn't really find necessary, especially the MRU sort order. What it ended up being is a very clean list that shows buffer number, filename, and relative path of each buffer you'd see in the `:ls` command; a key mappings to open buffers (including in splits), delete buffers, or sort the list.

## Installation

Use your favorite plugin manager to install this plugin. My personal favorite is [vim-plug](https://github.com/junegunn/vim-plug). In your **`.vimrc`**, add the following line.
```
Plug 'git@github.com:PhilRunninger/bufselect.vim.git'
```

[Vundle](https://github.com/VundleVim/Vundle.vim) and [pathogen](https://github.com/tpope/vim-pathogen) should also work just as easily. Just follow the convention set up for either one.

## Command

The only command necessary to know is **`:ShowBufferList`**, which can be assigned to a key. For example,
```
nnoremap <silent> <leader>b :ShowBufferList<CR>
```

## Key Mappings

They key mappings are configurable by setting some global variables.

Variable | Default Key | Function
---|---|---
`g:BufSelectExit` |        **`q`** | Exit the buffer list.
`g:BufSelectOpen` |        **`o`** | Open this buffer in the current window.
`g:BufSelectSplit` |       **`s`** | Split the window horizontally, and open this buffer there.
`g:BufSelectVSplit` |      **`v`** | Split the window vertically, and open this buffer there.
`g:BufSelectDeleteBuffer` |**`x`** | Close the buffer. This actually uses vim's **`:bwipeout`** command.
`g:BufSelectSort` |        **`S`** | Change the sort order: by Number, Name, or Path
 | **`?`** | Display a short message describing these commands.

The default sort order can be set in the variable `g:BufSelectSortOrder`. The valid values are: `"Num"`, `"Name"`, `"Path"`.
