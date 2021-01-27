local ogrt = require("octagen.runtime")
local outstream = require("octagen.runtime.outstream")
local ansicolors = require("ansicolors")

local live = {proto={}}
local _live = {__index=live.proto}

function live.onerror(err)
  local printf = function(fmt, ...)
    local str = string.format(fmt:gsub("@c", "%%%%{%%s}"), ...)
    io.stdout:write(ansicolors(str), "\n")
    io.stdout:flush()
  end

  printf("@c%s", "red", debug.traceback(err, 3))
--[[
  if err:find("not found") then
    local modname = err:match("%b''"):gsub("octagen%.runtime%.", "")
    printf("@c%s@c: nenajdene", "red", modname, "white")
  else
  end]]
end

function live.start()
  local o = setmetatable({
    rt = ogrt.new(live.onerror),
    out = outstream.wrap(io.stdout),
    cmds = require("octagen.cmds")()
  }, _live)

  repeat
    local continue = o:prompt()
  until not continue
end

function live.proto:prompt()
  while true do
    self:printf("\n@cAkt. databanka@c: %s\n@cZadaj prikaz alebo help:", "blue", "white", self.rt.curb,"green")
    local cmd = io.stdin:read("*l")

    local _first = cmd:sub(1,1)
    if _first == ":" then
      local d = {self.rt:eval(cmd)}
      --print(d)
    elseif self.cmds[_first] then
      return self.cmds[_first][cmd:sub(2, #cmd)]
    else
      self:printf("%%{%s}>%s:%%{%s} Nezname", "redbg white", cmd, "red blackbg")
    end
  end
end

function live.proto:printf(fmt, ...)
  self.out:format(fmt:gsub("@c", "%%%%{%%s}"), ...)
  self.out:write("\n")
end

return live
