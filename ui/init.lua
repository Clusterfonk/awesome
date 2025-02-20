-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local taglist_bar = require("ui.bars.taglist")
local time_bar = require("ui.bars.time")
local info_bar = require("ui.bars.info")


local capi = {
    mouse = mouse
}

local SECONDARY_SCREEN <const> = 2

awful.screen.connect_for_each_screen(function(s)
    local taglist_bar_width = dpi(350, s)
    local bar_height = dpi(24, s)
	local bar_offset = bt.useless_gap

    local geometry = {top = bar_offset, side = bt.useless_gap * 2}
    geometry.bottom = geometry.top + bar_height + 2 * bt.taglist_border_width

	taglist_bar {
        screen = s,
        height = bar_height,
        width = taglist_bar_width,
        strut_offset = bar_offset
    }
    time_bar {
        screen = s,
        height = bar_height,
        geometry = geometry
    }

    info_bar {
        screen = s,
        height = bar_height,
        geometry = geometry
    }

	if s.index == SECONDARY_SCREEN then
	end
end)

awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
        capi.mouse.screen.time_bar:emit_signal("clear::popups")
    end)
})
