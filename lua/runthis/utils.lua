local v = vim.api
local M = {}

-- local state to save references
M._postWriteRef = {
	-- {buf[n]} = {
	--   win = number,
	--   client = string{e.g "test.lua"}
	-- },
}

local function bufExists(name)
	for _, buf in pairs(M._postWriteRef) do
		if buf.client == name then
			return true
		end
	end
end

function M.attach_to_buf(command, client)
	local clientBuf, path, name = client.buf, "/" .. client.data.path, client.data.name

	local auGroup = v.nvim_create_augroup("AutoRun " .. name, { clear = true })

	v.nvim_create_autocmd({ "BufWritePost" }, {
		desc = "Creates a buffer to show what's executed on save for the given buf as client",
		group = auGroup,
		callback = function()
			local pluginBufnr

			if not bufExists(name) then
				local newBuf = v.nvim_create_buf(true, true)
				M._postWriteRef[newBuf] = {}
				pluginBufnr = newBuf
				local clientFT = v.nvim_buf_get_option(clientBuf, "filetype")
				v.nvim_buf_set_option(pluginBufnr, "filetype", clientFT)
			else
				for buffer, content in pairs(M._postWriteRef) do
					if name == content.client then
						pluginBufnr = buffer
					end
				end
			end

			local winnr = M._postWriteRef[pluginBufnr].win

			local winExists = false

			for _, val in pairs(v.nvim_list_wins()) do
				if val == winnr then
					winExists = true
					break
				end
			end

			if not winExists then
				vim.cmd([[vsplit]])
				winnr = v.nvim_get_current_win()
				v.nvim_win_set_buf(winnr, pluginBufnr)
				v.nvim_win_set_option(winnr, "winfixwidth", true)
				v.nvim_win_set_width(winnr, 40)
				winExists = true
			end

			local handleStdout = function(_, data)
				if data and table.concat(data) ~= "" then
					table.insert(data, 1, ("Running %s on '%s'"):format(command, name))
					table.insert(data, 2, "-")
					table.insert(data, 2, " ")
					v.nvim_buf_set_lines(pluginBufnr, 0, -1, false, data)
				end
			end

			local finalCommand
			if command == "" then
				finalCommand = { path }
			else
				finalCommand = { command, path }
			end
			vim.fn.jobstart(finalCommand, {
				stdout_buffered = true,
				on_stdout = handleStdout,
				on_stderr = handleStdout,
			})

			-- Save the state for this buf
			M._postWriteRef[pluginBufnr] = {
				win = winnr,
				client = name,
			}
		end,
		pattern = name,
	})
end

function M.detach_buf(name)
	local bufTarget
	for buf, content in pairs(M._postWriteRef) do
		if content.client == name then
			bufTarget = buf
		end
	end
	v.nvim_del_augroup_by_name("AutoRun " .. name)
	v.nvim_buf_delete(bufTarget, { force = true })
	M._postWriteRef[bufTarget] = nil
end
return M
