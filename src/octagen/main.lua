local params = {...}
if params[1] == "vuje" then
  _G.__VUJE = true
end
local uimain = require("octagen.ui.main")


uimain(params)
