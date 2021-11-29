# bufselect.vim

This is a minimalist alternative to [bufexplorer](https://github.com/jlanzarotta/bufexplorer) and [buffergator](https://github.com/jeetsukumaran/vim-buffergator), both of which I'd used in the past. I wanted this plugin to be a lot lighter weight, so I removed functionality I didn't really find necessary. What it ended up being is:

* a very clean list that shows the buffer number, filename, and relative path of the buffers you see in the `:ls` command
* a few key mappings to do the following tasks:
    * open buffer, including into splits or a new tab (**`o`**, **`s`**, **`v`**, **`t`**)
    * delete buffer from Vim (**`x`**)
    * sort the list (**`S`**)
    * change the working directory (**`..`**, **`cd`**)
    * highlight open buffers in the list (**`#`**)
    * highlight buffers by number (**`0`**...**`9`**)
* a single command to kick things off (**`:ShowBufferList`**)
* a non-persistent list of buffers. The buffer list is generated each time the command is called, rather than being maintained behind the scenes with autocommands. This simplifies the code considerably.

## Installation

Use your favorite plugin manager to install this plugin. [vim-pathogen](https://github.com/tpope/vim-pathogen), [Vundle.vim](https://github.com/VundleVim/Vundle.vim), [vim-plug](https://github.com/junegunn/vim-plug), [neobundle.vim](https://github.com/Shougo/neobundle.vim), and [dein.vim](https://github.com/Shougo/dein.vim) are some of the more popular ones. A lengthy discussion of these and other managers can be found on [vi.stackexchange.com](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers).

If you have no favorite, or want to manage your plugins without 3rd-party dependencies, I recommend using Vim 8 packages, as described in Greg Hurrell's excellent Youtube video: [Vim screencast #75: Plugin managers](https://www.youtube.com/watch?v=X2_R3uxDN6g)

## Command

The only command is **`:ShowBufferList`**, which can be assigned to a key. For example,
```vim
nnoremap <silent> <leader>b :ShowBufferList<CR>
```
The mapping is not done by this plugin, so as not to interfere with any existing mappings you may have.

## Settings
### Key Mappings

The following key mappings are used only within the **`[Buffer List]`** buffer. They are configurable by setting the corresponding global variables.

Default Key | Variable | Function
---|---|---
**`o`**<br>**`<CR>`** | `g:BufSelectKeyOpen`<br>*n/a* | Open the selected buffer in the current window. `<CR>` is unconfigurable.
**`s`**               | `g:BufSelectKeySplit`         | Split the window horizontally, and open the selected buffer there.
**`v`**               | `g:BufSelectKeyVSplit`        | Split the window vertically, and open the selected buffer there.
**`t`**               | `g:BufSelectKeyTab`           | Open the selected buffer in a new tab.
**`x`**               | `g:BufSelectKeyDeleteBuffer`  | Close the selected buffer using vim's **`:bwipeout`** command.
**`S`**               | `g:BufSelectKeySort`          | Change the sort order, cycling between **Number**, **Status**, **Name**, **Extension**, and **Path**.
**`cd`**              | `g:BufSelectKeyChDir`         | Change the working directory to that of the selected buffer
**`..`**              | `g:BufSelectKeyChDirUp`       | Change the working directory up one level from current
**`#`**               | `g:BufSelectKeySelectOpen`    | Highlight (move cursor to) the next open buffer, those marked with `h` or `a`. See `:h :ls`.
**`0`**...**`9`**     |                               | Highlight (move cursor to) the next buffer matching the cumulatively-typed buffer number.
**`q`**               | `g:BufSelectKeyExit`          | Exit the buffer list.
**`?`**               |                               | Display short descriptions of these commands.

### Sort Order
The default sort order can be set in the variable `g:BufSelectSortOrder`. The valid values are `"Num"`, `"Status"`, `"Name"`, `"Extension"`, and `"Path"`, with `"Name"` being the default. `"Status"` refers to whether or not that buffer is loaded into Vim. See `:h :ls`.

* `h` means the buffer is loaded and currently hidden.
* `a` identifies the latest active buffer (not counting the Buffer List)
* ` `(space) indicates a file that's been `:badd`ed to vim, but is not yet loaded.
