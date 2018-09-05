# bufselect.vim

This is a much scaled-down alternative to [bufexplorer](https://github.com/jlanzarotta/bufexplorer) and [buffergator](https://github.com/jeetsukumaran/vim-buffergator), both of which I'd used in the past. I wanted this plugin to be a lot fewer lines of code, so I removed functionality I didn't really find necessary. What it ended up being is:

* a very clean list that shows buffer number, filename, and relative path of each buffer you'd see in the `:ls` command
* a few key mappings to open buffers (including in splits), delete buffers, or sort the list
* a single command to kick things off
* a non-persistent list of buffers (The buffer list is generated each time the command is called, rather than being maintained by autocommands when buffers are entered, exited, or deleted. This simplifies the code considerably.)

## Installation

Use your favorite plugin manager to install this plugin. My personal favorite is [vim-plug](https://github.com/junegunn/vim-plug). In your **`.vimrc`**, add the following line.
```
Plug 'git@github.com:PhilRunninger/bufselect.vim.git'
```

[Vundle](https://github.com/VundleVim/Vundle.vim), [pathogen](https://github.com/tpope/vim-pathogen), and others should also work just as easily. Just follow the convention set up the plugin manager of your choice.

## Command

The only command is **`:ShowBufferList`**, which can be assigned to a key. For example,
```
nnoremap <silent> <leader>b :ShowBufferList<CR>
```

## Key Mappings

The following key mappings are used to interact with the BufSelect buffer. They are configurable by setting the corresponding global variables.

Default Key | Variable                  | Function
---|---|---
**`o`**     | `g:BufSelectOpen`         | Open this buffer in the current window.
**`s`**     | `g:BufSelectSplit`        | Split the window horizontally, and open this buffer there.
**`v`**     | `g:BufSelectVSplit`       | Split the window vertically, and open this buffer there.
**`x`**     | `g:BufSelectDeleteBuffer` | Close the buffer. This actually uses vim's **`:bwipeout`** command.
**`S`**     | `g:BufSelectSort`         | Change the sort order: by Number, Name, or Path
**`q`**     | `g:BufSelectExit`         | Exit the buffer list.
**`?`**     |                           | Display a short message describing these commands.

The default sort order can be set in the variable `g:BufSelectSortOrder`. The valid values are: `"Num"`, `"Name"`, `"Path"`, with `"Name"` being the default.
