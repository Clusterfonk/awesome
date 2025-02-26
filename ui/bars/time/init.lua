-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local clock = require("ui.widgets.clock")

local capi = {
    client = client
}


return function(args)
    local s = args.screen
    local geo = args.geometry

    local function popup_placement(d)
        awful.placement.top_left(d,
            {
                margins = {top = geo.bottom + 2 * bt.useless_gap, left = geo.side},
                parent = s,
            })
    end

    local clock_widget = clock {
        screen = s,
        format = " %d %b %H:%M ", -- spaces prevent colors bugging out
        font = bt.clock.font,
        placement = popup_placement
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
        placement = function(c)
            awful.placement.top_left(c, { margins = {top = geo.top, left = geo.side}})
        end,
    }

    local function hide_popups_on_lbutton(_, _, _, button)
        if button == 1 then
            --clock_widget.popup:emit_signal("popup::hide")
        end
    end

    s:connect_signal("property::geometry", function(screen)
        awful.placement.top_left(time_bar, {
            margins = {top = geo.top, left = geo.side},
            parent = screen
        })
    end)

    s:connect_signal("fullscreen_changed", function(_, has_fullscreen)
        if time_bar then
            time_bar.visible = not has_fullscreen
        end
    end)

    time_bar:connect_signal("clear::popups", function()
        --clock_widget.popup:emit_signal("popup::hide")
    end)

    capi.client.connect_signal("button::press", hide_popups_on_lbutton)

    s:connect_signal("removed", function(screen)
        capi.client.disconnect_signal("button::press", hide_popups_on_lbutton)
        time_bar.visible = false
        clock_widget.visible = false
        time_bar = nil
        clock_widget = nil
        -- TODO: might need to emit signals to let popups know ?
    end)

    if DEBUG then
        local debug =require("util.debug")
        debug.attach_finalizer(time_bar, "time_bar")
        debug.attach_finalizer(clock_widget, "clock_widget")
    end
    return time_bar
end

