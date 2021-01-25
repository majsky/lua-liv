local c = require("ansicolors")

local function rozsah(str)
  local zac, kon = str:match("(%d+)-(%d+)")

  if kon < zac then
    local tmp = zac
    zac = kon
    kon = zac
  end

  local r = {}

  for i = zac, kon do
    table.insert(r, i)
  end

  return r
end

return function(zoznam, ibajeden, farba)
  if not farba then
    farba = "blue"
  end

  for ln, txt in ipairs(zoznam) do
    if type(txt) == "table" then
      txt = txt.txt
    end
    local color = ln % 2 == 0 and farba .."bg black" or farba
    io.stdout:write(c("%{" .. color .. "}" .. string.format("%d:\t%s", ln, txt)), "\n")
  end

  if ibajeden then
    io.stdout:write(c("%{red}Vyber jeden"), "\n")
  else
    io.stdout:write(c("%{red}Vyber viacero %{white}(napr 1, 5;20;25, 1-15, 1-20;^4, ^15, 0 - pokračuj)"), "\n")
  end

  local i = io.stdin:read("*l")

  if ibajeden then
    return tonumber(i)
  else
    local vyber = {}
    local block = {}
    for tkn in i:gmatch("([%S]+)%s*") do
      local data = nil
      local target = vyber

      if tkn:sub(1,1) == "^" then
        target = block
        tkn = tkn:sub(2, #tkn)
      end

      if tkn:find("-") then
        data = rozsah(tkn)
      elseif tonumber(tkn) then
        data = tonumber(tkn)
      end

      if type(data) == "table" then
        for _, v in pairs(data) do
          target[v] = true
        end
      else
        target[data] = true
      end
    end

    for k in pairs(block) do
      vyber[k] = nil
    end

    return vyber
  end
end
