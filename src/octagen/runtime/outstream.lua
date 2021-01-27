local clr = require("ansicolors")

local outstream = {proto = {}}
local _outstream = {
  __index = outstream.proto
}

function outstream.wrap(str)
  local o = setmetatable({out = str}, {
__index = function(t, k) return outstream.proto[k] or t.out[k] end
  })
  return o
end

function outstream.proto:write(...)
  local params = {...}

  for i=1, #params do
    self.out:write(clr(params[i]))
  end
  return self
end

function outstream.proto:format(fmt, ...)
  self:write(string.format(fmt, ...))
  return self
end

return outstream
