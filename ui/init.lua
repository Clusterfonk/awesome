-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi

local taglist_bar = require(... .. ".bars.taglist")
local info_bar = require(... .. ".bars.info")

local SECONDARY_SCREEN <const> = 2

test = {}

awful.screen.connect_for_each_screen(function(s)
    local taglist_bar_width = dpi(350, s)
    local bar_height = dpi(24, s)
	local bar_offset = dpi(5, s)

    --TODO: probably want them to build like all the widgets new()
	taglist_bar(s, taglist_bar_width, bar_height, bar_offset)

    info_bar(s, bar_height, bar_offset) -- returns only a function

	if s.index == SECONDARY_SCREEN then
	end

--    awful.mouse.append_global_mousebindings({
--        awful.button({}, 1, function()
--            print("click on screen: " .. awful.screen.index)
--            -- clear popups/widgets that should be closed when clicking anywhere
--        end)
--    })
end)

