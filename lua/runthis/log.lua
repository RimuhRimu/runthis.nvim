local M = {}

local utils = require("runthis.utils")
local v = vim.api

function M.createLog(state, client, defaults)
	local bufApp
	-- Check if it doesn't exists already
	if not utils.bufExists(client.name, state) then
		local newBuf = v.nvim_create_buf(true, true)
		local clientFT = v.nvim_buf_get_option(client.buf, "filetype")
		v.nvim_buf_set_option(newBuf, "filetype", clientFT)
		state[newBuf] = {}
		bufApp = newBuf
	else
		-- Otherwise return the existing buffer number
		for buffer, content in pairs(state) do
			if client.name == content.client then
				bufApp = buffer
			end
		end
	end
	P(state)
	P(client)
	P(bufApp)

	local winnr = state[bufApp].win

	if not utils.winExists(winnr) then
		vim.cmd([[vsplit]])
		winnr = v.nvim_get_current_win()
		v.nvim_win_set_buf(winnr, bufApp)
		v.nvim_win_set_option(winnr, "winfixwidth", true)
		v.nvim_win_set_width(winnr, defaults.winConf.width)
	end

	return bufApp, winnr, state
end

return M
