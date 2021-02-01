local presisit = require("liv.util.presist")
local logger = require("liv.util.log")
local ui = require("liv.ui")

local devapi = {
    ---@type ZoznamPristrojov
    proto = {},
    typy = require("liv.gen.pristroje.typy")
}

local _devapi = {__index=devapi.proto}

function devapi.new(zapojenie)
    ---@class ZoznamPristrojov
    local o = setmetatable({
        db = {},
        log = logger.new("pristroje")
    }, _devapi)

    if zapojenie then
        o:analyzuj(zapojenie)
    end

    return o
end

function devapi.proto:uloz(path)
    presisit.save(self.db, path)
end

function devapi.proto:ulozLog(path)
    self.log:uloz(path)
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
        if t and not self.db[nazov] then
            self:registruj(nazov, t)
        end
    end

    return self
end

function devapi.proto:nacitaj(path)
    local loaded = presisit.load(path)

    for n,t in pairs(self.db) do
        if loaded[n] then
            self.db[n] = loaded[n]
        end
    end
end

function devapi.proto:dopln()
    ui.actual:zobrazMenu("pristroje", self)
    return self
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

    if typ == "svorkovnica" then
        return svorka.smer
    end

    local hnd = devapi.typy[typ]

    if not hnd then
        error("Neznamy typ zariadenia '" .. typ .. "'")
    end

    local smer = hnd.nasmeruj(nazov, svorka, typ)
    self.log:info(nazov, svorka.svorka, smer)
    return smer
end

return devapi
