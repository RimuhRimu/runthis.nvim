# runthis.nvim
automatically run code on save and see the output inside neovim :)

install it with your favorite plugin manager
```
use{"RimuhRimu/runthis.nvim"} //example with packer
```

## Usage
execute in command mode
```
:RunThis or :Runthis attach //will auto run the current buf if just 1 open
```

you'll be prompted the following

```
What buffer do you choose?: ... //you'll be shown the buffers currently open
1. {buf1}
2. {buf2}
3. {buf3}
...

What command should be executed?(whole command with options): ... //if left empty it will use the shebang in the file
```
now when you save that buffer you'll see a split buffer with the results

you can stop executing on save with
```
:Runthis detach //you'll be asked what buffer you want to detach
```

![sh1](./screenshots/sh1.png) 

## NOTE
It still doesn't work quite well with compiled languages, I'll rewrite this probably to make it work though

## TODO

- [ ] rewrite prompt to allow autocompletion for path and commands
- [ ] track if the name of the file changes
- [ ] add a `attach/detach current` command
