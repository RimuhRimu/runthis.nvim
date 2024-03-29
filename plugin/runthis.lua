local v = vim.api
local runthis = require("runthis")
local completionOptions = {
	[""] = { "attach", "detach" },
	["first"] = { "current" },
	primary = {},
}
local function completion(ArgLead, CmdLine, CursorPos)
	local params = vim.split(CmdLine, "%s+", { trimempty = true })
	if params[2] == "attach" or params[2] == "detach" then
		return completionOptions["first"]
	elseif params[1] == "RunThis" and #params <= 2 then
		return completionOptions[""]
	end
	return completionOptions
end

v.nvim_create_user_command("RunThis", runthis.prompt, { nargs = "?", complete = completion })
