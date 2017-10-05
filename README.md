# bufselect.vim

I wrote this as a much scaled-down alternative to [bufexplorer](https://github.com/jlanzarotta/bufexplorer), with commands mapped very much like my new favorite file manager, [vifm](http://vifm.info/). There are no settings or customization in this plugin.

## Installation

Use your favorite plugin manager to install this plugin. My personal favorite is [vim-plug](https://github.com/junegunn/vim-plug). In your **`.vimrc`**, add the following line.
```
Plug 'git@github.com:PhilRunninger/bufselect.vim.git'
```

[Vundle](https://github.com/VundleVim/Vundle.vim) and [pathogen](https://github.com/tpope/vim-pathogen) should also work just as easily. Just follow the convention setup for either one.

## Command

The only command necessary to know is **`:ShowBufferList`**, which can be assigned to a key. For example,
```
nnoremap <silent> <leader>b :ShowBufferList<CR>
```

## Key Mappings

Key | Function
---|---
**`h`** or **`Esc`** | Exit the buffer list. I know **`h`** seems strange, but it mirrors vifm's **`up one directory`** key. The **`<Esc>`** key provides a (perhaps) more intuitive alternative.
**`j`**/**`k`** | Move down or up the list. Other motions will work too, but not **`h`** or **`l`**.
**`l`** or **`Enter`** | Open this buffer in the window. This mirrors vifm's **`launch`** key.
**`s`** | Split the window horizontally, and open this buffer there.
**`v`** | Split the window vertically, and open this buffer there.
**`x`** | Close the buffer. This actually uses vim's **`:bwipeout`** command.
**`?`** | Display a short message describing these commands.
