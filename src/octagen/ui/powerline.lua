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
local _pwrln = {}
local __segment = {}

---@return Powerline @New powerline
function pwrln.build()
  ---@class Powerline
  local ln = {}
  return setmetatable(ln, _pwrln)
end

---Prida novy segment
---@param bg string @Farba pozadia
---@param fg string @Farba texxtu
---@param sep string @Powerline znak
---@param len number|nil @Dlzka segmentu
---@return Powerline self
function pwrln.proto:add(bg, fg, sep, len)
  local sg = setmetatable({bg = bg, fg = fg, sep = sep, len = len}, __segment)
  table.insert(self, sg)
  return self
end

---Vrati naformatovany powerline
---@param ... string @Texty segmentov
---@return string @Powerline
function pwrln.proto:format(...)
  local txts = {...}
  local l = {}

  for i, seg in ipairs(self) do
    local txt = txts[i]
    if txt then
      local nxt = ((i + 1) <= #self) and self[i + 1]

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

      table.insert(l, ansicolors(table.concat({
        "%{", seg.fg, " ", seg.bg, "bg}",
        " ", txt, " ",
        "%{", nxt and nxt.bg or "black", "bg ", seg.bg, "}", seg.sep
      })))
    end
  end

  return table.concat(l)
end

_pwrln.__index = pwrln.proto
_pwrln.__call = pwrln.proto.format

return setmetatable(pwrln, {
  ---@return Powerline
  __call=pwrln.build
})
