local M = {}
local v = vim.api

function M.getBufList()
	local bufList = {}
	for _, buf in pairs(v.nvim_list_bufs()) do
		local bufInList = v.nvim_buf_get_option(buf, "buflisted")
		local bufPath = string.sub(v.nvim_buf_get_name(buf), 2, -1)

		if bufInList and bufPath ~= "" then
			local lastSlash
			local bufName = ""

			for i = 1, #bufPath do
				local char = bufPath:sub(i, i)
				if i == #bufPath then
					bufName = bufPath:sub(lastSlash + 1, -1)
				else
					if char == "/" then
						lastSlash = i
					end
				end
			end
			bufList[buf] = {
				path = bufPath,
				name = bufName,
			}
		end
	end

	return bufList
end

function M.getBufListText(bufList)
	local text = ""
	local i = 0
	for _, bufInfo in pairs(bufList) do
		i = i + 1
		text = text .. ("\n%s %s"):format(i, bufInfo.name)
	end
	return text
end

function M.tableLength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

function M.toTable(str)
	local t, i = {}, 1
	for param in string.gmatch(str, "%g+") do
		t[i] = param
		i = i + 1
	end
	return t
end

function M.parseCommand(client, command, runAbles)
	local auxCommand = command
	local useShebang = false
	local firstLine = v.nvim_buf_get_lines(client.buf, 0, 1, true)[1]
	local Cname = client.data.name
	local extension = Cname:sub(-Cname:reverse():find("%.") + 1, -1)
	-- case empty command check if shebang exists
	if #auxCommand == 0 and firstLine:sub(1, 2) == "#!" then
		auxCommand = firstLine:sub(3, -1)
		useShebang = true
	-- otherwise try to find a possible executable
	elseif runAbles[extension] then
		local runable = runAbles[extension]
		-- TODO: check if the program exists instead of just using the first
		auxCommand = runable
	else
		-- TODO: show a message tha says theres not an executable for this file
		auxCommand = "echo"
	end
	return auxCommand, useShebang
end

function M.bufExists(name, ref)
	for _, buf in pairs(ref) do
		if buf.client == name then
			return true
		end
	end
end

function M.winExists(winnr)
	for _, val in pairs(v.nvim_list_wins()) do
		if val == winnr then
			return true
		end
	end
end

return M
