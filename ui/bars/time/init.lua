-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local clock = require("ui.widgets.clock")


return function(args)
    local s = args.screen
    local geo = args.geometry


    local function placement(widget)
        return awful.placement.top_left(widget,
            {
                margins = {top = geo.bottom + 2 * bt.useless_gap, left = geo.side}
            })
    end

    clock_widget = clock {
        screen = s,
        format = " %d %b %H:%M ", -- spaces prevent colors bugging out
        font = bt.clock.font,
        placement = placement
    }

    local time_bar = awful.popup {
        screen = s,
        ontop = true,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        minimum_height = args.height,
        maximum_height = args.height,
        bg = bt.bg_normal,
        widget = {
            layout = wibox.layout.fixed.horizontal,
            clock_widget,
        },
        placement = function(widget)
            return awful.placement.top_left(widget,
                {
                    margins = { top = geo.top, left = geo.side}
                })
        end
    }

    client.connect_signal("property::fullscreen", function(client)
        if s ~= client.screen then
            return
        end

        has_fullscreen_clients = false
        for _, c in pairs(s.clients) do
            has_fullscreen_clients = has_fullscreen_clients or c.fullscreen
        end
        time_bar.visible = not has_fullscreen_clients
    end)

    time_bar:connect_signal("clear::popups", function()
        clock_widget.popup:emit_signal("popup::hide")
    end)

    client.connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            clock_widget.popup:emit_signal("popup::hide")
        end
    end)

    return time_bar
end

