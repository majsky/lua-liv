local icoload = require("octagen.ui.icoload")
local term = require("octagen.platform").term

local domov = {
  name = "DOMOV",
  icon = icoload(0xf015)
}

local lastkey = nil
function domov.draw()
  term.curpos(1,2)
  print("Domovska karta")
  print("Stlačils: ", lastkey)
end

function domov.update(key)
  lastkey = key
end

return domov

