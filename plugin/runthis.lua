local v = vim.api

local function prompt()

  local function getBufList()
    local bufList = {}
    for _, buf in pairs(v.nvim_list_bufs()) do
      local bufInList = v.nvim_buf_get_option(buf,"buflisted")
      local bufPath = string.sub(v.nvim_buf_get_name(buf),2,-1)

      if bufInList and bufPath ~= ""  then
        local lastSlash
        local bufName = ""

        for i=1, #bufPath do
          local char = bufPath:sub(i,i)
          if i == #bufPath then
            bufName = bufPath:sub(lastSlash+1,-1)
          end
          if char == "/" then
            lastSlash = i
          end
        end
        bufList[buf] = {
          path = bufPath,
          name = bufName
        }
      end
    end

    return bufList
  end

  local bufList = getBufList()

  local function getBufListText()
    local text = ""
    local i = 0
    local bufs = {}
    for bufNum, bufInfo in pairs(bufList) do
      i = i+1
      text = text..("\n%s %s"):format(i,bufInfo.name)
      table.insert(bufs,i,bufNum)
    end
    return text
  end

  local bufTextList = getBufListText()
  local bufTarget = vim.fn.input({
    prompt = "What buffer should be ran?: "..bufTextList.."\n",
  })
  local selectedBuf
  local i = 0
  for bufNum, _ in pairs(bufList) do
    i=i+1
    if i == tonumber(bufTarget) then
      selectedBuf = bufNum
    end
  end
  local command = vim.fn.input "What command should be executed?: "
  local commandOptions = vim.fn.input "What options should be added?: "
  local attach_to_buf = require("attach")
  local bufName,bufPath = bufList[selectedBuf].name,bufList[selectedBuf].path
  attach_to_buf(command,commandOptions,bufName,"/"..bufPath)
end

v.nvim_create_user_command("RunThis",prompt,{})
