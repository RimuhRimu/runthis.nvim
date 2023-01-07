local M = {}
local v = vim.api

local utils = require("runthis.utils")

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

function M.prompt(task)
	local bufList = M.getBufList()

	local function getBufListText()
		local text = ""
		local i = 0
		for _, bufInfo in pairs(bufList) do
			i = i + 1
			text = text .. ("\n%s %s"):format(i, bufInfo.name)
		end
		return text
	end

	local bufTextList = getBufListText()
	local bufTarget = vim.fn.input({
		prompt = "What buffer do you choose?: " .. bufTextList .. "\n",
	})

	local selectedBuf
	local i = 0
	for bufNum, _ in pairs(bufList) do
		i = i + 1
		if i == tonumber(bufTarget) then
			selectedBuf = bufNum
			break
		end
	end
	local client = { buf = selectedBuf, data = bufList[selectedBuf] }
	local handlers = {
		["attach"] = function()
			local command = vim.fn.input("What command should be executed?(whole command with options): ")
			utils.attach_to_buf(command, client)
		end,
		["detach"] = function()
			utils.detach_buf(client.data.name)
		end,
	}
	local trigger
	if #task.args == 0 then
		trigger = "attach"
	else
		trigger = task.args
	end
	handlers[trigger]()
end
return M
