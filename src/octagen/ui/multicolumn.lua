local windcon = require("windcon")

local function drawleft(data, i, j, w)
  for k = i, j do
    local str = ("%s <- %s"):format(data.value, data.key)
    local strl = #str

    windcon.movecursor(w - strl, k)
    io.stdout:write(str)
  end
end

return function (data, rowcount)
  local width, height = windcon.size()
  local cperside = (width - 1) / 2

  drawleft(data, 1, rowcount, cperside)
  print(width, height)
end
