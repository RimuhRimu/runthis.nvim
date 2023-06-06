---@diagnostic disable: undefined-global
describe("shebang test", function()
	local v = vim.api
	it("parse shebang", function()
		-- make use of coroutines due to async functionality of saving files
		local co = coroutine.running()
		local utils = require("runthis.utils")
		local r = require("runthis")
		-- INFO: uses deno
		vim.cmd([[:e test/test_shebang.ts]])
		local bufList = utils.getBufList()
		local client = {
			buf = 0,
			data = {
				name = bufList[next(bufList)].name,
				path = bufList[next(bufList)].path,
			},
		}
		r.attach_to_buf("", client)
		vim.cmd([[:w]])

		local bufContent
		vim.defer_fn(function()
			local pluginWin = v.nvim_list_wins()[next(v.nvim_list_wins(), 1)]
			local pluginBuf = v.nvim_win_get_buf(pluginWin)
			bufContent = v.nvim_buf_get_lines(pluginBuf, 3, -2, false)
			coroutine.resume(co)
		end, 2000)

		coroutine.yield()

		r.detach_buf(client.data.name)
		vim.cmd([[:bdel]])

		assert.equals(bufContent[1], "This is a test")
		assert.equals(bufContent[2], "[ 2, 4 ]")
	end)
end)
