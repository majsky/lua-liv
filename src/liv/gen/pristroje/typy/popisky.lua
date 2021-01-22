local popdata = require("liv.import.popisky")

---@class PopiskyDeviceHandler : DeviceHandler
local pop = {
    def = popdata.builtin()
}

function pop.nasmeruj(nazov, svorka, typ)
    local def = typ:sub(2,#typ)
end

function pop.jetyp(typ)
    return typ:sub(1,1) == "@"
end

return pop