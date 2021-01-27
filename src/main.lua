local lfs = require("lfs")

local import = require("liv.import")
local pristroje = require("liv.gen.pristroje")

local ui = require("liv.ui")

local zapojenie = require("liv.banany.zapojenie")
local addr = require("liv.banany.adresa")
--[[
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end
]]

ui.init(ui.modes.text)

local klo = import("../lua-libliv/klo.CSV")
local gan = import("../lua-libliv/gan.csv")
local zap = zapojenie.new(addr.new("=ADA06", "+ASD06"), gan, klo)
zap:nacitajDoplnenia("doplnene.csv")
--local zp = pristroje.new()
--zp:analyzuj(zap):dopln(zap)

--local th = io.open("pristroje.csv", "w")
--for p, t in pairs(zp.db) do
--  th:write(p, ":", t, "\n")
--end
--th:flush()
--th:close()

local zp = pristroje.nacitaj("pristroje.csv")
zp:analyzuj(zap):dopln():uloz("pristroje.csv")
zp:uloz("pristroje.csv")
local b = zap:generuj(zp)
zap:ulozDoplnene("doplnene.csv")

lfs.mkdir("banany")
lfs.chdir("banany")
lfs.mkdir(zap.pole)
lfs.mkdir(zap.pole .. "/" .. zap.skrina)
lfs.chdir(zap.pole .. "/" .. zap.skrina)
for pr, bny in pairs(b) do
  local fh = io.open(lfs.currentdir() .. "/" .. pr .. ".csv", "w")
  for _, bn in pairs(bny) do
    fh:write(bn, "\n")
  end
  fh:flush()
  fh:close()
end

print "hotovo"
