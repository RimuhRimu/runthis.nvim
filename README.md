# runthis.nvim
automatically run code on save and see the output inside neovim :)

## Usage
execute in command mode
```
:RunThis
```

you'll be prompted the following

```
What buffer should be ran?: ... //you'll be shown the buffers currently open
1. {buf1}
2. {buf2}
3. {buf3}
...

What command should be executed?: ...
What options should be added?: ... // this is optional ;-;
```
now when you save that buffer you'll see a split buffer with the results

![sh1](./screenshots/sh1.png) 
