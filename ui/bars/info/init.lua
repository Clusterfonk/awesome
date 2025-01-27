-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local clock = require("ui.widgets.clock")


return function(s, height, strut_offset)
    local geometry = {top = strut_offset, left = dpi(bt.useless_gap,s) * 2}
    geometry.bottom = geometry.top + height + 2 * dpi(bt.taglist_border_width, s)

    local clock_widget = clock {
        screen = s,
        format = " %H:%M ",
        font = bt.font_bold,
        top = geometry.bottom + 2 * bt.useless_gap,
        left = geometry.left
    }

    s.info_bar = awful.popup {
        screen = s,
        ontop = true,
        height = height,
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
                clock_widget,
            }
        }
    }

    awful.placement.align(s.info_bar,
        {
            position = "top_left",
            margins = { top = geometry.top, left = geometry.left }
        })
   -- TODO: might be useless yeet it
   -- s.info_bar:struts {
   --     top = geometry.bottom
   -- }

    client.connect_signal("focus", function(client)
        if client.fullscreen then
            s.info_bar.visible = false
        end
    end)

    client.connect_signal("property::fullscreen", function(client)
        if client.fullscreen then
            s.info_bar.visible = false
        else
            any_fullscreen = false
            for _, c in pairs(s.clients) do
                any_fullscreen = any_fullscreen or c.fullscreen
            end
            s.info_bar.visible = not any_fullscreen
        end
    end)
end
