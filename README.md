# BufSelect

## Summary

**BufSelect** is a minimalist buffer switcher plugin for Vim or Neovim. It was inspired by [bufexplorer](https://github.com/jlanzarotta/bufexplorer) and [buffergator](https://github.com/jeetsukumaran/vim-buffergator), but with some of their advanced functionality removed. What **BufSelect** ended up being is:

* A [single command](#command) to kick things off.
* A simple list in a floating window, showing the buffer number, filename, and relative path of all listed buffers. The list is generated each time **BufSelect** is displayed, thereby simplifying the code considerably.

    ![image](media/darkScreenshot.png)
    <br/>**Figure 1**: BufSelect on a dark background

* A few [key mappings](#key-mappings) to open and delete buffers, sort the list, change working directory, and quickly move between buffers.
* Other settings define [sort order](#sort-order) and [custom highlighting](#custom-highlighting).

## Installation

Use your favorite plugin manager. If you don't have one, try one of these: [vim-pathogen](https://github.com/tpope/vim-pathogen), [vim-plug](https://github.com/junegunn/vim-plug), [Packer.nvim](https://github.com/wbthomason/packer.nvim) or [lazy.nvim](https://github.com/folke/lazy.nvim). Alternatively, you can use packages and submodules, as Greg Hurrell ([@wincent](https://github.com/wincent)) describes in his excellent Youtube video: [Vim screencast #75: Plugin managers](https://www.youtube.com/watch?v=X2_R3uxDN6g)

## Compatibility

The `master` branch of this plugin is no longer compatible with Vim, and all new development will target Neovim. If you are using Vim 8+, you can still use this plugin without all the newer functionality; just checkout the `vim-compatible` branch.

## Command

The only command is **`:ShowBufferList`**, which can be assigned to a key. The mapping is not done by this plugin, so as not to interfere with your existing mappings. Here's an example of how you would map the command:
```vim
" vim script
nnoremap <silent> <leader>b :ShowBufferList<CR>
```
```lua
-- lua
vim.api.nvim_set_keymap('n', '<leader>b', ':ShowBufferList<CR>', {noremap=true, slient=true})
```

## Settings

Settings for **BufSelect** formerly were specified by 15 separate variables. They now are deprecated in favor of a single dictionary variable named `g:BufSelectSetup`. Using any of the old variables still will work but will cause a warning to be displayed.

The structure of the dictionary follows. Only the settings you want to override need to be specified. All others will have the default value, which also is shown here. The corresponding old variables are in the last column.

<table>
    <thead>
        <tr>
            <th>Vim Script</th><th>Lua</th><th>Corresponding Old Variable</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
<pre>
let g:BufSelectSetup={
\ 'mappings':{
 \ 'open':'o',
 \ 'split':'s',
 \ 'vsplit':'v',
 \ 'tab':'t',
 \ 'gopen':'go',
 \ 'gsplit':'gs',
 \ 'gvsplit':'gv',
 \ 'gtab':'gt',
 \ 'exit':'q',
 \ 'find':'f',
 \ 'delete':'x',
 \ 'sort':'S',
 \ 'cd':'cd',
 \ 'cdup':'..',
 \ 'next':'#'
\ },
\ 'sortOrder':'Name',
\ 'win':{
 \ 'config':{'border':'double'},
 \ 'hl':''
 \ }
\ }
</pre>
            </td>
            <td>
<pre>
vim.g.BufSelectSetup={
 mappings={
  open='o',
  split='s',
  vsplit='v',
  tab='t',
  gopen='go',
  gsplit='gs',
  gvsplit='gv',
  gtab='gt',
  exit='q',
  find='f',
  delete='x',
  sort='S',
  cd='cd',
  cdup='..',
  next='#'
 },
 sortOrder='Name',
 win={
  config={border='double'},
  hl=''
 }
}
</pre>
            </td>
            <td>
<pre>
           •
           •
BufSelectKeyOpen
BufSelectKeySplit
BufSelectKeyVSplit
BufSelectKeyTab
BufSelectKeyPreviewOpen
BufSelectKeyPreviewSplit
BufSelectKeyPreviewVSplit
BufSelectKeyPreviewTab
BufSelectKeyExit
BufSelectKeyFind
BufSelectKeyDeleteBuffer
BufSelectKeySort
BufSelectKeyChDir
BufSelectKeyChDirUp
BufSelectKeySelectOpen
           •
BufSelectSortOrder
           •
BufSelectFloatWinConfig
(No old variable)
           •
           •
</pre>
            </td>
        </tr>
    </tbody>
</table>

### Key Mappings

The `'mappings'` dictionary defines the key mappings that work only within **BufSelect**. They perform the following functions:

| Dictionary Key | Function |
| :-: | --- |
| `'open'`    | Open the buffer in the current window, meaning the one under the **BufSelect** floating window. |
| `'split'`   | Open the buffer in a new horizontal split. |
| `'vsplit'`  | Open the buffer in a new vertical split. |
| `'tab'`     | Open the buffer in a new tab. |
| | |
| `'gopen'`   | Preview the buffer in the current window, keeping **BufSelect** open. |
| `'gsplit'`  | Preview the buffer in a new horizontal split, keeping **BufSelect** open. |
| `'gvsplit'` | Preview the buffer in a new vertical split, keeping **BufSelect** open. |
| `'gtab'`    | Preview the buffer in a new tab, keeping **BufSelect** open. |
| | |
| `'find'`    | Find the buffer in any open window, and go there. |
| `'delete'`  | Close the buffer using vim's `bwipeout` command. |
| `'sort'`    | Change the sort order. |
| `'cd'`      | Change working directory to match the buffer's. |
| `'cdup'`    | Change working directory up one level from current. |
| `'next'`    | Move cursor to the next listed open buffer. |
| `'exit'`    | Exit the buffer list. |

Some other mappings are non-configurable. They are:

| Mapping | Function |
| :-: | --- |
| <kbd>Enter</kbd> | opens a buffer in the current window. It's the same as `'open'`. |
| <kbd>Esc</kbd> | exits the buffer list - the same as `'exit'`. |
| <kbd>0</kbd>...<kbd>9</kbd> | moves the cursor to the next buffer matching the cumulatively-typed buffer number. See **Figure 2** below for illustration.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. Typing <kbd>3</kbd> will search for and find buffer **3**.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. Then typing <kbd>2</kbd> will search for and find buffer **32**.<br>&nbsp;&nbsp;&nbsp;3a. Then pressing <kbd>4</kbd> will look for buffer **324**.<br>&nbsp;&nbsp;&nbsp;3b. It doesn't exist, so drop the leading search digit and look for **24**.<br>&nbsp;&nbsp;&nbsp;3c. That doesn't exist either, so drop the **2** and look for buffer **4**, which exists. The search is over. |
| <kbd>?</kbd> | shows/hides short descriptions of all mappings. |

![image](media/lightScreenshot.png)
<br/>**Figure 2**: On a light background, with help text shown. *(Note that `'open'`, `'gopen'`, and `'delete'` were overridden in this screenshot.)*

### Sort Order
The initial sort order is set by the `'sortOrder'` setting. Valid values are `'Num'`, `'Status'`, `'Name'`, `'Extension'`, and `'Path'`.

`'Status'` refers to whether a buffer is loaded or visible. See [:help :ls](https://neovim.io/doc/user/windows.html#%3Als), which states:

* `a` an active buffer: it is loaded and visible
* `h` a hidden buffer: it is loaded, but currently not displayed in a window
* ` `(space) indicates a file that's been added (see [:help :badd](https://neovim.io/doc/user/windows.html#%3Abadd)), but is not yet loaded.

### Floating Window Customizations

The **BufSelect** floating window can be customized two different ways in the `'win'` dictionary, which contains these two items:

1. The `'config'` dictionary lets you change things like the border and title of the window. Check out [:help nvim_open_win()](https://neovim.io/doc/user/api.html#nvim_open_win()) for more for details. Example:

    ```vim
    " vim script
    let g:BufSelectSetup = {'win': {'config': {'border': 'single', 'title': ' Buffers: '}}
    ```
    ```lua
    -- lua
    vim.g.BufSelectSetup = {win={config={border='single',title=' Buffers: '}}
    ```
    
    ![image](media/floatwinconfig.png)
    <br/>**Figure 3**: BufSelect with a single border and a title

1. The `'hl'` string setting is used to override highlighting. Read [:help 'winhl'](https://neovim.io/doc/user/options.html#'winhl') to see how it works. For example, if your colorscheme doesn't define `NormalFloat`, you can use this to make it look like the normal background. It also works to link the **BufSelect** highlight groups to other highlight groups. Both scenarios are shown in this example:

    ```vim
    " vim script
    let g:BufSelectSetup = {'win': {'hl': 'NormalFloat:Normal,BufSelectCurrent:Keyword'}}
    ```
    ```lua
    -- lua
    vim.g.BufSelectSetup = {win={hl='NormalFloat:Normal,BufSelectCurrent:Keyword'}}
    ```

    The highlight groups defined for **BufSelect** are:

    * `BufSelectSort` - the sort indicator
    * `BufSelectCurrent` - the current buffer (also indicated by a `%`) and the current working directory
    * `BufSelectAlt` - the alternate buffer (also indicated by a `#`)
    * `BufSelectUnsaved` - unsaved buffers (also indicated by a `+`)
    * `BufSelectHelp` - the question mark in `? for help`, and the list of mapped keys in the help text
