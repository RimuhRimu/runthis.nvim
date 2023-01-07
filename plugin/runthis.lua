local v = vim.api
local runthis = require("runthis")

-- TODO: add the option to opt for not deleting buff content on save and just append it instead
-- TODO: implement a pre-set of commands e.g {python3,node,deno,lua,...}

local function completion()
	return { "attach", "detach" }
end

v.nvim_create_user_command("RunThis", runthis.prompt, { nargs = "?", complete = completion })
