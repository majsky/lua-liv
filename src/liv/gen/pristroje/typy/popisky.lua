local popdata = require("liv.import.popisky")

---@class PopiskyDeviceHandler : DeviceHandler
local pop = {
    def = popdata.builtin()
}

function pop.nasmeruj(nazov, svorka, typ)
    local d = typ:sub(2,#typ)

    if pop.def[d] then
        local pristroj = pop.def[d]
        local smer = pristroj[svorka.svorka]

        if not smer then
            if pristroj.vsetky then
                smer = pristroj.vsetky
            end
        end
        --print("PPP: " .. nazov .. ":" .. svorka.svorka .." - " .. (s or "nil"))
        return smer
    end

    error("WTf" .. nazov .. " " .. typ)
    return "L"
end

function pop.jetyp(typ)
    return (typ:sub(1,1) == "@")
end

function pop.definuje()
    local d = {}

    for k in pairs(pop.def) do
        table.insert(d, "@" .. k)
    end

    return unpack(d)
end

return pop
