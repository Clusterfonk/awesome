-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
require("awful.autofocus")

local taglist_bar = require(... .. ".widgets.taglist_bar")
local right_bar = require(... .. ".widgets.right_bar")
-- local calendar = require(... .. ".widgets.calendar")

local RIGHT_BAR_SCREEN <const> = 2

awful.screen.connect_for_each_screen(function(s)
    local taglist_bar_width = dpi(350, s)
    local bar_height = dpi(24, s)
	local bar_offset = dpi(5, s)
    
	taglist_bar(s, taglist_bar_width, bar_height, bar_offset)
	
	-- calendar(s)
	if s.index == 1 then
		local right_bar_width = dpi(250, s)
		right_bar(s, right_bar_width, bar_height, bar_offset)
	end

	--info_panel(s) -> mem, temp, space, and such
	-- sound panel ?
	--notification_panel(s)
end)
