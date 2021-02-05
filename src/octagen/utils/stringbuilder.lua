local sb = {proto={}}
local _sb = {__index = sb.proto}

function sb.new(...)
  local o = setmetatable({...}, _sb)
  return o
end

function sb.proto:add(...)
  for k, v in ipairs({...}) do
    table.insert(self, v)
  end

  return self
end

function sb.proto:string()
  return table.concat(self)
end

_sb.__tostring = sb.proto.string

return sb
