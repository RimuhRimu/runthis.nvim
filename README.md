# runthis.nvim
automatically run code on save and see the output inside neovim :)

install it with your favorite plugin manager
```
use {
  "RimuhRimu/runthis.nvim",
  module = "runthis"
  } //example with packer
```

## Usage
execute in command mode or add your custom key map
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

What command should be executed?(whole command with options): ... 
//if left empty it will use the shebang in the file
//or if it has no shebang it will try to guess how to run it
```
now when you save that buffer you'll see a split buffer with the results

you can stop executing on save with
```
:Runthis detach //you'll be asked what buffer you want to detach
```

## Config

you can change the default size of the window or the default programs to run certain
extensions if you do not provide a command or it does not have a shebang

```lua
local r = require("runthis")
r.setup({
  programs = {
    ["js"] = "deno run"
  },
  window = {
    width = 50
  }
})
```

these are the defaults

```lua
local runAbles = {
	-- rust, c, and c++ are treated differently due to the compile process
	["py"] = "python3",
	["js"] = "node",
	["lua"] = "lua",
	["hs"] = "runhaskell",
	["ts"] = "deno run --allow-net --allow-read --allow-write --allow-env --unstable",
	["go"] = "go run",
	["rb"] = "ruby",
	["rs"] = "",
	["c"] = "./main",
	["cpp"] = "./main",
	["java"] = "java",
	["sh"] = "sh",
	["fish"] = "fish",
}

local defaults = {
	runAbles = runAbles,
	winConf = {
		width = 40,
	},
}
```

# Preview

![sh1](https://github.com/RimuhRimu/runthis.nvim/assets/68438095/abd469fd-21fe-47dc-b864-388877d1b9b8)

## NOTE

1. I do not usually code with compiled languages so I don't think I'll tweak much the plugin for compiled languages,feel free to make pull requests
2. Obviously you cannot handle stdin using this plugin, at least not yet
3. If you want to run code selection you can use the built-in method
`vim.api.nvim_set_keymap('v', '<leader>r', ':w !python3<CR>', {noremap = true})`
