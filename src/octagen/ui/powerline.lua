local ansicolors = require("ansicolors")
local c = require("utf8").char

local function _ch2(base, ofs)
  return {
    full = c(base),
    r = {
      full = c(base + (ofs or 1))
    }
  }
end
local function _ch(base)
  return {
    full = c(base),
    line = c(base + 1),
    r = {
      full = c(base + 2),
      line = c(base + 3)
    }
  }
end

local pwrln = {
  ---@type Powerline
  proto={},
  chars = {
    tri = _ch(0xe0b0),
    round = _ch(0xe0b4),
    fall = _ch(0xe0b8),
    rise = _ch(0xe0bc),
    flame = _ch(0xe0c0),
    digis = _ch2(0xe0c4),
    digi = _ch2(0xe0c6),
    splat = _ch2(0xe0c8, 2),
    wings = {
      full = c(0xe0d2),
      r = {
        full = c(0xe0d4)
      }
    },

    hex = {
      full = c(0xe0cc),
      line = c(0xe0cd)
    },

    lego = {
      full = c(0xe0ce),
      line = c(0xe0d1),
      up = c(0xe0cf),
      front =c(0xe0d0)
    }
  },
  icons = {
    branch = c(0xe0a0),
    ln = c(0xe0a1),
    lock = c(0xe0a2),
    cn = c(0xe0a3)
  }
}
local _pwrln = {
  __index = pwrln.proto
}

---@return Powerline @New powerline
function pwrln.build(...)
  ---@class Powerline
  local ln = {...}
  return setmetatable(ln, _pwrln)
end
local pla = nil

  ---@param adr Addresa
function pwrln.adresa(adr, prefix)
  if not pla then
    local s = pwrln.segment
    local segments = {
      s("red", "black", pwrln.chars.tri),
      s("yellow", "black", pwrln.chars.tri),
      s("green", "black", pwrln.chars.tri),
      s("magenta", "black", pwrln.chars.tri),
      s("magenta", "black", pwrln.chars.tri),
      s("magenta", "black", pwrln.chars.tri)
    }
    if prefix then
      table.insert(segments, s("white", "black", pwrln.chars.tri, nil, prefix),1)
    end
    pla = pwrln.build(table.unpack(segments))
  end
  return pla(
      adr.pole,
      adr.skrina,
      adr.pristroj,
      adr.pristroj2,
      adr.pristroj3,
      adr.svorka)
end
---Prida novy segment
---@param bg string @Farba pozadia
---@param fg string @Farba texxtu
---@param sep string @Powerline znak
---@param len number|nil @Dlzka segmentu
---@return Powerline self
function pwrln.proto:add(bg, fg, sep, len, text)
  local sg = {bg = bg, fg = fg, sep = sep, len = len, txt=text}
  table.insert(self, sg)
  return self
end

function pwrln.segment(bg, fg, sep, len, text)
  return {bg = bg, fg = fg, sep = sep, len = len, txt = text}
end

---Vrati naformatovany powerline
---@param ... string @Texty segmentov
---@return string @Powerline
function pwrln.proto:format(...)
  local txts = {...}
  local l = {}

  local used = {}
  for i=#self, 1, -1 do
    if txts[i] and #txts[i] > 0 then
      table.insert(used, setmetatable({txt=txts[i], nxt=used[#used]}, {__index = self[i]}))
    end
  end

  for i = #used, 1, -1 do
    local seg = used[i]
    local first = i == #used
    if seg.len then
      local delta = seg.len - #txts[i]
      if delta < 0 then
        txt = txt:sub(1, seg.len)
      elseif delta > 0 then
        local s = math.floor(delta / 2)
        local pad = string.rep(" ", s)

        txt = string.format(delta%2==0 and "%s%s%s" or "%s%s %s", pad, txt, pad)
      end
    end

    local sep = seg.sep.full

    local ebg = "black"
    local efg = seg.bg

    local sfg = seg.fg
    local sbg = seg.bg

    local txt = {}



    if seg.nxt then
      if seg.nxt.bg == seg.bg then
        sep = seg.sep.line
        efg = "black"
      end
      ebg = seg.nxt.bg
    end

    if first then
      sfg = "black"
      sbg = seg.bg
    end

    table.insert(txt, seg.txt)

      table.insert(l, ansicolors(table.concat( {
        first and ("%{black ".. seg.bg .."bg}" ..seg.sep.full) or "",
        "%{", seg.fg, " ", seg.bg, "bg}",
        " ", table.concat(txt), " ",
        "%{", ebg, "bg ", efg, "}", sep
      })))
  end

  return table.concat(l)
end

_pwrln.__index = pwrln.proto
_pwrln.__call = pwrln.proto.format

return setmetatable(pwrln, {
  ---@return Powerline
  __call=pwrln.build
})
