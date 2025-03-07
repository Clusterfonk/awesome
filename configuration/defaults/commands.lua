-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local capi = {
    mouse = mouse
}


local function launcher()
    local screen = capi.mouse.screen
    local index = screen.index - 1 -- dmenu uses 0 index start

    width = math.floor(screen.geometry.width / 3)
    x = math.floor(screen.geometry.width / 2 - width / 2)
    y = dpi(24) + 1 + bt.useless_gap * 2 + 2 * bt.bars.border_width + bt.useless_gap
    l = 1

    return string.format("dmenu_run -x %d -y %d -z %d -l %d -m %d", x, y, width, l, index)
end

return {
    terminal = "alacritty",
    text_editor = "alacritty -e nvim",
    web_browser = "brave-beta",
    notes = "notes",
    launcher = launcher,
    snipregion = "snipregion",
    toggle_headphone_speakers = "toggle-headphone-speakers",
}
