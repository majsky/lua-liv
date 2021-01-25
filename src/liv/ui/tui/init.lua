local tui = {
  proto = {},
  menu = {
    pristroje = require("liv.ui.tui.menu.typypristrojov")
  }
}
local _tui = {__index=tui.proto}

function tui.init()
  local o = {
    input = io.stdin,
    output = io.stdout,
    errout = io.stderr
  }

  return setmetatable(o, _tui)
end


function tui.proto:prompt(...)
  self.output:write(...)
  self.output:flush()
  return self.input:read("*l")
end

function tui.proto:zobrazMenu(menu, ...)
  if not tui.menu[menu] then
    error(string.format("Nezname menu '%s'", menu))
  end

  tui.menu[menu].zobraz(...)
end

return tui
