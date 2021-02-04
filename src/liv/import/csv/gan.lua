local base64 = require("base64")
local adresa = require("liv.banany.adresa")

local gan = {}

local function swapkv(t)
  local nt = {}

  for k,v in pairs(t) do
    rawset(nt, v, k)
  end

  return nt
end

local skipp = {
  ["STENA SKRINE"] = true,
  ["DVERE"] = true,
  ["RÁM"] = true
}



local map = swapkv({
  ["PŘÍSTROJ ="] = "pole",
  ["PŘÍSTROJ +"] = "skrina",
  ["PŘÍSTROJ -"] = "pristroj",
  ["PŘÍSTROJ -1"] = "pristroj2",
  ["PŘÍSTROJ -AN"] = "pristroj3",
  ["PŘÍSTROJ :1"] =  "svorka",
  ["PRŮŘEZ"] = "prierez",
  ["CÍL ="] = "cpole",
  ["CÍL +"] = "cskrina",
  ["CÍL -"] = "cpristroj",
  ["CÍL -1"] = "cpristroj2",
  ["CÍL -AN"] = "cpristroj3",
  ["CÍL :1"] = "csvorka",
  ["POT"] = "potencial"
})

local function odstranBordel(str)
  str = str:match("[=%+-%.]*(.+)")
  if skipp[str] then
    return ""
  end
  return str or ""
end

function gan.process(head, lines)
  local lmap = {}

  for k, v in pairs(map) do
    for _k, _v in pairs(head) do
      if _v == v then
        lmap[k] = _k
        break
      end
    end
  end

  local __linemeta = {
    __index = function(t, k)
      local uk = lmap[k]
      if uk then
        return rawget(t, uk)
      end
    end
  }

  local data = {}
  local cur = {}
  local lastPr = "-"
  for ln = 1, #lines do
    local l = setmetatable(lines[ln], __linemeta)

    local svorka = l.svorka

      local pole = l.pole:sub(2, #l.pole)
      local skr = l.skrina:sub(2, #l.skrina)
      local pri = l.pristroj:sub(2, #l.pristroj)
      local pri2 = l.pristroj2:match("%+%.?(.+)") or ""
      local pri3 = l.pristroj3

      if #pole > 0 and #skr > 0 and #pri > 0 then
        cur.pole = pole
        cur.skr = skr
        cur.pri = pri
        cur.pri2 = pri2
        cur.pri3 = pri3
      end

      if #svorka > 0 then

      if not skipp[pri] then

        l.cpristroj = l.cpristroj:sub(2, #l.cpristroj)

        if #pole == 0 then
          pole = cur.pole
        end

        if #skr == 0 then
          skr = cur.skr
        end

        if #pri == 0 then
          pri = cur.pri
        end

        if #pri2 == 0 then
          pri2 = cur.pri2
        end

        if #pri3 == 0 then
          pri3 = cur.pri3
        end

        if not data[pole] then
          data[pole] = {}
        end

        if not data[pole][skr] then
          data[pole][skr] = {}
        end

        if not data[pole][skr][pri] then
          data[pole][skr][pri] = {}
        end

        local pr = data[pole][skr][pri]

        local hasVal = false
        local ldata = {
          pristroj2 = pri2,
          pristroj3 = pri3
        }
        for _, k in pairs({"svorka", "cpristroj", "cpristroj2", "cpristroj3", "csvorka", "prierez", "cpole", "cskrina", "potencial"}) do
          ldata[k] = odstranBordel(l[k])

          if #l[k] > 0 then
            hasVal = true
          end
        end

        if pri == "KC" then
          print("kc")
        end
        if string.sub(ldata.pristroj2, 1, 1) == "." then
          ldata.pristroj2 = ldata.pristroj2:sub(2, #ldata.pristroj2)
        end

        if #l.cpole == 0 then
          l.cpole = pole
        end

        if #l.cskrina == 0 then
          l.cskrina = skr
        end

        if ldata.prierez:byte() == 34 or #ldata.prierez == 0 then
          ldata.prierez = lastPr
        else

          ldata.prierez =  ldata.prierez:gsub("2,5", "1,5")

          local cele, des = ldata.prierez:match("(%d+),?(%d*)m?m?")
          if cele then
            ldata.prierez = cele
            if #des > 0 then
              ldata.prierez = ldata.prierez .. "," .. des
            end
            ldata.prierez = ldata.prierez .. "mm"
          end

          lastPr = #ldata.prierez == 0 and "-" or ldata.prierez
        end

        ldata.obsadena = #ldata.csvorka > 0 and #ldata.cpristroj > 0 and #ldata.svorka > 0

        table.insert(pr, ldata)
      end
    end
  end

  return data
end

gan.headers = {"PŘÍSTROJ =", "PŘÍSTROJ +", "PŘÍSTROJ -", "PŘÍSTROJ -1", "PŘÍSTROJ -AN", "PŘÍSTROJ :1", "PRŮŘEZ", "CÍL =", "CÍL +", "CÍL -", "CÍL -1", "CÍL -AN", "CÍL :1"}

return gan
