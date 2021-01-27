local ogrt = require("octagen.runtime")
local iogrt = require("octagen.runtime.interactive")

local og = {}

function og.main(...)
  local rt = ogrt.new()
  local plist = {...}

  for k, v in pairs(plist) do
    if v == "-w" then
      print("Waiting for ide")
      dbg.waitIDE()
      table.remove(plist, k)
    end
  end

  --rt:eval(table.concat(plist))

  iogrt.start()
end

return og
