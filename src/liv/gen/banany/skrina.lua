local addr = require("liv.banany.adresa")
local bnn = require("liv.gen.banany")
local popisky = require("liv.import.popisky")

local gbs = {}

function gbs.generuj(skrina, pristroje)
  local done = {}
  local smery = popisky.builtin()
  for pristroj, svorky in pairs(skrina) do
    for k,v in pairs(svorky) do
      local tu = addr(nil, nil, pristroj, v.svorka)
      local prec = addr(nil, nil, v.cpristroj, v.csvorka)

      local a = tu:text()..">"..prec:text()
      local b = prec:text()..">"..tu:text()

      if not done[a] and not done[b] then
        done[a] = true
        done[b] = true

        local k1 = {
          pristroj = pristroj,
          svorka = v.svorka
        }

        local k2 = {
          pristroj = v.cpristroj,
          svorka = v.csvorka
        }

        print(bnn.sprav(bnn.LAVY, k1, k2))
        print(bnn.sprav(bnn.LAVY, k2, k1))

      end
    end
  end
end

return gbs
