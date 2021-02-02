local bnn = {
  LAVY = "L",
  PRAVY = "P"
}

function bnn.sprav(smer, tu, tam)
  local cnt = nil
  if smer == bnn.LAVY then
    cnt = {bnn.spravLavy(tam), tam.pristroj, bnn.spravPravy(tu)}
  elseif smer == bnn.PRAVY then
    cnt = {bnn.spravLavy(tu), tam.pristroj, bnn.spravPravy(tam)}
  end

  if not cnt then
    error("Neznamy smer: " .. smer)
  end

  return table.concat(cnt, ":")
end

local koncovka = {"svorka", "pristroj3", "pristroj2"}
local function urobKoniec(adr, i, j, k)
  local t = {}
  for _i = i, j, k do
    local psep = _i ~= 1
    if #adr[koncovka[_i]] > 0 then
      if psep and k > 0 then
        table.insert(t, "/")
      end

      table.insert(t, adr[koncovka[_i]])

      if psep and k < 0 then
        table.insert(t, "/")
      end
    end
  end

  return table.concat(t)
end

function bnn.spravLavy(a)
  return urobKoniec(a, 1, #koncovka, 1)
end

function bnn.spravPravy(a)
  return urobKoniec(a, #koncovka, 1, -1)
end

return bnn
