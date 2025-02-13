-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi

local taglist_bar = require(... .. ".bars.taglist")
local info_bar = require(... .. ".bars.info")


local SECONDARY_SCREEN <const> = 2

awful.screen.connect_for_each_screen(function(s)
    local taglist_bar_width = dpi(350, s)
    local bar_height = dpi(24, s)
	local bar_offset = dpi(5, s)

	taglist_bar {
        screen = s,
        height = bar_height,
        width = taglist_bar_width,
        strut_offset = bar_offset
    }

    info_bar {
        screen = s,
        height = bar_height,
        strut_offset = bar_offset
    }

	if s.index == SECONDARY_SCREEN then
	end

end)

awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
        mouse.screen.info_bar:emit_signal("clear::popups")
    end)
})
