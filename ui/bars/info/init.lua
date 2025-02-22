-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local audio = require("ui.widgets.audio")
local microphone = require("ui.widgets.microphone")
local network = require("ui.widgets.network")
local sync = require("ui.widgets.sync")
local notify = require("ui.widgets.notify")
local tray = require("ui.widgets.tray")


return function(args)
    local s = args.screen
    local geo = args.geometry

    local function placement(widget)
        return awful.placement.top_right(widget,
            {
                margins = {top = geo.bottom + 2 * bt.useless_gap, right = geo.side}
            })
    end

    local audio_w = audio {
        screen = s,
        height = args.height,
        margins = {left = bt.useless_gap},
        --color = bt.colors.aqua_1,
        placement = placement
    }
    local microphone_w = microphone {
        screen = s,
        height = args.height,
        placement = placement,
    }
    local network_w = network {
        height = args.height
    }
    local sync_w = sync {
        height = args.height
    }
    local notify_w = notify {
        screen = s,
        height = args.height,
        placement = placement,
    }
    local systray_w = tray {
        screen = s,
        height = args.height,
        margins = {right = bt.useless_gap},
        placement = placement
    }

    local info_bar = awful.popup {
        screen = s,
        ontop = true,
        border_width = dpi(bt.taglist_border_width, s),
        border_color = bt.taglist_border_color,
        minimum_height = args.height,
        maximum_height = args.height,
        bg = bt.bg_normal,
        widget = {
            layout = wibox.layout.fixed.horizontal,
            spacing = 2 * bt.useless_gap,
            audio_w,
            microphone_w,
            network_w,
            sync_w,
            notify_w,
            systray_w
        },
        placement = function(c)
            awful.placement.top_right(c, {margins = { top = geo.top, right = geo.side}})
        end,
    }

    client.connect_signal("property::fullscreen", function(client)
        if s ~= client.screen then
            return
        end

        has_fullscreen_clients = false
        for _, c in pairs(s.clients) do
            has_fullscreen_clients = has_fullscreen_clients or c.fullscreen
        end
        info_bar.visible = not has_fullscreen_clients
    end)

    info_bar:connect_signal("clear::popups", function()
        --audio_w:emit_signal("popup::hide")
        --microphone_w:emit_signal("popup::hide")
        --network_w:emit_signal("popup::hide")
        --sync_w:emit_signal("popup::hide")
        --notification_w:emit_signal("popup::hide")
        --systray_w:emit_signal("popup::hide")
    end)

    client.connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            --audio_w:emit_signal("popup::hide")
            --microphone_w:emit_signal("popup::hide")
            --network_w:emit_signal("popup::hide")
            --sync_w:emit_signal("popup::hide")
            --notification_w:emit_signal("popup::hide")
            --systray_w:emit_signal("popup::hide")
        end
    end)

    return info_bar
end
