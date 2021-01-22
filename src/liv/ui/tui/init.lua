local tui = {proto = {}}
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

return tui
