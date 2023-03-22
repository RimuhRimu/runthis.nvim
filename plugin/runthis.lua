local v = vim.api
local runthis = require("runthis")
local completionSource = {
	[""] = { "attach", "detach" },
	primary = {},
}
local function completion(leadArg, CmdLine, cursorPos)
	local hasSpace = string.match(CmdLine, "%s$")
	local params = vim.split(CmdLine, "%s+", { trimempty = true })
	if #params == 1 then
		return completionSource[""]
	end
	return completionSource
end

v.nvim_create_user_command("RunThis", runthis.prompt, { nargs = "?", complete = completion })
