-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
require("awful.autofocus")

local taglist_bar = require(... .. ".bars.taglist")
local info_bar = require(... .. ".bars.info")

local SECONDARY_SCREEN <const> = 2

awful.screen.connect_for_each_screen(function(s)
    local taglist_bar_width = dpi(350, s)
    local bar_height = dpi(24, s)
	local bar_offset = dpi(5, s)
    
	taglist_bar(s, taglist_bar_width, bar_height, bar_offset)
	
	if s.index == SECONDARY_SCREEN then
        local info_bar_width = dpi(250, s)
        info_bar(s, info_bar_width, bar_height, bar_offset)
	end
end)
