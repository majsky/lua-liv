---@class DeviceHandler
local proto = {}
local _proto = {__index=proto}

---@param typ string
---@return boolean
function proto.jetyp(typ)
    return false
end

---@param nazov string
---@param svorky table
---@return string
function proto.otypuj(nazov, svorky)
    return "-"
end

---@param nazov string
---@param svorka table
---@param typ string
---@return string
function proto.nasmeruj(nazov, svorka, typ)
    return "L"
end

function proto.definuje()
    return nil
end

local function typ(nazov)
    local ch = require("liv.gen.pristroje.typy." .. nazov)
    return setmetatable(ch, _proto)
end

local typy = {
    typ("chranic"),
    typ("istic"),
    typ("bezne"),
    typ("popisky")
}

local _typy = {
    __index = function (t, k)
        for _, typ in pairs(t) do
            if typ.jetyp(k) then
                return typ
            end
        end
    end
}

return setmetatable(typy, _typy)
