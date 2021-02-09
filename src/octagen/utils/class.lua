local class = {proto={}}
local _class = {__index=class.proto}

function class.new(super)
  local o = setmetatable({}, _class)

  if type(super) == "string" then
    super = require(super)
  end
  o.meta = {
    __index = function(t, k)
      if super then
        return o[k] or super[k]
      end
      return o[k]
    end
  }
  return o
end

function class.proto:new(...)
  local o = setmetatable({}, self.meta)
  o:init(...)
  return o
end

function class.proto:init()

end

return class
