local ui = require("liv.ui")

local devapi = {
    ---@type ZoznamPristrojov
    proto = {},
    typy = require("liv.gen.pristroje.typy")
}

local _devapi = {__index=devapi.proto}

function devapi.new()
    ---@class ZoznamPristrojov
    local o = {db = {}}

    return setmetatable(o, _devapi)
end


function devapi.nacitaj(path)
    local fh = io.open(path, "r")

    local o = devapi.new()
    local line = fh:read("*l")
    while line do
        local pr, ty = line:match("([^:]+):(.+)")
        o:registruj(pr, ty)
        line = fh:read("*l")
    end

    fh:close()

    return o
end

function devapi.proto:uloz(path)
    local fh = io.open(path, "w")

    for k, v in pairs(self.db) do
        fh:write(k, ":", v, "\n")
    end

    fh:close()
end

function devapi.proto:registruj(nazov, typ)
    self.db[nazov] = typ
end

function devapi.proto:analyzuj(zapojenie)
    for _, nazov in pairs(zapojenie.svorkovnice) do
        self:registruj(nazov, "svorkovnica")
    end

    for _, nazov in pairs(zapojenie.pristroje) do
        local t = self:otypuj(nazov, zapojenie.data[nazov])
        if t then
            self:registruj(nazov, t)
        end
    end

    return self
end

function devapi.proto:dopln()
    ui.actual:zobrazMenu("pristroje", self)
end

function devapi.proto:otypuj(nazov, svorky)
    for _, hnd in ipairs(devapi.typy) do
        local t = hnd.otypuj(nazov, svorky)
        if t then
            return t
        end
    end
end

function devapi.proto:nasmeruj(nazov, svorka)
    local typ = self.db[nazov]
    if not typ then
        error("'" .. nazov .. "' nemá zaregistrovaný typ!")
    end

    local hnd = devapi.typy[typ]

    if not hnd then
        error("Neznamy typ zariadenia '" .. typ .. "'")
    end

    return hnd.nasmeruj(nazov, svorka, typ)
end

return devapi
