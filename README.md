# bufselect.vim

This is a minimalist alternative to [bufexplorer](https://github.com/jlanzarotta/bufexplorer) and [buffergator](https://github.com/jeetsukumaran/vim-buffergator), both of which I'd used in the past. I wanted this plugin to be a lot lighter weight, so I removed functionality I didn't really find necessary. What it ended up being is:

* a very clean list that shows the buffer number, filename, and relative path of the buffers you see in the `:ls` command
* a few key mappings to do the following tasks:
    * open buffers, including into splits (**`o`**, **`s`**, **`v`**)
    * delete buffers (**`x`**)
    * sort the list (**`S`**)
    * change the working directory (**`..`**, **`cd`**)
    * highlight open buffers in the list (**`#`**)
    * highlight buffers by number (**`0`**...**`9`**)
* a single command to kick things off (**`:ShowBufferList`**)
* a non-persistent list of buffers. The buffer list is generated each time the command is called, rather than being maintained behind the scenes with autocommands. This simplifies the code considerably.

## Installation

Use your favorite plugin manager to install this plugin. My personal favorite is [vim-plug](https://github.com/junegunn/vim-plug). In your **`.vimrc`**, add the following line.

```vim
Plug 'git@github.com:PhilRunninger/bufselect.vim.git'
```

[Vundle](https://github.com/VundleVim/Vundle.vim), [pathogen](https://github.com/tpope/vim-pathogen), and others should also work as easily. Just follow the convention set up by the plugin manager of your choice.

## Command

The only command is **`:ShowBufferList`**, which can be assigned to a key. For example,
```vim
nnoremap <silent> <leader>b :ShowBufferList<CR>
```
The mapping is not done by this plugin, so as not to interfere with any existing mappings you may have.

## Settings
### Key Mappings

The following key mappings are used only within the **`[Buffer List]`** buffer. They are configurable by setting the corresponding global variables.

Default Key       | Variable                     | Function
---|---|---
**`o`**           | `g:BufSelectKeyOpen`         | Open the selected buffer in the current window.
**`s`**           | `g:BufSelectKeySplit`        | Split the window horizontally, and open the selected buffer there.
**`v`**           | `g:BufSelectKeyVSplit`       | Split the window vertically, and open the selected buffer there.
**`x`**           | `g:BufSelectKeyDeleteBuffer` | Close the selected buffer using vim's **`:bwipeout`** command.
**`S`**           | `g:BufSelectKeySort`         | Change the sort order, cycling between **Number**, **Status**, **Name**, **Extension**, and **Path**.
**`cd`**          | `g:BufSelectKeyChDir`        | Change the working directory to that of the selected buffer
**`..`**          | `g:BufSelectKeyChDirUp`      | Change the working directory up one level from current
**`#`**           | `g:BufSelectKeySelectOpen`   | Highlight (move cursor to) the next open buffer, those marked with `h` or `a`. See `:h :ls`.
**`0`**...**`9`** | *n/a*                        | Highlight (move cursor to) the next buffer matching the cumulatively-typed buffer number.
**`q`**           | `g:BufSelectKeyExit`         | Exit the buffer list.
**`?`**           |                              | Display short descriptions of these commands.

### Sort Order
The default sort order can be set in the variable `g:BufSelectSortOrder`. The valid values are `"Num"`, `"Status"`, `"Name"`, `"Extension"`, and `"Path"`, with `"Name"` being the default. `"Status"` refers to whether or not that buffer is loaded into Vim. See `:h :ls`.

* `h` means the buffer is loaded and currently hidden.
* `a` identifies the latest active buffer (not counting the Buffer List)
* ` `(space) indicates a file that's been `:badd`ed to vim, but is not yet loaded.
