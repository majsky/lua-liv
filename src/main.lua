local import = require("liv.import")
local pristroje = require("liv.gen.pristroje")


local ui = require("liv.ui")

local zapojenie = require("liv.banany.zapojenie")
local addr = require("liv.banany.adresa")

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

ui.init(ui.modes.text)

local klo = import("klo.CSV")
local gan = import("gan.csv")
local zap = zapojenie.new(addr.new("ADA06", "ASD06"), gan, klo)
local zp = pristroje.new()
zp:analyzuj(zap)
local b = zap:generuj()
print "hotovo"
