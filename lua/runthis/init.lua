local M = {}
local v = vim.api
local fn = vim.fn

local utils = require("runthis.utils")
local stateModule = require("runthis.state")
local state = stateModule.REF

M.runAbles = {
	["py"] = "python3",
	["js"] = "node",
	["lua"] = "lua",
	["hs"] = "runhaskell",
	["ts"] = "deno run --allow-net --allow-read --allow-write --allow-env --unstable",
	["go"] = "go run",
	["rb"] = "ruby",
	["rs"] = "",
	["c"] = "./main",
	["cpp"] = "./main",
	["java"] = "java",
	["sh"] = "sh",
	["fish"] = "fish",
}

M.defaults = {
	runAbles = M.runAbles,
	winConf = {
		width = 40,
	},
}

function M.setup(opts)
	opts = opts or {}
	if opts.programs then
		for extension, command in pairs(opts.programs) do
			M.runAbles[extension] = command
		end
	end

	if opts.winConf then
		for option, value in pairs(opts.winConf) do
			M.defaults.winConf[option] = value
		end
	end
end

function M.attach_to_buf(command, client)
	local clientBuf, name = client.buf, client.data.name

	local auGroup = v.nvim_create_augroup("AutoRun " .. name, { clear = true })

	v.nvim_create_autocmd({ "BufDelete" }, {
		desc = "In case the buf is closed, the tracking will be closed too",
		group = auGroup,
		callback = function()
			M.detach_buf(name)
		end,
	})
	v.nvim_create_autocmd({ "BufWritePost" }, {
		desc = "Creates a buffer to show what's executed on save for the given buf as client",
		group = auGroup,
		callback = function()
			local pluginBufnr

			-- Case there's no plugin buf, create a new one
			if not utils.bufExists(name, state) then
				local newBuf = v.nvim_create_buf(true, true)
				state[newBuf] = {}
				pluginBufnr = newBuf
				local clientFT = v.nvim_buf_get_option(clientBuf, "filetype")
				v.nvim_buf_set_option(pluginBufnr, "filetype", clientFT)
			else
				for buffer, content in pairs(state) do
					if name == content.client then
						pluginBufnr = buffer
					end
				end
			end

			local winnr = state[pluginBufnr].win

			-- The same with the window
			if not utils.winExists(winnr) then
				vim.cmd([[vsplit]])
				winnr = v.nvim_get_current_win()
				v.nvim_win_set_buf(winnr, pluginBufnr)
				v.nvim_win_set_option(winnr, "winfixwidth", true)
				v.nvim_win_set_width(winnr, M.defaults.winConf.width)
			end

			local finalCommand, programCommand = utils.parseCommand(client, command, M.runAbles)

			local handleStdout = function(_, data)
				if data and table.concat(data) ~= "" then
					-- Write to the plugin buffer the following
					table.insert(data, 1, ("Running { %s } on file -> '%s'"):format(programCommand, name))
					table.insert(data, 2, "-")
					table.insert(data, 3, " ")
					v.nvim_buf_set_lines(pluginBufnr, 0, -1, false, data)
				end
			end

			-- Write this while it is still loading or whatever is doing
			v.nvim_buf_set_lines(pluginBufnr, 0, -1, false, {
				"🔎 Loading your File, please wait...",
				"if it hangs out here, check if you program really returns anything to stdout",
			})

			fn.jobstart(utils.toTable(finalCommand), {
				stdout_buffered = true,
				on_stdin = function(job_id, _)
					local user_input = vim.fn.input("Enter input: ")
					vim.fn.jobsend(job_id, user_input .. "\n")
				end,
				on_stdout = handleStdout,
				on_stderr = handleStdout,
				-- INFO: solves deno color characters not being parsed
				env = { NO_COLOR = true },
			})

			-- Save the state for this buf
			state[pluginBufnr] = {
				win = winnr,
				-- file = v.nvim_buf_get_name(clientBuf), -- Store the file name
				client = vim.fn.fnamemodify(v.nvim_buf_get_name(clientBuf), ":t"),
			}
		end,
		pattern = name,
	})
end

function M.detach_buf(name)
	local bufTarget
	for buf, content in pairs(state) do
		if content.client == name then
			bufTarget = buf
		end
	end
	v.nvim_del_augroup_by_name("AutoRun " .. name)
	v.nvim_buf_delete(bufTarget, { force = true })
	state[bufTarget] = nil
end

function M.prompt(t)
	local task = t.args
	-- Split by whitespaces
	local Ttask = utils.toTable(task, "%S+")
	local selectedBuf
	local bufList = utils.getBufList()

	-- Case just 1 buf opened or task is current, run the current one, else ask what buf
	if #bufList == 1 or Ttask[2] == "current" then
		selectedBuf = vim.api.nvim_get_current_buf()
	else
		local bufTextList = utils.getBufListText(bufList)
		local bufTarget = vim.fn.input({
			prompt = "What buffer do you choose?: " .. bufTextList .. "\n",
		})

		local i = 0
		for bufNum, _ in pairs(bufList) do
			i = i + 1
			if i == tonumber(bufTarget) then
				selectedBuf = bufNum
				break
			end
		end
	end

	local client = { buf = selectedBuf, data = bufList[selectedBuf] }
	local handlers = {
		["attach"] = function()
			local command = vim.fn.input(
				"What command should be executed?(whole command with options, leave empty to use shebang): "
			)
			M.attach_to_buf(command, client)
		end,
		["detach"] = function()
			M.detach_buf(client.data.name)
		end,
	}
	handlers[Ttask[1] or "attach"]()
end

return M
