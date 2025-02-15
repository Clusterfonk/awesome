-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local clock = require("ui.widgets.clock")

return function(args)
    local s = args.screen

    local geometry = {top = args.strut_offset, left = dpi(bt.useless_gap,s) * 2}
    geometry.bottom = geometry.top + args.height + 2 * dpi(bt.taglist_border_width, s)

    local clock_widget = clock {
        screen = s,
        format = " %d %b %H:%M ", -- spaces prevent colors bugging out
        font = bt.clock.font,
        -- popup location
        top = geometry.bottom + 2 * bt.useless_gap,
        left = geometry.left
    }

    s.time_bar = awful.popup {
        screen = s,
        ontop = true,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        minimum_height = args.height,
        maximum_height = args.height,
        bg = bt.colors.background,
        widget = {
            layout = wibox.layout.fixed.horizontal,
            clock_widget,
        }
    }

    awful.placement.align(s.time_bar,
        {
            position = "top_left",
            margins = { top = geometry.top, left = geometry.left }
        })

    client.connect_signal("property::fullscreen", function(client)
        if s ~= client.screen then
            return
        end

        has_fullscreen_clients = false
        for _, c in pairs(s.clients) do
            has_fullscreen_clients = has_fullscreen_clients or c.fullscreen
        end
        s.time_bar.visible = not has_fullscreen_clients
    end)

    s.time_bar:connect_signal("clear::popups", function()
        clock_widget.popup:emit_signal("popup::hide")
    end)

    client.connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            clock_widget.popup:emit_signal("popup::hide")
        end
    end)
end
