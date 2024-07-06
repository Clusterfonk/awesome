-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>

local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local clock = require ("ui.widgets.clock")

return function(s, width, height, strut_offset)
    local clock_widget = clock {
        format = "%H:%M",
        font = bt.font_bold,
    }

    s.info_bar = awful.popup {
        screen = s,
        ontop = true,
        maximum_width = width,
        maximum_height = height,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        bg = bt.colors.background,

        widget = {
            layout = wibox.layout.align.horizontal,
            expand = "outside",
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(10, s),
                forced_height = height,
                clock_widget
            }
        }
    }
    awful.placement.align(s.info_bar,
        {
            position = "top_left",
            margins = {top = strut_offset, left = dpi(bt.useless_gap, s) * 2}
        })
    s.info_bar:struts{
        top = height + 2*dpi(bt.taglist_border_width, s) + strut_offset
    }
end
