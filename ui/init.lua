-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local info_bar = require("ui.bars.info")
local nbox = require("ui.widgets.nbox")
local taglist_bar = require("ui.bars.taglist")
local time_bar = require("ui.bars.time")

local capi = {
    screen = screen
}


local multi_screen = capi.screen.count() > 1

capi.screen.connect_signal("request::desktop_decoration", function(s) -- created
    if multi_screen and s == capi.screen.primary then return end

    local taglist_bar_width = dpi(350)
    local bar_height = dpi(24)
    local bar_offset = bt.useless_gap

    local geometry = { top = bar_offset, side = 2 * bt.useless_gap }
    geometry.bottom = geometry.top + bar_height + 2 * bt.bars.border_width

    local left = time_bar {
        screen = s,
        height = bar_height,
        geometry = geometry
    }

    local middle = taglist_bar {
        screen = s,
        height = bar_height,
        width = taglist_bar_width,
        strut_offset = bar_offset
    }

    local right = info_bar {
        screen = s,
        height = bar_height,
        geometry = geometry
    }

    nbox.init_bars(s, left, middle, right)
end)

awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
        --:emit_signal("clear::popups") TODO: popups will no longer be screen dependent
    end)
})
