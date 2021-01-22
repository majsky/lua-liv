local ui = {
  modes = {
    text = require("liv.ui.tui")
  },
  actual = nil,
  proto = {}
}

function ui.init(mode)
  local act = mode.init()
  ui.actual = act
  setmetatable(ui, {__index=act})
  return act
end

return ui
