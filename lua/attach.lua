local v = vim.api
local _postWriteRef = {}

local attach_to_buf = function(command,opts,name,path)
  v.nvim_create_autocmd({"BufWritePost"}, {
      group = v.nvim_create_augroup("AutoRunNode", {clear = true}),
      callback = function ()
          if not _postWriteRef["buf"] then
              _postWriteRef["buf"] = v.nvim_create_buf(true,true)
              v.nvim_buf_set_option(_postWriteRef["buf"],"filetype","javascript")
          end

          local bufnr, winnr = _postWriteRef["buf"],_postWriteRef["win"]

          local winExists = false

          for _, val in pairs(v.nvim_list_wins()) do
              if val == winnr then
                  winExists = true
                  break
              end
          end

          if not winExists then
              vim.cmd[[vsplit]]
              winnr = v.nvim_get_current_win()
              v.nvim_win_set_buf(winnr,bufnr)
              winExists = true
          end

          local handleStd = function(_,data)
              if data and table.concat(data) ~= "" then
                  table.insert(data,1,("Running %s %s on %s"):format(command,opts,name))
                  table.insert(data,2,"-")
                  table.insert(data,2," ")
                  v.nvim_buf_set_lines(bufnr,0,-1,false,data)
              end
          end

          local fullCommand
          if opts == "" then
            fullCommand = command
          else
            fullCommand = command.." "..opts
          end

          vim.fn.jobstart({fullCommand,path},{
              stdout_buffered = true,
              on_stdout = handleStd,
              on_stderr = handleStd
          })

          _postWriteRef["win"] = winnr
      end,
      pattern = name
  })
end
return attach_to_buf
