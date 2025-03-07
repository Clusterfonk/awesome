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

    local function bar_placement(c)
        awful.placement.top_left(c, {
            margins = { top = geo.top, left = geo.side },
        })
    end

    local time_bar = awful.popup {
        screen = s,
        ontop = true,
        border_width = bt.bars.border_width,
        border_color = bt.bars.border_color,
        minimum_height = args.height,
        maximum_height = args.height,
        bg = bt.bg_normal,
        widget = wibox.widget.base.empty_widget(),
        placement = bar_placement
    }

    local function attach_to_bar(popup)
        awful.placement.next_to(popup, {
            preferred_positions = "bottom",
            preferred_anchor = "front",
            offset = { x = 0, y = bt.useless_gap * 2 },
            attach = true,
            geometry = time_bar,
        })
    end

    local clock_widget = clock {
        screen = s,
        format = " %d %b %H:%M ", -- spaces prevent colors bugging out
        font = bt.clock.font,
        attach = attach_to_bar
    }

    time_bar:setup {
        layout = wibox.layout.fixed.horizontal,
        clock_widget,
    }

    local function hide_popups_on_lbutton(_, _, _, button)
        if button == 1 then
            --clock_widget.popup:emit_signal("popup::hide")
        end
    end

    time_bar:connect_signal("clear::popups", function()
        --clock_widget.popup:emit_signal("popup::hide")
    end)

    -- screens
    s:connect_signal("property::geometry", function(_)
        bar_placement(time_bar)
    end)

    s:connect_signal("fullscreen_changed", function(_, has_fullscreen)
        if time_bar then
            time_bar.visible = not has_fullscreen
        end
    end)
    capi.client.connect_signal("button::press", hide_popups_on_lbutton)
    s:connect_signal("removed", function(screen)
        capi.client.disconnect_signal("button::press", hide_popups_on_lbutton)
        time_bar.visible = false
        clock_widget.visible = false
        clock_widget:emit_signal("bar::removed")
        clock_widget = nil
        time_bar = nil
        -- TODO: might need to emit signals to let popups know ?
    end)

    local _debug = require("_debug")
    if _debug.gc_finalize then
        _debug.attach_finalizer(time_bar, "time_bar")
        _debug.attach_finalizer(clock_widget, "clock_widget")
    end
    return time_bar
end
