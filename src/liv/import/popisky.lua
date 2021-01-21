local bnn = require("liv.gen.banany")
local conv = require("liv.import.charset")
local resources = require("liv.resources")
local pop = {}

function pop.read(path)
  local prs = {}

  local ctx=""
  local name = nil
  local cur = {}
  for l in io.lines(path) do
    l = conv(l, "CP1250")
    for tkn in l:gmatch("([^\t]+)") do
      if not name then
        name = tkn
      else
        if tkn == "lava_svorka" then
          ctx = bnn.LAVY
        elseif tkn == "prava_svorka" then
          ctx = bnn.PRAVY
        elseif tkn == "koniec_svoriek" then
          ctx = nil
        elseif tkn == "END" then
          prs[name] = cur
          cur = {}
          name = nil
        else
          cur[tkn] = ctx
        end
      end
    end
  end

  return prs
end

function pop.builtin()
  return pop.read(resources.getPath("popisky.txt"))
end

return pop
