# BufSelect

## Summary

![image](media/darkScreenshot.png) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ![image](media/lightScreenshot.png)

**BufSelect** is a minimalist buffer switcher plugin for Vim or Neovim. It is a much lighter-weight alternative to [bufexplorer](https://github.com/jlanzarotta/bufexplorer) and [buffergator](https://github.com/jeetsukumaran/vim-buffergator), both of which I'd used in the past. To achieve this, I removed functionality I didn't really find necessary. What it ended up being is:

* A single command to kick things off (`:ShowBufferList`).
* A simple list showing, in a floating window, the buffer number, filename, and relative path of all listed buffers. The buffer list is generated each time the command is called, rather than being maintained behind the scenes with autocommands. This simplifies the code considerably.
* A few key mappings to open and delete buffers, sort the list, change working directory, and quickly move between buffers.

## Installation

Use your favorite plugin manager to install this plugin. [vim-pathogen](https://github.com/tpope/vim-pathogen), [Vundle.vim](https://github.com/VundleVim/Vundle.vim), [vim-plug](https://github.com/junegunn/vim-plug), [neobundle.vim](https://github.com/Shougo/neobundle.vim), and [Packer.nvim](https://github.com/wbthomason/packer.nvim) are some of the more popular ones. A lengthy discussion of these and other managers can be found on [vi.stackexchange.com](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers).

If you have no favorite, or want to manage your plugins without 3rd-party dependencies, I recommend using packages, as described in Greg Hurrell's excellent Youtube video: [Vim screencast #75: Plugin managers](https://www.youtube.com/watch?v=X2_R3uxDN6g)

## Compatibility

The `master` branch of this plugin is no longer compatible with Vim, and all new development will target Neovim. If you are using Vim 8+, you can still use this plugin; just checkout the `vim-compatible` branch.

## Command

The only command is **`:ShowBufferList`**, which can be assigned to a key. The mapping is not done by this plugin, so as not to interfere with your existing mappings. Here is how you would map the command:
```vim
nnoremap <silent> <leader>b :ShowBufferList<CR>
```

## Settings
### Key Mappings

The following key mappings are used only within the BufSelect list.

The first group are configurable by changing the value in the global variables. The default values are shown here, and only the keys you want to change need to be included in your `.vimrc`.

```vim
let g:BufSelectKeyOpen         = 'o'  " Open the buffer in the current window.
let g:BufSelectKeySplit        = 's'  " Open the buffer in a new horzontal split.
let g:BufSelectKeyVSplit       = 'v'  " Open the buffer in a new vertical split.
let g:BufSelectKeyTab          = 't'  " Open the buffer in a new tab.
let g:BufSelectKeyDeleteBuffer = 'x'  " Close the buffer using vim's bwipeout command.
let g:BufSelectKeySort         = 'S'  " Change the sort order.
let g:BufSelectKeyChDir        = 'cd' " Change working directory to match the buffer's
let g:BufSelectKeyChDirUp      = '..' " Change working directory up one level from current
let g:BufSelectKeySelectOpen   = '#'  " Move cursor to the next listed open buffer,
let g:BufSelectKeyExit         = 'q'  " Exit the buffer list.
```
The following keys are not configurable.
* <kbd>Enter</kbd> opens a buffer in the current window. It's the same as `g:BufSelectKeyOpen`.
* <kbd>Esc</kbd> exits the buffer list - the same as `g:BufSelectKeyExit`.
* <kbd>0</kbd>...<kbd>9</kbd> moves the cursor to the next buffer matching the cumulatively-typed buffer number.
* <kbd>?</kbd> displays short descriptions of these commands.

### Sort Order
The default sort order can be set with this statement, which shows the default:
```vim
let g:BufSelectSortOrder = 'Name'
```
Valid values are `'Num'`, `'Status'`, `'Name'`, `'Extension'`, and `'Path'`.

`'Status'` refers to whether or not that buffer is loaded into Vim. See `:help :ls`, which states:

* `a` an active buffer: it is loaded and visible
* `h` a hidden buffer: it is loaded, but currently not displayed in a window
* ` `(space) indicates a file that's been added (see `:help :badd`), but is not yet loaded.

### Custom Highlighting
The colors used in BufSelect were picked to work in both dark and light backgrounds, but they can be customized if desired, by changing these variables. Their default values are shown here:

```vim
let g:BufSelectHighlightCurrent = 'guibg=NONE guifg=#5F87FF ctermbg=NONE ctermfg=69'
let g:BufSelectHighlightAlt     = 'guibg=NONE guifg=#5FAF00 ctermbg=NONE ctermfg=70'
let g:BufSelectHighlightUnsaved = 'guibg=NONE guifg=#FF5F00 ctermbg=NONE ctermfg=202'
let g:BufSelectHighlightSort    = 'guibg=NONE guifg=#FF8700 ctermbg=NONE ctermfg=208'
```

The syntax above shows how to hard-code the colors. The value must adhere to valid syntax when used as `{args}` when placed into a `:highlight {group-name} {args}` statement. See `:help :highlight-args` for more detail.

To match a colorscheme's colors, use the syntax below to link to an existing highlight group. Change `Statement` as appropriate.

```vim
let g:BufSelectHighlightCurrent = 'link Statement'
```
