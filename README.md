# bufselect

I wrote this as a much scaled-down alternative to [bufexplorer](https://github.com/jlanzarotta/bufexplorer), with commands mapped to same keys used by my new favorite file manager, [vifm](http://vifm.info/). There is no customization in this plugin, and the keys are mapped as follows:

Key | Function
---+---
h | Exit the buffer list. I know it seems strange, but it mirrors vifm's `go up a folder` key.
l | Open this buffer in the window. This mirrors vifm's `open` key.
j/k | Move down or up the list. Other motions will work too, but not `h` or `l`.
d | Close the buffer. This actually uses vim's `:bwipeout` command.
? | Display a short message describing these commands.
