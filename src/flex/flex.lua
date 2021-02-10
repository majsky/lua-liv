local lfs = require("lfs")
local base64 = require("base64")

local cfg = {
  LUA = "tools\\lua5.3.dll",
  main = "octagen.main",
  resdir = "src",
  dir = "build",
}

local logh = nil
local function log(...)
  local str = table.concat({os.date(), ...}, "\t")
  logh:write(str, "\n")
  print(...)
end

local resources = {}
local function serachDir(dir, lst)
  local lst = lst or {}
  for f in lfs.dir(dir) do
    local attribs = lfs.attributes(dir .. "\\" .. f)

    if attribs then
      if attribs.mode == "directory" then
        if f ~= "." and f ~= ".." then
          serachDir(dir .. "\\" .. f, lst)
        end
      else
        if f:sub(#f-3) ~= ".lua" then
          resources[f] =  dir .. "\\" .. f
        end
      end
    end
  end
  return lst
end

local function fname(path)
  local r = path:reverse()
  local slash = r:find("\\")
  r = r:sub(1, slash - 1)
  return r:reverse()
end
local function cplib(from, name)
  local h = io.open(from, "rb")
  local w = assert(io.open(cfg.dir .. "\\bin-" .. os.getenv("PROCESSOR_ARCHITECTURE") .. "\\" .. name, "wb"))

  w:write(h:read("*a"))

  w:close()
  h:close()
end

local function read(path)
  local h = io.open(path, "r")
  local src = h:read("*a")
  h:close()
  return src
end

local function write(where, what)
  local h = io.open(where, "w")
  h:write(what)
  h:close()
end


local libs = {}
local srcs = {}
local function getdeps(mod)
  if srcs[mod] or libs[mod] then
    return
  end

  local mpth = package.searchpath(mod, package.path)
  if mpth then
    local modsrc = read(mpth)
    log("MOD", mod)
    srcs[mod] = modsrc

    for rqrd in modsrc:gmatch("require%(\"([^\"]+)\"%)") do
      getdeps(rqrd)
    end

    for rqrd in modsrc:gmatch("class%.new%(\"([^\"]+)\"%)") do
      getdeps(rqrd)
    end
  else
    mpth = package.searchpath(mod, package.cpath)
    if mpth and not libs[mod] then
      libs[mod] = mpth
    end
  end
end

local function gen(main)
  getdeps(main)

  local final = {}
  table.insert(final, "local files = {\n")

  for mod, src in pairs(srcs) do
    local def = string.format('\t["%s"] = "%s",\n', mod, base64.encode(src))
    table.insert(final, def)
  end

  table.insert(final, "}")

  local b64p = package.searchpath("base64", package.path)
  local b64s = read(b64p):gsub("return base64\n", string.rep("--++", 50))
  table.insert(final, b64s)

  table.insert(final, string.format([[

  for name, mod in pairs(files) do
    local mfn, err = load(base64.decode(mod), name)

    if not mfn then
      error(err)
    end

    package.preload[name] = mfn
  end

  require("%s")
  ]], cfg.main))

  return table.concat(final)
end

local flex = {}
function flex.glue()
  local bindir = cfg.dir .. "\\bin-" .. os.getenv("PROCESSOR_ARCHITECTURE")
  lfs.mkdir(cfg.dir)
  lfs.mkdir(bindir)

  --  SCRIPT
  logh = io.open(cfg.dir .. "\\build.log", "a")
  local script = gen(cfg.main)
  write(cfg.dir .. "\\script.lua", script)

  --  LUA
  log("LUA", cfg.LUA)

  --  LIBS
  cplib(cfg.LUA, fname(cfg.LUA))
  for lname, lib in pairs(libs) do
    log("LIB", lname)
    cplib(lib, lname .. ".dll")
  end

  --  RESOURCES
  serachDir(cfg.resdir)
  for rname, res in pairs(resources) do
    log("RES", rname)
    cplib(res, rname)
  end

  logh:close()

  print("\n\nA significant amount of damage has been done!\n")
end

local function clean(dir)
  local dir = dir or cfg.dir
  for f in lfs.dir(dir) do
    if f ~= "." and f ~= ".." then
      local attribs = lfs.attributes(dir .. "\\" .. f)

      if attribs then
        if attribs.mode == "directory" then
          clean(dir .. "\\" .. f)
        else
          print("DEL", dir .. "\\" .. f)
          assert(os.remove(dir .. "\\" .. f))
        end
      end
    end
  end
  lfs.rmdir(dir)
end

function flex.clean()
  clean("build")
  lfs.rmdir(cfg.dir)
  print("\n\nThat's a lot of damage!\n")
end

local args = {...}
for i, arg in ipairs(args) do
  local cmd, param = arg:match("([a-z]+)%(?([^%)]*)%)?")
  print("[[".. cmd:upper() .."]]")
  flex[cmd](param)
  print()
end
