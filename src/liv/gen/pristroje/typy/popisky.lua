local popdata = require("liv.import.popisky")

---@class PopiskyDeviceHandler : DeviceHandler
local pop = {
    def = popdata.builtin()
}

function pop.nasmeruj(nazov, svorka, typ)
    local def = typ:sub(2,#typ)

    return "L"
end

function pop.jetyp(typ)
    return typ:sub(1,1) == "@"
end

function pop.definuje()
    local d = {}

    for k in pairs(pop.def) do
        table.insert(d, "@" .. k)
    end

    return unpack(d)
end

return pop
