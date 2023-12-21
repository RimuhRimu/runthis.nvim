local M = {}
local v = vim.api

--- @return table
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

-- Parses the current buffers opened
-- like this:
-- 1. buf1name
-- 2. buf2name
-- 3. ...
--- @param bufList table
--- @return string
function M.getBufListText(bufList)
	local text = ""
	local i = 0
	for _, bufInfo in pairs(bufList) do
		i = i + 1
		text = text .. ("\n%s %s"):format(i, bufInfo.name)
	end
	return text
end

-- Converts a string a table by splitting it into separate parameters.
-- Each parameter consists of one or more printable (non-space)characters (%g+ by default).
-- Parameters are stored in the table as separate elements.
--
--- @param str string input string to convert
--- @param pattern? string optinal pattern
--- @return table
function M.toTable(str, pattern)
	local t, i = {}, 1
	for param in string.gmatch(str, pattern or "%g+") do
		t[i] = param
		i = i + 1
	end
	return t
end

local compilers = {
	java = function(absPath)
		vim._system(("javac %s"):format(absPath))
		return "./" .. absPath:sub(1, absPath:find(".java") - 1)
	end,
	c = function(absPath)
		vim._system(("clang %s -o %s"):format(absPath, "main"))
		return "./main"
	end,
	cpp = function(absPath)
		vim._system(("clang %s -o %s"):format(absPath, "main"))
		return "./main"
	end,
	rs = function(absPath)
		vim._system(("rustc -C linker=clang %s"):format(absPath))
		return "./" .. absPath:sub(1, absPath:find(".rs") - 1)
	end,
}

--- @return string command, string? origialCommand What will be ran on the file
function M.parseCommand(client, command, runAbles)
	local absPath = "/" .. client.data.path
	local extension = absPath:sub(-absPath:reverse():find("%.") + 1, -1)

	if #command == 0 then
		if v.nvim_buf_get_lines(client.buf, 0, 1, true)[1]:sub(1, 2) == "#!" then
			command = v.nvim_buf_get_lines(client.buf, 0, 1, true)[1]:sub(3, -1)
		elseif not runAbles[extension] then
			return "echo 'No executable found for this file'"
		else
			command = runAbles[extension]
		end
	end

	if compilers[extension] then
		return compilers[extension](absPath), command
	else
		return command .. " " .. absPath, command
	end
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
