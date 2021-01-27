local tasks = require("octagen.runtime.tasks")
local runtime = {proto = {bank = {}, curb = 1}, registry = {}}
local _rt = {__index = runtime.proto}

function runtime.new(on_err)
  local o = setmetatable({
    on_err = on_err
  }, _rt)

  for k,v in pairs(runtime.proto) do
    rawset(o, k, v)
  end

  table.insert(runtime.registry, o)
  o.id = #runtime.registry
  o:newbank("default")
  return o
end

function runtime.last()
  return runtime.registry[#runtime.registry]
end

function runtime.get(id)
  return runtime.registry[id]
end

function runtime.proto:eval(src)
  local s = 'return require("octagen.runtime").get(@id@):run()' .. src
  src = s:gsub("@id@", self.id)
  local ok, compiled = pcall(loadstring, src, src)

  if not ok then
    self.onerr(compiled)
    return
  end

  local ok, val = xpcall(function() return compiled(self) end, self.on_err)
  return ok, val
end

local function dump(t, pre)
  if not pre then pre = "" end
  if type(t) == "table" then
    for k,v in pairs(t) do
      if type(v) == "table" then
        dump(v, pre .. "." .. k)
      else
        print(k, v)
      end
    end
  else
    print(t)
  end
end

local task = {proto={}}
local _task = {__index=task.proto}

function task.new(fun, databank, fn)
  local o = setmetatable({
    fn = fun,
    db = databank,
    fname = fn or "unnamed"
  }, _task)

  return o
end
function _task.__call(t, ...)
  print("Spustam " .. t.fname)
  local data = t.fn(...)
  if data then
    for k, v in pairs(data) do
      t.db[k] = v
    end
  end
  return t.db
end


local function ntask(fn, tsks)

end

function runtime.proto:run(db)
  local data = db or {}
  local _tsks = {
    __index = function(t, k)
      if tasks[k] then
        --return ntask(tasks[k], t)
        return task.new(tasks[k], data, k)
      else
        error("Neznama uloha '" .. k .. "'")
      end
    end
  }
  local _ctx = {

  }
  return setmetatable(data, _tsks)
end

function runtime.proto:newbank(name)
  local b = {name = name, data = {}, active=true}
  local id = table.insert(self.bank, b)
  b.id = id
  return id
end

return runtime
