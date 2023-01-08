--[[ local v = vim.api ]]
local commands = {
	js = "node",
	python = "python3",
	lua = "lua",
}
local utils = require("runthis.utils")
describe("runthis tests", function()
	it("loads runthis", function()
		require("runthis")
		require("runthis.utils")
	end)

	it("attach and detach buf", function()
		local r = require("runthis")
		vim.cmd([[:e test/test.js]])
		local bufList = utils.getBufList()
		local client = {
			buf = 0,
			data = {
				name = bufList[1].name,
				path = bufList[1].path,
			},
		}
		r.attach_to_buf(commands.js, client)
		vim.cmd([[:w]])
		r.detach_buf(client.data.name)
	end)
end)
