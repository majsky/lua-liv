---@class BasicDeviceHandler : DeviceHandler
local basic = {
    zariadenia = {
        ["E[LTV]%d"] = {s="L", n="bezny-pristroj"},
        ["XC%d"] = {s="L", n="bezna-zasuvka", upresnenie = function(nazov) return nazov:find("X") == 1 end},
        ["BT%d"] = {s="L", n="bezny-pristroj"},

    }
}

local function _find(name)
    for pat in pairs(basic.zariadenia) do
        if name:match(pat) then
            return pat
        end
    end
end

function basic.otypuj(nazov, svorky)
    local pat = _find(nazov)
    if not pat then
        return nil
    end
    local typ = basic.zariadenia[pat]
    
    if typ.upresnenie then
        if not typ.upresnenie(nazov) then
            return nil
        end
    end

    return typ.n
end

function basic.jetyp(typ)
    return _find(typ) and true or false
end

return basic