# bufselect.vim

![image](https://user-images.githubusercontent.com/5598066/187665965-1e0c922b-8ae3-4075-ba06-80e56629e6d0.png)

**bufselect.vim** is a minimalist alternative to [bufexplorer](https://github.com/jlanzarotta/bufexplorer) and [buffergator](https://github.com/jeetsukumaran/vim-buffergator), both of which I'd used in the past. I wanted this plugin to be a lot lighter weight, so I removed functionality I didn't really find necessary. What it ended up being is:

* a simple list that shows the buffer number, filename, and relative path of the buffers you see in the `:ls` command
* a few key mappings to do the following tasks:
    * open the buffer (<kbd>o</kbd>), including into splits (<kbd>s</kbd>, <kbd>v</kbd>) or a new tab (<kbd>t</kbd>)
    * delete buffer from Vim (<kbd>x</kbd>)
    * sort the list (<kbd>S</kbd>)
    * change the working directory (<kbd>..</kbd>, <kbd>cd</kbd>)
    * highlight open buffers in the list (<kbd>#</kbd>)
    * highlight buffers by number (<kbd>0</kbd>...<kbd>9</kbd>)
* a single command to kick things off (`:ShowBufferList`)
* a non-persistent list of buffers. The buffer list is generated each time the command is called, rather than being maintained behind the scenes with autocommands. This simplifies the code considerably.

## Installation

Use your favorite plugin manager to install this plugin. [vim-pathogen](https://github.com/tpope/vim-pathogen), [Vundle.vim](https://github.com/VundleVim/Vundle.vim), [vim-plug](https://github.com/junegunn/vim-plug), [neobundle.vim](https://github.com/Shougo/neobundle.vim), and [Packer.nvim](https://github.com/wbthomason/packer.nvim) are some of the more popular ones. A lengthy discussion of these and other managers can be found on [vi.stackexchange.com](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers).

If you have no favorite, or want to manage your plugins without 3rd-party dependencies, I recommend using packages, as described in Greg Hurrell's excellent Youtube video: [Vim screencast #75: Plugin managers](https://www.youtube.com/watch?v=X2_R3uxDN6g)

## Compatibility

The `master` branch of this plugin is no longer compatible with vim, as it uses functions found only in Neovim to display BufSelect in a floating window. When opening a buffer into the same tab, it is done relative to the window underneath the floating BufSelect window.

If you are using Vim 8+, not Neovim, you can still use this plugin; just checkout the `vim-compatible` branch. This branch will display BufSelect in the current window, as it always has.

## Command

The only command is **`:ShowBufferList`**, which can be assigned to a key. For example,
```vim
nnoremap <silent> <leader>b :ShowBufferList<CR>
```
The mapping is not done by this plugin, so as not to interfere with any existing mappings you may have.

## Settings
### Key Mappings

The following key mappings are used only within the BufSelect list. They are configurable by setting the corresponding global variables.

Default Key | Variable | Function
:-:|---|---
<kbd>o</kbd><br><kbd>Enter</kbd> | `g:BufSelectKeyOpen`<br>*n/a* | Open the selected buffer in the current window. <kbd>Enter</kbd> is unconfigurable.
<kbd>s</kbd>                     | `g:BufSelectKeySplit`         | Split the window horizontally, and open the selected buffer in the new window.
<kbd>v</kbd>                     | `g:BufSelectKeyVSplit`        | Split the window vertically, and open the selected buffer in the new window.
<kbd>t</kbd>                     | `g:BufSelectKeyTab`           | Open the selected buffer in a new tab.
<kbd>x</kbd>                     | `g:BufSelectKeyDeleteBuffer`  | Close the selected buffer using vim's `:bwipeout` command.
<kbd>S</kbd>                     | `g:BufSelectKeySort`          | Change the sort order: **Number**, **Status**, **Name**, **Extension**, or **Path**.
<kbd>cd</kbd>                    | `g:BufSelectKeyChDir`         | Change the working directory to match the selected buffer's
<kbd>..</kbd>                    | `g:BufSelectKeyChDirUp`       | Change the working directory up one level from current
<kbd>#</kbd>                     | `g:BufSelectKeySelectOpen`    | Move cursor to the next open buffer, those marked with `h` or `a`. See `:h :ls`.
<kbd>0</kbd>...<kbd>9</kbd>      |                               | Move cursor to the next buffer matching the cumulatively-typed buffer number.
<kbd>q</kbd>                     | `g:BufSelectKeyExit`          | Exit the buffer list.
<kbd>?</kbd>                     |                               | Display short descriptions of these commands.

### Sort Order
The default sort order can be set in the variable `g:BufSelectSortOrder`. The valid values are `"Num"`, `"Status"`, `"Name"`, `"Extension"`, and `"Path"`, with `"Name"` being the default. `"Status"` refers to whether or not that buffer is loaded into Vim. See `:h :ls`.

* `h` means the buffer is loaded and currently hidden.
* `a` identifies the latest active buffer (not counting the Buffer List)
* ` `(space) indicates a file that's been `:badd`ed to vim, but is not yet loaded.
