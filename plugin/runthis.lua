local v = vim.api
local runthis = require("runthis")

local function completion()
	return { "attach", "detach" }
end

v.nvim_create_user_command("RunThis", runthis.prompt, { nargs = "?", complete = completion })
