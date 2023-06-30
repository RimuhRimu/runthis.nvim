---@diagnostic disable: undefined-global
describe("setup with defaults", function()
	it("should be able to load runthis with defaults", function()
		local r = require("runthis")
		r.setup({})
		assert(r.defaults.winConf.width, 40)
	end)

	it("should be able to load runthis with custom width", function()
		local r = require("runthis")
		r.setup({ winConf = { width = 100 } })
		assert(r.defaults.winConf.width, 100)
	end)
end)
