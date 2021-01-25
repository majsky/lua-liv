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

package.cpath = package.cpath .. ";c:/Users/oresany/.vscode/extensions/tangzx.emmylua-0.3.49/debugger/emmy/windows/x86/?.dll"
local dbg = require("emmy_core")
dbg.tcpListen("localhost", 9966)
dbg.waitIDE()

ui.init(ui.modes.text)

local klo = import("klo.CSV")
local gan = import("gan.csv")
local zap = zapojenie.new(addr.new("ADA06", "ASD06"), gan, klo)
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
zp:dopln()
zp:uloz("pristroje.csv")
local b = zap:generuj(zp)
zap:ulozDoplnene("doplnene.csv")

for pr, bny in pairs(b) do
  local fh = io.open(pr .. ".csv", "w")
  for _, bn in pairs(bny) do
    fh:write(bn, "\n")
  end
  fh:flush()
  fh:close()
end

print "hotovo"
