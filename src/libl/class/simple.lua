if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local tabu = require("libl.util.tab")

local lcls = {}

local rootclass = {
  super="none",
   getclass = function (self)
    return getmetatable(self).class
   end
}

local reserved = {
 new = function (self, ...)
    local o = tabu.cp(self.fields)
    setmetatable(o, self._om)
    if self.methods.init then
      self.methods.init(o, ...)
    end
    return o
 end
}

function lcls.new(parent)
  local c = {
    super = parent or rootclass,
    methods = {},
    fields = {},

    _om = {
      __index = function (self, k)
          local mt = getmetatable(self)
          if k == "super" then
            return mt.class.super
          end
          return mt.class.methods[k] or mt.class.super[k]
      end,
      __newindex = function (t, k, v)
          rawset(t, k, v)
      end
    },


    _m = {
      __index = function(t, k)
      if reserved[k] then 
        return reserved[k]
      end

      return t.super[k]
    end,

    __newindex = function (t, k, v)
        if type(v) == "function" then
          t.methods[k] = v
        else
          t.fields[k] = v
        end
    end
    }
  }

  setmetatable(c, c._m)

  c._om.class = c

  return c
end


return lcls
