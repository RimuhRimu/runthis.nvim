local v = vim.api

-- local state to save references
local _postWriteRef = {
	-- {buf[n]} = {
	--   win = number,
	--   client = number
	-- },
}

local function bufExists(name)
	for _, buf in pairs(_postWriteRef) do
		if buf.client == name then
			return true
		end
	end
end

local attach_to_buf = function(command, client, clientBuf)
	local name, path = client.name, "/" .. client.path

	local auGroup = v.nvim_create_augroup("AutoRun " .. name, { clear = true })
	v.nvim_create_autocmd({ "BufWritePost" }, {
		desc = "Creates a buffer to show what's executed on save for the given buf as client",
		group = auGroup,
		callback = function()
			local pluginBufnr

			if not bufExists(name) then
				local newBuf = v.nvim_create_buf(true, true)
				_postWriteRef[newBuf] = {}
				pluginBufnr = newBuf
				local clientFT = v.nvim_buf_get_option(clientBuf, "filetype")
				v.nvim_buf_set_option(pluginBufnr, "filetype", clientFT)
			else
				for buffer, content in pairs(_postWriteRef) do
					if name == content.client then
						pluginBufnr = buffer
					end
				end
			end

			local winnr = _postWriteRef[pluginBufnr].win

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
			_postWriteRef[pluginBufnr] = {
				win = winnr,
				client = name,
			}
		end,
		pattern = name,
	})
end
return attach_to_buf
