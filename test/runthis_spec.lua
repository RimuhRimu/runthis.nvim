describe("basic functionatily tests", function()
	it("loads runthis", function()
		require("runthis")
		require("runthis.utils")
	end)

	it("attach and detach buf", function()
		local utils = require("runthis.utils")
		local r = require("runthis")
		vim.cmd([[:e test/test.js]])
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
		r.detach_buf(client.data.name)
		vim.cmd([[:bdel]])
	end)
end)

describe("shebang test", function()
	it("parse shebang", function()
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
		r.detach_buf(client.data.name)
		vim.cmd([[:bdel]])
	end)
end)
