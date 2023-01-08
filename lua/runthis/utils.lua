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

function M.toTable(str)
	local t, i = {}, 1
	for param in string.gmatch(str, "%g+") do
		t[i] = param
		i = i + 1
	end
	return t
end

return M
